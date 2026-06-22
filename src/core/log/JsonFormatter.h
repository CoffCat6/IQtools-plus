// src/core/log/JsonFormatter.h
#pragma once

#include <spdlog/formatter.h>
#include <spdlog/details/log_msg.h>
#include <spdlog/details/os.h>
#include <spdlog/details/fmt_helper.h>
#include <spdlog/fmt/fmt.h>

#include <string>
#include <string_view>
#include <ctime>

namespace iqtools {

// 辅助：向 memory_buf_t 追加字符串片段（兼容 fmt v11 的 append(begin, end) 签名）
inline void buf_append(spdlog::memory_buf_t& dest, const char* data, size_t size) {
    dest.append(data, data + size);
}

/**
 * @brief 输出合法 JSON Lines 格式的 spdlog formatter
 *
 * 每行一个 JSON 对象：
 * {"time":"2026-06-21T20:47:49.270","level":"info","module":"app","src":"Logger.cpp:112","msg":"...","pid":59820}
 *
 * 与原 pattern_formatter 的区别：
 * - msg 字段经过 JSON 转义（换行、引号、反斜杠等），保证输出可被 jq 等工具解析
 * - src 字段自动从 __FILE__ 完整路径中截取文件名
 * - 格式固定，不依赖 pattern 字符串
 */
class JsonLineFormatter : public spdlog::formatter {
public:
    JsonLineFormatter() = default;

    std::unique_ptr<spdlog::formatter> clone() const override {
        return std::make_unique<JsonLineFormatter>();
    }

    void format(const spdlog::details::log_msg& msg, spdlog::memory_buf_t& dest) override {
        // ── { ────────────────────────────────────────────────────────────────
        dest.push_back('{');

        // ── "time":"YYYY-MM-DDTHH:MM:SS.mmm" ───────────────────────────────
        buf_append(dest, R"("time":")", 8);
        format_timestamp(msg.time, dest);
        dest.push_back('"');

        // ── ,"level":"xxx" ──────────────────────────────────────────────────
        buf_append(dest, R"(,"level":")", 10);
        auto lvl = spdlog::level::to_string_view(msg.level);
        buf_append(dest, lvl.data(), lvl.size());
        dest.push_back('"');

        // ── ,"module":"xxx" ─────────────────────────────────────────────────
        buf_append(dest, R"(,"module":")", 11);
        buf_append(dest, msg.logger_name.data(), msg.logger_name.size());
        dest.push_back('"');

        // ── ,"src":"file:line" ──────────────────────────────────────────────
        buf_append(dest, R"(,"src":")", 8);
        append_basename(msg.source.filename, dest);
        dest.push_back(':');
        spdlog::details::fmt_helper::pad_uint(
            static_cast<uint32_t>(msg.source.line), 1, dest);
        dest.push_back('"');

        // ── ,"msg":"escaped" ────────────────────────────────────────────────
        buf_append(dest, R"(,"msg":")", 8);
        append_json_escaped(msg.payload, dest);
        dest.push_back('"');

        // ── ,"pid":XXXXX ────────────────────────────────────────────────────
        buf_append(dest, R"(,"pid":)", 6);
        spdlog::details::fmt_helper::append_int(
            static_cast<uint64_t>(spdlog::details::os::pid()), dest);

        // ── }\n ─────────────────────────────────────────────────────────────
        dest.push_back('}');
        dest.push_back('\n');
    }

private:
    // 上次缓存的日期字符串，避免每条日志都格式化日期
    std::string cached_date_;
    std::tm     cached_tm_{};

    /**
     * @brief 格式化时间戳为 YYYY-MM-DDTHH:MM:SS.mmm
     */
    void format_timestamp(const std::chrono::system_clock::time_point& tp,
                          spdlog::memory_buf_t& dest) {
        const auto duration = tp.time_since_epoch();
        const auto secs = std::chrono::duration_cast<std::chrono::seconds>(duration);
        const auto ms   = std::chrono::duration_cast<std::chrono::milliseconds>(duration)
                          - std::chrono::duration_cast<std::chrono::milliseconds>(secs);

        const std::time_t time = std::chrono::system_clock::to_time_t(
            std::chrono::system_clock::time_point(secs));

        std::tm tm_buf{};
#ifdef _WIN32
        localtime_s(&tm_buf, &time);
#else
        localtime_r(&time, &tm_buf);
#endif

        // 日期部分：仅在天变化时重新格式化
        if (tm_buf.tm_year != cached_tm_.tm_year ||
            tm_buf.tm_mon  != cached_tm_.tm_mon  ||
            tm_buf.tm_mday != cached_tm_.tm_mday) {
            cached_tm_ = tm_buf;
            char date_buf[16];
            std::strftime(date_buf, sizeof(date_buf), "%Y-%m-%d", &tm_buf);
            cached_date_ = date_buf;
        }
        buf_append(dest, cached_date_.data(), cached_date_.size());

        // 分隔符 'T'
        dest.push_back('T');

        // HH:MM:SS
        spdlog::details::fmt_helper::pad2(tm_buf.tm_hour, dest);
        dest.push_back(':');
        spdlog::details::fmt_helper::pad2(tm_buf.tm_min, dest);
        dest.push_back(':');
        spdlog::details::fmt_helper::pad2(tm_buf.tm_sec, dest);

        // .mmm
        dest.push_back('.');
        spdlog::details::fmt_helper::pad3(
            static_cast<uint32_t>(ms.count()), dest);
    }

    /**
     * @brief 从完整路径中提取文件名（basename）
     */
    static void append_basename(const char* filename, spdlog::memory_buf_t& dest) {
        if (!filename) return;
        const char* base = filename;
        for (const char* p = filename; *p; ++p) {
            if (*p == '/' || *p == '\\') base = p + 1;
        }
        for (; *base; ++base) dest.push_back(*base);
    }

    /**
     * @brief JSON 字符串转义
     *
     * 处理：\ " \b \f \n \r \t 及其他控制字符（\u00XX）
     */
    static void append_json_escaped(spdlog::string_view_t str,
                                    spdlog::memory_buf_t& dest) {
        for (const auto ch : str) {
            const auto uc = static_cast<unsigned char>(ch);
            switch (uc) {
                case '"':  buf_append(dest, "\\\"", 2); break;
                case '\\': buf_append(dest, "\\\\", 2); break;
                case '\b': buf_append(dest, "\\b",  2); break;
                case '\f': buf_append(dest, "\\f",  2); break;
                case '\n': buf_append(dest, "\\n",  2); break;
                case '\r': buf_append(dest, "\\r",  2); break;
                case '\t': buf_append(dest, "\\t",  2); break;
                default:
                    if (uc < 0x20) {
                        // 控制字符 → \u00XX
                        buf_append(dest, "\\u00", 4);
                        constexpr char hex[] = "0123456789abcdef";
                        dest.push_back(hex[(uc >> 4) & 0x0F]);
                        dest.push_back(hex[uc & 0x0F]);
                    } else {
                        dest.push_back(ch);
                    }
            }
        }
    }
};

}  // namespace iqtools
