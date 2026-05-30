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

# Windows application icon
if(WIN32)
    target_sources(iqtoolsplus_app PRIVATE app.rc)
    target_link_libraries(iqtoolsplus_app PRIVATE user32)
endif()

target_link_libraries(iqtoolsplus_app
    PRIVATE
        iqtools_app
        iqtools_ui
)

target_compile_definitions(iqtoolsplus_app
    PRIVATE
        IQTOOLS_GIT_VERSION="${IQTOOLS_GIT_DESCRIBE}"
        IQTOOLS_APP_VERSION="${PROJECT_VERSION}"
)

set_target_properties(iqtoolsplus_app PROPERTIES
    OUTPUT_NAME "IQtoolsPlus"
    WIN32_EXECUTABLE FALSE
    MACOSX_BUNDLE TRUE
)

if(WIN32 AND DEFINED Qt6_DIR)
    get_filename_component(IQTOOLS_QT_BIN_DIR "${Qt6_DIR}/../../../bin" ABSOLUTE)
    set(IQTOOLS_WINDEPLOYQT_EXECUTABLE "${IQTOOLS_QT_BIN_DIR}/windeployqt.exe")

    if(EXISTS "${IQTOOLS_WINDEPLOYQT_EXECUTABLE}")
        add_custom_command(TARGET iqtoolsplus_app POST_BUILD
            COMMAND "${IQTOOLS_WINDEPLOYQT_EXECUTABLE}"
                --dir "$<TARGET_FILE_DIR:iqtoolsplus_app>"
                --qmldir "${PROJECT_SOURCE_DIR}/src/ui"
                --no-compiler-runtime
                "$<TARGET_FILE:iqtoolsplus_app>"
            COMMENT "Deploying Qt runtime and QML dependencies for iqtoolsplus_app"
            VERBATIM
        )
    else()
        message(WARNING "windeployqt.exe not found. iqtoolsplus_app may not start outside configured test environments.")
    endif()
endif()

iqtools_apply_common_options(iqtoolsplus_app)
