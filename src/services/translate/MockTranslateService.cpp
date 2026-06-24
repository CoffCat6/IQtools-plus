// src/services/translate/MockTranslateService.cpp
#include "services/translate/MockTranslateService.h"

#include <QElapsedTimer>
#include <QTimer>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"

MockTranslateService::MockTranslateService(QObject* parent)
    : QObject(parent) {
    TB_LOG_INFO(LogModule::Translate, "MockTranslateService initialized");
}

void MockTranslateService::translateAsync(const TranslateRequest& request,
                                           TranslateCallback       callback) {
    const QString trimmed = request.text.trimmed();
    if (trimmed.isEmpty()) {
        callback(Result<TranslateResult>::err(
            TB_MAKE_ERROR(ErrorCode::TranslateEmptyInput,
                          "Text cannot be empty")));
        return;
    }

    QElapsedTimer timer;
    timer.start();

    // 模拟 280ms 网络延迟
    QTimer::singleShot(280, this, [this, request, trimmed,
                                    callback, timer]() mutable {
        const qint64 elapsed = timer.elapsed() + 280;

        TranslateResult result;
        result.translatedText = QStringLiteral("[Mock Translation]\nEngine: %1\nFrom: %2\nTo: %3\n\n%4")
                                    .arg(m_currentEngine, request.fromLang,
                                         request.toLang, trimmed);
        result.detectedLang = request.fromLang == QStringLiteral("auto")
                                  ? QStringLiteral("en")
                                  : request.fromLang;
        result.engineId     = m_currentEngine;
        result.latencyMs    = static_cast<int>(elapsed);
        result.timestamp    = QDateTime::currentDateTime();
        result.cacheHit     = false;

        m_cacheHitRate = 0.0;  // mock 始终不命中

        TB_LOG_INFO(LogModule::Translate,
            "Mock translation done in {}ms | engine={} from={} to={}",
            elapsed, m_currentEngine.toStdString(),
            request.fromLang.toStdString(), request.toLang.toStdString());

        callback(Result<TranslateResult>::ok(std::move(result)));
    });
}

Result<TranslateResult>
MockTranslateService::translateSync(const TranslateRequest& request) {
    const QString trimmed = request.text.trimmed();
    if (trimmed.isEmpty()) {
        return Result<TranslateResult>::err(
            TB_MAKE_ERROR(ErrorCode::TranslateEmptyInput,
                          "Text cannot be empty"));
    }

    QElapsedTimer timer;
    timer.start();

    TranslateResult result;
    result.translatedText = QStringLiteral("[Mock Translation]\nEngine: %1\nFrom: %2\nTo: %3\n\n%4")
                                .arg(m_currentEngine, request.fromLang,
                                     request.toLang, trimmed);
    result.detectedLang = request.fromLang == QStringLiteral("auto")
                              ? QStringLiteral("en")
                              : request.fromLang;
    result.engineId     = m_currentEngine;
    result.latencyMs    = static_cast<int>(timer.elapsed());
    result.timestamp    = QDateTime::currentDateTime();
    result.cacheHit     = false;

    return Result<TranslateResult>::ok(std::move(result));
}

QList<TranslateEngineInfo> MockTranslateService::availableEngines() const {
    return {
        TranslateEngineInfo{
            .id        = QStringLiteral("mock-local"),
            .name      = QStringLiteral("Mock Local Engine"),
            .available = true,
        },
    };
}

void MockTranslateService::setCurrentEngine(const QString& engineId) {
    if (m_currentEngine != engineId) {
        m_currentEngine = engineId;
        TB_LOG_DEBUG(LogModule::Translate,
            "Mock engine switched to '{}'", engineId.toStdString());
    }
}

QString MockTranslateService::currentEngine() const {
    return m_currentEngine;
}

QStringList MockTranslateService::supportedLanguages() const {
    return {
        QStringLiteral("auto"),
        QStringLiteral("zh-CN"),
        QStringLiteral("en"),
        QStringLiteral("ja"),
        QStringLiteral("ko"),
    };
}

double MockTranslateService::cacheHitRate() const {
    return m_cacheHitRate;
}
