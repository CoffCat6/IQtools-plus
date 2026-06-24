// src/services/ai/IAIService.h
#pragma once

#include <QObject>
#include <QString>
#include <QJsonArray>
#include <functional>
#include <memory>

#include "core/error/Error.h"

/// AI 服务抽象接口
///
/// ViewModel 通过此接口与 AI 后端通信，不关心具体实现。
/// 实现类：MockAIService（开发阶段）、OpenAIService（未来）。
class IAIService {
public:
    using Ptr = std::shared_ptr<IAIService>;

    /// 异步消息回调：成功返回 AI 回复文本，失败返回错误
    using MessageCallback = std::function<void(Result<QString>)>;

    virtual ~IAIService() = default;

    /// 异步发送消息（回调在调用线程或内部线程中执行）
    virtual void sendMessageAsync(const QString& message,
                                  const QJsonArray& conversationHistory,
                                  MessageCallback callback) = 0;

    /// 同步发送消息（供测试使用）
    [[nodiscard]] virtual Result<QString>
    sendMessageSync(const QString& message) = 0;

    /// 取消当前进行中的请求
    virtual void cancelRequest() = 0;

    /// 检查是否有请求正在进行
    [[nodiscard]] virtual bool isLoading() const = 0;
};
