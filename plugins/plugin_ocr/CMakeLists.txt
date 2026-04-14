add_library(iqtools_plugin_ocr INTERFACE)

target_include_directories(iqtools_plugin_ocr
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_plugin_ocr
    INTERFACE
        iqtools_core
)
