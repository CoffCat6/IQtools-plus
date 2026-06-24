// src/app/AppContext.cpp
#include "app/AppContext.h"

#include "services/translate/MockTranslateService.h"

void AppContext::registerDefaultServices() {
    // 翻译服务：当前阶段使用 Mock 实现
    // 未来：根据配置加载 YoudaoEngine / DeepLEngine
    if (!hasService<ITranslateService>()) {
        registerService<ITranslateService>(
            std::make_shared<MockTranslateService>());
    }
}
