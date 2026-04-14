# core 层聚合所有基础设施模块。
add_subdirectory(log)
add_subdirectory(event)
add_subdirectory(plugin)
add_subdirectory(config)
add_subdirectory(error)
add_subdirectory(thread)

add_library(iqtools_core INTERFACE)

target_include_directories(iqtools_core
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_core
    INTERFACE
        iqtools_core_log
        iqtools_core_event
        iqtools_core_plugin
        iqtools_core_config
        iqtools_core_error
        iqtools_core_thread
)
