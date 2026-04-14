# 单元测试目标放在这里，例如 test_translate_cache。
# tests/unit/CMakeLists.txt

find_package(Qt6 COMPONENTS Core Gui Test REQUIRED)

add_executable(test_translate_viewmodel
    test_translate_viewmodel.cpp
)

target_link_libraries(test_translate_viewmodel
    PRIVATE
        iqtools_viewmodels
        Qt6::Core
        Qt6::Gui
        Qt6::Test
)

add_test(
    NAME test_translate_viewmodel
    COMMAND test_translate_viewmodel
)