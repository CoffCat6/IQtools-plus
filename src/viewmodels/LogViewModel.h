// src/viewmodels/LogViewModel.h
#pragma once

#include <QtQml/qqmlregistration.h>

#include <QObject>
#include <QString>
#include <QJsonArray>
#include <QJsonObject>
#include <QMutex>
#include <QTimer>

/**
 * @brief 日志面板 ViewModel
 *
 * 通过 CallbackLogSink 接收 spdlog 日志，存储在环形缓冲区中，
 * 定时批量推送到 QML 侧显示。支持按级别过滤和运行时级别控制。
 */
class LogViewModel final : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // QML 侧读取的日志条目数组（每项: {msg, level, time, module}）
    Q_PROPERTY(QJsonArray entries READ entries NOTIFY entriesChanged FINAL)

    // 过滤级别：0=trace,1=debug,2=info,3=warn,4=error,5=critical,6=off
    Q_PROPERTY(int filterLevel READ filterLevel WRITE setFilterLevel
                   NOTIFY filterLevelChanged FINAL)

    // 当前控制台日志级别（运行时可调）
    Q_PROPERTY(int consoleLevel READ consoleLevel WRITE setConsoleLevel
                   NOTIFY consoleLevelChanged FINAL)

    // 当前文件日志级别（运行时可调）
    Q_PROPERTY(int fileLevel READ fileLevel WRITE setFileLevel
                   NOTIFY fileLevelChanged FINAL)

    // 日志目录绝对路径
    Q_PROPERTY(QString logDirectory READ logDirectory CONSTANT FINAL)

public:
    explicit LogViewModel(QObject* parent = nullptr);
    ~LogViewModel() override = default;

    [[nodiscard]] QJsonArray entries() const;
    [[nodiscard]] int filterLevel() const noexcept;
    [[nodiscard]] int consoleLevel() const noexcept;
    [[nodiscard]] int fileLevel() const noexcept;
    [[nodiscard]] QString logDirectory() const;

    void setFilterLevel(int level);
    void setConsoleLevel(int level);
    void setFileLevel(int level);

    // 清空日志面板
    Q_INVOKABLE void clear();

    // 复制全部日志到剪贴板
    Q_INVOKABLE void copyAll();

signals:
    void entriesChanged();
    void filterLevelChanged();
    void consoleLevelChanged();
    void fileLevelChanged();

private:
    // 由 spdlog 回调线程调用，需线程安全
    void onLogReceived(const std::string& formattedMsg, int level);

    // 定时将缓冲区中的新日志推送到 m_entries
    void flushPending();

    mutable QMutex m_mutex;
    QJsonArray m_entries;
    QJsonArray m_pending;          // 缓冲区：回调线程写入，主线程读取

    int m_filterLevel{0};          // 默认显示全部
    int m_consoleLevel{2};         // info
    int m_fileLevel{2};            // info
    QString m_logDirectory;

    QTimer m_flushTimer;

    static constexpr int kMaxEntries = 500;  // 环形缓冲区上限
};
