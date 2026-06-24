// src/core/config/ConfigSchema.h
#pragma once

#include <QString>

/// 截图模块配置
struct ScreenshotConfig {
    QString savePath        = QStringLiteral("~/Pictures/IQtools");
    QString defaultFormat   = QStringLiteral("png");
    int     jpegQuality     = 90;
    bool    showCursor      = false;
    int     delaySeconds    = 3;
    QString hotkey          = QStringLiteral("Ctrl+Shift+A");
};

/// 翻译模块配置
struct TranslateConfig {
    QString defaultEngine   = QStringLiteral("mock-local");
    QString defaultFromLang = QStringLiteral("auto");
    QString defaultToLang   = QStringLiteral("zh-CN");
    int     cacheMaxSize    = 1000;
    bool    enableCache     = true;
    // 引擎 API 密钥（默认为空）
    QString youdaoAppId;
    QString youdaoAppSecret;
    QString deeplApiKey;
    bool    deeplFreeApi    = true;
};

/// 剪贴板模块配置
struct ClipboardConfig {
    int  maxHistorySize     = 500;
    bool persistHistory     = true;
    bool monitorImages      = true;
    int  imageSizeLimitKB   = 5120;
};

/// 外观配置
struct AppearanceConfig {
    QString theme           = QStringLiteral("auto");  // "light"/"dark"/"auto"
    QString language        = QStringLiteral("zh_CN");
    bool    followSystemTheme = false;
    bool    darkMode        = false;
};

/// 应用全局配置（聚合所有模块配置）
struct AppConfig {
    ScreenshotConfig screenshot;
    TranslateConfig  translate;
    ClipboardConfig  clipboard;
    AppearanceConfig appearance;
};
