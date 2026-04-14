# IQtoolsPlus CMake 架构与扩展指南

## 1. 目标

本文档解释当前仓库中各级 `CMakeLists.txt` 的职责边界、target 关系，以及后续新增模块时应遵循的扩展方式。

当前落地遵循两条原则：

- 根入口只做总控，不承载具体模块依赖细节。
- 目录结构与 target 结构一一对应，便于从文件夹直接推断链接关系。

## 2. 阅读顺序

理解当前 CMake 结构时，建议按下面顺序阅读：

1. `CMakeLists.txt`
2. `cmake/GitVersion.cmake`
3. `cmake/CompilerOptions.cmake`
4. `cmake/Dependencies.cmake`
5. `src/CMakeLists.txt`
6. `src/core/CMakeLists.txt`
7. `src/services/CMakeLists.txt`
8. `src/viewmodels/CMakeLists.txt`
9. `src/app/CMakeLists.txt`
10. `src/ui/CMakeLists.txt`
11. `plugins/CMakeLists.txt`
12. `tests/CMakeLists.txt`

读法原则是先看“谁负责总控”，再看“谁负责聚合”，最后看“谁是真正的叶子模块”。

## 3. 当前分层与 target 关系

### 3.1 分层关系

```text
iqtoolsplus_app
  -> iqtools_app
  -> iqtools_ui

iqtools_app
  -> iqtools_core
  -> iqtools_services
  -> iqtools_viewmodels

iqtools_viewmodels
  -> iqtools_core
  -> iqtools_services

iqtools_services
  -> iqtools_service_screenshot
  -> iqtools_service_translate
  -> iqtools_service_clipboard
  -> iqtools_service_hotkey

 iqtools_service_translate
  -> iqtools_translate_engines
  -> iqtools_core

iqtools_core
  -> iqtools_core_log
  -> iqtools_core_event
  -> iqtools_core_plugin
  -> iqtools_core_config
  -> iqtools_core_error
  -> iqtools_core_thread
```

### 3.2 三类 CMake 文件

当前仓库中的 `CMakeLists.txt` 分三类：

- 总控层：只做全局配置与入口分发。例如根 `CMakeLists.txt`。
- 聚合层：只聚合下层模块，不直接承载业务源码。例如 `src/core/CMakeLists.txt`、`src/services/CMakeLists.txt`。
- 叶子层：对应一个明确模块，声明自己的 include、依赖和源码。例如 `src/services/translate/CMakeLists.txt`。

## 4. 各级文件职责

### 4.1 根 `CMakeLists.txt`

根文件只负责以下事情：

- 声明项目信息，如项目名、版本、C++ 标准。
- 引入 `cmake/` 下的共享模块。
- 决定是否进入 `src/`、`plugins/`、`tests/`。
- 不直接声明业务 target。

判断标准很简单：如果一个逻辑只属于某个模块，而不是整个仓库，就不应该放在根文件里。

### 4.2 `cmake/*.cmake`

`cmake/` 目录放的是共享构建能力，不是业务模块：

- `GitVersion.cmake`：生成版本描述。
- `CompilerOptions.cmake`：统一编译警告与标准。
- `Dependencies.cmake`：集中 `find_package(...)`。
- `Packaging.cmake`：集中处理打包设置。

这里的规则是：只放“通用构建能力”，不要在这里写某个业务模块的源码列表。

### 4.3 `src/CMakeLists.txt`

`src/` 是应用主程序的装配层：

- 先进入各层目录，让各层 target 就位。
- 再创建 `iqtoolsplus_app`。
- 最终可执行程序只链接高层 target，不直接逐个链接每个底层业务模块。

当前可执行程序直接链接的是：

- `iqtools_app`
- `iqtools_ui`

这意味着底层依赖通过分层 target 逐层传递，而不是在主程序里写成一长串。

### 4.4 `src/core/CMakeLists.txt`

`core/` 是基础设施聚合层。它只做两件事：

- `add_subdirectory(...)` 引入日志、事件、插件、配置、错误、线程等子模块。
- 提供 `iqtools_core` 作为统一入口供上层依赖。

后续只要某个模块属于基础设施，就应先落在 `core/<module>/`，再由 `iqtools_core` 聚合。

### 4.5 `src/services/CMakeLists.txt`

`services/` 是业务服务聚合层。服务层 target 的设计目标是：

- 服务模块之间边界清楚。
- ViewModel 或 app 层只依赖 `iqtools_services` 或具体服务，不直接下沉到更底层实现文件。

### 4.6 `src/viewmodels/CMakeLists.txt`

`viewmodels/` 负责桥接 QML 与 services：

- 可以依赖 `iqtools_services`。
- 可以依赖必要的 `iqtools_core` 类型。
- 不应该反向让 services 依赖 viewmodels。

### 4.7 `src/app/CMakeLists.txt`

`app/` 是组合根：

- 负责初始化与装配。
- 负责把 `core`、`services`、`viewmodels` 接到应用入口。
- 不承载纯界面资源。

### 4.8 `src/ui/CMakeLists.txt`

`ui/` 只负责界面相关依赖：

- QML / Quick / QuickControls 依赖。
- QML 资源文件。
- 不直接承担业务层装配职责。

### 4.9 `plugins/` 与 `tests/`

这两个目录都采用“总目录聚合 + 子目录独立 target”的方式：

