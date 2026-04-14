add_library(iqtools_service_screenshot INTERFACE)

target_include_directories(iqtools_service_screenshot
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_service_screenshot
    INTERFACE
        iqtools_core
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_service_screenshot
        INTERFACE
            Qt6::Core
            Qt6::Gui
    )
endif()

if(OpenCV_FOUND)
    target_link_libraries(iqtools_service_screenshot
        INTERFACE
            ${OpenCV_LIBS}
    )
endif()
