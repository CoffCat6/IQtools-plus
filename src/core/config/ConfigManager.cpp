// src/core/config/ConfigManager.cpp
#include "core/config/ConfigManager.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"

// ── JSON 序列化辅助函数 ────────────────────────────────────────────────────

static QJsonObject screenshotToJson(const ScreenshotConfig& c) {
    return {
        {QStringLiteral("savePath"),      c.savePath},
        {QStringLiteral("defaultFormat"), c.defaultFormat},
        {QStringLiteral("jpegQuality"),   c.jpegQuality},
        {QStringLiteral("showCursor"),    c.showCursor},
        {QStringLiteral("delaySeconds"),  c.delaySeconds},
        {QStringLiteral("hotkey"),        c.hotkey},
    };
}

static ScreenshotConfig screenshotFromJson(const QJsonObject& obj) {
    ScreenshotConfig c;
    c.savePath      = obj[QStringLiteral("savePath")].toString(c.savePath);
    c.defaultFormat = obj[QStringLiteral("defaultFormat")].toString(c.defaultFormat);
    c.jpegQuality   = obj[QStringLiteral("jpegQuality")].toInt(c.jpegQuality);
    c.showCursor    = obj[QStringLiteral("showCursor")].toBool(c.showCursor);
    c.delaySeconds  = obj[QStringLiteral("delaySeconds")].toInt(c.delaySeconds);
    c.hotkey        = obj[QStringLiteral("hotkey")].toString(c.hotkey);
    return c;
}

static QJsonObject translateToJson(const TranslateConfig& c) {
    return {
        {QStringLiteral("defaultEngine"),   c.defaultEngine},
        {QStringLiteral("defaultFromLang"), c.defaultFromLang},
        {QStringLiteral("defaultToLang"),   c.defaultToLang},
        {QStringLiteral("cacheMaxSize"),    c.cacheMaxSize},
        {QStringLiteral("enableCache"),     c.enableCache},
        {QStringLiteral("youdaoAppId"),     c.youdaoAppId},
        {QStringLiteral("youdaoAppSecret"), c.youdaoAppSecret},
        {QStringLiteral("deeplApiKey"),     c.deeplApiKey},
        {QStringLiteral("deeplFreeApi"),    c.deeplFreeApi},
    };
}

static TranslateConfig translateFromJson(const QJsonObject& obj) {
    TranslateConfig c;
    c.defaultEngine   = obj[QStringLiteral("defaultEngine")].toString(c.defaultEngine);
    c.defaultFromLang = obj[QStringLiteral("defaultFromLang")].toString(c.defaultFromLang);
    c.defaultToLang   = obj[QStringLiteral("defaultToLang")].toString(c.defaultToLang);
    c.cacheMaxSize    = obj[QStringLiteral("cacheMaxSize")].toInt(c.cacheMaxSize);
    c.enableCache     = obj[QStringLiteral("enableCache")].toBool(c.enableCache);
    c.youdaoAppId     = obj[QStringLiteral("youdaoAppId")].toString();
    c.youdaoAppSecret = obj[QStringLiteral("youdaoAppSecret")].toString();
    c.deeplApiKey     = obj[QStringLiteral("deeplApiKey")].toString();
    c.deeplFreeApi    = obj[QStringLiteral("deeplFreeApi")].toBool(c.deeplFreeApi);
    return c;
}

static QJsonObject clipboardToJson(const ClipboardConfig& c) {
    return {
        {QStringLiteral("maxHistorySize"),   c.maxHistorySize},
        {QStringLiteral("persistHistory"),   c.persistHistory},
        {QStringLiteral("monitorImages"),    c.monitorImages},
        {QStringLiteral("imageSizeLimitKB"), c.imageSizeLimitKB},
    };
}

static ClipboardConfig clipboardFromJson(const QJsonObject& obj) {
    ClipboardConfig c;
    c.maxHistorySize   = obj[QStringLiteral("maxHistorySize")].toInt(c.maxHistorySize);
    c.persistHistory   = obj[QStringLiteral("persistHistory")].toBool(c.persistHistory);
    c.monitorImages    = obj[QStringLiteral("monitorImages")].toBool(c.monitorImages);
    c.imageSizeLimitKB = obj[QStringLiteral("imageSizeLimitKB")].toInt(c.imageSizeLimitKB);
    return c;
}

