// src/core/log/Logger.cpp
#include "core/log/Logger.h"
#include "core/log/JsonFormatter.h"
#include "core/log/LogSink.h"

#include <spdlog/sinks/rotating_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>

#include <QCoreApplication>
#include <QStandardPaths>

#include <filesystem>
#include <mutex>
#include <unordered_map>
#include <vector>
#include <chrono>
#include <ctime>
#include <sstream>
#include <iomanip>
#include <cstdio>

// ── 文件内部实现 ─────────────────────────────────────────────────────────────

namespace {

// 所有模块 logger 共享的 sink 列表（console + file + callback sinks）
std::vector<spdlog::sink_ptr> g_sinks;

// 命名指针：避免用数组索引假设 sink 顺序
spdlog::sink_ptr g_consoleSink;
spdlog::sink_ptr g_fileSink;

// 模块 logger 缓存（懒初始化）
std::mutex g_loggersMutex;
std::unordered_map<std::string, std::shared_ptr<spdlog::logger>> g_loggers;

// 全局默认 logger（模块 "app"）
std::shared_ptr<spdlog::logger> g_globalLogger;

bool g_initialized = false;

// 解析后的绝对日志目录（init 后通过 Logger::logDir() 访问）
std::string g_resolvedLogDir;

/**
 * @brief 将 filePattern 中的 "{date}" 替换为当前本地日期 YYYYMMDD
 */
std::string resolveDatePattern(const std::string& pattern) {
    auto now   = std::chrono::system_clock::now();
    auto t     = std::chrono::system_clock::to_time_t(now);
    std::tm tm_buf{};
#if defined(_WIN32)
    localtime_s(&tm_buf, &t);
#else
    localtime_r(&t, &tm_buf);
#endif
    std::ostringstream oss;
    oss << std::put_time(&tm_buf, "%Y%m%d");

    std::string result = pattern;
    const std::string kPlaceholder = "{date}";
    if (auto pos = result.find(kPlaceholder); pos != std::string::npos)
        result.replace(pos, kPlaceholder.size(), oss.str());
    return result;
}

/**
 * @brief 挂载所有共享 sink，创建并注册一个模块 logger
 */
std::shared_ptr<spdlog::logger> makeModuleLogger(const std::string& name) {
    auto logger = std::make_shared<spdlog::logger>(name, g_sinks.begin(), g_sinks.end());
    // 让 logger 接收所有级别，过滤由各 sink 自身完成
    logger->set_level(spdlog::level::trace);
    // WARN 及以上立即刷盘，避免崩溃时丢失错误日志
    logger->flush_on(spdlog::level::warn);
    spdlog::register_logger(logger);
    return logger;
}

}  // namespace

// ── Logger 公开接口实现 ───────────────────────────────────────────────────────

void Logger::init(const LoggerConfig& config) {
    std::lock_guard<std::mutex> lock(g_loggersMutex);
    if (g_initialized) return;

    try {
        // ── 解析日志目录为绝对路径 ─────────────────────────────────────────
        std::string logDir = config.logDir;
        {
            std::filesystem::path p(logDir);
            if (p.is_relative()) {
                // Logger::init() 在 QGuiApplication 之前调用，
                // 此时 applicationDirPath() 不可用，直接用 CWD 解析绝对路径。
                // QGuiApplication 创建后，应用层可在需要时重新调用 init() 或
                // 手动调整日志路径。
                p = std::filesystem::absolute(p);
                logDir = p.string();
            }
            // 确保目录存在
            std::filesystem::create_directories(p);
        }
        // 保存解析后的绝对路径供外部查询
        g_resolvedLogDir = logDir;

        // ── 控制台 sink（彩色，MT 安全）───────────────────────────────────
        if (config.consoleOutput) {
            g_consoleSink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
            g_consoleSink->set_level(config.consoleLevel);
            // 格式：[HH:MM:SS.mmm] [LEVEL] [module] message（控制台不显示源位置）
            g_consoleSink->set_pattern("[%H:%M:%S.%e] [%^%l%$] [%n] %v");
            g_sinks.push_back(g_consoleSink);
        }

        // ── 滚动文件 sink（MT 安全）───────────────────────────────────────
        {
            const std::string filename =
                logDir + "/" + resolveDatePattern(config.filePattern);
            g_fileSink = std::make_shared<spdlog::sinks::rotating_file_sink_mt>(
                filename,
                config.maxFileSize,
                config.maxFiles,
                /*rotate_on_open=*/false);
            g_fileSink->set_level(config.fileLevel);
            // 文件格式：自定义 JSON Lines formatter，保证输出合法 JSON
            g_fileSink->set_formatter(std::make_unique<iqtools::JsonLineFormatter>());
            g_sinks.push_back(g_fileSink);
        }

        // ── 创建全局（app）logger ──────────────────────────────────────────
        g_globalLogger = makeModuleLogger("app");
        spdlog::set_default_logger(g_globalLogger);

        g_initialized = true;

        g_globalLogger->log(
            spdlog::source_loc{"Logger.cpp", __LINE__, __func__},
            spdlog::level::info,
            "Logger initialized | logDir='{}' maxFiles={} maxFileSize={}MB consoleLevel={} fileLevel={}",
            logDir,
            config.maxFiles,
            config.maxFileSize / (1024 * 1024),
            spdlog::level::to_string_view(config.consoleLevel),
            spdlog::level::to_string_view(config.fileLevel));

    } catch (const spdlog::spdlog_ex& ex) {
        std::fprintf(stderr, "[Logger::init] FAILED: %s\n", ex.what());
    }
}

