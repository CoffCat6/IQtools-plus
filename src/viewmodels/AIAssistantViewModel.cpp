// src/viewmodels/AIAssistantViewModel.cpp
#include "viewmodels/AIAssistantViewModel.h"

#include <QJsonDocument>
#include <QFile>
#include <QFileInfo>
#include <QDateTime>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"
#include "services/ai/MockAIService.h"

AIAssistantViewModel::AIAssistantViewModel(QObject* parent)
    : QObject(parent) {
    TB_LOG_INFO(LogModule::AI, "AIAssistantViewModel initialized");
}

void AIAssistantViewModel::injectService(IAIService::Ptr service) {
    m_service = std::move(service);
    TB_LOG_DEBUG(LogModule::AI, "AI service injected");
}

IAIService::Ptr AIAssistantViewModel::ensureService() {
    if (!m_service) {
        m_service = std::make_shared<MockAIService>();
        TB_LOG_DEBUG(LogModule::AI,
            "Lazy-created MockAIService (no injection)");
    }
    return m_service;
}

QJsonArray AIAssistantViewModel::conversationHistory() const noexcept {
    return m_conversationHistory;
}

QJsonArray AIAssistantViewModel::uploadedFiles() const noexcept {
    return m_uploadedFiles;
}

bool AIAssistantViewModel::isLoading() const noexcept {
    return m_isLoading;
}

QString AIAssistantViewModel::lastError() const noexcept {
    return m_lastError;
}

void AIAssistantViewModel::sendMessage(const QString& message) {
    if (message.trimmed().isEmpty()) {
        return;
    }

    TB_LOG_DEBUG(LogModule::AI, "sendMessage | len={} preview='{}'",
        message.length(), message.left(50).toStdString());

    // 添加用户消息到历史
    QJsonObject userMessage;
    userMessage[QStringLiteral("role")] = QStringLiteral("user");
    userMessage[QStringLiteral("content")] = message;
    userMessage[QStringLiteral("timestamp")] =
        QDateTime::currentDateTime().toString(QStringLiteral("hh:mm"));

    m_conversationHistory.append(userMessage);
    emit conversationHistoryChanged();

    setLoading(true);
    setLastError(QString());

    auto svc = ensureService();
    svc->sendMessageAsync(message, m_conversationHistory,
        [this](Result<QString> result) {
            setLoading(false);

            if (result.isErr()) {
                setLastError(QString::fromStdString(result.error().message));
                emit errorOccurred();
                TB_LOG_WARN(LogModule::AI, "AI request failed: {}",
                    result.error().message);
                return;
            }

            const QString response = std::move(result).value();

            // 添加 AI 响应到历史
            QJsonObject aiMessage;
            aiMessage[QStringLiteral("role")] = QStringLiteral("assistant");
            aiMessage[QStringLiteral("content")] = response;
            aiMessage[QStringLiteral("timestamp")] =
                QDateTime::currentDateTime().toString(QStringLiteral("hh:mm"));

            m_conversationHistory.append(aiMessage);
            emit conversationHistoryChanged();
            emit messageReceived(response);

            TB_LOG_DEBUG(LogModule::AI,
                "AI response received | responseLen={}", response.length());
        });
}

void AIAssistantViewModel::uploadFile(const QString& filePath) {
    const QFileInfo fileInfo(filePath);

    if (!fileInfo.exists()) {
        setLastError(QStringLiteral("File not found: ") + filePath);
        emit errorOccurred();
        TB_LOG_WARN(LogModule::AI, "File upload failed: not found | path='{}'",
            filePath.toStdString());
        return;
    }

    // 计算文件大小
    const auto bytes = fileInfo.size();
    QString sizeStr;
    if (bytes < 1024) {
        sizeStr = QString::number(bytes) + QStringLiteral(" B");
    } else if (bytes < 1024 * 1024) {
        sizeStr = QString::number(bytes / 1024.0, 'f', 1) + QStringLiteral(" KB");
    } else {
        sizeStr = QString::number(bytes / (1024.0 * 1024.0), 'f', 1) + QStringLiteral(" MB");
    }

    QJsonObject fileObj;
    fileObj[QStringLiteral("fileName")]   = fileInfo.fileName();
    fileObj[QStringLiteral("filePath")]   = filePath;
    fileObj[QStringLiteral("fileSize")]   = sizeStr;
    fileObj[QStringLiteral("uploadTime")] =
        QDateTime::currentDateTime().toString(QStringLiteral("hh:mm"));

    m_uploadedFiles.append(fileObj);
    emit uploadedFilesChanged();
    emit fileUploaded(fileInfo.fileName());

    TB_LOG_INFO(LogModule::AI, "File uploaded | name='{}' size={}",
        fileInfo.fileName().toStdString(), sizeStr.toStdString());
}

void AIAssistantViewModel::clearConversation() {
    const int count = m_conversationHistory.size();
    m_conversationHistory = QJsonArray();
    emit conversationHistoryChanged();
    TB_LOG_DEBUG(LogModule::AI, "Conversation cleared | removed {} messages", count);
}

void AIAssistantViewModel::removeFile(const QString& fileName) {
    for (int i = 0; i < m_uploadedFiles.size(); ++i) {
        if (m_uploadedFiles[i].toObject()[QStringLiteral("fileName")].toString() == fileName) {
            m_uploadedFiles.removeAt(i);
            emit uploadedFilesChanged();
            break;
        }
    }
}

void AIAssistantViewModel::cancelRequest() {
    auto svc = ensureService();
    svc->cancelRequest();
    setLoading(false);
    TB_LOG_DEBUG(LogModule::AI, "AI request cancelled");
}

void AIAssistantViewModel::setLastError(const QString& error) {
    if (m_lastError != error) {
        m_lastError = error;
    }
}

void AIAssistantViewModel::setLoading(bool loading) {
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}
