#include "viewmodels/HomeViewModel.h"

HomeViewModel::HomeViewModel(QObject* parent) : QObject(parent) {
  m_welcomeMessage = tr("欢迎使用 IQtools Plus！");
  m_appVersion = tr("版本 1.0.0");
  m_buildDate = tr("构建日期: 2024-06-01");
}

QString HomeViewModel::welcomeMessage() const noexcept { return m_welcomeMessage; }

QString HomeViewModel::appVersion() const noexcept { return m_appVersion; }

QString HomeViewModel::buildDate() const noexcept { return m_buildDate; }

