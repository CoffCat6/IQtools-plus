cmake_minimum_required(VERSION 3.25)

project(IQtoolsPlus
    VERSION 0.1.0
    DESCRIPTION "IQtools Plus desktop toolbox application"
    LANGUAGES CXX
)

option(IQTOOLS_BUILD_PLUGINS "Build official plugins" ON)
option(IQTOOLS_BUILD_TESTS "Build automated tests" OFF)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(CTest)
include(GitVersion)
include(CompilerOptions)
include(Dependencies)

# ── 第三方依赖（bundled header-only）──────────────────────────────────────────
# spdlog 位于 libs/spdlog/include，通过 core/log 模块的 INTERFACE 目标暴露
# 无需 add_subdirectory，不产生额外编译目标

add_subdirectory(src)

if(IQTOOLS_BUILD_PLUGINS)
    add_subdirectory(plugins)
endif()

if(BUILD_TESTING AND IQTOOLS_BUILD_TESTS)
    add_subdirectory(tests)
endif()

include(Packaging)
