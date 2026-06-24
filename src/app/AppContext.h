// src/app/AppContext.h
#pragma once

#include <memory>
#include <typeindex>
#include <unordered_map>
#include <mutex>

#include "services/translate/ITranslateService.h"

/// 应用级依赖注入容器（组合根）
///
/// 在 main() 中注册所有服务实例，ViewModel 通过 AppContext 获取服务。
/// 解耦 ViewModel 与具体 Service 实现，便于测试和替换。
///
/// 用法：
/// @code
/// AppContext ctx;
/// ctx.registerService<ITranslateService>(std::make_shared<MockTranslateService>());
/// auto svc = ctx.getService<ITranslateService>();
/// @endcode
class AppContext {
public:
    AppContext() = default;
    ~AppContext() = default;

    AppContext(const AppContext&) = delete;
    AppContext& operator=(const AppContext&) = delete;
    AppContext(AppContext&&) = delete;
    AppContext& operator=(AppContext&&) = delete;

    /// 注册服务实例
    template <typename Interface>
    void registerService(std::shared_ptr<Interface> service) {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_services[std::type_index(typeid(Interface))] =
            std::static_pointer_cast<void>(service);
    }

    /// 获取已注册的服务实例
    /// @return 服务指针，未注册时返回 nullptr
    template <typename Interface>
    [[nodiscard]] std::shared_ptr<Interface> getService() const {
        std::lock_guard<std::mutex> lock(m_mutex);
        auto it = m_services.find(std::type_index(typeid(Interface)));
        if (it == m_services.end()) return nullptr;
        return std::static_pointer_cast<Interface>(it->second);
    }

    /// 检查服务是否已注册
    template <typename Interface>
    [[nodiscard]] bool hasService() const {
        std::lock_guard<std::mutex> lock(m_mutex);
        return m_services.count(std::type_index(typeid(Interface))) > 0;
    }

private:
    mutable std::mutex m_mutex;
    std::unordered_map<std::type_index, std::shared_ptr<void>> m_services;
};
