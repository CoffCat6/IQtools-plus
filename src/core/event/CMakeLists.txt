add_library(iqtools_core_event INTERFACE)

target_include_directories(iqtools_core_event
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_core_event
        INTERFACE
            Qt6::Core
    )
endif()
