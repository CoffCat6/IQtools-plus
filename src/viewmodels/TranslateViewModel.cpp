// src/viewmodels/TranslateViewModel.cpp
#include "viewmodels/TranslateViewModel.h"

#include <QClipboard>
#include <QGuiApplication>
#include <QTimer>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"

TranslateViewModel::TranslateViewModel(QObject* parent) : QObject(parent) {
  TB_LOG_INFO(LogModule::Translate, "TranslateViewModel initialized (mock engine)");
}

QString TranslateViewModel::sourceText() const noexcept { return m_sourceText; }

QString TranslateViewModel::resultText() const noexcept { return m_resultText; }

bool TranslateViewModel::translating() const noexcept { return m_translating; }

QString TranslateViewModel::fromLanguage() const noexcept {
  return m_fromLanguage;
}

QString TranslateViewModel::toLanguage() const noexcept { return m_toLanguage; }

QStringList TranslateViewModel::supportedLanguages() const {
  return {QStringLiteral("auto"), QStringLiteral("zh-CN"), QStringLiteral("en"),
          QStringLiteral("ja"), QStringLiteral("ko")};
}

QString TranslateViewModel::currentEngine() const noexcept {
  return m_currentEngine;
}

QStringList TranslateViewModel::availableEngines() const {
  return {QStringLiteral("mock-local")};
}

QString TranslateViewModel::errorMessage() const noexcept {
  return m_errorMessage;
}

QString TranslateViewModel::latencyInfo() const noexcept {
  return m_latencyInfo;
}

double TranslateViewModel::cacheHitRate() const noexcept {
  return m_cacheHitRate;
}

void TranslateViewModel::setSourceText(const QString& text) {
  if (m_sourceText == text) {
    return;
  }

  m_sourceText = text;
  emit sourceTextChanged();
}

void TranslateViewModel::setFromLanguage(const QString& language) {
  if (m_fromLanguage == language) {
    return;
  }

  m_fromLanguage = language;
  emit fromLanguageChanged();
}

void TranslateViewModel::setToLanguage(const QString& language) {
  if (m_toLanguage == language) {
    return;
  }

  m_toLanguage = language;
  emit toLanguageChanged();
}

void TranslateViewModel::setCurrentEngine(const QString& engineId) {
  if (m_currentEngine == engineId) {
    return;
  }

  m_currentEngine = engineId;
  emit currentEngineChanged();
}

void TranslateViewModel::translate() {
  const QString trimmed = m_sourceText.trimmed();
  if (trimmed.isEmpty()) {
    setErrorMessage(tr("请输入待翻译文本。"));
    emit translateFailed(m_errorMessage);
    return;
  }

  setErrorMessage(QString());
  setTranslating(true);

  QElapsedTimer timer;
  timer.start();

  // NOTE:
  // 当前为 UI 骨架阶段，先用 mock 结果联调界面。
  // 下一轮接入真实 TranslateService 时，这里替换为
  // service->translateAsync(...)。
  QTimer::singleShot(
      280, this, [this, trimmed, elapsed = timer.elapsed()]() mutable {
        const qint64 actualElapsed = elapsed + 280;

        const QString mockResult =
            tr("[Mock Translation]\nEngine: %1\nFrom: %2\nTo: %3\n\n%4")
                .arg(m_currentEngine, m_fromLanguage, m_toLanguage, trimmed);

        setResultText(mockResult);
        setLatencyInfo(tr("%1 ms").arg(actualElapsed));
        setCacheHitRate(0.0);
        setTranslating(false);

        emit translateSucceeded(m_resultText);

        TB_LOG_INFO(LogModule::Translate, "Mock translation done in {}ms | engine={} from={} to={}",
            actualElapsed, m_currentEngine, m_fromLanguage, m_toLanguage);
      });
}

void TranslateViewModel::clear() {
  setSourceText(QString());
  setResultText(QString());
  setErrorMessage(QString());
  setLatencyInfo(QStringLiteral("-- ms"));

  TB_LOG_DEBUG(LogModule::Translate, "Input cleared");
}

void TranslateViewModel::copyResult() {
  if (m_resultText.trimmed().isEmpty()) {
    setErrorMessage(tr("当前没有可复制的翻译结果。"));
    return;
  }

  if (QClipboard* clipboard = QGuiApplication::clipboard();
      clipboard != nullptr) {
    clipboard->setText(m_resultText);
    TB_LOG_INFO(LogModule::Translate, "Result copied to clipboard (len={})",
        m_resultText.length());
  } else {
    setErrorMessage(tr("无法访问系统剪贴板。"));
    TB_LOG_WARN(LogModule::Translate, "System clipboard unavailable");
  }
}

void TranslateViewModel::switchLanguages() {
  if (m_fromLanguage == QStringLiteral("auto")) {
    TB_LOG_DEBUG(LogModule::Translate, "Language switch skipped: source is 'auto'");
    return;
  }

  const QString oldFrom = m_fromLanguage;
  setFromLanguage(m_toLanguage);
  setToLanguage(oldFrom);

  TB_LOG_INFO(LogModule::Translate, "Languages swapped: {} <-> {}", m_fromLanguage, m_toLanguage);
}

void TranslateViewModel::setResultText(const QString& text) {
  if (m_resultText == text) {
    return;
  }

  m_resultText = text;
  emit resultTextChanged();
}

void TranslateViewModel::setErrorMessage(const QString& message) {
  if (m_errorMessage == message) {
    return;
  }

  m_errorMessage = message;
  emit errorMessageChanged();
}

void TranslateViewModel::setTranslating(bool value) {
  if (m_translating == value) {
    return;
  }

  m_translating = value;
  emit translatingChanged();
}

void TranslateViewModel::setLatencyInfo(const QString& info) {
  if (m_latencyInfo == info) {
    return;
  }

  m_latencyInfo = info;
  emit latencyInfoChanged();
}

void TranslateViewModel::setCacheHitRate(double value) {
  if (qFuzzyCompare(m_cacheHitRate, value)) {
    return;
  }

  m_cacheHitRate = value;
  emit cacheHitRateChanged();
}