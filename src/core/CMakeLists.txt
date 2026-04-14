add_library(iqtools_core INTERFACE)

target_include_directories(iqtools_core
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_core
        INTERFACE
            Qt6::Core
    )
endif()

if(spdlog_FOUND)
    target_link_libraries(iqtools_core
        INTERFACE
            spdlog::spdlog
    )
endif()
