// src/services/translate/MockTranslateService.h
#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

#include "services/translate/ITranslateService.h"

/// 翻译服务的 Mock 实现（开发阶段联调用）
///
/// 模拟 280ms 延迟后返回格式化的 mock 文本。
/// 未来替换为真实引擎实现时，ViewModel 无需改动。
class MockTranslateService final : public QObject, public ITranslateService {
    Q_OBJECT

public:
    explicit MockTranslateService(QObject* parent = nullptr);
    ~MockTranslateService() override = default;

    // ── ITranslateService ──────────────────────────────────────────────────
    void translateAsync(const TranslateRequest& request,
                        TranslateCallback       callback) override;

    [[nodiscard]] Result<TranslateResult>
    translateSync(const TranslateRequest& request) override;

    [[nodiscard]] QList<TranslateEngineInfo> availableEngines() const override;
    void setCurrentEngine(const QString& engineId) override;
    [[nodiscard]] QString currentEngine() const override;
    [[nodiscard]] QStringList supportedLanguages() const override;
    [[nodiscard]] double cacheHitRate() const override;

private:
    QString m_currentEngine{QStringLiteral("mock-local")};
    double  m_cacheHitRate{0.0};
};
