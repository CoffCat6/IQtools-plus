// src/core/log/LogSink.h
#pragma once

#include <spdlog/sinks/base_sink.h>
#include <spdlog/details/log_msg.h>
#include <mutex>
#include <functional>
#include <string>

/**
 * @brief 自定义日志 Sink 接口
 *
 * 实现此接口可将日志转发到任意目标（如 QML 日志面板、数据库等）。
 *
 * 使用示例：
 * @code
 * // 将日志转发给 Qt 信号槽（主线程）
 * auto qtSink = std::make_shared<CallbackLogSink>(
 *     [this](const std::string& msg, int level) {
 *         QMetaObject::invokeMethod(this, [=]() {
 *             emit logReceived(QString::fromStdString(msg));
 *         }, Qt::QueuedConnection);
 *     });
 *
 * // 在 Logger::init() 之后注册（需在 Logger 内部扩展接口，此处仅演示原理）
 * @endcode
 */

/**
 * @brief 基于回调函数的通用 Sink
 *
 * 线程安全（继承自 spdlog::sinks::base_sink<std::mutex>）。
 */
class CallbackLogSink : public spdlog::sinks::base_sink<std::mutex> {
public:
    using Callback = std::function<void(const std::string& formattedMsg,
                                        int                 level)>;

    explicit CallbackLogSink(Callback callback)
        : m_callback(std::move(callback)) {}

protected:
    void sink_it_(const spdlog::details::log_msg& msg) override {
        spdlog::memory_buf_t buf;
        base_sink<std::mutex>::formatter_->format(msg, buf);
        if (m_callback) {
            m_callback(std::string(buf.data(), buf.size()),
                       static_cast<int>(msg.level));
        }
    }

    void flush_() override {}

private:
    Callback m_callback;
};
