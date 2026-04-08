# Core Tool (On-Demand Reference)

> 任务需要时按需调用，不在每个 Mode 中自动触发。
> 创建/更新技能时参考 [AgentSkill](../agent-skill/AgentSkill.md) 编写规范。

## 工具

Depend => Maps external integrations and internal dependencies to understand "what connects to what". Analyzes sibling/parent directories for structural patterns, traces node_modules/libs usage (public APIs, not internals), and verifies dependency availability.

Study => Exhaustively reads a directory's contents to extract patterns, conventions, and architectural insights. When invoked on a directory, enumerate ALL entries via list_dir and read every file without omission.

Xray => Generates tree structure diagrams to visualize architecture, dependencies, and file relationships. Use for architecture analysis, structure validation, or exploring unfamiliar codebases.

## 协作关系

- **Xray → Study**: Xray 生成结构骨架作为 Study 的阅读清单
- **Xray → Depend**: Xray 提供布局供 Depend 定位连接点
- **Depend → Study**: Depend 的依赖地图帮助 Study 优先读取集成关键文件
- **Study → Depend/Xray**: Study 的语义标注反哺 Depend 验证模式、Xray 渲染富化图