add_library(iqtools_services INTERFACE)

target_include_directories(iqtools_services
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_services
        INTERFACE
            Qt6::Core
            Qt6::Gui
            Qt6::Network
            Qt6::Sql
    )
endif()

if(OpenCV_FOUND)
    target_link_libraries(iqtools_services
        INTERFACE
            ${OpenCV_LIBS}
    )
endif()
