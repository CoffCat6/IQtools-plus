add_library(iqtools_core_log INTERFACE)

target_include_directories(iqtools_core_log
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

if(spdlog_FOUND)
    target_link_libraries(iqtools_core_log
        INTERFACE
            spdlog::spdlog
    )
endif()
