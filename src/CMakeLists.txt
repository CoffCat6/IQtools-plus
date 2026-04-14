add_subdirectory(app)
add_subdirectory(core)
add_subdirectory(services)
add_subdirectory(viewmodels)
add_subdirectory(ui)

if(IQTOOLS_QT_AVAILABLE)
    qt_add_executable(iqtoolsplus_app
        main.cpp
        ui/qml.qrc
    )

    target_link_libraries(iqtoolsplus_app
        PRIVATE
            Qt6::Core
            Qt6::Gui
            Qt6::Qml
            Qt6::Quick
            Qt6::QuickControls2
            iqtools_app
            iqtools_core
            iqtools_services
            iqtools_viewmodels
            iqtools_ui
    )

    target_include_directories(iqtoolsplus_app
        PRIVATE
            "${PROJECT_SOURCE_DIR}/src"
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
else()
    message(STATUS "Skip iqtoolsplus_app target because Qt6 is unavailable.")
endif()
