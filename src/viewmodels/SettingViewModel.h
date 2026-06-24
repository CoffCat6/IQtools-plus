// src/viewmodels/SettingViewModel.h
#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QtQml/qqmlregistration.h>
#include <memory>

#include "services/translate/ITranslateService.h"

class ConfigManager;

/**
 * @brief 设置页面 ViewModel
 *
 * 负责把 ConfigManager 中的配置项暴露给 QML，并处理保存。
 * 主题相关的运行时状态由 AppShellViewModel 持有，但持久化通过本类完成。
 */
class SettingViewModel final : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // 主题模式：0=浅色, 1=深色, 2=跟随系统
    Q_PROPERTY(int themeMode READ themeMode WRITE setThemeMode
                   NOTIFY themeModeChanged FINAL)

    // 是否跟随系统主题
    Q_PROPERTY(bool followSystemTheme READ followSystemTheme WRITE setFollowSystemTheme
                   NOTIFY followSystemThemeChanged FINAL)

    // 当前是否为深色模式（仅在非跟随系统时有效，供 UI 显示）
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode
                   NOTIFY darkModeChanged FINAL)

    // 界面语言
    Q_PROPERTY(QString language READ language WRITE setLanguage
                   NOTIFY languageChanged FINAL)

    // 默认翻译引擎 ID
    Q_PROPERTY(QString translateEngine READ translateEngine WRITE setTranslateEngine
                   NOTIFY translateEngineChanged FINAL)

    // 可用翻译引擎 ID 列表
    Q_PROPERTY(QStringList availableEngines READ availableEngines
                   NOTIFY availableEnginesChanged FINAL)

public:
    explicit SettingViewModel(QObject* parent = nullptr);
    ~SettingViewModel() override;

    /// 注入配置管理器
    void setConfigManager(std::shared_ptr<ConfigManager> mgr);

    /// 注入翻译服务，用于获取可用引擎列表
    void injectTranslateService(ITranslateService::Ptr service);

    [[nodiscard]] int themeMode() const noexcept;
    [[nodiscard]] bool followSystemTheme() const noexcept;
    [[nodiscard]] bool darkMode() const noexcept;
    [[nodiscard]] QString language() const noexcept;
    [[nodiscard]] QString translateEngine() const noexcept;
    [[nodiscard]] QStringList availableEngines() const;

    void setThemeMode(int mode);
    void setFollowSystemTheme(bool value);
    void setDarkMode(bool value);
    void setLanguage(const QString& value);
    void setTranslateEngine(const QString& value);

    /// 从 ConfigManager 重新加载所有设置
    Q_INVOKABLE void load();

    /// 把当前设置持久化到 ConfigManager
    Q_INVOKABLE void save();

    /// 仅同步当前深浅色显示状态，不切换主题模式（用于跟随系统主题）
    void syncDarkMode(bool value);

signals:
    void themeModeChanged();
    void followSystemThemeChanged();
    void darkModeChanged();
    void languageChanged();
    void translateEngineChanged();
    void availableEnginesChanged();
    void saveSucceeded();
    void saveFailed(const QString& reason);

private:
    void refreshAvailableEngines();
    void syncThemeModeFromFlags();

    std::shared_ptr<ConfigManager> m_configManager;
    ITranslateService::Ptr m_translateService;

    int m_themeMode{0};              // 0=light, 1=dark, 2=auto
    bool m_followSystemTheme{false};
    bool m_darkMode{false};
    QString m_language{QStringLiteral("zh_CN")};
    QString m_translateEngine{QStringLiteral("mock-local")};
    QStringList m_availableEngines;
};
