add_subdirectory(engines)

add_library(iqtools_service_translate INTERFACE)

target_include_directories(iqtools_service_translate
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_service_translate
    INTERFACE
        iqtools_core
        iqtools_translate_engines
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_service_translate
        INTERFACE
            Qt6::Core
            Qt6::Network
    )
endif()
