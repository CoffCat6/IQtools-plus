# services 层聚合业务模块，避免可执行程序直接链接每个业务目标。
add_subdirectory(screenshot)
add_subdirectory(translate)
add_subdirectory(clipboard)
add_subdirectory(hotkey)

add_library(iqtools_services INTERFACE)

target_include_directories(iqtools_services
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_services
    INTERFACE
        iqtools_service_screenshot
        iqtools_service_translate
        iqtools_service_clipboard
        iqtools_service_hotkey
)
