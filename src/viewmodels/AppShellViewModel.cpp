// src/viewmodels/AppShellViewModel.cpp
#include "viewmodels/AppShellViewModel.h"

#include <QSettings>
#include <QStyleHints>
#include <QGuiApplication>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"
#include "viewmodels/HomeViewModel.h"
#include "viewmodels/TranslateViewModel.h"
#include "viewmodels/LogViewModel.h"

AppShellViewModel::AppShellViewModel(QObject* parent)
    : QObject(parent),
      m_homeViewModel(new HomeViewModel(this)),
      m_translateViewModel(new TranslateViewModel(this)),
      m_logViewModel(new LogViewModel(this)) {
  loadSettings();
  TB_LOG_INFO(LogModule::App,
      "AppShellViewModel created | darkMode={} followSystem={}",
      m_darkMode, m_followSystemTheme);
}

AppShellViewModel::~AppShellViewModel() {
  saveSettings();
  TB_LOG_DEBUG(LogModule::App, "AppShellViewModel destroyed");
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

QObject* AppShellViewModel::logViewModel() const noexcept {
  return m_logViewModel;
}

void AppShellViewModel::setCurrentPageIndex(int pageIndex) {
  if (pageIndex < 0 || pageIndex > 6) {
    TB_LOG_WARN(LogModule::App, "Invalid page index={}", pageIndex);
    return;
  }

  if (m_currentPageIndex == pageIndex) {
    return;
  }

  m_currentPageIndex = pageIndex;
  emit currentPageIndexChanged();

  TB_LOG_INFO(LogModule::App, "Page switched to index={}", m_currentPageIndex);
}

void AppShellViewModel::setDarkMode(bool enabled) {
  if (m_darkMode == enabled) {
    return;
  }

  m_darkMode = enabled;
  emit darkModeChanged();
  saveSettings();

  TB_LOG_INFO(LogModule::App, "Dark mode changed to={}", m_darkMode);
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
  TB_LOG_INFO(LogModule::App, "Follow system theme set to={}", m_followSystemTheme);
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
