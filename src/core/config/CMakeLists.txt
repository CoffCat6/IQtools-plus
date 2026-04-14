add_library(iqtools_core_config INTERFACE)

target_include_directories(iqtools_core_config
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_core_config
        INTERFACE
            Qt6::Core
    )
endif()
