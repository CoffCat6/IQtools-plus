// src/viewmodels/SettingViewModel.cpp
#include "viewmodels/SettingViewModel.h"

#include "core/config/ConfigManager.h"
#include "core/config/ConfigSchema.h"
#include "core/log/Logger.h"
#include "core/log/LogModules.h"

SettingViewModel::SettingViewModel(QObject* parent)
    : QObject(parent) {
}

SettingViewModel::~SettingViewModel() = default;

void SettingViewModel::setConfigManager(std::shared_ptr<ConfigManager> mgr) {
    m_configManager = std::move(mgr);
}

void SettingViewModel::injectTranslateService(ITranslateService::Ptr service) {
    m_translateService = std::move(service);
    refreshAvailableEngines();
}

int SettingViewModel::themeMode() const noexcept {
    return m_themeMode;
}

bool SettingViewModel::followSystemTheme() const noexcept {
    return m_followSystemTheme;
}

bool SettingViewModel::darkMode() const noexcept {
    return m_darkMode;
}

QString SettingViewModel::language() const noexcept {
    return m_language;
}

QString SettingViewModel::translateEngine() const noexcept {
    return m_translateEngine;
}

QStringList SettingViewModel::availableEngines() const {
    return m_availableEngines;
}

void SettingViewModel::setThemeMode(int mode) {
    if (mode < 0 || mode > 2) {
        TB_LOG_WARN(LogModule::Config, "Invalid themeMode={}", mode);
        return;
    }
    if (m_themeMode == mode) return;

    m_themeMode = mode;
    if (m_themeMode == 2) {
        m_followSystemTheme = true;
    } else {
        m_followSystemTheme = false;
        m_darkMode = (m_themeMode == 1);
    }

    emit themeModeChanged();
    emit followSystemThemeChanged();
    emit darkModeChanged();
    save();
}

void SettingViewModel::setFollowSystemTheme(bool value) {
    if (m_followSystemTheme == value) return;

    m_followSystemTheme = value;
    syncThemeModeFromFlags();
    emit followSystemThemeChanged();
    emit themeModeChanged();
    save();
}

void SettingViewModel::setDarkMode(bool value) {
    if (m_darkMode == value) return;

    m_darkMode = value;
    if (m_followSystemTheme) {
        // 手动切换深浅色时，退出跟随系统模式
        m_followSystemTheme = false;
        emit followSystemThemeChanged();
    }
    syncThemeModeFromFlags();
    emit darkModeChanged();
    emit themeModeChanged();
    save();
}

void SettingViewModel::setLanguage(const QString& value) {
    if (m_language == value) return;
    m_language = value;
    emit languageChanged();
    save();
}

void SettingViewModel::setTranslateEngine(const QString& value) {
    if (m_translateEngine == value) return;
    m_translateEngine = value;
    emit translateEngineChanged();
    save();
}

void SettingViewModel::load() {
    if (!m_configManager) {
        TB_LOG_WARN(LogModule::Config, "Cannot load settings: ConfigManager not injected");
        return;
    }

    const auto appearance = m_configManager->get<AppearanceConfig>();
    const auto translate  = m_configManager->get<TranslateConfig>();

    m_language = appearance.language;
    m_followSystemTheme = appearance.followSystemTheme;
    m_darkMode = appearance.darkMode;
    syncThemeModeFromFlags();

    m_translateEngine = translate.defaultEngine;
    refreshAvailableEngines();

    emit themeModeChanged();
    emit followSystemThemeChanged();
    emit darkModeChanged();
    emit languageChanged();
    emit translateEngineChanged();
    emit availableEnginesChanged();

    TB_LOG_INFO(LogModule::Config,
        "SettingViewModel loaded | themeMode={} language={} engine={}",
        m_themeMode, m_language.toStdString(), m_translateEngine.toStdString());
}

void SettingViewModel::save() {
    if (!m_configManager) {
        TB_LOG_WARN(LogModule::Config, "Cannot save settings: ConfigManager not injected");
        return;
    }

    m_configManager->update<AppearanceConfig>([this](AppearanceConfig& c) {
        c.theme = m_followSystemTheme
                      ? QStringLiteral("auto")
                      : (m_darkMode ? QStringLiteral("dark") : QStringLiteral("light"));
        c.language = m_language;
        c.followSystemTheme = m_followSystemTheme;
        c.darkMode = m_darkMode;
    });

    m_configManager->update<TranslateConfig>([this](TranslateConfig& c) {
        c.defaultEngine = m_translateEngine;
    });

    const auto result = m_configManager->save();
    if (result.isOk()) {
        emit saveSucceeded();
        TB_LOG_INFO(LogModule::Config,
            "SettingViewModel saved | themeMode={} language={} engine={}",
            m_themeMode, m_language.toStdString(), m_translateEngine.toStdString());
    } else {
        const QString reason = QString::fromStdString(result.error().message);
        emit saveFailed(reason);
        TB_LOG_ERROR(LogModule::Config,
            "SettingViewModel save failed | error={}", reason.toStdString());
    }
}

void SettingViewModel::syncDarkMode(bool value) {
    if (m_darkMode == value) return;
    m_darkMode = value;
    emit darkModeChanged();
}

void SettingViewModel::refreshAvailableEngines() {
    m_availableEngines.clear();
    if (!m_translateService) return;

    for (const auto& engine : m_translateService->availableEngines()) {
        m_availableEngines.append(engine.id);
    }
}

void SettingViewModel::syncThemeModeFromFlags() {
    if (m_followSystemTheme) {
        m_themeMode = 2;
    } else {
        m_themeMode = m_darkMode ? 1 : 0;
    }
}
