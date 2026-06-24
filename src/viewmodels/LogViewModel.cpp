// src/viewmodels/LogViewModel.cpp
#include "viewmodels/LogViewModel.h"

#include <QGuiApplication>
#include <QClipboard>
#include <QDateTime>
#include <QJsonDocument>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"

LogViewModel::LogViewModel(QObject* parent)
    : QObject(parent)
{
    // 解析日志目录
    m_logDirectory = QString::fromStdString(Logger::logDir());

    // 注册回调 sink，接收所有模块的日志
    m_callbackSink = Logger::addCallbackSink(
        [this](const std::string& msg, int level) {
            onLogReceived(msg, level);
        });

    // 定时刷新：50ms 间隔，将缓冲区日志批量推送到 QML
    connect(&m_flushTimer, &QTimer::timeout, this, &LogViewModel::flushPending);
    m_flushTimer.start(50);

    TB_LOG_INFO(LogModule::UI, "LogViewModel initialized | logDir='{}'", m_logDirectory.toStdString());
}

LogViewModel::~LogViewModel() {
    // 从 Logger 安全移除回调 sink，防止 spdlog 线程回调悬空 this 指针
    if (m_callbackSink) {
        Logger::removeCallbackSink(m_callbackSink);
        m_callbackSink.reset();
    }
}

QJsonArray LogViewModel::entries() const {
    QMutexLocker locker(&m_mutex);
    return m_entries;
}

int LogViewModel::filterLevel() const noexcept { return m_filterLevel; }
int LogViewModel::consoleLevel() const noexcept { return m_consoleLevel; }
int LogViewModel::fileLevel() const noexcept { return m_fileLevel; }

QString LogViewModel::logDirectory() const { return m_logDirectory; }

void LogViewModel::setFilterLevel(int level) {
    if (m_filterLevel == level) return;
    m_filterLevel = level;
    emit filterLevelChanged();
}

void LogViewModel::setConsoleLevel(int level) {
    const auto lvl = static_cast<spdlog::level::level_enum>(level);
    Logger::setConsoleLevel(lvl);
    if (m_consoleLevel != level) {
        m_consoleLevel = level;
        emit consoleLevelChanged();
    }
    TB_LOG_INFO(LogModule::UI, "Console log level changed to {}",
        spdlog::level::to_string_view(lvl));
}

void LogViewModel::setFileLevel(int level) {
    const auto lvl = static_cast<spdlog::level::level_enum>(level);
    Logger::setFileLevel(lvl);
    if (m_fileLevel != level) {
        m_fileLevel = level;
        emit fileLevelChanged();
    }
    TB_LOG_INFO(LogModule::UI, "File log level changed to {}",
        spdlog::level::to_string_view(lvl));
}

void LogViewModel::clear() {
    QMutexLocker locker(&m_mutex);
    m_entries = QJsonArray();
    emit entriesChanged();
}

void LogViewModel::copyAll() {
    QMutexLocker locker(&m_mutex);
    QByteArray text;
    for (const auto& v : m_entries) {
        const auto obj = v.toObject();
        text.append(obj[QStringLiteral("msg")].toString().toUtf8());
        text.append('\n');
    }
    if (auto* clip = QGuiApplication::clipboard()) {
        clip->setText(QString::fromUtf8(text));
    }
}

void LogViewModel::onLogReceived(const std::string& formattedMsg, int level) {
    // spdlog 回调线程 → 写入缓冲区（锁保护）
    QJsonObject entry;
    entry[QStringLiteral("msg")]  = QString::fromStdString(formattedMsg);
    entry[QStringLiteral("level")] = level;
    entry[QStringLiteral("time")] = QDateTime::currentDateTime()
                                        .toString(QStringLiteral("HH:mm:ss.zzz"));

    QMutexLocker locker(&m_mutex);
    m_pending.append(entry);
}

void LogViewModel::flushPending() {
    QJsonArray pending;
    {
        QMutexLocker locker(&m_mutex);
        if (m_pending.isEmpty()) return;
        pending = std::exchange(m_pending, QJsonArray());
    }

    // 主线程中追加到 m_entries，执行环形缓冲区淘汰
    bool changed = false;
    for (const auto& item : pending) {
        const int lvl = item.toObject()[QStringLiteral("level")].toInt();
        if (lvl < m_filterLevel) continue;  // 按级别过滤

        m_entries.append(item);
        changed = true;
    }

    // 超过上限时从头部淘汰
    while (m_entries.size() > kMaxEntries) {
        m_entries.removeAt(0);
    }

    if (changed) emit entriesChanged();
}
