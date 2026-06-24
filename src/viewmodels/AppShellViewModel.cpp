// src/viewmodels/AppShellViewModel.cpp
#include "viewmodels/AppShellViewModel.h"

#include <QStyleHints>
#include <QGuiApplication>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"
#include "viewmodels/HomeViewModel.h"
#include "viewmodels/TranslateViewModel.h"
#include "viewmodels/AIAssistantViewModel.h"
#include "viewmodels/LogViewModel.h"
#include "viewmodels/SettingViewModel.h"
#include "app/AppContext.h"
#include "core/config/ConfigManager.h"
#include "services/translate/ITranslateService.h"
#include "services/ai/IAIService.h"

AppShellViewModel::AppShellViewModel(QObject* parent)
    : QObject(parent),
      m_homeViewModel(new HomeViewModel(this)),
      m_translateViewModel(new TranslateViewModel(this)),
      m_aiAssistantViewModel(new AIAssistantViewModel(this)),
      m_logViewModel(new LogViewModel(this)),
      m_settingViewModel(new SettingViewModel(this)) {
  // 监听 SettingViewModel 的配置变化，同步到本类的运行时状态
  connect(m_settingViewModel, &SettingViewModel::darkModeChanged,
          this, [this]() {
            const bool value = m_settingViewModel->darkMode();
            if (m_darkMode != value) {
              m_darkMode = value;
              emit darkModeChanged();
            }
          });
  connect(m_settingViewModel, &SettingViewModel::followSystemThemeChanged,
          this, [this]() {
            const bool value = m_settingViewModel->followSystemTheme();
            if (m_followSystemTheme != value) {
              m_followSystemTheme = value;
              emit followSystemThemeChanged();
              if (m_followSystemTheme) {
                syncDarkModeFromSystem();
              }
            }
          });

  TB_LOG_INFO(LogModule::App,
      "AppShellViewModel created");
}

AppShellViewModel::~AppShellViewModel() {
  TB_LOG_DEBUG(LogModule::App, "AppShellViewModel destroyed");
}

void AppShellViewModel::setAppContext(AppContext* ctx) {
  if (!ctx) return;

  // 配置管理器注入 SettingViewModel
  auto configManager = ctx->getService<ConfigManager>();
  if (configManager) {
    m_settingViewModel->setConfigManager(configManager);
    TB_LOG_INFO(LogModule::App, "ConfigManager injected into SettingViewModel");
  } else {
    TB_LOG_WARN(LogModule::App, "No ConfigManager registered in AppContext");
  }

  // 翻译服务注入
  auto translateSvc = ctx->getService<ITranslateService>();
  if (translateSvc) {
    m_translateViewModel->injectService(translateSvc);
    m_settingViewModel->injectTranslateService(translateSvc);
    TB_LOG_INFO(LogModule::App, "TranslateService injected");
  } else {
    TB_LOG_WARN(LogModule::App, "No TranslateService registered in AppContext");
  }

  // AI 服务注入
  auto aiSvc = ctx->getService<IAIService>();
  if (aiSvc) {
    m_aiAssistantViewModel->injectService(aiSvc);
    TB_LOG_INFO(LogModule::App, "AIService injected into AIAssistantViewModel");
  } else {
    TB_LOG_WARN(LogModule::App, "No AIService registered in AppContext");
  }

  // 从配置文件加载设置并同步运行时状态
  m_settingViewModel->load();
  m_followSystemTheme = m_settingViewModel->followSystemTheme();
  if (m_followSystemTheme) {
    syncDarkModeFromSystem();
  } else {
    m_darkMode = m_settingViewModel->darkMode();
  }
  emit darkModeChanged();
  emit followSystemThemeChanged();

  TB_LOG_INFO(LogModule::App,
      "Settings loaded | darkMode={} followSystem={}",
      m_darkMode, m_followSystemTheme);

  // 监听系统主题变化（仅在跟随系统时生效）
  if (auto* app = qobject_cast<QGuiApplication*>(
          QCoreApplication::instance())) {
    connect(app->styleHints(), &QStyleHints::colorSchemeChanged,
            this, &AppShellViewModel::syncDarkModeFromSystem,
            Qt::UniqueConnection);
  }

  // 未来：注入其他服务（剪贴板、截图等）
}