static QJsonObject appearanceToJson(const AppearanceConfig& c) {
    return {
        {QStringLiteral("theme"),             c.theme},
        {QStringLiteral("language"),          c.language},
        {QStringLiteral("followSystemTheme"), c.followSystemTheme},
        {QStringLiteral("darkMode"),          c.darkMode},
    };
}

static AppearanceConfig appearanceFromJson(const QJsonObject& obj) {
    AppearanceConfig c;
    c.theme             = obj[QStringLiteral("theme")].toString(c.theme);
    c.language          = obj[QStringLiteral("language")].toString(c.language);
    c.followSystemTheme = obj[QStringLiteral("followSystemTheme")].toBool(c.followSystemTheme);
    c.darkMode          = obj[QStringLiteral("darkMode")].toBool(c.darkMode);
    return c;
}

// ── ConfigManager 实现 ─────────────────────────────────────────────────────

ConfigManager::ConfigManager(const QString& configPath)
    : m_configPath(configPath) {
    if (m_configPath.isEmpty()) {
        m_configPath = QStandardPaths::writableLocation(
                           QStandardPaths::AppConfigLocation) +
                       QStringLiteral("/config.json");
    }
}

Result<void> ConfigManager::load() {
    std::lock_guard<std::mutex> lock(m_mutex);

    QFile file(m_configPath);
    if (!file.exists()) {
        TB_LOG_INFO(LogModule::Config,
            "Config file not found, using defaults | path='{}'",
            m_configPath.toStdString());
        return Result<void>::ok();
    }

    if (!file.open(QIODevice::ReadOnly)) {
        TB_LOG_ERROR(LogModule::Config,
            "Cannot open config file | path='{}'",
            m_configPath.toStdString());
        return Result<void>::err(
            TB_MAKE_ERROR(ErrorCode::IoError,
                "Cannot open config file: " + m_configPath.toStdString()));
    }

    QJsonParseError parseErr;
    const auto doc = QJsonDocument::fromJson(file.readAll(), &parseErr);
    if (parseErr.error != QJsonParseError::NoError) {
        TB_LOG_ERROR(LogModule::Config,
            "Config parse failed | error='{}'",
            parseErr.errorString().toStdString());
        return Result<void>::err(
            TB_MAKE_ERROR(ErrorCode::InvalidArgument,
                "Config parse error: " + parseErr.errorString().toStdString()));
    }

    const auto root = doc.object();
    if (root.contains(QStringLiteral("screenshot")))
        m_config.screenshot = screenshotFromJson(root[QStringLiteral("screenshot")].toObject());
    if (root.contains(QStringLiteral("translate")))
        m_config.translate = translateFromJson(root[QStringLiteral("translate")].toObject());
    if (root.contains(QStringLiteral("clipboard")))
        m_config.clipboard = clipboardFromJson(root[QStringLiteral("clipboard")].toObject());
    if (root.contains(QStringLiteral("appearance")))
        m_config.appearance = appearanceFromJson(root[QStringLiteral("appearance")].toObject());

    TB_LOG_INFO(LogModule::Config, "Config loaded | path='{}'",
        m_configPath.toStdString());
    return Result<void>::ok();
}

Result<void> ConfigManager::save() {
    std::lock_guard<std::mutex> lock(m_mutex);

    // 确保目录存在
    QFileInfo info(m_configPath);
    QDir().mkpath(info.absolutePath());

    QJsonObject root;
    root[QStringLiteral("screenshot")] = screenshotToJson(m_config.screenshot);
    root[QStringLiteral("translate")]  = translateToJson(m_config.translate);
    root[QStringLiteral("clipboard")]  = clipboardToJson(m_config.clipboard);
    root[QStringLiteral("appearance")] = appearanceToJson(m_config.appearance);

    QFile file(m_configPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        TB_LOG_ERROR(LogModule::Config,
            "Cannot write config file | path='{}'",
            m_configPath.toStdString());
        return Result<void>::err(
            TB_MAKE_ERROR(ErrorCode::IoError,
                "Cannot write config file: " + m_configPath.toStdString()));
    }

    file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));

    TB_LOG_INFO(LogModule::Config, "Config saved | path='{}'",
        m_configPath.toStdString());
    return Result<void>::ok();
}

void ConfigManager::setConfigPath(const QString& path) {
    std::lock_guard<std::mutex> lock(m_mutex);
    m_configPath = path;
}

QString ConfigManager::configPath() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_configPath;
}
