// src/viewmodels/AIAssistantViewModel.h
#pragma once

#include <QtQml/qqmlregistration.h>

#include <QObject>
#include <QString>
#include <QList>
#include <QJsonObject>
#include <QJsonArray>
#include <memory>

#include "services/ai/IAIService.h"

/**
 * @brief AI 助手页面 ViewModel
 *
 * 通过注入的 IAIService 与 AI 后端通信，不包含业务逻辑。
 * 管理对话历史和已上传文件列表。
 * 若未注入服务，延迟创建 MockAIService（兼容 QML_ELEMENT / 测试）。
 */
class AIAssistantViewModel final : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // 当前对话消息列表
    Q_PROPERTY(QJsonArray conversationHistory READ conversationHistory
                   NOTIFY conversationHistoryChanged FINAL)

    // 已上传文件列表
    Q_PROPERTY(QJsonArray uploadedFiles READ uploadedFiles
                   NOTIFY uploadedFilesChanged FINAL)

    // 是否正在加载 AI 响应
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged FINAL)

    // 最后一条错误信息
    Q_PROPERTY(QString lastError READ lastError NOTIFY errorOccurred FINAL)

public:
    explicit AIAssistantViewModel(QObject* parent = nullptr);
    ~AIAssistantViewModel() override = default;

    /// 注入 AI 服务（由 AppShellViewModel 在构造后调用）
    void injectService(IAIService::Ptr service);

    [[nodiscard]] QJsonArray conversationHistory() const noexcept;
    [[nodiscard]] QJsonArray uploadedFiles() const noexcept;
    [[nodiscard]] bool isLoading() const noexcept;
    [[nodiscard]] QString lastError() const noexcept;

    Q_INVOKABLE void sendMessage(const QString& message);
    Q_INVOKABLE void uploadFile(const QString& filePath);
    Q_INVOKABLE void clearConversation();
    Q_INVOKABLE void removeFile(const QString& fileName);
    Q_INVOKABLE void cancelRequest();

signals:
    void conversationHistoryChanged();
    void uploadedFilesChanged();
    void isLoadingChanged();
    void errorOccurred();
    void messageReceived(const QString& message);
    void fileUploaded(const QString& fileName);

private:
    /// 确保服务可用：若未注入则延迟创建 MockAIService
    [[nodiscard]] IAIService::Ptr ensureService();

    void setLastError(const QString& error);
    void setLoading(bool loading);

    IAIService::Ptr m_service;
    QJsonArray m_conversationHistory;
    QJsonArray m_uploadedFiles;
    bool m_isLoading{false};
    QString m_lastError;
};
