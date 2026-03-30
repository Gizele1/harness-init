# harness-init

基于 [OpenAI harness engineering](https://openai.com/index/harness-engineering/) 方法论，为任意代码仓库搭建 agent-first 开发脚手架。

> **范围说明：** 这是 harness engineering 的**仓库初始化子集**。运行时反馈回路、agent 互审、可观测性集成不在本 skill 范围内。

## 做什么

通过 7 个阶段将仓库转变为 agent-ready 环境：

| 阶段 | 内容 |
|------|------|
| 0. Discovery | 检测技术栈、映射架构、识别分层、注入动态上下文 |
| 1. AGENTS.md | ~100 行导向地图（索引，不是百科全书） |
| 2. docs/ | 单一事实来源：`architecture/LAYERS.md` + `golden-principles/` + `guides/` |
| 3. Testing | 架构边界测试 + 棘轮机制（KNOWN_VIOLATIONS 只能缩减） |
| 4. Linting | 导入限制规则（错误信息内含修复指令） |
| 5. CI | 并行 lint + typecheck + test + build 流水线 |
| 6. GC | 垃圾回收扫描脚本 + 每周定时执行 |
| 7. Hooks | Pre-commit 拦截 |

## 核心原则（来自 OpenAI）

1. 工程师成为环境设计师 — 定义约束，而非实现
2. 给 agent 一张地图，不是百科全书 — AGENTS.md ~100 行，渐进式披露
3. agent 看不到就不存在 — 所有知识必须机器可读且在 repo 内
4. 用机械手段强制架构 — linter 和测试，而非 markdown 指令
5. 无聊技术赢 — 可组合、稳定、被充分训练过的 API
6. 熵管理就是垃圾回收 — 定期清理 agent
7. 吞吐量改变合并哲学 — 最小阻塞门禁
8. Agent 之间互审代码 — 人类仅介入判断决策

## 安装

### Claude Code（配合 oh-my-claudecode）

```bash
mkdir -p ~/.claude/skills/omc-learned/harness-init
curl -fsSL https://raw.githubusercontent.com/Gizele1/harness-init/main/SKILL.md \
  -o ~/.claude/skills/omc-learned/harness-init/SKILL.md
```

### Claude Code（原生）

```bash
mkdir -p .claude/skills/harness-init
curl -fsSL https://raw.githubusercontent.com/Gizele1/harness-init/main/SKILL.md \
  -o .claude/skills/harness-init/SKILL.md
```

### OpenAI Codex

```bash
mkdir -p .agents/skills/harness-init
curl -fsSL https://raw.githubusercontent.com/Gizele1/harness-init/main/SKILL.md \
  -o .agents/skills/harness-init/SKILL.md
```

### Cursor

将 `SKILL.md` 内容复制到 `.cursor/rules/harness-init.md` 或 `.cursorrules` 文件中。

### 手动使用

直接阅读 `SKILL.md`，在任何 AI 编码助手中按阶段执行即可。

## 使用

在 Claude Code 中：

```
/harness-init          # 完整设置，全部阶段
/harness-init 2        # 只执行特定阶段
```

或者直接说：

- "harness init 这个项目"
- "把这个 repo 变成 agent-ready"
- "设置架构边界"

## 生成的文件结构

```
project-root/
├── AGENTS.md                          # ~100 行，导向地图
├── .agent/
│   └── PLANS.md                       # ExecPlan 模板标准
├── docs/
│   ├── architecture/
│   │   └── LAYERS.md                  # 分层依赖规则
│   ├── guides/
│   │   ├── setup.md                   # 本地开发环境
│   │   ├── testing.md                 # 测试约定
│   │   └── deployment.md             # 部署流程
│   └── golden-principles/             # 每个 30-60 行，DO/DON'T
│       ├── IMPORTS.md
│       ├── NAMING.md
│       ├── ERROR_HANDLING.md
│       └── TESTING.md
├── scripts/gc/                        # 垃圾回收脚本
├── tests/architecture/
│   └── boundary.test.*                # 机械性层级强制
└── .github/workflows/
    ├── ci.yml                         # lint + typecheck + test + build
    └── gc.yml                         # 每周熵扫描
```

## 上下文策略：静态 vs 动态

**静态上下文**（写在 repo 里，随时可读）：
- `AGENTS.md` — agent 入口索引，~100 行
- `docs/architecture/LAYERS.md` — 分层依赖的权威定义
- `docs/golden-principles/*.md` — 典范模式
- linter 规则 + 边界测试 — 机械性强制

**动态上下文**（每次会话启动时探测）：
- `git status` + `git log` — 工作进度
- LSP diagnostics — 代码健康度
- CI/CD 状态 — 流水线健康度
- 架构边界测试运行 — 合规检查

## 支持的技术栈

适用于任何技术栈。内置分层模板：

- Web Frontend（React / Vue / Svelte）
- Backend API（Express / FastAPI / Rails）
- Full-Stack（Next.js / Nuxt / SvelteKit）
- Monorepo（Turborepo / Nx）

Skill 通过读取实际的 import 模式来发现真实的依赖图，而不是假设一个结构。

## 局限性

本 skill 实现的是 OpenAI harness engineering 方法论中的**仓库脚手架**部分。**不包含**：

- 运行时可读性（启动应用、浏览器/CDP 验证）
- 可观测性集成（日志/指标/trace 供 agent 查询）
- Agent 互审回路（agent-to-agent PR review）
- 自动回归验证
- PR 反馈迭代循环
- 质量评分和追踪
- 设计文档和产品规格版本管理

这些能力需要运行时基础设施，超出了一个 skill 文件能提供的范围。

## 参考资料

- [Harness engineering: leveraging Codex in an agent-first world | OpenAI](https://openai.com/index/harness-engineering/)
- [Custom instructions with AGENTS.md | OpenAI Developers](https://developers.openai.com/codex/guides/agents-md)
- [Using PLANS.md for multi-hour problem solving | OpenAI Cookbook](https://developers.openai.com/cookbook/articles/codex_exec_plans)
- [Best practices | Codex](https://developers.openai.com/codex/learn/best-practices)
- [Harness Engineering | Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)

## 许可证

MIT
