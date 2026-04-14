# tests 层按测试类型拆分，后续每个测试目标只链接自己需要的模块。
add_subdirectory(unit)
add_subdirectory(integration)
add_subdirectory(e2e)
