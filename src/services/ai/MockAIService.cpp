// src/services/ai/MockAIService.cpp
#include "services/ai/MockAIService.h"

#include <QTimer>
#include <QRandomGenerator>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"

MockAIService::MockAIService(QObject* parent)
    : QObject(parent) {
    TB_LOG_INFO(LogModule::AI, "MockAIService initialized");
}

void MockAIService::sendMessageAsync(const QString& message,
                                      const QJsonArray& /*conversationHistory*/,
                                      MessageCallback callback) {
    if (message.trimmed().isEmpty()) {
        callback(Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::InvalidArgument, "Message cannot be empty")));
        return;
    }

    m_loading = true;

    TB_LOG_DEBUG(LogModule::AI, "Mock sendMessage | len={} preview='{}'",
        message.length(), message.left(50).toStdString());

    // 模拟 1000ms AI 响应延迟
    QTimer::singleShot(1000, this, [this, callback, message]() {
        m_loading = false;

        const QStringList responses = {
            QStringLiteral("这是一个很好的问题。根据您的输入，我的分析如下：\n1. 首先，理解问题的核心需求\n2. 然后，设计合适的解决方案\n3. 最后，实施并验证结果"),
            QStringLiteral("根据上下文，我建议采取以下步骤：\n• 分析当前状态\n• 识别关键问题\n• 实施改进措施\n• 跟踪改进效果"),
            QStringLiteral("这涉及到几个重要的方面。让我为您详细解释：\n首先是理论基础...其次是实践应用...最后是常见注意事项..."),
            QStringLiteral("有趣的观点！我来补充一些见解：\n从技术角度看...从业务角度看...从用户体验角度看..."),
            QStringLiteral("这个问题很常见。常见的解决方案包括：\n方案A: 优点是... 缺点是...\n方案B: 优点是... 缺点是...\n方案C: 优点是... 缺点是..."),
        };

        const int idx = QRandomGenerator::global()->bounded(responses.size());
        const QString response = responses[idx];

        TB_LOG_DEBUG(LogModule::AI, "Mock response generated | responseLen={}",
            response.length());

        callback(Result<QString>::ok(response));
    });
}

Result<QString> MockAIService::sendMessageSync(const QString& message) {
    if (message.trimmed().isEmpty()) {
        return Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::InvalidArgument, "Message cannot be empty"));
    }

    return Result<QString>::ok(
        QStringLiteral("[Mock AI Response]\nYou said: %1").arg(message));
}

void MockAIService::cancelRequest() {
    if (m_loading) {
        m_loading = false;
        TB_LOG_DEBUG(LogModule::AI, "Mock AI request cancelled");
    }
}

bool MockAIService::isLoading() const {
    return m_loading;
}
