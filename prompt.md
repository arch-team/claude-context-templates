当前的claude-code-dev-guide 项目定义Claude Code 组件包括 plugin、hooks、skills、mcp、subagent的一些规范，分散在当前目录下。
这些规范有些是适用于Claude Code 组件所有组件的通用原则、有些是适用具体某个Claude Code 组件的规范。需要按照如下格式进行组织。
┌─────────────────────────────────────────┐    
  │ 专用   │ 类型1 │  │ 类型1 │  │ 类型N │  │
  └─────────────────────────────────────────┘                                                     
  ┌─────────────────────────────────────────┐
  │ 通用   │ 类型1 │  │ 类型2 │  │ 类型N │  │                                                     
  └─────────────────────────────────────────┘   
重新组织后的这些规范，需要达到极高的可读性、可维护性、可扩展性标准，需要满足单一职责原则、单一信息源原则、抽象与具体实现分离的原则、单向依赖原则、专用可以依赖通用，通用不能依赖专用的原则

基于这个要求，给出符合要求的重构方案


/Users/jinhuasu/Project_Workspace/AI-Forge-Workspace/claude-context-templates/plugin/presets 这个目录是为不同类型的软件项目提供关于该类软件项目的Claude Code上下文规范，这些上下文规范有些是通用原则、有些是适用具体软件架构、技术站、软件形态的专用规范。
需要按照如下格式进行组织提炼。
┌─────────────────────────────────────────┐    
  │ 专用   │ 类型1 │  │ 类型1 │  │ 类型N │  │
  └─────────────────────────────────────────┘                                                     
  ┌─────────────────────────────────────────┐
  │ 通用   │ 类型1 │  │ 类型2 │  │ 类型N │  │                                             

重新组织后的这些规范后，你需要仔细分析一下。看看这些规范需要做哪些优化，以达到极高的可读性、可维护性、可扩展性标准，同时需要满足单一职责原则、单一信息源原则、抽象与具体实现分离的原则、单向依赖原则、专用可以依赖通用，通用不能依赖专用的原则，
基于这个要求，给出符合要求的重构方案
你对我意图和要求如果有不明确必须跟我确认，不要自己猜测


1.当前的claude-code-dev-guide 项目定义Claude Code 组件包括 plugin、hooks、skills、mcp、subagent的一些Claude Code上下文规范。
2.请使用claude-md-improver对这些规范进行优化，优化后的这些规范需要达到极高的可读性、可维护性、可扩展性标准，需要满足单一职责原则、单一信息源原则、抽象与具体实现分离的原则、单向依赖原则、专用可以依赖通用，通用不能依赖专用的原则。且token的利用率有明显改善。
3.基于这个要求，给出符合要求的重构方案。
4.你对我意图和要求如果有不明确必须跟我确认，不要自己猜测


不对，类型和通用层和专用层是两个不同的维度，具体来说每个不同的preset（aws-cdk, python-fastapi 等）会自己的通用层和专用层以及在不同层的不同规范类型，通用层和专用层的区分是为了保证抽象与具体实现分离的原则。而规范类型的区分是为了保证单一职责原则；同时整个presets目录下的_common这个目录是presets级别适用于不同的preset（aws-cdk, python-fastapi 等）的通用规范


❯ 3. 通用原则写在通用层，专用文件只写专用内容                                      
     彻底分离：通用层文档包含所有跨 preset 的工程原则，专用层文档只包含技术栈特定的实现指导，不再重复通用内容。init.sh 生成时两层都输出到用户项目。 


       维度 1: 跨 claude-code-dev-guide（_common）                                                                                                                                                                                              
    └── 维度 2: 每个 claude-code-dev-guide 内部                                                                                                                                                                                          
          ├── 通用层（抽象原则 — WHY / WHAT）                                                                                                                                                                             
          │   ├── 规范类型1 (skills)     ← 维度 3: 按单一职责分类
          │   ├── 规范类型2 (hooks)
          │   └── ...
          └── 专用层（具体实现 — HOW）
              ├── 规范类型1 (skills)
              ├── 规范类型2 (hooks)
              └── ...

  让我用一个具体例子确认理解是否正确。

类型和通用层和专用层是两个不同的维度，整个claude-code-dev-guide项目定义Claude Code 组件包括 plugin、hooks、skills、mcp、subagent的一些Claude Code上下文规范。这个规范有些是适用于这个项目的通用类型

     维度 1: 跨 claude-code-dev-guide（_common）                                                                                                                                                                                              
    └── 维度 2: 每个 claude-code-dev-guide 内部                                                                                                                                                                                          
          ├── 通用层（抽象原则 — WHY / WHAT）                                                                                                                                                                             
          │   ├── 规范类型1 (skills)     ← 维度 3: 按单一职责分类
          │   ├── 规范类型2 (hooks)
          │   └── ...
          └── 专用层（具体实现 — HOW）
              ├── 规范类型1 (skills)
              ├── 规范类型2 (hooks)
              └── ...

  ⎿  Tool use rejected with user message: 规范文件按通用层和专用层，以及按照不同类型进行拆分目的是让最终的规范文件整体上符合单一职责原则和抽象与具体实现分离的原则，具体拆分后的文件是否必须存在还是可选存在需要判断分析

