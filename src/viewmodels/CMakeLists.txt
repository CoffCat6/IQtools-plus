# src/viewmodels/CMakeLists.txt

add_library(iqtools_viewmodels STATIC
    AppShellViewModel.cpp
    TranslateViewModel.cpp
    HomeViewModel.cpp
    AIAssistantViewModel.cpp
    LogViewModel.cpp
    SettingViewModel.cpp
)

target_sources(iqtools_viewmodels
    PUBLIC
        FILE_SET HEADERS
        BASE_DIRS ${PROJECT_SOURCE_DIR}/src
        FILES
            ${PROJECT_SOURCE_DIR}/src/viewmodels/AppShellViewModel.h
            ${PROJECT_SOURCE_DIR}/src/viewmodels/TranslateViewModel.h
            ${PROJECT_SOURCE_DIR}/src/viewmodels/HomeViewModel.h
            ${PROJECT_SOURCE_DIR}/src/viewmodels/AIAssistantViewModel.h
            ${PROJECT_SOURCE_DIR}/src/viewmodels/LogViewModel.h
            ${PROJECT_SOURCE_DIR}/src/viewmodels/SettingViewModel.h
)

target_include_directories(iqtools_viewmodels
    PUBLIC
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_viewmodels
    PUBLIC
        iqtools_core
        iqtools_services
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
)

target_compile_features(iqtools_viewmodels PUBLIC cxx_std_20)