- `plugins/<plugin_name>/CMakeLists.txt` 只管理该插件。
- `tests/unit|integration|e2e/` 各自管理各自测试。

## 5. 命名规则

当前 target 命名统一采用下面规则：

- 聚合层：`iqtools_<layer>`
- 叶子模块：`iqtools_<layer>_<module>`
- 服务子模块：`iqtools_service_<module>`
- 可执行程序：`iqtoolsplus_app`

示例：

- `iqtools_core`
- `iqtools_core_log`
- `iqtools_service_translate`
- `iqtools_translate_engines`
- `iqtools_viewmodels`

命名目标是：看到 target 名就知道它属于哪一层、对应哪个目录。

## 6. 为什么现在大量使用 `INTERFACE`

当前仓库仍处于骨架阶段，很多目录还没有 `.cpp` 源文件，因此叶子模块先以 `INTERFACE` target 占位。

这不是最终形态，而是一种过渡策略：

- 模块还没有实现文件：用 `INTERFACE`，先把依赖关系定下来。
- 模块开始有实现文件：切换为 `STATIC`，并显式列出源码。

切换示例：

```cmake
add_library(iqtools_service_translate STATIC
    TranslateService.cpp
    TranslateService.h
    TranslateCache.cpp
    TranslateCache.h
)

target_include_directories(iqtools_service_translate
    PUBLIC
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_service_translate
    PUBLIC
        iqtools_core
        iqtools_translate_engines
        Qt6::Core
        Qt6::Network
)
```

## 7. 新增模块的标准步骤

### 7.1 新增一个 core 模块

以 `core/metrics` 为例：

1. 新建目录 `src/core/metrics/`
2. 新建 `src/core/metrics/CMakeLists.txt`
3. 在 `src/core/CMakeLists.txt` 里增加 `add_subdirectory(metrics)`
4. 在 `iqtools_core` 的 `target_link_libraries(...)` 中增加 `iqtools_core_metrics`
5. 若该模块已有 `.cpp`，直接定义为 `STATIC`

骨架示例：

```cmake
add_library(iqtools_core_metrics INTERFACE)

target_include_directories(iqtools_core_metrics
    INTERFACE
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_core_metrics
    INTERFACE
        iqtools_core_error
)
```

### 7.2 新增一个 service 模块

以 `services/ocr` 为例：

1. 新建目录 `src/services/ocr/`
2. 新建 `src/services/ocr/CMakeLists.txt`
3. 在 `src/services/CMakeLists.txt` 中添加 `add_subdirectory(ocr)`
4. 把 `iqtools_service_ocr` 加入 `iqtools_services` 聚合
5. 如果 ViewModel 需要它，再在 `viewmodels` 中使用

建议模板：

```cmake
add_library(iqtools_service_ocr STATIC
    OcrService.cpp
    OcrService.h
)

target_include_directories(iqtools_service_ocr
    PUBLIC
        "${PROJECT_SOURCE_DIR}/src"
)

target_link_libraries(iqtools_service_ocr
    PUBLIC
        iqtools_core
        Qt6::Core
        Qt6::Network
)
```

### 7.3 新增一个插件

以 `plugins/plugin_exporter` 为例：

1. 新建目录 `plugins/plugin_exporter/`
2. 新建 `plugins/plugin_exporter/CMakeLists.txt`
3. 在 `plugins/CMakeLists.txt` 中增加 `add_subdirectory(plugin_exporter)`
4. 插件内部再决定自己依赖 `iqtools_core` 还是具体 service target

### 7.4 新增一个测试目标

以 `tests/unit/test_translate_cache.cpp` 为例：

1. 在 `tests/unit/` 新增测试源码
2. 在 `tests/unit/CMakeLists.txt` 中新增 `add_executable(...)`
3. 链接目标模块，如 `iqtools_service_translate`
4. 使用 `add_test(...)` 注册到 CTest

示例：

```cmake
add_executable(test_translate_cache
    test_translate_cache.cpp
)

target_link_libraries(test_translate_cache
    PRIVATE
        iqtools_service_translate
)

add_test(
    NAME test_translate_cache
    COMMAND test_translate_cache
)
```

## 8. 常见误区

以下做法应避免：

- 在根 `CMakeLists.txt` 直接写具体服务模块源码。
- 让 `iqtoolsplus_app` 直接链接所有叶子模块。
- 在 `Dependencies.cmake` 里混入业务 target 定义。
- 新增模块时只建目录，不把它接入父级聚合层。
- 模块已经有 `.cpp` 文件，仍长期保持 `INTERFACE`。

## 9. 当前阶段的约定

当前仓库还在起步阶段，因此有两个现实约定：

- 文档原名为 `ToolBox`，但仓库落地命名统一使用 `IQtoolsPlus`。
- UI 资源暂时仍由主程序 target 直接带入，后续若 QML 页面与组件规模扩大，再评估迁移到 `qt_add_qml_module(...)`。

## 10. 后续建议

随着代码逐步补齐，建议按下面顺序继续演进：

1. 先把 `core/` 和 `services/` 的叶子模块从 `INTERFACE` 逐步切换为 `STATIC`。
2. 再为 `viewmodels/` 引入实际源码与 QML 注册。
3. UI 规模足够后，再把资源管理升级到 `qt_add_qml_module(...)`。
4. 测试目标优先从 `services` 层开始补，避免一上来就写重 UI 测试。
