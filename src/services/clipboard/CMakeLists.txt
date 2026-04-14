add_library(iqtools_service_clipboard INTERFACE)

target_include_directories(iqtools_service_clipboard
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_service_clipboard
    INTERFACE
        iqtools_core
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_service_clipboard
        INTERFACE
            Qt6::Core
            Qt6::Gui
            Qt6::Sql
    )
endif()