int AppShellViewModel::currentPageIndex() const noexcept {
  return m_currentPageIndex;
}

bool AppShellViewModel::darkMode() const noexcept { return m_darkMode; }

bool AppShellViewModel::followSystemTheme() const noexcept {
  return m_followSystemTheme;
}

QString AppShellViewModel::pageTitle() const {
  // 数据驱动：按索引查找标题，替代 switch-case 硬编码
  static const QStringList titles = {
      tr("首页"),
      tr("AI 助手"),
      tr("翻译"),
      tr("剪贴板"),
      tr("截图"),
      tr("待办"),
      tr("设置"),
  };
  if (m_currentPageIndex >= 0 && m_currentPageIndex < titles.size()) {
    return titles.at(m_currentPageIndex);
  }
  return tr("IQtools Plus");
}

QString AppShellViewModel::pageSubtitle() const {
  // 数据驱动：按索引查找副标题
  static const QStringList subtitles = {
      tr("欢迎使用 IQtools Plus！请选择左侧功能导航进入对应页面。"),
      tr("与 AI 进行对话，支持上传文件进行分析"),
      tr("多引擎翻译入口与结果展示"),
      tr("剪贴板历史、搜索与分类入口"),
      tr("截图、延时截图与后续标注入口"),
      tr("任务管理、待办事项与工作计划"),
      tr("设置"),
  };
  if (m_currentPageIndex >= 0 && m_currentPageIndex < subtitles.size()) {
    return subtitles.at(m_currentPageIndex);
  }
  return tr("企业级桌面效率工具箱");
}

QObject* AppShellViewModel::homeViewModel() const noexcept {
  return m_homeViewModel;
}

QObject* AppShellViewModel::translateViewModel() const noexcept {
  return m_translateViewModel;
}

QObject* AppShellViewModel::aiAssistantViewModel() const noexcept {
  return m_aiAssistantViewModel;
}

QObject* AppShellViewModel::logViewModel() const noexcept {
  return m_logViewModel;
}

QObject* AppShellViewModel::settingViewModel() const noexcept {
  return m_settingViewModel;
}

int AppShellViewModel::pageCount() const noexcept {
  return kPageCount;
}

void AppShellViewModel::setCurrentPageIndex(int pageIndex) {
  if (pageIndex < 0 || pageIndex >= kPageCount) {
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

  if (m_settingViewModel) {
    m_settingViewModel->setDarkMode(enabled);
  } else {
    m_darkMode = enabled;
    emit darkModeChanged();
  }

  TB_LOG_INFO(LogModule::App, "Dark mode changed to={}", enabled);
}

void AppShellViewModel::setFollowSystemTheme(bool enabled) {
  if (m_followSystemTheme == enabled) {
    return;
  }

  if (m_settingViewModel) {
    m_settingViewModel->setFollowSystemTheme(enabled);
  } else {
    m_followSystemTheme = enabled;
    emit followSystemThemeChanged();
    if (m_followSystemTheme) {
      syncDarkModeFromSystem();
    }
  }

  TB_LOG_INFO(LogModule::App, "Follow system theme set to={}", enabled);
}

void AppShellViewModel::toggleDarkMode() noexcept {
  setDarkMode(!m_darkMode);
}

void AppShellViewModel::navigateTo(int pageIndex) {
  setCurrentPageIndex(pageIndex);
}

void AppShellViewModel::syncDarkModeFromSystem() {
  if (!m_followSystemTheme) return;

  if (auto* app =
          qobject_cast<QGuiApplication*>(QCoreApplication::instance())) {
    const bool systemDark =
        app->styleHints()->colorScheme() == Qt::ColorScheme::Dark;
    if (m_darkMode != systemDark) {
      m_darkMode = systemDark;
      emit darkModeChanged();
      if (m_settingViewModel) {
        m_settingViewModel->syncDarkMode(systemDark);
      }
      TB_LOG_INFO(LogModule::App, "System dark mode synced to={}", m_darkMode);
    }
  }
}
