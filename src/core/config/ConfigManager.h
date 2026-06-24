// src/core/config/ConfigManager.h
#pragma once

#include <functional>
#include <mutex>
#include <string>
#include <type_traits>

#include <QString>

#include "core/config/ConfigSchema.h"
#include "core/error/Error.h"

/// 应用配置管理器
///
/// 线程安全的配置读写，支持 JSON 持久化。
/// 不是单例 —— 由 AppContext 持有，通过 DI 注入到需要配置的模块。
///
/// 用法：
/// @code
/// ConfigManager mgr;
/// mgr.load();                          // 从文件加载（失败则用默认值）
/// auto tc = mgr.get<TranslateConfig>();// 读取翻译配置
/// mgr.update<TranslateConfig>([](TranslateConfig& c) {
///     c.defaultEngine = "deepl";
/// });
/// mgr.save();                          // 持久化到文件
/// @endcode
class ConfigManager {
public:
    explicit ConfigManager(const QString& configPath = {});
    ~ConfigManager() = default;

    ConfigManager(const ConfigManager&) = delete;
    ConfigManager& operator=(const ConfigManager&) = delete;

    /// 从 JSON 文件加载配置。文件不存在时使用默认值，返回 true。
    [[nodiscard]] Result<void> load();

    /// 将当前配置保存到 JSON 文件。
    [[nodiscard]] Result<void> save();

    /// 获取指定模块的配置副本（线程安全）
    template <typename ConfigT>
    [[nodiscard]] ConfigT get() const {
        std::lock_guard<std::mutex> lock(m_mutex);
        if constexpr (std::is_same_v<ConfigT, ScreenshotConfig>)
            return m_config.screenshot;
        else if constexpr (std::is_same_v<ConfigT, TranslateConfig>)
            return m_config.translate;
        else if constexpr (std::is_same_v<ConfigT, ClipboardConfig>)
            return m_config.clipboard;
        else if constexpr (std::is_same_v<ConfigT, AppearanceConfig>)
            return m_config.appearance;
        else
            static_assert(sizeof(ConfigT) == 0, "Unknown config type");
    }

    /// 原子修改指定模块的配置（锁内执行 modifier）
    template <typename ConfigT>
    void update(std::function<void(ConfigT&)> modifier) {
        std::lock_guard<std::mutex> lock(m_mutex);
        if constexpr (std::is_same_v<ConfigT, ScreenshotConfig>)
            modifier(m_config.screenshot);
        else if constexpr (std::is_same_v<ConfigT, TranslateConfig>)
            modifier(m_config.translate);
        else if constexpr (std::is_same_v<ConfigT, ClipboardConfig>)
            modifier(m_config.clipboard);
        else if constexpr (std::is_same_v<ConfigT, AppearanceConfig>)
            modifier(m_config.appearance);
        else
            static_assert(sizeof(ConfigT) == 0, "Unknown config type");
    }

    /// 设置配置文件路径
    void setConfigPath(const QString& path);

    /// 获取配置文件路径
    [[nodiscard]] QString configPath() const;

private:
    mutable std::mutex m_mutex;
    AppConfig m_config;
    QString   m_configPath;
};
