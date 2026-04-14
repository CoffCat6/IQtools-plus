# 端到端测试目标放在这里，例如 test_main_window_flow。
# tests/e2e/CMakeLists.txt

add_test(
    NAME qml_main_shell_binding
    COMMAND qmltestrunner -input ${CMAKE_CURRENT_SOURCE_DIR} -platform offscreen
)