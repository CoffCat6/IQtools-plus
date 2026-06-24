// src/core/error/Error.h
#pragma once

#include <concepts>
#include <cstdint>
#include <optional>
#include <stdexcept>
#include <string>
#include <string_view>
#include <type_traits>
#include <utility>

// ── 错误码枚举 ────────────────────────────────────────────────────────────
enum class ErrorCode : int32_t {
    // 通用
    Ok                  = 0,
    Unknown             = 1,
    InvalidArgument     = 2,
    Timeout             = 3,
    NetworkError        = 4,
    PermissionDenied    = 5,
    NotFound            = 6,
    IoError             = 7,
    Cancelled           = 8,

    // 截图
    ScreenCaptureError  = 1000,
    AnnotationError     = 1001,

    // 翻译
    TranslateApiError   = 2000,
    TranslateQuotaError = 2001,
    TranslateAuthError  = 2002,
    TranslateEmptyInput = 2003,

    // 剪贴板
    ClipboardEmpty      = 3000,
    ClipboardReadError  = 3001,

    // 插件
    PluginLoadError       = 4000,
    PluginVersionMismatch = 4001,
    PluginDependencyMissing = 4002,
};

// ── 错误信息结构体 ────────────────────────────────────────────────────────
struct AppError {
    ErrorCode   code{ErrorCode::Unknown};
    std::string message;
    std::string details;    // 供调试，不展示给用户
    std::string location;   // __FILE__ + __LINE__（宏注入）

    [[nodiscard]] static AppError make(ErrorCode code,
                                       std::string message,
                                       std::string details  = {},
                                       std::string location = {}) {
        return {code, std::move(message), std::move(details), std::move(location)};
    }

    /// 转换为简短描述，便于日志输出
    [[nodiscard]] std::string toString() const {
        return std::string{"["} + std::to_string(static_cast<int>(code)) +
               "] " + message;
    }
};

// ── Result<T> ─────────────────────────────────────────────────────────────
/// 通用结果类型，用于替代异常进行错误传播。
/// 用法：
///   Result<int> foo() { return Result<int>::ok(42); }
///   auto r = foo();
///   if (r.isErr()) { ... }
///   int v = std::move(r).value();
template <typename T>
class Result {
public:
    /// 成功构造
    static Result ok(T value) {
        Result r;
        r.m_data = std::move(value);
        return r;
    }

    /// 失败构造
    static Result err(AppError error) {
        Result r;
        r.m_error = std::move(error);
        return r;
    }

    [[nodiscard]] bool isOk() const noexcept { return m_data.has_value(); }
    [[nodiscard]] bool isErr() const noexcept { return m_error.has_value(); }

    /// 获取值（调用前须检查 isOk()）
    [[nodiscard]] const T& value() const& {
        if (!m_data) throw std::logic_error("Result has no value");
        return *m_data;
    }

    [[nodiscard]] T&& value() && {
        if (!m_data) throw std::logic_error("Result has no value");
        return std::move(*m_data);
    }

    /// 获取错误（调用前须检查 isErr()）
    [[nodiscard]] const AppError& error() const& {
        if (!m_error) throw std::logic_error("Result has no error");
        return *m_error;
    }

    /// 函数式变换：isOk 时对值应用 f，isErr 时传播错误
    template <typename F>
        requires std::invocable<F, const T&>
    auto map(F&& f) const -> Result<std::invoke_result_t<F, const T&>> {
        using U = std::invoke_result_t<F, const T&>;
        if (isOk()) return Result<U>::ok(f(value()));
        return Result<U>::err(*m_error);
    }

    /// 获取值或回退默认值
    [[nodiscard]] T valueOr(T fallback) const& {
        return isOk() ? *m_data : std::move(fallback);
    }

    [[nodiscard]] T valueOr(T fallback) && {
        return isOk() ? std::move(*m_data) : std::move(fallback);
    }

private:
    std::optional<T>        m_data;
    std::optional<AppError> m_error;
};

// ── Result<void> 特化 ─────────────────────────────────────────────────────
template <>
class Result<void> {
public:
    static Result ok() {
        Result r;
        r.m_success = true;
        return r;
    }

    static Result err(AppError error) {
        Result r;
        r.m_error = std::move(error);
        return r;
    }

    [[nodiscard]] bool isOk() const noexcept { return m_success; }
    [[nodiscard]] bool isErr() const noexcept { return m_error.has_value(); }

    [[nodiscard]] const AppError& error() const& {
        if (!m_error) throw std::logic_error("Result has no error");
        return *m_error;
    }

private:
    bool                     m_success{false};
    std::optional<AppError>  m_error;
};

// ── 辅助宏 ────────────────────────────────────────────────────────────────
#define IQTOOLS_FILE_LINE (std::string(__FILE__) + ":" + std::to_string(__LINE__))

#define TB_MAKE_ERROR(code, msg) \
    AppError::make((code), (msg), {}, IQTOOLS_FILE_LINE)

#define TB_MAKE_ERROR_DETAIL(code, msg, detail) \
    AppError::make((code), (msg), (detail), IQTOOLS_FILE_LINE)

/// 展开并检查表达式结果，若为错误则直接 return 该错误
#define TB_RETURN_IF_ERR(expr)        \
    do {                              \
        auto&& _r = (expr);           \
        if (_r.isErr()) return _r;    \
    } while (0)
