// src/viewmodels/AppShellViewModel.h
#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>
#include <QStyleHints>

class HomeViewModel;
class TranslateViewModel;
class AIAssistantViewModel;
class LogViewModel;
class SettingViewModel;
class AppContext;

/**
 * @brief Main shell ViewModel for the application window.
 * 中文说明：
 * - 管理主界面的页面切换、主题状态、标题信息
 * - 聚合子 ViewModel，供 QML 根对象统一访问
 * - 支持暗色模式持久化存储（QSettings）
 * - 支持跟随系统主题（QStyleHints::colorScheme）
 */
class AppShellViewModel final : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int currentPageIndex
               READ currentPageIndex
               WRITE setCurrentPageIndex
               NOTIFY currentPageIndexChanged
               FINAL)

    Q_PROPERTY(bool darkMode
               READ darkMode
               WRITE setDarkMode
               NOTIFY darkModeChanged
               FINAL)

    Q_PROPERTY(bool followSystemTheme
               READ followSystemTheme
               WRITE setFollowSystemTheme
               NOTIFY followSystemThemeChanged
               FINAL)

    Q_PROPERTY(QString pageTitle
               READ pageTitle
               NOTIFY currentPageIndexChanged
               FINAL)

    Q_PROPERTY(QString pageSubtitle
               READ pageSubtitle
               NOTIFY currentPageIndexChanged
               FINAL)

    Q_PROPERTY(QObject* homeViewModel
               READ homeViewModel
               CONSTANT
               FINAL)

    Q_PROPERTY(QObject* translateViewModel
               READ translateViewModel
               CONSTANT
               FINAL)

    Q_PROPERTY(QObject* aiAssistantViewModel
               READ aiAssistantViewModel
               CONSTANT
               FINAL)

    Q_PROPERTY(QObject* logViewModel
               READ logViewModel
               CONSTANT
               FINAL)

    Q_PROPERTY(QObject* settingViewModel
               READ settingViewModel
               CONSTANT
               FINAL)

    /// 总页面数（供首页统计展示）
    Q_PROPERTY(int pageCount READ pageCount CONSTANT FINAL)

public:
    explicit AppShellViewModel(QObject* parent = nullptr);
    ~AppShellViewModel() override;

    /// 注入应用上下文，将服务分发给子 ViewModel
    /// 在构造后、QML 引擎加载前调用
    void setAppContext(AppContext* ctx);

    [[nodiscard]] int currentPageIndex() const noexcept;
    [[nodiscard]] bool darkMode() const noexcept;
    [[nodiscard]] bool followSystemTheme() const noexcept;
    [[nodiscard]] QString pageTitle() const;
    [[nodiscard]] QString pageSubtitle() const;
    [[nodiscard]] QObject* homeViewModel() const noexcept;
    [[nodiscard]] QObject* translateViewModel() const noexcept;
    [[nodiscard]] QObject* aiAssistantViewModel() const noexcept;
    [[nodiscard]] QObject* logViewModel() const noexcept;
    [[nodiscard]] QObject* settingViewModel() const noexcept;
    [[nodiscard]] int pageCount() const noexcept;

    void setCurrentPageIndex(int pageIndex);
    void setDarkMode(bool enabled);
    void setFollowSystemTheme(bool enabled);

public slots:
    Q_INVOKABLE void toggleDarkMode() noexcept;
    Q_INVOKABLE void navigateTo(int pageIndex);

signals:
    void currentPageIndexChanged();
    void darkModeChanged();
    void followSystemThemeChanged();

private:
    void syncDarkModeFromSystem();

    static constexpr int kPageCount = 7;

    int m_currentPageIndex{0};
    bool m_darkMode{false};
    bool m_followSystemTheme{false};
    HomeViewModel* m_homeViewModel{nullptr};
    TranslateViewModel* m_translateViewModel{nullptr};
    AIAssistantViewModel* m_aiAssistantViewModel{nullptr};
    LogViewModel* m_logViewModel{nullptr};
    SettingViewModel* m_settingViewModel{nullptr};
};
