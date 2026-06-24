// src/services/translate/TranslateTypes.h
#pragma once

#include <QString>
#include <QStringList>
#include <QDateTime>
#include <cstdint>

/// 翻译请求参数
struct TranslateRequest {
    QString text;
    QString fromLang{QStringLiteral("auto")};  ///< "auto" 表示自动检测
    QString toLang{QStringLiteral("zh-CN")};
    QString engineId;                          ///< 空则使用当前默认引擎
};

/// 翻译结果
struct TranslateResult {
    QString     translatedText;
    QString     detectedLang;    ///< 自动检测到的源语言
    QString     engineId;        ///< 实际使用的引擎
    QStringList alternatives;    ///< 备选翻译
    int         latencyMs{0};    ///< 请求耗时（毫秒）
    QDateTime   timestamp;
    bool        cacheHit{false}; ///< 是否命中缓存
};

/// 引擎元信息
struct TranslateEngineInfo {
    QString id;
    QString name;
    bool    available{false};
};
