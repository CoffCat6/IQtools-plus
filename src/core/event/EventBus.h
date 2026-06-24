// src/core/event/EventBus.h
#pragma once

#include <any>
#include <functional>
#include <memory>
#include <mutex>
#include <typeindex>
#include <unordered_map>
#include <vector>

/// 全局类型化事件总线
///
/// 提供类型安全的发布/订阅机制，用于跨模块解耦通信。
/// 线程安全：publish/subscribe/unsubscribe 均可从任意线程调用。
///
/// 用法：
/// @code
/// #include "core/event/EventBus.h"
/// #include "core/event/EventTypes.h"
///
/// // 订阅
/// int subId = EventBus::instance().subscribe<TranslateCompletedEvent>(
///     [](const TranslateCompletedEvent& e) {
///         qDebug() << "Translated:" << e.result;
///     });
///
/// // 发布
/// EventBus::instance().publish(TranslateCompletedEvent{
///     .result = "Hello", .engineId = "mock", .latencyMs = 100
/// });
///
/// // 取消订阅
/// EventBus::instance().unsubscribe(subId);
/// @endcode
///
/// 注意：回调在发布者的线程中执行。跨线程通信需调用方自行处理
/// （如使用 QMetaObject::invokeMethod 或 Qt::QueuedConnection）。
class EventBus {
public:
    static EventBus& instance();

    /// 订阅指定类型的事件
    /// @return 订阅 ID，用于后续 unsubscribe
    template <typename EventT>
    int subscribe(std::function<void(const EventT&)> handler) {
        std::lock_guard<std::mutex> lock(m_mutex);
        const int id = m_nextId++;
        auto sub = std::make_shared<TypedSubscription<EventT>>(std::move(handler));
        m_subscriptions[std::type_index(typeid(EventT))].emplace_back(id, std::move(sub));
        return id;
    }

    /// 发布事件，通知所有该类型的订阅者
    template <typename EventT>
    void publish(const EventT& event) {
        std::vector<std::pair<int, std::shared_ptr<SubscriptionBase>>> handlers;
        {
            std::lock_guard<std::mutex> lock(m_mutex);
            auto it = m_subscriptions.find(std::type_index(typeid(EventT)));
            if (it == m_subscriptions.end()) return;
            handlers = it->second;  // 复制，在锁外调用
        }
        for (const auto& [id, sub] : handlers) {
            static_cast<TypedSubscription<EventT>*>(sub.get())->handler(event);
        }
    }

    /// 取消订阅
    void unsubscribe(int subscriptionId);

    /// 清除所有订阅（用于测试或重置）
    void clear();

private:
    EventBus() = default;
    EventBus(const EventBus&) = delete;
    EventBus& operator=(const EventBus&) = delete;

    struct SubscriptionBase { virtual ~SubscriptionBase() = default; };

    template <typename EventT>
    struct TypedSubscription : SubscriptionBase {
        std::function<void(const EventT&)> handler;
        explicit TypedSubscription(std::function<void(const EventT&)> h)
            : handler(std::move(h)) {}
    };

    using SubPair = std::pair<int, std::shared_ptr<SubscriptionBase>>;

    mutable std::mutex m_mutex;
    std::unordered_map<std::type_index, std::vector<SubPair>> m_subscriptions;
    int m_nextId{1};
};