claude-context-templates是一个Claude Code Plugin项目
作用是：生成和审计 `.claude/` 上下文目录，提升 Claude Code 对项目的理解能力。

需要提升用户的使用体验

用户执行 /init-context — 生成Claude Code上下文目录及规范文件时。
有两种类型
1.是空项目
2.是已经存在的项目

在信息收集端-需要规范标准化信息收集的方式和流程

对空项目需要以交互的形式向用户收集信息，这类信息包括使用的开发语言、架构、项目说明等等，越详细越好，因此对于输入，你需要提供充分的跟Claude Code上下文规范的信息，并将这些信息已结构化的形式在交互的时候让用户提供。
对已经存在的项目，你需要感知分析提炼项目已经存在的规范或者模式，如果这些规范模式不符合最佳实践，可以以交互问答的形式让用户补充。


在信息输出端（最终针对特定项目的Claude Code上下文目录及规范文件）-通用需要规范标准化特定项目的Claude Code上下文目录及规范文件
为此，你需要提供适用于各种类型项目的Claude Code上下文目录及规范文件的原信息。这些元信息包括适用于所有类型项目的通用规范，规范的类型说明。

/init-context这个skill会根据在信息收集端的输入推断需要的规范。

同时在 /Users/jinhuasu/Project_Workspace/AI-Forge-Workspace/claude-context-templates/plugin/presets在这个目录下会提供匹配不同项目类型的规范模版，匹配上这些模版的项目可以直接使用。

以上当前的/init-context应该承载的功能

结合当前项目的实现设计相应的优化和重构方案

value-map


在深入全面的了解claude-context-templates项目的基础上帮我整理一份关于这个下面项目的详细介绍文档，内容应该包括项目背景、设计理念与原则、使用与实践，如果你不清楚这个文档的内容规划可以提问跟我一起讨论


在理解当前项目（claude-context-templates）的基础上将下面devpace项目的Claude code上下文规范：
/Users/jinhuasu/Project_Workspace/Anker-Projects/ml-platform-research/llm-platform-solution/claude-code-forge/devpace/.claude
转换为当前项目（claude-context-templates）的Claude code上下文规范


通用原则统一整理到ia-principles.md中，design-principles.md作为本项目基于ia-principles.md通用原则的具体说明，design-principles.md可以引用ia-principles.md，ia-principles.md不能引用design-principles.md


发现背景

  基于当前项目状态（Phase 1.5 收尾，Phase 2 待启动），以下是我从代码库和策略文档中识别到的 5 个探索方向。

  ---
  方向 1: 新 Preset 扩展（对齐 M2.2）

  当前 4 个 preset: python-fastapi, react-typescript, aws-cdk, generic。路线图提到 Go 和 Next.js/Vue。

  发现问题：
  - 你有没有收到过用户反馈要求特定技术栈的 preset？
  - Go preset 和 Next.js/Vue preset 哪个优先级更高？还是有其他技术栈更紧急（如 Django、Spring Boot、Rust）？
  - 是否考虑社区贡献 preset 而非自己维护？

  ---
  方向 2: Preset 可组合性（对齐 M2.1）

  当前 _common/ 已有 4 个跨 preset 工程原则。但 rule 级别的继承/组合机制尚未设计。

  发现问题：
  - 你设想的"组合"是什么形态？例如：一个 preset 可以 extends: generic 然后只覆盖特定 rules？
  - 还是更简单的方案 — 多个 preset 共享同一组 rules 文件？
  - 这对终端用户有什么可见的好处？

  ---
  方向 3: Plugin 能力增强

  当前 Plugin 有 2 个 command（init-context, audit-context）和 1 个 skill（context-setup）。

  发现问题：
  - 是否需要新的命令，如 /upgrade-context（从旧版模板升级）或 /add-rule（向已有 .claude/ 添加单个规范）？
  - context-setup skill 的自动触发效果如何？是否需要调优 description？

  ---
  方向 4: 社区贡献通道（对齐 M2.3）

  已有 CONTRIBUTING.md、Issue/PR 模板。但缺少 preset 贡献的具体流程。

  发现问题：
  - 社区贡献 preset 是否需要审核标准？如何保证质量一致性？
  - 是否需要一个 "preset 创建 CLI 工具" 或脚手架来降低贡献门槛？

  ---
  方向 5: 用户获取与验证（对齐 OBJ-4 MoS）

  Phase 1 成功标准是 "≥1 个确认的外部使用报告"，这是当前最关键的差距。

  发现问题：
  - 你目前有收到任何外部使用反馈吗（GitHub Issues、Discussions、邮件、社交媒体）？
  - 推广计划执行到哪一步了（Hacker News Show HN、掘金、知乎等渠道）？
  - 是否需要调整推广策略或先聚焦某个特定渠道？

  ---
  请选择你想深入探索的方向（可多选），或者提出你自己的想法。我会根据你的回答生成候选的 BR→PF 实体。