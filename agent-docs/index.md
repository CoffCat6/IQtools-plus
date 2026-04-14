# Agent Docs 索引

## 全局关键记忆

- 2026-04-14：当前仓库的 CMake 采用“根总控 + 分层聚合 + 叶子模块”的结构，工程名按仓库落地为 `IQtoolsPlus`，不沿用架构文档里的 `ToolBox` 名称。
- 2026-04-14：空模块阶段允许叶子模块先使用 `INTERFACE` target 占位；一旦该模块新增 `.cpp` 实现文件，应优先切换为 `STATIC` 库，再把源码显式加入 target。

## 文档索引

| 文档 | 适用场景 | 摘要 |
|------|----------|------|
| [build/CMake架构与扩展指南.md](./build/CMake架构与扩展指南.md) | 理解当前 CMake 结构、扩展新模块、排查 target 关系 | 说明各级 `CMakeLists.txt` 的职责边界、target 命名规则、扩展步骤与常见误区。 |
