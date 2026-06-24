// src/services/translate/ITranslateService.h
#pragma once

#include <QList>
#include <QObject>
#include <QString>
#include <functional>
#include <memory>

#include "core/error/Error.h"
#include "services/translate/TranslateTypes.h"

/// 翻译服务抽象接口（纯虚类）
///
/// ViewModel 通过此接口调用翻译功能，不关心具体引擎实现。
/// 实现类：MockTranslateService（开发阶段）、YoudaoEngine/DeepLEngine（未来）。
class ITranslateService {
public:
    using Ptr = std::shared_ptr<ITranslateService>;

    /// 异步翻译回调
    using TranslateCallback = std::function<void(Result<TranslateResult>)>;

    virtual ~ITranslateService() = default;

    /// 异步翻译（回调在调用线程或内部线程池中执行）
    /// ViewModel 需自行处理跨线程信号转发（QMetaObject::invokeMethod）。
    virtual void translateAsync(const TranslateRequest& request,
                                TranslateCallback       callback) = 0;

    /// 同步翻译（供测试/命令行使用）
    [[nodiscard]] virtual Result<TranslateResult>
    translateSync(const TranslateRequest& request) = 0;

    /// 获取已注册的翻译引擎列表
    [[nodiscard]] virtual QList<TranslateEngineInfo> availableEngines() const = 0;

    /// 设置当前默认引擎
    virtual void setCurrentEngine(const QString& engineId) = 0;

    /// 获取当前默认引擎 ID
    [[nodiscard]] virtual QString currentEngine() const = 0;

    /// 获取支持的语言列表
    [[nodiscard]] virtual QStringList supportedLanguages() const = 0;

    /// 缓存命中率（0.0 ~ 1.0），供 ViewModel 展示
    [[nodiscard]] virtual double cacheHitRate() const = 0;
};