void Logger::shutdown() {
    {
        std::lock_guard<std::mutex> lock(g_loggersMutex);
        if (!g_initialized) return;
        if (g_globalLogger) {
            g_globalLogger->log(
                spdlog::source_loc{"Logger.cpp", __LINE__, __func__},
                spdlog::level::info,
                "Logger shutting down - flushing all sinks.");
            g_globalLogger->flush();
        }
    }

    spdlog::shutdown();  // 刷新并销毁所有已注册 logger

    std::lock_guard<std::mutex> lock(g_loggersMutex);
    g_loggers.clear();
    g_sinks.clear();
    g_consoleSink.reset();
    g_fileSink.reset();
    g_globalLogger.reset();
    g_initialized = false;
}

std::shared_ptr<spdlog::logger> Logger::get(std::string_view module) {
    // 未初始化时：尝试注册表查找，找不到就返回默认 logger
    if (!g_initialized) {
        if (auto existing = spdlog::get(std::string(module)))
            return existing;
        return spdlog::default_logger();
    }

    const std::string name(module);

    // 快速路径：本地缓存命中（读多写少，先无锁尝试）
    {
        std::lock_guard<std::mutex> lock(g_loggersMutex);
        if (auto it = g_loggers.find(name); it != g_loggers.end())
            return it->second;
    }

    // spdlog 全局注册表（跨翻译单元的 logger 复用）
    if (auto existing = spdlog::get(name)) {
        std::lock_guard<std::mutex> lock(g_loggersMutex);
        g_loggers[name] = existing;
        return existing;
    }

    // 懒创建（加锁，双重检查）
    std::lock_guard<std::mutex> lock(g_loggersMutex);
    if (auto it = g_loggers.find(name); it != g_loggers.end())
        return it->second;

    auto logger = makeModuleLogger(name);
    g_loggers[name] = logger;
    return logger;
}

std::shared_ptr<spdlog::logger> Logger::global() {
    if (g_globalLogger) return g_globalLogger;
    return spdlog::default_logger();
}

std::string Logger::logDir() {
    std::lock_guard<std::mutex> lock(g_loggersMutex);
    return g_resolvedLogDir;
}

void Logger::setConsoleLevel(spdlog::level::level_enum level) {
    std::lock_guard<std::mutex> lock(g_loggersMutex);
    if (g_consoleSink) {
        g_consoleSink->set_level(level);
    }
}

void Logger::setFileLevel(spdlog::level::level_enum level) {
    std::lock_guard<std::mutex> lock(g_loggersMutex);
    if (g_fileSink) {
        g_fileSink->set_level(level);
    }
}

std::shared_ptr<spdlog::sinks::sink> Logger::addCallbackSink(LogCallback callback) {
    std::lock_guard<std::mutex> lock(g_loggersMutex);

    // 创建回调 sink，使用与控制台相同的简洁格式
    auto cbSink = std::make_shared<CallbackLogSink>(
        [cb = std::move(callback)](const std::string& msg, int level) {
            if (cb) cb(msg, level);
        });
    cbSink->set_pattern("[%H:%M:%S.%e] [%^%l%$] [%n] %v");
    // 接收所有级别的日志，由各模块 logger 的 level 控制
    cbSink->set_level(spdlog::level::trace);

    // 注册到所有已存在的模块 logger
    for (auto& [name, logger] : g_loggers) {
        logger->sinks().push_back(cbSink);
    }
    // 全局 logger 也要加
    if (g_globalLogger) {
        g_globalLogger->sinks().push_back(cbSink);
    }

    // 同时加入 g_sinks，后续新建的模块 logger 也会自动获得此 sink
    g_sinks.push_back(cbSink);

    return cbSink;
}

void Logger::removeCallbackSink(std::shared_ptr<spdlog::sinks::sink> sink) {
    if (!sink) return;

    std::lock_guard<std::mutex> lock(g_loggersMutex);

    // 从 g_sinks 中移除
    std::erase(g_sinks, sink);

    // 从所有模块 logger 的 sink 列表中移除
    for (auto& [name, logger] : g_loggers) {
        auto& sinks = logger->sinks();
        std::erase(sinks, sink);
    }

    // 从全局 logger 中移除
    if (g_globalLogger) {
        auto& sinks = g_globalLogger->sinks();
        std::erase(sinks, sink);
    }
}
