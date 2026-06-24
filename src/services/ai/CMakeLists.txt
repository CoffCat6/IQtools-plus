add_library(iqtools_service_ai STATIC
    MockAIService.cpp
)

target_include_directories(iqtools_service_ai
    PUBLIC
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_service_ai
    PUBLIC
        iqtools_core
)

if(IQTOOLS_QT_AVAILABLE)
    target_link_libraries(iqtools_service_ai
        PUBLIC
            Qt6::Core
    )
endif()

target_compile_features(iqtools_service_ai PUBLIC cxx_std_20)
