# src/ui/CMakeLists.txt

add_library(iqtools_ui STATIC
    UiResources.cpp
    qml.qrc
)

target_include_directories(iqtools_ui
    PUBLIC
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_ui
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
)

target_compile_features(iqtools_ui PUBLIC cxx_std_20)