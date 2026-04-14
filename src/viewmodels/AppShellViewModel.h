// src/viewmodels/AppShellViewModel.h
#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

class TranslateViewModel;

/**
 * @brief Main shell ViewModel for the application window.
 * 中文说明：
 * - 管理主界面的页面切换、主题状态、标题信息
 * - 聚合子 ViewModel，供 QML 根对象统一访问
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

    Q_PROPERTY(QString pageTitle
               READ pageTitle
               NOTIFY currentPageIndexChanged
               FINAL)

    Q_PROPERTY(QString pageSubtitle
               READ pageSubtitle
               NOTIFY currentPageIndexChanged
               FINAL)

    Q_PROPERTY(QObject* translateViewModel
               READ translateViewModel
               CONSTANT
               FINAL)

public:
    explicit AppShellViewModel(QObject* parent = nullptr);
    ~AppShellViewModel() override;

    [[nodiscard]] int currentPageIndex() const noexcept;
    [[nodiscard]] bool darkMode() const noexcept;
    [[nodiscard]] QString pageTitle() const;
    [[nodiscard]] QString pageSubtitle() const;
    [[nodiscard]] QObject* translateViewModel() const noexcept;

    void setCurrentPageIndex(int pageIndex);
    void setDarkMode(bool enabled);

public slots:
    Q_INVOKABLE void toggleDarkMode() noexcept;
    Q_INVOKABLE void navigateTo(int pageIndex);

signals:
    void currentPageIndexChanged();
    void darkModeChanged();

private:
    int m_currentPageIndex{0};
    bool m_darkMode{false};
    TranslateViewModel* m_translateViewModel{nullptr};
};