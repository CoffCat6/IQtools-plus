add_library(iqtools_plugin_qrcode INTERFACE)

target_include_directories(iqtools_plugin_qrcode
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_plugin_qrcode
    INTERFACE
        iqtools_core
)
