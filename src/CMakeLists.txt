# src/ 只负责组装主程序，不在这里声明底层依赖细节。
add_subdirectory(core)
add_subdirectory(services)
add_subdirectory(viewmodels)
add_subdirectory(app)
add_subdirectory(ui)

if(NOT IQTOOLS_QT_AVAILABLE)
    message(STATUS "Skip iqtoolsplus_app target because Qt6 is unavailable.")
    return()
endif()

qt_add_executable(iqtoolsplus_app
    main.cpp
    ui/qml.qrc
)

target_link_libraries(iqtoolsplus_app
    PRIVATE
        iqtools_app
        iqtools_ui
)

target_compile_definitions(iqtoolsplus_app
    PRIVATE
        IQTOOLS_GIT_VERSION="${IQTOOLS_GIT_DESCRIBE}"
)

set_target_properties(iqtoolsplus_app PROPERTIES
    OUTPUT_NAME "IQtoolsPlus"
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

iqtools_apply_common_options(iqtoolsplus_app)
