#include "viewmodels/HomeViewModel.h"

#include <QDateTime>
#include <QLocale>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"

HomeViewModel::HomeViewModel(QObject* parent) : QObject(parent) {
  m_welcomeMessage = generateWelcomeMessage();

#ifdef IQTOOLS_APP_VERSION
  m_appVersion = QStringLiteral(IQTOOLS_APP_VERSION);
#else
  m_appVersion = QStringLiteral("0.1.0");
#endif

  m_buildDate = QStringLiteral(__DATE__ "  " __TIME__);

  m_weatherText = tr("点击刷新获取天气");
  m_weatherTemperature = QStringLiteral("--\u00B0C");
  m_weatherCity = tr("未设置");
  m_weatherIcon = QStringLiteral("\u2601");

  updateDateTime();

  connect(&m_timer, &QTimer::timeout, this, &HomeViewModel::updateDateTime);
  m_timer.start(1000);

  TB_LOG_INFO(LogModule::App, "HomeViewModel initialized | version={}", m_appVersion.toStdString());
}

void HomeViewModel::updateDateTime() {
  const QDateTime now = QDateTime::currentDateTime();
  const QString newTime = now.toString(QStringLiteral("HH:mm"));
  const QString newDate =
      now.toString(QStringLiteral("yyyy-MM-dd dddd"));

  if (m_currentTime != newTime) {
    m_currentTime = newTime;
    emit currentTimeChanged();
  }
  if (m_currentDate != newDate) {
    m_currentDate = newDate;
    emit currentDateChanged();
  }

  static int lastHour = now.time().hour();
  if (now.time().hour() != lastHour) {
    lastHour = now.time().hour();
    refreshWelcomeMessage();
  }
}

QString HomeViewModel::welcomeMessage() const noexcept {
  return m_welcomeMessage;
}

QString HomeViewModel::appVersion() const noexcept { return m_appVersion; }

QString HomeViewModel::buildDate() const noexcept { return m_buildDate; }

QString HomeViewModel::totalPagesText() const noexcept {
  return tr("6 个页面");
}

QString HomeViewModel::totalToolsText() const noexcept {
  return tr("12 个工具");
}

QString HomeViewModel::currentTime() const noexcept { return m_currentTime; }

QString HomeViewModel::currentDate() const noexcept { return m_currentDate; }

QString HomeViewModel::weatherText() const noexcept { return m_weatherText; }

QString HomeViewModel::weatherTemperature() const noexcept {
  return m_weatherTemperature;
}

QString HomeViewModel::weatherCity() const noexcept { return m_weatherCity; }

QString HomeViewModel::weatherIcon() const noexcept { return m_weatherIcon; }

void HomeViewModel::refreshWelcomeMessage() {
  const QString msg = generateWelcomeMessage();
  if (m_welcomeMessage != msg) {
    m_welcomeMessage = msg;
    emit welcomeMessageChanged();
  }
}

void HomeViewModel::refreshWeather(const QString& city) {
  if (city.isEmpty()) return;
  m_weatherCity = city;
  // 预留接口：接入天气 API 后替换此处
  m_weatherText = tr("天气数据待接入");
  m_weatherTemperature = QStringLiteral("--\u00B0C");
  emit weatherChanged();

  TB_LOG_DEBUG(LogModule::Network, "Weather refresh requested | city='{}'", city.toStdString());
}

QString HomeViewModel::generateWelcomeMessage() const {
  const int hour = QDateTime::currentDateTime().time().hour();
  if (hour < 6) {
    return tr("夜深了，注意休息 🌙");
  } else if (hour < 12) {
    return tr("早上好，开启高效的一天 ☀️");
  } else if (hour < 18) {
    return tr("下午好，保持专注 💪");
  } else {
    return tr("晚上好，今日事今日毕 🌆");
  }
}

