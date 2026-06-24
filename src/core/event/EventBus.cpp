// src/core/event/EventBus.cpp
#include "core/event/EventBus.h"

#include "core/log/Logger.h"
#include "core/log/LogModules.h"

EventBus& EventBus::instance() {
    static EventBus bus;
    return bus;
}

void EventBus::unsubscribe(int subscriptionId) {
    std::lock_guard<std::mutex> lock(m_mutex);
    for (auto& [typeIdx, subs] : m_subscriptions) {
        std::erase_if(subs, [subscriptionId](const SubPair& p) {
            return p.first == subscriptionId;
        });
    }
}

void EventBus::clear() {
    std::lock_guard<std::mutex> lock(m_mutex);
    m_subscriptions.clear();
    TB_LOG_DEBUG(LogModule::App, "EventBus: all subscriptions cleared");
}
