include_guard(GLOBAL)

set(IQTOOLS_QT_COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Network
    Sql
    Test
)

find_package(Qt6 6.6 COMPONENTS ${IQTOOLS_QT_COMPONENTS} QUIET)

if(Qt6_FOUND)
    set(IQTOOLS_QT_AVAILABLE ON CACHE INTERNAL "Qt6 availability")
    message(STATUS "Qt6 found: ${Qt6_VERSION}")
else()
    set(IQTOOLS_QT_AVAILABLE OFF CACHE INTERNAL "Qt6 availability")
    message(STATUS "Qt6 not found. Set CMAKE_PREFIX_PATH or Qt6_DIR to enable the desktop app target.")
endif()

find_package(spdlog CONFIG QUIET)
if(spdlog_FOUND)
    message(STATUS "spdlog found via system/vcpkg.")
else()
    # 回退：使用 libs/spdlog（header-only，仅含 include/）
    # 由 core/log 模块直接暴露 include 路径，无需 add_subdirectory
    message(STATUS "spdlog not found via find_package; using bundled libs/spdlog (header-only).")
    set(spdlog_FOUND TRUE)
    set(IQTOOLS_SPDLOG_BUNDLED TRUE)
endif()

find_package(OpenCV CONFIG QUIET)
if(OpenCV_FOUND)
    message(STATUS "OpenCV found: ${OpenCV_VERSION}")
else()
    message(STATUS "OpenCV not found. Screenshot image processing stays unbound for now.")
endif()
