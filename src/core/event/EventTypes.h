// src/core/event/EventTypes.h
#pragma once

#include <QString>
#include <cstdint>

/// EventBus 使用的事件类型定义
///
/// 每个事件类型是一个 plain struct，通过 EventBus::publish<T>() 发布，
/// 通过 EventBus::subscribe<T>() 订阅。类型由 type_index 自动区分。

/// 翻译完成事件
struct TranslateCompletedEvent {
    QString result;
    QString engineId;
    int     latencyMs{0};
};

/// 翻译失败事件
struct TranslateFailedEvent {
    QString reason;
};

/// 剪贴板内容变化事件
struct ClipboardChangedEvent {
    QString preview;
    int     contentType{0};  // ClipboardContentType enum value
};

/// 截图完成事件
struct ScreenshotCapturedEvent {
    QString filePath;
    int     width{0};
    int     height{0};
};

/// 插件加载事件
struct PluginLoadedEvent {
    QString pluginId;
    QString pluginName;
};

/// 配置变更事件
struct ConfigChangedEvent {
    QString section;  // 变更的配置段名（如 "translate", "screenshot"）
};
