// src/viewmodels/AppShellViewModel.cpp
#include "viewmodels/AppShellViewModel.h"

#include <QDebug>

#include "viewmodels/HomeViewModel.h"
#include "viewmodels/TranslateViewModel.h"

AppShellViewModel::AppShellViewModel(QObject* parent)
    : QObject(parent),
      m_homeViewModel(new HomeViewModel(this)),
      m_translateViewModel(new TranslateViewModel(this)) {
  qInfo() << "[AppShellViewModel] Created";
}

AppShellViewModel::~AppShellViewModel() {
  qInfo() << "[AppShellViewModel] Destroyed";
}

int AppShellViewModel::currentPageIndex() const noexcept {
  return m_currentPageIndex;
}

bool AppShellViewModel::darkMode() const noexcept { return m_darkMode; }

QString AppShellViewModel::pageTitle() const {
  switch (m_currentPageIndex) {
    case 0:
      return tr("首页");
    case 1:
      return tr("翻译");
    case 2:
      return tr("剪贴板");
    case 3:
      return tr("截图");
    default:
      return tr("IQtools Plus");
  }
}

QString AppShellViewModel::pageSubtitle() const {
  switch (m_currentPageIndex) {
    case 0:
      return tr("欢迎使用 IQtools Plus！请选择左侧功能导航进入对应页面。");
    case 1:
      return tr("多引擎翻译入口与结果展示骨架");
    case 2:
      return tr("剪贴板历史、搜索与分类入口");
    case 3:
      return tr("截图、延时截图与后续标注入口");
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
  if (pageIndex < 0 || pageIndex > 3) {
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

  qInfo() << "[AppShellViewModel] Dark mode changed:" << m_darkMode;
}

void AppShellViewModel::toggleDarkMode() noexcept { setDarkMode(!m_darkMode); }

void AppShellViewModel::navigateTo(int pageIndex) {
  setCurrentPageIndex(pageIndex);
}
