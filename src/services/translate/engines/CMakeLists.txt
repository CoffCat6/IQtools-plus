add_library(iqtools_translate_engines INTERFACE)

target_include_directories(iqtools_translate_engines
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_translate_engines
    INTERFACE
        iqtools_core
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_translate_engines
        INTERFACE
            Qt6::Core
            Qt6::Network
    )
endif()
