add_library(iqtools_core_event STATIC
    EventBus.cpp
)

target_include_directories(iqtools_core_event
    PUBLIC
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_core_event
    PUBLIC
        iqtools_core_log
)

target_compile_features(iqtools_core_event PUBLIC cxx_std_20)
