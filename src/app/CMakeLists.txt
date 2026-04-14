add_library(iqtools_app INTERFACE)

target_include_directories(iqtools_app
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_app
        INTERFACE
            Qt6::Core
    )
endif()
