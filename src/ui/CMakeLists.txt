add_library(iqtools_ui INTERFACE)

target_include_directories(iqtools_ui
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_ui
        INTERFACE
            Qt6::Qml
            Qt6::Quick
            Qt6::QuickControls2
    )
endif()
