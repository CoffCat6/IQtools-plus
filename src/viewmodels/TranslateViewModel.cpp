// src/viewmodels/TranslateViewModel.cpp
#include "viewmodels/TranslateViewModel.h"

#include <QClipboard>
#include <QGuiApplication>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"
#include "services/translate/MockTranslateService.h"

TranslateViewModel::TranslateViewModel(QObject* parent) : QObject(parent) {
  TB_LOG_INFO(LogModule::Translate, "TranslateViewModel initialized");
}

void TranslateViewModel::injectService(ITranslateService::Ptr service) {
  m_service = std::move(service);

  // 从服务同步当前引擎和语言列表
  if (m_service) {
    m_currentEngine = m_service->currentEngine();
    emit currentEngineChanged();
    emit supportedLanguagesChanged();
    emit availableEnginesChanged();
  }

  TB_LOG_DEBUG(LogModule::Translate, "Service injected | engine='{}'",
      m_currentEngine.toStdString());
}

ITranslateService::Ptr TranslateViewModel::ensureService() {
  if (!m_service) {
    // 注意：不传 parent，由 shared_ptr 管理生命周期，避免 Qt 父子机制 + shared_ptr 双重释放
    m_service = std::make_shared<MockTranslateService>();
    m_currentEngine = m_service->currentEngine();
    emit currentEngineChanged();
    emit supportedLanguagesChanged();
    emit availableEnginesChanged();
    TB_LOG_DEBUG(LogModule::Translate,
        "Lazy-created MockTranslateService (no injection)");
  }
  return m_service;
}

QString TranslateViewModel::sourceText() const noexcept { return m_sourceText; }

QString TranslateViewModel::resultText() const noexcept { return m_resultText; }

bool TranslateViewModel::translating() const noexcept { return m_translating; }

QString TranslateViewModel::fromLanguage() const noexcept {
  return m_fromLanguage;
}

QString TranslateViewModel::toLanguage() const noexcept {
  return m_toLanguage;
}

QStringList TranslateViewModel::supportedLanguages() const {
  if (m_service) return m_service->supportedLanguages();
  // 回退默认列表（与 MockTranslateService 一致）
  return {QStringLiteral("auto"), QStringLiteral("zh-CN"), QStringLiteral("en"),
          QStringLiteral("ja"), QStringLiteral("ko")};
}

QString TranslateViewModel::currentEngine() const noexcept {
  return m_currentEngine;
}

QStringList TranslateViewModel::availableEngines() const {
  if (m_service) {
    QStringList engines;
    for (const auto& info : m_service->availableEngines()) {
      engines.append(info.id);
    }
    return engines;
  }
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

  auto svc = ensureService();
  svc->setCurrentEngine(engineId);

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

  TranslateRequest request;
  request.text     = trimmed;
  request.fromLang = m_fromLanguage;
  request.toLang   = m_toLanguage;
  request.engineId = m_currentEngine;

  auto svc = ensureService();

  // 捕获 raw 指针用于回判断 ViewModel 是否仍然存活
  // （QTimer 延迟回调期间 ViewModel 可能被销毁）
  svc->translateAsync(request, [this](Result<TranslateResult> result) {
    // 异步回调：确保通过 QueuedConnection 在主线程执行
    // MockTranslateService 使用 QTimer::singleShot，已在主线程
    if (result.isErr()) {
      setTranslating(false);
      const QString reason = QString::fromStdString(result.error().message);
      setErrorMessage(reason);
      emit translateFailed(reason);
      TB_LOG_WARN(LogModule::Translate, "Translate failed: {}",
          result.error().message);
      return;
    }

    const auto& data = result.value();
    setResultText(data.translatedText);
    setLatencyInfo(tr("%1 ms").arg(data.latencyMs));
    setCacheHitRate(data.cacheHit ? 1.0 : 0.0);
    setTranslating(false);

    emit translateSucceeded(m_resultText);

    TB_LOG_INFO(LogModule::Translate,
        "Translation succeeded | engine={} latency={}ms cacheHit={}",
        data.engineId.toStdString(), data.latencyMs, data.cacheHit);
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
