add_library(iqtools_viewmodels INTERFACE)

target_include_directories(iqtools_viewmodels
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_viewmodels
    INTERFACE
        iqtools_services
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_viewmodels
        INTERFACE
            Qt6::Core
            Qt6::Qml
    )
endif()
