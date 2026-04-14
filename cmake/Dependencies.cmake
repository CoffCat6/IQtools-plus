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
    message(STATUS "spdlog found.")
else()
    message(STATUS "spdlog not found. Core logging target remains as a placeholder.")
endif()

find_package(OpenCV CONFIG QUIET)
if(OpenCV_FOUND)
    message(STATUS "OpenCV found: ${OpenCV_VERSION}")
else()
    message(STATUS "OpenCV not found. Screenshot image processing stays unbound for now.")
endif()
