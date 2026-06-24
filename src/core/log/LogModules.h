// src/core/log/LogModules.h
#pragma once

#include <string_view>

/**
 * @brief 日志模块名常量
 *
 * 统一在此定义，避免模块名字符串散落在各处导致拼写不一致。
 * 所有模块使用 TB_LOG_xxx(LogModule::Xxx, ...) 的形式记录日志。
 *
 * @example
 * @code
 * #include "core/log/Logger.h"
 * #include "core/log/LogModules.h"
 *
 * TB_LOG_INFO(LogModule::Translate, "Engine switched to '{}'", engineId);
 * @endcode
 */
namespace LogModule {

constexpr std::string_view App        = "app";
constexpr std::string_view Screenshot = "screenshot";
constexpr std::string_view Translate  = "translate";
constexpr std::string_view Clipboard  = "clipboard";
constexpr std::string_view Plugin     = "plugin";
constexpr std::string_view Network    = "network";
constexpr std::string_view Hotkey     = "hotkey";
constexpr std::string_view Config     = "config";
constexpr std::string_view UI         = "ui";
constexpr std::string_view AI         = "ai";

}  // namespace LogModule
