set(IQTOOLS_QML_TEST_FILE "${CMAKE_CURRENT_SOURCE_DIR}/tst_main_shell.qml")
set(IQTOOLS_QMLTESTRUNNER_EXECUTABLE "${IQTOOLS_QT_BIN_DIR}/qmltestrunner.exe")

if(EXISTS "${IQTOOLS_QML_TEST_FILE}" AND EXISTS "${IQTOOLS_QMLTESTRUNNER_EXECUTABLE}")
    add_test(
        NAME qml_main_shell_binding
        COMMAND "${IQTOOLS_QMLTESTRUNNER_EXECUTABLE}" -input "${CMAKE_CURRENT_SOURCE_DIR}" -platform offscreen
    )

    iqtools_configure_test_runtime(qml_main_shell_binding)
else()
    message(STATUS "Skip qml_main_shell_binding: qmltestrunner or QML test file is unavailable.")
endif()
