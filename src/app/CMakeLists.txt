# app 层是组合根，负责把 core / services / viewmodels 装配给最终程序。
add_library(iqtools_app INTERFACE)

target_include_directories(iqtools_app
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_app
    INTERFACE
        iqtools_core
        iqtools_services
        iqtools_viewmodels
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_app
        INTERFACE
            Qt6::Core
            Qt6::Gui
            Qt6::Qml
    )
endif()
