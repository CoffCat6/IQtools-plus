add_subdirectory(engines)

add_library(iqtools_service_translate STATIC
    MockTranslateService.cpp
)

target_include_directories(iqtools_service_translate
    PUBLIC
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_service_translate
    PUBLIC
        iqtools_core
        iqtools_translate_engines
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_service_translate
        PUBLIC
            Qt6::Core
            Qt6::Network
    )
endif()

target_compile_features(iqtools_service_translate PUBLIC cxx_std_20)
