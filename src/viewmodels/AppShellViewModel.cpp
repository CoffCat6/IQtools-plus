// src/viewmodels/AppShellViewModel.cpp
#include "viewmodels/AppShellViewModel.h"

#include <QDebug>
#include <QSettings>
#include <QStyleHints>
#include <QGuiApplication>

#include "viewmodels/HomeViewModel.h"
#include "viewmodels/TranslateViewModel.h"

AppShellViewModel::AppShellViewModel(QObject* parent)
    : QObject(parent),
      m_homeViewModel(new HomeViewModel(this)),
      m_translateViewModel(new TranslateViewModel(this)) {
  loadSettings();
  qInfo() << "[AppShellViewModel] Created | darkMode:" << m_darkMode
          << "followSystem:" << m_followSystemTheme;
}

AppShellViewModel::~AppShellViewModel() {
  saveSettings();
  qInfo() << "[AppShellViewModel] Destroyed";
}

int AppShellViewModel::currentPageIndex() const noexcept {
  return m_currentPageIndex;
}

bool AppShellViewModel::darkMode() const noexcept { return m_darkMode; }

bool AppShellViewModel::followSystemTheme() const noexcept {
  return m_followSystemTheme;
}

QString AppShellViewModel::pageTitle() const {
  switch (m_currentPageIndex) {
    case 0:
      return tr("首页");
    case 1:
      return tr("AI 助手");
    case 2:
      return tr("翻译");
    case 3:
      return tr("剪贴板");
    case 4:
      return tr("截图");
    case 5:
      return tr("待办");
    case 6:
      return tr("设置");
    default:
      return tr("IQtools Plus");
  }
}

QString AppShellViewModel::pageSubtitle() const {
  switch (m_currentPageIndex) {
    case 0:
      return tr("欢迎使用 IQtools Plus！请选择左侧功能导航进入对应页面。");
    case 1:
      return tr("与 AI 进行对话，支持上传文件进行分析");
    case 2:
      return tr("多引擎翻译入口与结果展示");
    case 3:
      return tr("剪贴板历史、搜索与分类入口");
    case 4:
      return tr("截图、延时截图与后续标注入口");
    case 5:
      return tr("任务管理、待办事项与工作计划");
    case 6:
      return tr("设置");
    default:
      return tr("企业级桌面效率工具箱");
  }
}

QObject* AppShellViewModel::homeViewModel() const noexcept {
  return m_homeViewModel;
}

QObject* AppShellViewModel::translateViewModel() const noexcept {
  return m_translateViewModel;
}

void AppShellViewModel::setCurrentPageIndex(int pageIndex) {
  if (pageIndex < 0 || pageIndex > 6) {
    qWarning() << "[AppShellViewModel] Invalid page index:" << pageIndex;
    return;
  }

  if (m_currentPageIndex == pageIndex) {
    return;
  }

  m_currentPageIndex = pageIndex;
  emit currentPageIndexChanged();

  qInfo() << "[AppShellViewModel] Switched page to index ="
          << m_currentPageIndex;
}

void AppShellViewModel::setDarkMode(bool enabled) {
  if (m_darkMode == enabled) {
    return;
  }

  m_darkMode = enabled;
  emit darkModeChanged();
  saveSettings();

  qInfo() << "[AppShellViewModel] Dark mode changed:" << m_darkMode;
}

void AppShellViewModel::setFollowSystemTheme(bool enabled) {
  if (m_followSystemTheme == enabled) {
    return;
  }

  m_followSystemTheme = enabled;
  emit followSystemThemeChanged();

  if (m_followSystemTheme) {
    // Connect to system theme changes
    syncDarkModeFromSystem();
    if (auto* app = qobject_cast<QGuiApplication*>(
            QCoreApplication::instance())) {
      connect(app->styleHints(), &QStyleHints::colorSchemeChanged, this,
              &AppShellViewModel::syncDarkModeFromSystem);
    }
  }

  saveSettings();
  qInfo() << "[AppShellViewModel] Follow system theme:" << m_followSystemTheme;
}

void AppShellViewModel::toggleDarkMode() noexcept {
  setDarkMode(!m_darkMode);
}

void AppShellViewModel::navigateTo(int pageIndex) {
  setCurrentPageIndex(pageIndex);
}

void AppShellViewModel::saveSettings() {
  QSettings settings;
  settings.setValue(QStringLiteral("theme/darkMode"), m_darkMode);
  settings.setValue(QStringLiteral("theme/followSystem"), m_followSystemTheme);
}

void AppShellViewModel::loadSettings() {
  QSettings settings;
  m_followSystemTheme =
      settings.value(QStringLiteral("theme/followSystem"), false).toBool();
  if (m_followSystemTheme) {
    syncDarkModeFromSystem();
  } else {
    m_darkMode =
        settings.value(QStringLiteral("theme/darkMode"), false).toBool();
  }
}

void AppShellViewModel::syncDarkModeFromSystem() {
  if (!m_followSystemTheme) return;

  if (auto* app =
          qobject_cast<QGuiApplication*>(QCoreApplication::instance())) {
    const bool systemDark =
        app->styleHints()->colorScheme() == Qt::ColorScheme::Dark;
    setDarkMode(systemDark);
  }
}
