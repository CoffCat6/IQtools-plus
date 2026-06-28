# AI 服务开发实战指南

> 本文档以 AI 助手功能为例，讲解从 QML 用户操作到 OpenAI API 的完整数据流，
> 并手把手指导你实现真实的 OpenAI 对话服务。
>
> 更新日期：2025-06-23

---

## 目录

1. [与翻译引擎的差异](#1-与翻译引擎的差异)
2. [整体数据流全景图](#2-整体数据流全景图)
3. [逐层代码走读](#3-逐层代码走读)
4. [当前架构问题与修复方案](#4-当前架构问题与修复方案)
5. [如何实现 OpenAI 服务](#5-如何实现-openai-服务)
6. [实现流式响应（SSE）](#6-实现流式响应sse)
7. [测试策略](#7-测试策略)
8. [常见问题与注意事项](#8-常见问题与注意事项)

---

## 1. 与翻译引擎的差异

在开始之前，先理解 AI 服务和翻译服务的核心区别：

| 维度 | 翻译服务 | AI 服务 |
|------|---------|---------|
| **架构** | 多引擎（有道/DeepL/Google） | 单服务（OpenAI/兼容 API） |
| **请求模式** | 一问一答，无上下文 | 多轮对话，携带完整历史 |
| **响应模式** | 一次性返回完整结果 | 可流式（SSE）逐字返回 |
| **数据格式** | 简单的 text → text | JSON 数组（role/content） |
| **取消机制** | 无需取消 | 长响应需要支持取消 |
| **文件支持** | 无 | 可上传文件供 AI 分析 |

这些差异决定了 AI 服务的接口设计和实现策略与翻译服务不同。

---

## 2. 整体数据流全景图

```
用户操作 ──────────────────────────────────────────────────────────────────────

  ┌──────────────────────────────────────────────────────────────────────┐
  │  AIAssistantPage.qml                                                │
  │                                                                      │
  │  用户输入 "解释这段代码" → 点击"发送"按钮                             │
  │                                                                      │
  │  ⚠️ 当前实现问题：QML 自己管理 ListModel 和 Timer，                    │
  │     没有通过 ViewModel。详见第 4 节。                                  │
  └─────────────┬────────────────────────────────────────────────────────┘
                │
QML ↔ C++ 边界 ─┼────────────────────────────────────────────────────────────
                │
  ┌─────────────▼────────────────────────────────────────────────────────┐
  │  AIAssistantViewModel::sendMessage(message)                          │
  │  (src/viewmodels/AIAssistantViewModel.cpp:48)                        │
  │                                                                      │
  │  1. 添加 user 消息到 m_conversationHistory                           │
  │  2. emit conversationHistoryChanged()  →  QML 刷新列表               │
  │  3. setLoading(true)                                                  │
  │  4. service->sendMessageAsync(message, conversationHistory, callback)│
  │                        │                                             │
  │     [等待异步回调...]    │                                             │
  │                        │                                             │
  │  5. 回调触发时：                                                      │
  │     - 成功 → 添加 assistant 消息到历史                                │
  │            → emit messageReceived(response)                          │
  │     - 失败 → setLastError() + emit errorOccurred()                   │
  │     - 最终 → setLoading(false)                                       │
  └───────────────────────┼──────────────────────────────────────────────┘
                          │ C++ 接口调用
  ┌───────────────────────▼──────────────────────────────────────────────┐
  │  MockAIService::sendMessageAsync()                                    │
  │  (src/services/ai/MockAIService.cpp:15)                              │
  │                                                                      │
  │  当前实现：QTimer::singleShot(1000ms) → 返回随机预设回复              │
  │                                                                      │
  │  未来实现（OpenAIService）：                                          │
  │  ① 将 conversationHistory 转换为 OpenAI messages 格式                 │
  │  ② 如果有上传文件，将文件内容注入 system prompt                       │
  │  ③ HTTP POST → api.openai.com/v1/chat/completions                   │
  │  ④ 解析响应 → 返回 Result<QString>                                   │
  └──────────────────────────────────────────────────────────────────────┘

外部 API ──────────────────────────────────────────────────────────────────────

  ┌──────────────────────────────────────────────────────────────────────┐
  │  OpenAI Chat Completions API                                        │
  │                                                                      │
  │  POST https://api.openai.com/v1/chat/completions                    │
  │  {                                                                   │
  │    "model": "gpt-4o",                                                │
  │    "messages": [                                                     │
  │      {"role": "system", "content": "You are a helpful assistant."},  │
  │      {"role": "user",   "content": "Hello"},                        │
  │      {"role": "assistant", "content": "Hi! How can I help?"},       │
  │      {"role": "user",   "content": "解释这段代码"}                   │
  │    ],                                                                │
  │    "stream": false                                                   │
  │  }                                                                   │
  │                                                                      │
  │  Response:                                                           │
  │  {                                                                   │
  │    "choices": [{                                                     │
  │      "message": {"role": "assistant", "content": "..."},            │
  │      "finish_reason": "stop"                                        │
  │    }]                                                                │
  │  }                                                                   │
  └──────────────────────────────────────────────────────────────────────┘
```

### 对话历史数据结构

AI 服务的核心区别是**对话历史**。每条消息是一个 JSON 对象：

```json
[
  {"role": "user",      "content": "你好",           "timestamp": "14:30"},
  {"role": "assistant", "content": "你好！有什么可以帮你的？", "timestamp": "14:30"},
  {"role": "user",      "content": "解释一下 MVVM",  "timestamp": "14:31"}
]
```

这个数组在 ViewModel 中维护（`m_conversationHistory`），每次发请求时完整传给 Service。
Service 负责把它转换为 API 需要的格式。

---

## 3. 逐层代码走读

### 3.1 接口层 — IAIService.h

**文件：** `src/services/ai/IAIService.h`

```cpp
class IAIService {
public:
    using Ptr = std::shared_ptr<IAIService>;
    using MessageCallback = std::function<void(Result<QString>)>;

    virtual ~IAIService() = default;

    // 核心方法：异步发送消息
    // 参数 conversationHistory 是完整对话历史（包含刚添加的用户消息）
    // Service 需要自行从历史中构建 API 请求
    virtual void sendMessageAsync(const QString& message,
                                  const QJsonArray& conversationHistory,
                                  MessageCallback callback) = 0;

    // 同步发送（测试用）
    [[nodiscard]] virtual Result<QString>
    sendMessageSync(const QString& message) = 0;

    // 取消当前请求（用户点击"停止"时调用）
    virtual void cancelRequest() = 0;

    // 是否正在加载
    [[nodiscard]] virtual bool isLoading() const = 0;
};
```

**与翻译接口的关键差异：**
- 多了 `conversationHistory` 参数 — Service 需要理解对话上下文
- 多了 `cancelRequest()` — AI 响应可能很长，用户需要能中途取消
- 返回值是简单的 `QString` 而非结构体 — AI 的回复就是纯文本

### 3.2 Mock 实现 — MockAIService

**文件：** `src/services/ai/MockAIService.h/.cpp`

```cpp
class MockAIService final : public QObject, public IAIService {
    Q_OBJECT
    // ...
private:
    bool m_loading{false};
};
```

**sendMessageAsync 的实现逻辑：**

```
sendMessageAsync(message, conversationHistory, callback)
    │
    ├─ 文本为空？
    │   └─ YES → callback(Result::err(InvalidArgument))
    │
    └─ NO → m_loading = true
             QTimer::singleShot(1000ms, ...)
              │
              └─ m_loading = false
                 从预设回复中随机选一个
                 callback(Result::ok(response))
```

**注意：** Mock 完全忽略了 `conversationHistory` 参数。真实实现需要使用它。

### 3.3 ViewModel 层 — AIAssistantViewModel

**文件：** `src/viewmodels/AIAssistantViewModel.h/.cpp`

ViewModel 做了三件关键的事：

**① 维护对话历史（这是与翻译 ViewModel 最大的区别）：**

```cpp
// AIAssistantViewModel.cpp:48-97
void AIAssistantViewModel::sendMessage(const QString& message) {
    if (message.trimmed().isEmpty()) return;

    // 1. 先把用户消息加入历史
    QJsonObject userMessage;
    userMessage["role"]      = "user";
    userMessage["content"]   = message;
    userMessage["timestamp"] = QDateTime::currentDateTime().toString("hh:mm");

    m_conversationHistory.append(userMessage);
    emit conversationHistoryChanged();   // QML 立即显示用户消息

    // 2. 调用服务，传入完整历史
    auto svc = ensureService();
    svc->sendMessageAsync(message, m_conversationHistory,
        [this](Result<QString> result) {
            if (result.isErr()) {
                setLastError(QString::fromStdString(result.error().message));
                emit errorOccurred();
                return;
            }

            // 3. 把 AI 回复也加入历史
            const QString response = std::move(result).value();
            QJsonObject aiMessage;
            aiMessage["role"]      = "assistant";
            aiMessage["content"]   = response;
            aiMessage["timestamp"] = QDateTime::currentDateTime().toString("hh:mm");

            m_conversationHistory.append(aiMessage);
            emit conversationHistoryChanged();   // QML 显示 AI 回复
            emit messageReceived(response);
        });
}
```

**② 管理上传文件列表：**

```cpp
// AIAssistantViewModel.cpp:100-135
void AIAssistantViewModel::uploadFile(const QString& filePath) {
    QFileInfo fileInfo(filePath);
    if (!fileInfo.exists()) {
        setLastError("File not found: " + filePath);
        emit errorOccurred();
        return;
    }

    QJsonObject fileObj;
    fileObj["fileName"]   = fileInfo.fileName();
    fileObj["filePath"]   = filePath;
    fileObj["fileSize"]   = formatFileSize(fileInfo.size());
    fileObj["uploadTime"] = QDateTime::currentDateTime().toString("hh:mm");

    m_uploadedFiles.append(fileObj);
    emit uploadedFilesChanged();
    emit fileUploaded(fileInfo.fileName());
}
```

**③ 支持取消请求：**

```cpp
// AIAssistantViewModel.cpp:154-159
void AIAssistantViewModel::cancelRequest() {
    auto svc = ensureService();
    svc->cancelRequest();
    setLoading(false);
}
```

### 3.4 QML 层 — AIAssistantPage.qml

**文件：** `src/ui/pages/AIAssistantPage.qml`

**⚠️ 当前实现有架构问题（详见第 4 节）。** 这里先讲解理想的数据流：

**理想的数据绑定方式：**

```qml
// 对话列表应由 ViewModel 驱动
Repeater {
    model: root.viewModel.conversationHistory  // QJsonArray

    delegate: ColumnLayout {
        // 用户消息 - 右对齐
        Rectangle {
            visible: modelData.role === "user"
            // ...
            Text { text: modelData.content }
        }
        // AI 响应 - 左对齐
        Rectangle {
            visible: modelData.role === "assistant"
            // ...
            Text { text: modelData.content }
        }
    }
}

// 发送按钮应调用 ViewModel
AppButton {
    text: qsTr("发送")
    onClicked: {
        root.viewModel.sendMessage(messageInput.text)
        messageInput.text = ""
    }
}

// 加载状态应绑定 ViewModel
BusyIndicator {
    running: root.viewModel.isLoading
}
```

### 3.5 服务注入链路

与翻译服务完全相同的模式：

```
main.cpp
  │  appContext.registerService<IAIService>(std::make_shared<MockAIService>());
  │  appShellViewModel.setAppContext(&appContext);
  ▼
AppShellViewModel::setAppContext(ctx)
  │  auto aiSvc = ctx->getService<IAIService>();
  │  m_aiAssistantViewModel->injectService(aiSvc);
  ▼
AIAssistantViewModel::injectService(service)
  │  m_service = std::move(service);
  ▼
QML: AIAssistantPage { viewModel: root.viewModel.aiAssistantViewModel }
```

---

## 4. 当前架构问题与修复方案

### 4.1 问题描述

当前 `AIAssistantPage.qml` 存在两处违反 MVVM 架构的问题：

**问题 1：QML 自己管理对话列表，没有使用 ViewModel**

```qml
// ❌ 当前实现：QML 本地 ListModel
ListModel { id: conversationModel }

// 发送时直接 append 到本地 model
conversationModel.append({
    role: "user",
    content: messageInput.text,
    timestamp: new Date().toLocaleTimeString()
})

// AI 响应也由本地 Timer 生成
Timer {
    id: aiResponseTimer
    interval: 1000
    onTriggered: {
        conversationModel.append({
            role: "assistant",
            content: randomResponse,
            ...
        })
    }
}
```

这意味着 ViewModel 的 `sendMessage()`、`conversationHistory`、`isLoading` 全部没有被使用。

**问题 2：文件上传没有调用 ViewModel**

```qml
// ❌ 当前实现：直接操作本地 model
FileDialog {
    onAccepted: {
        uploadedFilesModel.append({...})
    }
}
```

`viewModel.uploadFile()` 和 `viewModel.uploadedFiles` 完全没有被使用。

### 4.2 修复方案

将 QML 改为纯 UI 层，所有数据和逻辑交给 ViewModel：

**Step 1：对话列表改为绑定 ViewModel**

```qml
// ✅ 修复后：绑定 ViewModel 的 conversationHistory
Repeater {
    model: root.viewModel.conversationHistory

    delegate: ColumnLayout {
        required property int index
        required property var modelData
        // ... 渲染逻辑不变
    }
}
```

**Step 2：发送按钮改为调用 ViewModel**

```qml
// ✅ 修复后
AppButton {
    text: root.viewModel.isLoading ? qsTr("停止") : qsTr("发送")
    onClicked: {
        if (root.viewModel.isLoading) {
            root.viewModel.cancelRequest()
        } else {
            root.viewModel.sendMessage(messageInput.text)
            messageInput.text = ""
        }
    }
}
```

**Step 3：文件上传改为调用 ViewModel**

```qml
// ✅ 修复后
FileDialog {
    onAccepted: {
        var filePath = selectedFile.toString().replace("file:///", "")
        root.viewModel.uploadFile(filePath)
    }
}

// 文件列表绑定 ViewModel
Repeater {
    model: root.viewModel.uploadedFiles
    // ...
}
```

**Step 4：监听 ViewModel 信号**

```qml
// ✅ 修复后
Connections {
    target: root.viewModel

    function onMessageReceived(response) {
        // 自动滚到底部
        conversationScroll.ScrollBar.vertical.position = 1
    }

    function onErrorOccurred() {
        if (root.toast) root.toast.show(root.viewModel.lastError, "error")
    }
}
```

**Step 5：删除本地 Timer 和 ListModel**

删除 `aiResponseTimer`、`conversationModel`、`uploadedFilesModel` 这些本地状态。

---

## 5. 如何实现 OpenAI 服务

### 5.1 目标

替换 MockAIService，实现真实的 OpenAI Chat Completions API 调用。

### 5.2 Step 1：创建 OpenAIService 头文件

**新建文件：** `src/services/ai/OpenAIService.h`

```cpp
// src/services/ai/OpenAIService.h
#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonArray>
#include <QJsonObject>
#include <memory>

#include "services/ai/IAIService.h"

/// OpenAI 兼容 API 服务实现
///
/// 支持：
/// - OpenAI 官方 API (api.openai.com)
/// - 任何 OpenAI 兼容 API（通过 baseUrl 配置）
/// - 多轮对话（携带完整 conversationHistory）
/// - 可取消的请求
///
/// 配置项：
///   apiKey    — API Key（必填）
///   baseUrl   — API 地址（默认 https://api.openai.com/v1）
///   model     — 模型名称（默认 gpt-4o）
///   systemPrompt — 系统提示词（可选）
///   maxTokens — 最大回复 token 数（默认 2048）
///   temperature — 温度参数（默认 0.7）
class OpenAIService final : public QObject, public IAIService {
    Q_OBJECT

public:
    struct Config {
        QString apiKey;
        QString baseUrl{QStringLiteral("https://api.openai.com/v1")};
        QString model{QStringLiteral("gpt-4o")};
        QString systemPrompt;
        int     maxTokens{2048};
        double  temperature{0.7};
    };

    explicit OpenAIService(Config config, QObject* parent = nullptr);
    ~OpenAIService() override = default;

    // ── IAIService ──────────────────────────────────────────────────────────
    void sendMessageAsync(const QString& message,
                          const QJsonArray& conversationHistory,
                          MessageCallback callback) override;

    [[nodiscard]] Result<QString>
    sendMessageSync(const QString& message) override;

    void cancelRequest() override;
    [[nodiscard]] bool isLoading() const override;

    // ── 运行时配置 ──────────────────────────────────────────────────────────
    void setSystemPrompt(const QString& prompt);
    void setModel(const QString& model);

private:
    /// 构建 OpenAI API 请求体
    [[nodiscard]] QJsonObject buildRequestBody(
        const QJsonArray& conversationHistory) const;

    /// 将内部消息格式转换为 OpenAI messages 数组
    [[nodiscard]] QJsonArray convertMessages(
        const QJsonArray& conversationHistory) const;

    /// 解析 OpenAI API 响应
    [[nodiscard]] Result<QString> parseResponse(
        const QByteArray& responseData) const;

    Config                  m_config;
    QNetworkAccessManager   m_network;
    QNetworkReply*          m_activeReply{nullptr};  // 当前活跃的请求（用于取消）
    bool                    m_loading{false};
};
```

### 5.3 Step 2：实现 OpenAIService

**新建文件：** `src/services/ai/OpenAIService.cpp`

```cpp
// src/services/ai/OpenAIService.cpp
#include "services/ai/OpenAIService.h"

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QElapsedTimer>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"

OpenAIService::OpenAIService(Config config, QObject* parent)
    : QObject(parent)
    , m_config(std::move(config)) {
    TB_LOG_INFO(LogModule::AI,
        "OpenAIService created | model={} baseUrl={} systemPrompt={}",
        m_config.model.toStdString(),
        m_config.baseUrl.toStdString(),
        m_config.systemPrompt.isEmpty() ? "(none)" : "(set)");
}

void OpenAIService::setSystemPrompt(const QString& prompt) {
    m_config.systemPrompt = prompt;
    TB_LOG_DEBUG(LogModule::AI, "System prompt updated | len={}", prompt.length());
}

void OpenAIService::setModel(const QString& model) {
    m_config.model = model;
    TB_LOG_DEBUG(LogModule::AI, "Model changed to '{}'", model.toStdString());
}

QJsonArray OpenAIService::convertMessages(
    const QJsonArray& conversationHistory) const {

    QJsonArray messages;

    // 1. 添加 system prompt（如果有）
    if (!m_config.systemPrompt.isEmpty()) {
        QJsonObject sysMsg;
        sysMsg[QStringLiteral("role")]    = QStringLiteral("system");
        sysMsg[QStringLiteral("content")] = m_config.systemPrompt;
        messages.append(sysMsg);
    }

    // 2. 遍历对话历史，提取 role 和 content
    for (const auto& item : conversationHistory) {
        const auto obj = item.toObject();
        const QString role = obj[QStringLiteral("role")].toString();

        // 只取 user 和 assistant 角色，跳过 timestamp 等附加字段
        if (role == QStringLiteral("user") ||
            role == QStringLiteral("assistant")) {
            QJsonObject msg;
            msg[QStringLiteral("role")]    = role;
            msg[QStringLiteral("content")] = obj[QStringLiteral("content")];
            messages.append(msg);
        }
    }

    return messages;
}

QJsonObject OpenAIService::buildRequestBody(
    const QJsonArray& conversationHistory) const {

    QJsonObject body;
    body[QStringLiteral("model")]       = m_config.model;
    body[QStringLiteral("messages")]    = convertMessages(conversationHistory);
    body[QStringLiteral("max_tokens")]  = m_config.maxTokens;
    body[QStringLiteral("temperature")] = m_config.temperature;
    body[QStringLiteral("stream")]      = false;  // 非流式，第 6 节讲解流式

    return body;
}

Result<QString> OpenAIService::parseResponse(
    const QByteArray& responseData) const {

    QJsonParseError parseErr;
    const auto doc = QJsonDocument::fromJson(responseData, &parseErr);
    if (parseErr.error != QJsonParseError::NoError) {
        return Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::NetworkError,
                          "Invalid JSON response from OpenAI API"));
    }

    const auto root = doc.object();

    // 检查 API 错误
    if (root.contains(QStringLiteral("error"))) {
        const auto errorObj = root[QStringLiteral("error")].toObject();
        const QString errMsg = errorObj[QStringLiteral("message")].toString();
        const QString errType = errorObj[QStringLiteral("type")].toString();

        TB_LOG_ERROR(LogModule::AI,
            "OpenAI API error | type={} message={}",
            errType.toStdString(), errMsg.toStdString());

        // 根据错误类型返回不同错误码
        if (errType == QStringLiteral("invalid_request_error") ||
            errType == QStringLiteral("authentication_error")) {
            return Result<QString>::err(
                TB_MAKE_ERROR(ErrorCode::TranslateAuthError,
                              errMsg.toStdString()));
        }

        return Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::NetworkError, errMsg.toStdString()));
    }

    // 解析正常响应
    const QJsonArray choices = root[QStringLiteral("choices")].toArray();
    if (choices.isEmpty()) {
        return Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::NetworkError,
                          "Empty choices in OpenAI response"));
    }

    const auto firstChoice = choices[0].toObject();
    const auto messageObj = firstChoice[QStringLiteral("message")].toObject();
    const QString content = messageObj[QStringLiteral("content")].toString();

    if (content.isEmpty()) {
        return Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::NetworkError,
                          "Empty content in OpenAI response"));
    }

    // 可选：记录 token 使用量
    if (root.contains(QStringLiteral("usage"))) {
        const auto usage = root[QStringLiteral("usage")].toObject();
        TB_LOG_DEBUG(LogModule::AI,
            "Token usage | prompt={} completion={} total={}",
            usage[QStringLiteral("prompt_tokens")].toInt(),
            usage[QStringLiteral("completion_tokens")].toInt(),
            usage[QStringLiteral("total_tokens")].toInt());
    }

    return Result<QString>::ok(content);
}

void OpenAIService::sendMessageAsync(const QString& message,
                                      const QJsonArray& conversationHistory,
                                      MessageCallback callback) {
    if (message.trimmed().isEmpty()) {
        callback(Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::InvalidArgument,
                          "Message cannot be empty")));
        return;
    }

    if (m_config.apiKey.isEmpty()) {
        callback(Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::TranslateAuthError,
                          "OpenAI API key not configured")));
        return;
    }

    // 取消之前的请求（如果有）
    if (m_activeReply) {
        m_activeReply->abort();
        m_activeReply->deleteLater();
        m_activeReply = nullptr;
    }

    m_loading = true;

    // 构建请求
    const QUrl url(m_config.baseUrl + QStringLiteral("/chat/completions"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      QStringLiteral("application/json"));
    request.setRawHeader("Authorization",
                         ("Bearer " + m_config.apiKey).toUtf8());

    const QJsonObject body = buildRequestBody(conversationHistory);
    const QByteArray bodyData = QJsonDocument(body).toJson(QJsonDocument::Compact);

    TB_LOG_DEBUG(LogModule::AI,
        "OpenAI request | model={} messages={} bodySize={}B",
        m_config.model.toStdString(),
        convertMessages(conversationHistory).size(),
        bodyData.size());

    QElapsedTimer timer;
    timer.start();

    m_activeReply = m_network.post(request, bodyData);

    QObject::connect(m_activeReply, &QNetworkReply::finished, this,
        [this, callback, timer]() {
            if (!m_activeReply) return;

            m_activeReply->deleteLater();
            const int latencyMs = static_cast<int>(timer.elapsed());

            // 检查是否被取消
            if (m_activeReply->error() == QNetworkReply::OperationCanceledError) {
                m_activeReply = nullptr;
                m_loading = false;
                callback(Result<QString>::err(
                    TB_MAKE_ERROR(ErrorCode::Cancelled,
                                  "Request cancelled by user")));
                TB_LOG_INFO(LogModule::AI, "OpenAI request cancelled | latency={}ms",
                    latencyMs);
                return;
            }

            // 检查网络错误
            if (m_activeReply->error() != QNetworkReply::NoError) {
                const QString errStr = m_activeReply->errorString();
                m_activeReply = nullptr;
                m_loading = false;

                TB_LOG_ERROR(LogModule::AI,
                    "OpenAI HTTP error | code={} msg={}",
                    static_cast<int>(m_activeReply->error()),
                    errStr.toStdString());

                callback(Result<QString>::err(
                    TB_MAKE_ERROR(ErrorCode::NetworkError,
                                  errStr.toStdString())));
                return;
            }

            // 解析响应
            auto result = parseResponse(m_activeReply->readAll());
            m_activeReply = nullptr;
            m_loading = false;

            if (result.isOk()) {
                TB_LOG_INFO(LogModule::AI,
                    "OpenAI response OK | latency={}ms responseLen={}",
                    latencyMs, result.value().length());
            }

            callback(std::move(result));
        });
}

Result<QString> OpenAIService::sendMessageSync(const QString& message) {
    if (message.trimmed().isEmpty()) {
        return Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::InvalidArgument,
                          "Message cannot be empty"));
    }

    if (m_config.apiKey.isEmpty()) {
        return Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::TranslateAuthError,
                          "OpenAI API key not configured"));
    }

    // 构建一个简单的单轮对话
    QJsonArray history;
    QJsonObject userMsg;
    userMsg[QStringLiteral("role")]    = QStringLiteral("user");
    userMsg[QStringLiteral("content")] = message;
    history.append(userMsg);

    const QUrl url(m_config.baseUrl + QStringLiteral("/chat/completions"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      QStringLiteral("application/json"));
    request.setRawHeader("Authorization",
                         ("Bearer " + m_config.apiKey).toUtf8());

    const QJsonObject body = buildRequestBody(history);
    QNetworkReply* reply = m_network.post(
        request, QJsonDocument(body).toJson(QJsonDocument::Compact));

    // 同步等待
    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError) {
        return Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::NetworkError,
                          reply->errorString().toStdString()));
    }

    return parseResponse(reply->readAll());
}

void OpenAIService::cancelRequest() {
    if (m_activeReply && m_loading) {
        m_activeReply->abort();
        TB_LOG_DEBUG(LogModule::AI, "Cancelling active OpenAI request");
    }
}

bool OpenAIService::isLoading() const {
    return m_loading;
}
```

### 5.4 Step 3：更新 CMake 构建

**修改文件：** `src/services/ai/CMakeLists.txt`

```cmake
add_library(iqtools_service_ai STATIC
    MockAIService.cpp
    OpenAIService.cpp          # ← 新增
)

target_include_directories(iqtools_service_ai
    PUBLIC
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_service_ai
    PUBLIC
        iqtools_core
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_service_ai
        PUBLIC
            Qt6::Core
            Qt6::Network       # ← 新增：HTTP 请求需要
    )
endif()

target_compile_features(iqtools_service_ai PUBLIC cxx_std_20)
```

### 5.5 Step 4：替换 main.cpp 中的注册

```cpp
// main.cpp
#include "services/ai/OpenAIService.h"

// ...

// 替换前：
appContext.registerService<IAIService>(std::make_shared<MockAIService>());

// 替换后：
OpenAIService::Config aiConfig;
aiConfig.apiKey       = QStringLiteral("sk-your-api-key-here");
aiConfig.baseUrl      = QStringLiteral("https://api.openai.com/v1");
aiConfig.model        = QStringLiteral("gpt-4o");
aiConfig.systemPrompt = QStringLiteral(
    "You are a helpful assistant in a desktop toolbox app called IQtools Plus. "
    "Respond concisely and helpfully in the user's language.");
aiConfig.maxTokens    = 2048;
aiConfig.temperature  = 0.7;

appContext.registerService<IAIService>(
    std::make_shared<OpenAIService>(aiConfig));
```

**兼容国内 API（如 DeepSeek、通义千问等）：** 只需修改 `baseUrl` 和 `model`：

```cpp
// DeepSeek
aiConfig.baseUrl = QStringLiteral("https://api.deepseek.com/v1");
aiConfig.model   = QStringLiteral("deepseek-chat");

// 通义千问
aiConfig.baseUrl = QStringLiteral("https://dashscope.aliyuncs.com/compatible-mode/v1");
aiConfig.model   = QStringLiteral("qwen-plus");
```

---

## 6. 实现流式响应（SSE）

### 6.1 为什么需要流式

OpenAI 的完整响应可能需要 5-30 秒。如果等全部完成再显示，用户会看到长时间的空白。

流式模式（Server-Sent Events）让 AI 的回复逐字出现，体验好得多：

```
非流式：用户等待 10 秒 → 一次性显示完整回复
流式：  用户等待 0.5 秒 → "你" → "好" → "，" → "我" → "是" → ...
```

### 6.2 接口扩展

首先在 IAIService 中添加流式回调：

```cpp
// src/services/ai/IAIService.h — 新增
class IAIService {
public:
    // 流式 token 回调：每个 token 到达时调用
    using StreamCallback = std::function<void(const QString& token)>;

    // 流式完成回调：全部完成时调用
    using StreamDoneCallback = std::function<void(Result<QString> fullResponse)>;

    // 新增：流式发送消息
    virtual void sendMessageStream(const QString& message,
                                   const QJsonArray& conversationHistory,
                                   StreamCallback     onToken,
                                   StreamDoneCallback onDone) = 0;
    // ...
};
```

### 6.3 ViewModel 扩展

```cpp
// AIAssistantViewModel.h — 新增
Q_INVOKABLE void sendMessageStream(const QString& message);

signals:
    void tokenReceived(const QString& token);      // 逐字到达
    void streamCompleted(const QString& fullText);  // 流式完成
```

```cpp
// AIAssistantViewModel.cpp
void AIAssistantViewModel::sendMessageStream(const QString& message) {
    if (message.trimmed().isEmpty()) return;

    // 添加用户消息到历史
    QJsonObject userMsg;
    userMsg["role"]      = "user";
    userMsg["content"]   = message;
    userMsg["timestamp"] = QDateTime::currentDateTime().toString("hh:mm");
    m_conversationHistory.append(userMsg);
    emit conversationHistoryChanged();

    setLoading(true);
    setLastError(QString());

    // 添加一个空的 assistant 消息占位（后续逐字填充）
    QJsonObject aiPlaceholder;
    aiPlaceholder["role"]      = "assistant";
    aiPlaceholder["content"]   = QString();
    aiPlaceholder["timestamp"] = QDateTime::currentDateTime().toString("hh:mm");
    m_conversationHistory.append(aiPlaceholder);

    auto svc = ensureService();
    int tokenCount = 0;

    svc->sendMessageStream(message, m_conversationHistory,
        // onToken：每个 token 到达时
        [this, &tokenCount](const QString& token) {
            tokenCount++;
            // 更新最后一条消息的内容
            auto lastMsg = m_conversationHistory.last().toObject();
            lastMsg["content"] = lastMsg["content"].toString() + token;
            m_conversationHistory[m_conversationHistory.size() - 1] = lastMsg;

            emit tokenReceived(token);
            emit conversationHistoryChanged();
        },
        // onDone：流式完成
        [this](Result<QString> fullResponse) {
            setLoading(false);
            if (fullResponse.isOk()) {
                emit streamCompleted(fullResponse.value());
            } else {
                setLastError(QString::fromStdString(fullResponse.error().message));
                emit errorOccurred();
            }
        }
    );
}
```

### 6.4 OpenAI SSE 实现

```cpp
// OpenAIService.h — 新增成员
void sendMessageStream(const QString& message,
                       const QJsonArray& conversationHistory,
                       StreamCallback     onToken,
                       StreamDoneCallback onDone) override;

// OpenAIService.cpp
void OpenAIService::sendMessageStream(const QString& message,
                                       const QJsonArray& conversationHistory,
                                       StreamCallback     onToken,
                                       StreamDoneCallback onDone) {
    if (message.trimmed().isEmpty()) {
        onDone(Result<QString>::err(
            TB_MAKE_ERROR(ErrorCode::InvalidArgument, "Message cannot be empty")));
        return;
    }

    m_loading = true;

    // 关键：设置 stream = true
    QJsonObject body = buildRequestBody(conversationHistory);
    body[QStringLiteral("stream")] = true;

    QUrl url(m_config.baseUrl + QStringLiteral("/chat/completions"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      QStringLiteral("application/json"));
    request.setRawHeader("Authorization",
                         ("Bearer " + m_config.apiKey).toUtf8());

    m_activeReply = m_network.post(
        request, QJsonDocument(body).toJson(QJsonDocument::Compact));

    QString fullResponse;

    // SSE 数据通过 readyRead 信号逐步到达
    QObject::connect(m_activeReply, &QNetworkReply::readyRead, this,
        [this, &fullResponse, onToken]() {
            if (!m_activeReply) return;

            // SSE 格式：每行以 "data: " 开头
            while (m_activeReply->canReadLine()) {
                QByteArray line = m_activeReply->readLine().trimmed();

                if (line.isEmpty()) continue;
                if (!line.startsWith("data: ")) continue;

                QByteArray data = line.mid(6);  // 去掉 "data: "

                // 流结束标记
                if (data == "[DONE]") continue;

                QJsonParseError err;
                auto doc = QJsonDocument::fromJson(data, &err);
                if (err.error != QJsonParseError::NoError) continue;

                auto root = doc.object();
                auto choices = root[QStringLiteral("choices")].toArray();
                if (choices.isEmpty()) continue;

                auto delta = choices[0].toObject()
                    [QStringLiteral("delta")].toObject();

                if (delta.contains(QStringLiteral("content"))) {
                    QString token = delta[QStringLiteral("content")].toString();
                    fullResponse += token;
                    onToken(token);
                }
            }
        });

    // 请求完成
    QObject::connect(m_activeReply, &QNetworkReply::finished, this,
        [this, &fullResponse, onDone]() {
            m_loading = false;
            m_activeReply->deleteLater();

            if (m_activeReply->error() == QNetworkReply::OperationCanceledError) {
                m_activeReply = nullptr;
                onDone(Result<QString>::err(
                    TB_MAKE_ERROR(ErrorCode::Cancelled, "Request cancelled")));
                return;
            }

            if (m_activeReply->error() != QNetworkReply::NoError) {
                QString errStr = m_activeReply->errorString();
                m_activeReply = nullptr;
                onDone(Result<QString>::err(
                    TB_MAKE_ERROR(ErrorCode::NetworkError, errStr.toStdString())));
                return;
            }

            m_activeReply = nullptr;
            onDone(Result<QString>::ok(fullResponse));
        });
}
```

### 6.5 QML 端流式渲染

```qml
// AIAssistantPage.qml — 流式模式
Connections {
    target: root.viewModel

    function onTokenReceived(token) {
        // 不需要额外操作，conversationHistoryChanged 已经触发 Repeater 刷新
        // 自动滚到底部
        conversationScroll.ScrollBar.vertical.position = 1
    }

    function onStreamCompleted(fullText) {
        if (root.toast) root.toast.show(qsTr("回复完成"), "success")
    }
}
```

---

## 7. 测试策略

### 7.1 ViewModel 单元测试

**新建文件：** `tests/unit/test_ai_assistant_viewmodel.cpp`

```cpp
#include <QtTest/QtTest>
#include <QSignalSpy>
#include <QJsonArray>

#include "viewmodels/AIAssistantViewModel.h"

class AIAssistantViewModelTest final : public QObject {
    Q_OBJECT

private slots:
    void shouldRejectEmptyMessage();
    void shouldAddUserMessageToHistory();
    void shouldReceiveAIResponse();
    void shouldTrackLoadingState();
    void shouldCancelRequest();
    void shouldUploadFile();
    void shouldClearConversation();
};

void AIAssistantViewModelTest::shouldRejectEmptyMessage() {
    AIAssistantViewModel vm;
    vm.sendMessage("   ");  // 空白消息
    QCOMPARE(vm.conversationHistory().size(), 0);  // 不应添加到历史
}

void AIAssistantViewModelTest::shouldAddUserMessageToHistory() {
    AIAssistantViewModel vm;
    QSignalSpy historySpy(&vm, &AIAssistantViewModel::conversationHistoryChanged);

    vm.sendMessage("Hello");

    QCOMPARE(historySpy.count(), 1);  // 第一次：用户消息
    QCOMPARE(vm.conversationHistory().size(), 1);

    auto msg = vm.conversationHistory()[0].toObject();
    QCOMPARE(msg["role"].toString(), QStringLiteral("user"));
    QCOMPARE(msg["content"].toString(), QStringLiteral("Hello"));
}

void AIAssistantViewModelTest::shouldReceiveAIResponse() {
    AIAssistantViewModel vm;
    QSignalSpy historySpy(&vm, &AIAssistantViewModel::conversationHistoryChanged);
    QSignalSpy receivedSpy(&vm, &AIAssistantViewModel::messageReceived);

    vm.sendMessage("Hello");

    // Mock 延迟 1000ms
    QTRY_COMPARE(historySpy.count(), 2);  // 第二次：AI 回复
    QCOMPARE(vm.conversationHistory().size(), 2);

    auto aiMsg = vm.conversationHistory()[1].toObject();
    QCOMPARE(aiMsg["role"].toString(), QStringLiteral("assistant"));
    QVERIFY(!aiMsg["content"].toString().isEmpty());
    QCOMPARE(receivedSpy.count(), 1);
}

void AIAssistantViewModelTest::shouldTrackLoadingState() {
    AIAssistantViewModel vm;
    QSignalSpy loadingSpy(&vm, &AIAssistantViewModel::isLoadingChanged);

    vm.sendMessage("Hello");
    QCOMPARE(vm.isLoading(), true);
    QCOMPARE(loadingSpy.count(), 1);

    // 等待 Mock 响应
    QTRY_COMPARE(vm.isLoading(), false);
    QCOMPARE(loadingSpy.count(), 2);
}

void AIAssistantViewModelTest::shouldCancelRequest() {
    AIAssistantViewModel vm;
    vm.sendMessage("Hello");
    QCOMPARE(vm.isLoading(), true);

    vm.cancelRequest();
    QCOMPARE(vm.isLoading(), false);
}

void AIAssistantViewModelTest::shouldUploadFile() {
    AIAssistantViewModel vm;
    QSignalSpy filesSpy(&vm, &AIAssistantViewModel::uploadedFilesChanged);

    // 需要一个真实存在的临时文件
    QTemporaryFile tmpFile;
    QVERIFY(tmpFile.open());
    tmpFile.write("test content");
    tmpFile.close();

    vm.uploadFile(tmpFile.fileName());

    QCOMPARE(filesSpy.count(), 1);
    QCOMPARE(vm.uploadedFiles().size(), 1);

    auto fileObj = vm.uploadedFiles()[0].toObject();
    QVERIFY(!fileObj["fileName"].toString().isEmpty());
}

void AIAssistantViewModelTest::shouldClearConversation() {
    AIAssistantViewModel vm;
    vm.sendMessage("Hello");

    QTRY_VERIFY(vm.conversationHistory().size() > 0);

    vm.clearConversation();
    QCOMPARE(vm.conversationHistory().size(), 0);
}

QTEST_MAIN(AIAssistantViewModelTest)
#include "test_ai_assistant_viewmodel.moc"
```

### 7.2 OpenAI 服务集成测试

**新建文件：** `tests/unit/test_openai_service.cpp`

```cpp
#include <QtTest/QtTest>
#include "services/ai/OpenAIService.h"

class OpenAIServiceTest final : public QObject {
    Q_OBJECT

private slots:
    void shouldBeUnavailableWithoutApiKey();
    void shouldRejectEmptyMessage();
    void shouldReturnResponseWithValidKey();  // 需要真实 API Key
};

void OpenAIServiceTest::shouldBeUnavailableWithoutApiKey() {
    OpenAIService::Config config;
    // apiKey 为空
    OpenAIService service(config);

    QCOMPARE(service.isLoading(), false);

    QSignalSpy finishedSpy;  // 需要通过 callback 验证
    service.sendMessageAsync("hello", QJsonArray(),
        [](Result<QString> result) {
            QVERIFY(result.isErr());
            QCOMPARE(result.error().code, ErrorCode::TranslateAuthError);
        });
}

void OpenAIServiceTest::shouldRejectEmptyMessage() {
    OpenAIService::Config config;
    config.apiKey = QStringLiteral("sk-test");
    OpenAIService service(config);

    service.sendMessageAsync("", QJsonArray(),
        [](Result<QString> result) {
            QVERIFY(result.isErr());
            QCOMPARE(result.error().code, ErrorCode::InvalidArgument);
        });
}

void OpenAIServiceTest::shouldReturnResponseWithValidKey() {
    const QString apiKey = qEnvironmentVariable("OPENAI_API_KEY");
    if (apiKey.isEmpty()) {
        QSKIP("OPENAI_API_KEY not set");
    }

    OpenAIService::Config config;
    config.apiKey = apiKey;
    config.model  = QStringLiteral("gpt-4o-mini");  // 用便宜的模型测试

    OpenAIService service(config);

    QJsonArray history;
    QJsonObject userMsg;
    userMsg["role"] = "user";
    userMsg["content"] = "Say 'test ok' in exactly two words.";
    history.append(userMsg);

    bool done = false;
    service.sendMessageAsync("Say 'test ok'", history,
        [&done](Result<QString> result) {
            QVERIFY(result.isOk());
            QVERIFY(!result.value().isEmpty());
            done = true;
        });

    QTRY_VERIFY(done);  // 等待异步回调
}

QTEST_MAIN(OpenAIServiceTest)
#include "test_openai_service.moc"
```

### 7.3 在 CMake 中注册测试

**修改文件：** `tests/unit/CMakeLists.txt`，追加：

```cmake
# AI ViewModel 测试
add_executable(test_ai_assistant_viewmodel
    test_ai_assistant_viewmodel.cpp
)
target_link_libraries(test_ai_assistant_viewmodel
    PRIVATE
        iqtools_viewmodels
        Qt6::Core
        Qt6::Gui
        Qt6::Test
)
add_test(NAME test_ai_assistant_viewmodel
    COMMAND $<TARGET_FILE:test_ai_assistant_viewmodel>)
iqtools_configure_test_runtime(test_ai_assistant_viewmodel)

# OpenAI 服务测试
add_executable(test_openai_service
    test_openai_service.cpp
)
target_link_libraries(test_openai_service
    PRIVATE
        iqtools_service_ai
        Qt6::Core
        Qt6::Test
)
add_test(NAME test_openai_service
    COMMAND $<TARGET_FILE:test_openai_service>)
iqtools_configure_test_runtime(test_openai_service)
```

---

## 8. 常见问题与注意事项

### 8.1 API Key 安全

```
❌ 错误做法：API Key 硬编码在源码中
   aiConfig.apiKey = "sk-abc123...";

✅ 正确做法：
   1. 从环境变量读取
      aiConfig.apiKey = qEnvironmentVariable("OPENAI_API_KEY");

   2. 从配置文件读取（加密存储）
      aiConfig.apiKey = configManager->getDecrypted("ai.apiKey");

   3. 在设置页面让用户输入，保存到本地配置
```

### 8.2 与翻译服务的对比总结

```
翻译服务的"引擎"概念：
  ┌─────────────────────────────────┐
  │  TranslateService (调度层)       │
  │    ├── YoudaoEngine             │
  │    ├── DeepLEngine              │
  │    └── GoogleEngine             │
  └─────────────────────────────────┘
  多个引擎，用户可切换，接口统一。

AI 服务没有"引擎"概念：
  ┌─────────────────────────────────┐
  │  OpenAIService                  │
  │    → 通过 baseUrl + model 配置  │
  │    → 同一个接口，不同参数        │
  └─────────────────────────────────┘
  一个服务，通过配置适配不同 API 提供商。
```

这是因为所有 LLM API 都遵循 OpenAI 的接口规范，不需要像翻译那样为每个引擎写单独的实现。

### 8.3 对话历史的内存管理

```
问题：长时间对话，history 会越来越大，最终超出模型的 context window。

解决方案（按优先级）：
1. 设置 maxTokens 限制回复长度
2. 限制 history 最大条数（如保留最近 50 条）
3. 当 history 超过阈值时，丢弃最早的非 system 消息
4. （高级）对旧消息做摘要压缩

实现示例：
QJsonArray trimmedHistory(const QJsonArray& history, int maxMessages = 50) {
    if (history.size() <= maxMessages) return history;
    // 保留最近的 maxMessages 条
    QJsonArray result;
    for (int i = history.size() - maxMessages; i < history.size(); ++i) {
        result.append(history[i]);
    }
    return result;
}
```

### 8.4 实现清单

```
基础实现：
□ 1. 创建 OpenAIService.h/.cpp
□ 2. 更新 src/services/ai/CMakeLists.txt
□ 3. 在 main.cpp 中替换 MockAIService
□ 4. 修复 AIAssistantPage.qml 的 MVVM 违规问题

进阶：
□ 5. 实现流式响应（SSE）
□ 6. 添加 API Key 设置 UI（在设置页面）
□ 7. 对话历史截断/压缩策略
□ 8. 支持文件内容注入 prompt

测试：
□ 9. 编写 AI ViewModel 单元测试
□ 10. 编写 OpenAI 服务集成测试
```

---

## 附录：关键文件索引

| 你想了解 | 文件路径 |
|---------|---------|
| AI 服务接口 | `src/services/ai/IAIService.h` |
| Mock 实现 | `src/services/ai/MockAIService.h/.cpp` |
| ViewModel | `src/viewmodels/AIAssistantViewModel.h/.cpp` |
| QML 页面 | `src/ui/pages/AIAssistantPage.qml` |
| 日志模块 | `src/core/log/LogModules.h`（`LogModule::AI`） |
| 错误处理 | `src/core/error/Error.h` |
| 服务注入 | `src/viewmodels/AppShellViewModel.cpp` (L77-84) |
| main 入口 | `src/main.cpp` |
| 构建配置 | `src/services/ai/CMakeLists.txt` |
| 单元测试模板 | `tests/unit/test_translate_viewmodel.cpp`（参考模式） |
