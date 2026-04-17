find_package(Qt6 COMPONENTS Core Gui Quick Qml Test REQUIRED)

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
    COMMAND $<TARGET_FILE:test_translate_viewmodel>
)

iqtools_configure_test_runtime(test_translate_viewmodel)

add_executable(test_app_shell_boot
    test_app_shell_boot.cpp
)

target_link_libraries(test_app_shell_boot
    PRIVATE
        iqtools_ui
        iqtools_viewmodels
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::Test
)

add_test(
    NAME test_app_shell_boot
    COMMAND $<TARGET_FILE:test_app_shell_boot>
)

iqtools_configure_test_runtime(test_app_shell_boot)
set_property(TEST test_app_shell_boot APPEND PROPERTY ENVIRONMENT_MODIFICATION
    "QT_QPA_PLATFORM=set:offscreen"
)
