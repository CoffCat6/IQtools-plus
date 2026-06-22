add_library(iqtools_core_log STATIC
    Logger.cpp
)

target_include_directories(iqtools_core_log
    PUBLIC
        "${PROJECT_SOURCE_DIR}/src"
)

# ── Qt6::Core ──────────────────────────────────────────────────────────────
# Logger.h 包含 <QString>，需要 Qt6::Core 的头文件和链接
find_package(Qt6 REQUIRED COMPONENTS Core)
target_link_libraries(iqtools_core_log
    PUBLIC
        Qt6::Core
)

# ── spdlog ─────────────────────────────────────────────────────────────────
# 优先级：系统/vcpkg 安装 > 项目 bundled (libs/spdlog header-only)
#
# libs/spdlog 是纯 header-only 版本（仅 include/ 目录），
# 不含 CMakeLists.txt，无法 add_subdirectory。
# 这里创建一个 INTERFACE 库目标来封装 include 路径。
if(TARGET spdlog::spdlog)
    # 系统/vcpkg 安装的 spdlog（编译模式或 header-only 均可）
    target_link_libraries(iqtools_core_log PUBLIC spdlog::spdlog)
    message(STATUS "[core/log] Using system spdlog::spdlog")
elseif(TARGET spdlog::spdlog_header_only)
    # third_party/spdlog 的 header-only CMake 目标
    target_link_libraries(iqtools_core_log PUBLIC spdlog::spdlog_header_only)
    message(STATUS "[core/log] Using bundled spdlog::spdlog_header_only")
else()
    # libs/spdlog header-only：手动创建 IMPORTED INTERFACE 目标
    message(STATUS "[core/log] Using libs/spdlog (header-only, no CMake target)")
    add_library(spdlog_bundled INTERFACE)
    target_include_directories(spdlog_bundled
        INTERFACE
            "${PROJECT_SOURCE_DIR}/libs/spdlog/include"
    )
    # header-only 模式下，fmt 由 spdlog 内部 bundled 提供，无需额外链接
    # 但需要定义 SPDLOG_COMPILED_LIB 以外的宏确保 header-only 行为
    target_link_libraries(iqtools_core_log PUBLIC spdlog_bundled)
endif()

target_compile_features(iqtools_core_log PUBLIC cxx_std_20)
