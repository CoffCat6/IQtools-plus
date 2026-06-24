// src/services/ai/MockAIService.h
#pragma once

#include <QObject>
#include <QString>

#include "services/ai/IAIService.h"

/// AI 服务的 Mock 实现（开发阶段联调用）
///
/// 模拟 1000ms 延迟后返回随机响应。
/// 未来替换为真实 API 实现时，ViewModel 无需改动。
class MockAIService final : public QObject, public IAIService {
    Q_OBJECT

public:
    explicit MockAIService(QObject* parent = nullptr);
    ~MockAIService() override = default;

    // ── IAIService ──────────────────────────────────────────────────────────
    void sendMessageAsync(const QString& message,
                          const QJsonArray& conversationHistory,
                          MessageCallback callback) override;

    [[nodiscard]] Result<QString>
    sendMessageSync(const QString& message) override;

    void cancelRequest() override;
    [[nodiscard]] bool isLoading() const override;

private:
    bool m_loading{false};
};
