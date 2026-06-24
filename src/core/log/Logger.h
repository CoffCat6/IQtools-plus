// src/core/log/Logger.h
#pragma once

#include <memory>
#include <string>
#include <string_view>
#include <cstddef>

#include <spdlog/spdlog.h>
#include <spdlog/fmt/fmt.h>

#include <QString>
#include <QStringView>
#include <functional>

// ── fmt formatter for Qt QString types ─────────────────────────────────────
// 让 spdlog 的 fmt 库可以直接格式化 QString / QStringView，
// 无需在调用处手动 .toStdString()。自动处理 UTF-16 → UTF-8 转换。
template <>
struct fmt::formatter<QString> : fmt::formatter<std::string> {
    auto format(const QString& s, fmt::format_context& ctx) const {
        return fmt::formatter<std::string>::format(s.toStdString(), ctx);
    }
};

template <>
struct fmt::formatter<QStringView> : fmt::formatter<std::string> {
    auto format(const QStringView& s, fmt::format_context& ctx) const {
        return fmt::formatter<std::string>::format(s.toString().toStdString(), ctx);
    }
};

// ── Logger 初始化配置（在 Logger 类外，解决嵌套 struct 默认参数限制）────────
struct LoggerConfig {
    std::string logDir        = "logs";
    std::string filePattern   = "iqtools_{date}.log";
    std::size_t maxFileSize   = 10 * 1024 * 1024;      // 10 MB
    std::size_t maxFiles      = 7;
    bool        consoleOutput = true;
    spdlog::level::level_enum fileLevel    = spdlog::level::debug;
    spdlog::level::level_enum consoleLevel = spdlog::level::info;
};

/**
 * @brief 全局日志系统封装
 *
 * 基于 spdlog 的统一日志接口。在 main() 中调用 Logger::init() 完成初始化，
 * 在程序退出前调用 Logger::shutdown() 确保缓冲刷新。
 *
 * 推荐通过宏 TB_LOG_xxx 使用，自动注入模块名、文件名和行号。
 *
 * @example
 * @code
 * #include "core/log/Logger.h"
 * #include "core/log/LogModules.h"
 *
 * // 初始化（main() 中最先调用）
 * Logger::init();
 *
 * // 业务日志
 * TB_LOG_INFO (LogModule::Translate, "Engine='{}' started", engineId);
 * TB_LOG_WARN (LogModule::Network,   "Retry {}/{}", attempt, maxRetry);
 * TB_LOG_ERROR(LogModule::App,       "Config load failed: {}", path);
 * @endcode
 */
class Logger {
public:
    // 保留旧名称作为别名，方便迁移
    using Config = LoggerConfig;

    /**
     * @brief 初始化日志系统（main() 中调用一次）
     *
     * 创建控制台彩色输出 + 按大小滚动的文件日志（文件名含日期）。
     * 重复调用为 no-op。
     */
    static void init(const LoggerConfig& config = {});

    /**
     * @brief 关闭日志系统，刷新所有缓冲
     *
     * 应在 QGuiApplication 析构前调用，确保最后的日志写入磁盘。
     */
    static void shutdown();

    /**
     * @brief 获取指定模块的 logger（懒创建，线程安全）
     *
     * 所有模块 logger 共享相同的 sink（控制台 + 文件），
     * 仅 logger 名称（模块名）不同，便于按模块过滤日志。
     *
     * @param module  模块名，使用 LogModules.h 中的 LogModule 常量
     */
    [[nodiscard]] static std::shared_ptr<spdlog::logger>
    get(std::string_view module);

    /**
     * @brief 获取全局默认 logger（模块名 "app"）
     */
    [[nodiscard]] static std::shared_ptr<spdlog::logger> global();

    /**
     * @brief 获取解析后的绝对日志目录路径
     */
    [[nodiscard]] static std::string logDir();

    /**
     * @brief 动态调整控制台日志级别（运行时生效）
     */
    static void setConsoleLevel(spdlog::level::level_enum level);

    /**
     * @brief 动态调整文件日志级别（运行时生效）
     */
    static void setFileLevel(spdlog::level::level_enum level);

    /**
     * @brief 注册回调 sink，将日志转发到外部目标（如 QML UI）
     *
     * 回调在 spdlog 线程中执行，调用方需自行处理线程安全（如 QMetaObject::invokeMethod）。
     * 可在 init() 之后随时调用；返回的 sink 可用于后续移除。
     */
    using LogCallback = std::function<void(const std::string& formattedMsg, int level)>;
    static std::shared_ptr<spdlog::sinks::sink> addCallbackSink(LogCallback callback);

    /// 移除之前注册的回调 sink，从所有模块 logger 和全局 sink 列表中摘除。
    /// 用于 ViewModel 析构时安全释放回调引用，避免悬空指针。
    static void removeCallbackSink(std::shared_ptr<spdlog::sinks::sink> sink);

private:
    Logger() = delete;
};

// ── MSVC 兼容：__FILE_NAME__ 仅 GCC/Clang 支持 ───────────────────────────
#if defined(__FILE_NAME__)
#   define IQTOOLS_FILE_NAME __FILE_NAME__
#else
// MSVC 下 __FILE__ 含完整路径，用 lambda 运行期截取文件名部分
#   define IQTOOLS_FILE_NAME \
        ([]() -> const char* { \
            const char* f = __FILE__; \
            const char* s = f; \
            for (; *f; ++f) { if (*f == '/' || *f == '\\') s = f + 1; } \
            return s; \
        }())
#endif

// ── 日志宏 ────────────────────────────────────────────────────────────────
//
// 用法：TB_LOG_INFO(LogModule::Translate, "text='{}' len={}", text, len)
//
// 所有级别统一带 source_loc（文件名+行号+函数名），
// 定位信息在文件日志（JSON）中可见，控制台不显示源位置（保持简洁）。

#define IQTOOLS_LOG_WITH_LOC(logger_ptr, level, ...) \
    (logger_ptr)->log( \
        spdlog::source_loc{IQTOOLS_FILE_NAME, __LINE__, __func__}, \
        (level), __VA_ARGS__)

#define TB_LOG_TRACE(module, ...) \
    IQTOOLS_LOG_WITH_LOC(Logger::get(module), spdlog::level::trace, __VA_ARGS__)

#define TB_LOG_DEBUG(module, ...) \
    IQTOOLS_LOG_WITH_LOC(Logger::get(module), spdlog::level::debug, __VA_ARGS__)

#define TB_LOG_INFO(module, ...) \
    IQTOOLS_LOG_WITH_LOC(Logger::get(module), spdlog::level::info, __VA_ARGS__)

#define TB_LOG_WARN(module, ...) \
    IQTOOLS_LOG_WITH_LOC(Logger::get(module), spdlog::level::warn, __VA_ARGS__)

#define TB_LOG_ERROR(module, ...) \
    IQTOOLS_LOG_WITH_LOC(Logger::get(module), spdlog::level::err, __VA_ARGS__)

#define TB_LOG_CRITICAL(module, ...) \
    IQTOOLS_LOG_WITH_LOC(Logger::get(module), spdlog::level::critical, __VA_ARGS__)
