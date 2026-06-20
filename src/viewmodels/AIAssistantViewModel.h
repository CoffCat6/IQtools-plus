//src/viewmodels/AIAssistantViewModel.h

#pragma once

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QString>
#include <QList>
#include <QJsonObject>
#include <QJsonArray>

class AIAssistantViewModel final : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // 当前对话消息列表
    Q_PROPERTY(QJsonArray conversationHistory READ conversationHistory NOTIFY conversationHistoryChanged FINAL)

    // 已上传文件列表
    Q_PROPERTY(QJsonArray uploadedFiles READ uploadedFiles NOTIFY uploadedFilesChanged FINAL)

    // 是否正在加载 AI 响应
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged FINAL)

    // 最后一条错误信息
    Q_PROPERTY(QString lastError READ lastError NOTIFY errorOccurred FINAL)

public:
    explicit AIAssistantViewModel(QObject* parent = nullptr);
    ~AIAssistantViewModel() override = default;

    [[nodiscard]] QJsonArray conversationHistory() const noexcept;
    [[nodiscard]] QJsonArray uploadedFiles() const noexcept;
    [[nodiscard]] bool isLoading() const noexcept;
    [[nodiscard]] QString lastError() const noexcept;

    // 发送消息给 AI（后期接入真实 API）
    Q_INVOKABLE void sendMessage(const QString& message);

    // 上传文件
    Q_INVOKABLE void uploadFile(const QString& filePath);

    // 清空对话历史
    Q_INVOKABLE void clearConversation();

    // 删除特定文件
    Q_INVOKABLE void removeFile(const QString& fileName);

    // 取消当前 AI 请求
    Q_INVOKABLE void cancelRequest();

signals:
    void conversationHistoryChanged();
    void uploadedFilesChanged();
    void isLoadingChanged();
    void errorOccurred();
    void messageReceived(const QString& message);
    void fileUploaded(const QString& fileName);

private:
    // 模拟生成 AI 响应（后期替换为真实 API 调用）
    void simulateAIResponse(const QString& userMessage);

    QJsonArray m_conversationHistory;
    QJsonArray m_uploadedFiles;
    bool m_isLoading{false};
    QString m_lastError;
};
