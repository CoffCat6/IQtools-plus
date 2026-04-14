add_library(iqtools_service_hotkey INTERFACE)

target_include_directories(iqtools_service_hotkey
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_service_hotkey
    INTERFACE
        iqtools_core
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_service_hotkey
        INTERFACE
            Qt6::Core
    )
endif()
