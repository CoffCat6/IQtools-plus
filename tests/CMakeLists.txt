# tests/ 负责测试分层入口与公共测试环境配置。
if(DEFINED Qt6_DIR)
    get_filename_component(IQTOOLS_QT_BIN_DIR "${Qt6_DIR}/../../../bin" ABSOLUTE)
    get_filename_component(IQTOOLS_QT_PLUGIN_DIR "${Qt6_DIR}/../../../plugins" ABSOLUTE)
    get_filename_component(IQTOOLS_QT_QML_DIR "${Qt6_DIR}/../../../qml" ABSOLUTE)
    set(IQTOOLS_QT_PLATFORM_PLUGIN_DIR "${IQTOOLS_QT_PLUGIN_DIR}/platforms")
endif()

function(iqtools_configure_test_runtime test_name)
    if(EXISTS "${IQTOOLS_QT_BIN_DIR}")
        set_property(TEST ${test_name} APPEND PROPERTY ENVIRONMENT_MODIFICATION
            "PATH=path_list_prepend:${IQTOOLS_QT_BIN_DIR}"
        )
    endif()

    if(EXISTS "${IQTOOLS_QT_PLUGIN_DIR}")
        set_property(TEST ${test_name} APPEND PROPERTY ENVIRONMENT_MODIFICATION
            "QT_PLUGIN_PATH=set:${IQTOOLS_QT_PLUGIN_DIR}"
        )
    endif()

    if(EXISTS "${IQTOOLS_QT_PLATFORM_PLUGIN_DIR}")
        set_property(TEST ${test_name} APPEND PROPERTY ENVIRONMENT_MODIFICATION
            "QT_QPA_PLATFORM_PLUGIN_PATH=set:${IQTOOLS_QT_PLATFORM_PLUGIN_DIR}"
        )
    endif()

    if(EXISTS "${IQTOOLS_QT_QML_DIR}")
        set_property(TEST ${test_name} APPEND PROPERTY ENVIRONMENT_MODIFICATION
            "QML2_IMPORT_PATH=set:${IQTOOLS_QT_QML_DIR}"
            "QT_QML_IMPORT_PATH=set:${IQTOOLS_QT_QML_DIR}"
        )
    endif()
endfunction()

add_subdirectory(unit)
add_subdirectory(integration)
add_subdirectory(e2e)
