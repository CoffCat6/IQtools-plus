add_library(iqtools_core_config STATIC
    ConfigManager.cpp
)

target_include_directories(iqtools_core_config
    PUBLIC
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_core_config
    PUBLIC
        iqtools_core_log
        iqtools_core_error
        Qt6::Core
)

target_compile_features(iqtools_core_config PUBLIC cxx_std_20)
