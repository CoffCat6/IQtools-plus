//src/viewmodels/AIAssistantViewModel.cpp

#include "AIAssistantViewModel.h"
#include <QJsonDocument>
#include <QFile>
#include <QFileInfo>
#include <QTimer>
#include <QDateTime>
#include <QRandomGenerator>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"

AIAssistantViewModel::AIAssistantViewModel(QObject* parent)
    : QObject(parent)
    , m_isLoading(false)
{
    // 初始化对话历史为空
    m_conversationHistory = QJsonArray();
    m_uploadedFiles = QJsonArray();
    TB_LOG_INFO(LogModule::Plugin, "AIAssistantViewModel initialized");
}

QJsonArray AIAssistantViewModel::conversationHistory() const noexcept
{
    return m_conversationHistory;
}

QJsonArray AIAssistantViewModel::uploadedFiles() const noexcept
{
    return m_uploadedFiles;
}

bool AIAssistantViewModel::isLoading() const noexcept
{
    return m_isLoading;
}

QString AIAssistantViewModel::lastError() const noexcept
{
    return m_lastError;
}

void AIAssistantViewModel::sendMessage(const QString& message)
{
    if (message.trimmed().isEmpty()) {
        return;
    }

    TB_LOG_DEBUG(LogModule::Plugin, "AI sendMessage | len={} preview='{}'",
        message.length(), message.left(50).toStdString());

    // 添加用户消息到历史
    QJsonObject userMessage;
    userMessage["role"] = "user";
    userMessage["content"] = message;
    userMessage["timestamp"] = QDateTime::currentDateTime().toString("hh:mm");
    
    m_conversationHistory.append(userMessage);
    emit conversationHistoryChanged();

    // 设置加载状态
    m_isLoading = true;
    emit isLoadingChanged();

    // 延迟模拟 AI 响应
    QTimer::singleShot(1000, this, [this, message]() {
        simulateAIResponse(message);
    });
}

void AIAssistantViewModel::uploadFile(const QString& filePath)
{
    QFileInfo fileInfo(filePath);

    if (!fileInfo.exists()) {
        m_lastError = "File not found: " + filePath;
        emit errorOccurred();
        TB_LOG_WARN(LogModule::Plugin, "File upload failed: not found | path='{}'", filePath.toStdString());
        return;
    }

    // 计算文件大小
    auto bytes = fileInfo.size();
    QString sizeStr;
    if (bytes < 1024) {
        sizeStr = QString::number(bytes) + " B";
    } else if (bytes < 1024 * 1024) {
        sizeStr = QString::number(bytes / 1024.0, 'f', 1) + " KB";
    } else {
        sizeStr = QString::number(bytes / (1024.0 * 1024.0), 'f', 1) + " MB";
    }

    // 添加到已上传文件列表
    QJsonObject fileObj;
    fileObj["fileName"] = fileInfo.fileName();
    fileObj["filePath"] = filePath;
    fileObj["fileSize"] = sizeStr;
    fileObj["uploadTime"] = QDateTime::currentDateTime().toString("hh:mm");
    
    m_uploadedFiles.append(fileObj);
    emit uploadedFilesChanged();
    emit fileUploaded(fileInfo.fileName());

    TB_LOG_INFO(LogModule::Plugin, "File uploaded | name='{}' size={}",
        fileInfo.fileName().toStdString(), sizeStr.toStdString());
}

void AIAssistantViewModel::clearConversation()
{
    const int count = m_conversationHistory.size();
    m_conversationHistory = QJsonArray();
    emit conversationHistoryChanged();
    TB_LOG_DEBUG(LogModule::Plugin, "Conversation cleared | removed {} messages", count);
}

void AIAssistantViewModel::removeFile(const QString& fileName)
{
    for (int i = 0; i < m_uploadedFiles.size(); ++i) {
        if (m_uploadedFiles[i].toObject()["fileName"].toString() == fileName) {
            m_uploadedFiles.removeAt(i);
            emit uploadedFilesChanged();
            break;
        }
    }
}

void AIAssistantViewModel::cancelRequest()
{
    if (m_isLoading) {
        m_isLoading = false;
        emit isLoadingChanged();
        TB_LOG_DEBUG(LogModule::Plugin, "AI request cancelled");
    }
}

void AIAssistantViewModel::simulateAIResponse(const QString& userMessage)
{
    // 这是一个模拟响应，后期应该替换为真实的 API 调用
    // 例如：调用 OpenAI API、LangChain Agent 等
    
    QStringList responses = {
        "这是一个很好的问题。根据您的输入，我的分析如下：\n1. 首先，理解问题的核心需求\n2. 然后，设计合适的解决方案\n3. 最后，实施并验证结果",
        "根据上下文，我建议采取以下步骤：\n• 分析当前状态\n• 识别关键问题\n• 实施改进措施\n• 跟踪改进效果",
        "这涉及到几个重要的方面。让我为您详细解释：\n首先是理论基础...其次是实践应用...最后是常见注意事项...",
        "有趣的观点！我来补充一些见解：\n从技术角度看...从业务角度看...从用户体验角度看...",
        "这个问题很常见。常见的解决方案包括：\n方案A: 优点是... 缺点是...\n方案B: 优点是... 缺点是...\n方案C: 优点是... 缺点是..."
    };

    // 随机选择一个响应
    int randomIndex = QRandomGenerator::global()->bounded(responses.size());
    QString response = responses[randomIndex];

    // 添加 AI 响应到历史
    QJsonObject aiMessage;
    aiMessage["role"] = "assistant";
    aiMessage["content"] = response;
    aiMessage["timestamp"] = QDateTime::currentDateTime().toString("hh:mm");
    
    m_conversationHistory.append(aiMessage);
    emit conversationHistoryChanged();
    emit messageReceived(response);

    // 关闭加载状态
    m_isLoading = false;
    emit isLoadingChanged();

    TB_LOG_DEBUG(LogModule::Plugin, "AI mock response generated | responseLen={}", response.length());
}
