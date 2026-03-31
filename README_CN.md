# harness-init

基于 [OpenAI harness engineering](https://openai.com/index/harness-engineering/) 方法论，为任意代码仓库搭建 agent-first 开发脚手架。

> **范围说明：** 这是 harness engineering 的**仓库初始化子集**。运行时反馈回路、agent 互审、可观测性集成不在本 skill 范围内。

## 做什么

通过 8 个阶段将仓库转变为 agent-ready 环境：

| 阶段 | 内容 |
|------|------|
| 0. Discovery | 检测技术栈、映射架构、识别分层、注入动态上下文 |
| 1. AGENTS.md | ~100 行导向地图（索引，不是百科全书） |
| 2. docs/ | 单一事实来源：`architecture/LAYERS.md` + `golden-principles/` + `SECURITY.md` + `guides/` |
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
# 克隆并复制到用户级 skills（跨所有项目可用）
rm -rf /tmp/harness-init 2>/dev/null; git clone --depth 1 https://github.com/Gizele1/harness-init.git /tmp/harness-init
mkdir -p ~/.claude/skills/omc-learned/harness-init/references
cp /tmp/harness-init/SKILL.md ~/.claude/skills/omc-learned/harness-init/
cp /tmp/harness-init/references/*.md ~/.claude/skills/omc-learned/harness-init/references/
rm -rf /tmp/harness-init
```

### Claude Code（原生）

```bash
# 克隆并复制到项目级 skills
rm -rf /tmp/harness-init 2>/dev/null; git clone --depth 1 https://github.com/Gizele1/harness-init.git /tmp/harness-init
mkdir -p .claude/skills/harness-init/references
cp /tmp/harness-init/SKILL.md .claude/skills/harness-init/
cp /tmp/harness-init/references/*.md .claude/skills/harness-init/references/
rm -rf /tmp/harness-init
```

### OpenAI Codex

```bash
# 克隆并复制到 Codex skills 目录
rm -rf /tmp/harness-init 2>/dev/null; git clone --depth 1 https://github.com/Gizele1/harness-init.git /tmp/harness-init
mkdir -p .agents/skills/harness-init/references
cp /tmp/harness-init/SKILL.md .agents/skills/harness-init/
cp /tmp/harness-init/references/*.md .agents/skills/harness-init/references/
rm -rf /tmp/harness-init
```

### Cursor

将 `SKILL.md` 和 `references/` 目录复制到 `.cursor/rules/harness-init/` 目录中，或将参考内容内联到 `.cursorrules` 文件。

### 手动使用

直接阅读 `SKILL.md`，在任何 AI 编码助手中按阶段执行即可。

## 使用

在 Claude Code 中：

```
/harness-init          # 交互模式 — 询问要设置什么
/harness-init full     # 完整设置，全部阶段
/harness-init 2        # 只执行特定阶段
/harness-init 3-4      # 阶段范围
```

或者直接说：

- "harness init 这个项目"
- "把这个 repo 变成 agent-ready"
- "设置架构边界"

## 生成的文件结构

```
project-root/
├── AGENTS.md                          # ~100 行，导向地图                    [必须]
├── ARCHITECTURE.md                    # 顶层领域地图                         [必须]
├── docs/
│   ├── architecture/
│   │   └── LAYERS.md                  # 分层层级 + 强制执行                  [必须]
│   ├── golden-principles/             # DO/DON'T 模式，每个 30-60 行        [必须]
│   ├── SECURITY.md                    # 认证、密钥、威胁模型                  [必须]
│   ├── guides/                        # 开发环境、测试、部署                  [推荐]
│   ├── exec-plans/                    # ExecPlan 生命周期                    [推荐]
│   │   ├── active/
│   │   ├── completed/
│   │   └── tech-debt-tracker.md
│   ├── design-docs/                   # 架构决策记录 (ADR)                  [推荐]
│   │   ├── index.md
│   │   ├── core-beliefs.md
│   │   └── {NNNN-title}.md
│   ├── references/                    # 外部文档（LLM 友好格式）             [推荐]
│   │   └── {library}-llms.txt
│   ├── DESIGN.md                      # 设计哲学                             [推荐]
│   ├── PLANS.md                       # 执行计划概览                          [推荐]
│   ├── QUALITY_SCORE.md               # 各域质量评分                          [推荐]
│   ├── RELIABILITY.md                 # SLA、错误预算（仅服务类）             [条件]
│   ├── STACK.md                       # 技术栈约定                            [条件]
│   ├── product-specs/                 # 产品规格                              [条件]
│   └── generated/                     # 自动生成文档                          [条件]
│       └── {db-schema,api-spec}.md
├── scripts/gc/                        # 垃圾回收脚本
├── tests/architecture/
│   └── boundary.test.*                # 机械性层级强制
└── .github/workflows/
    ├── ci.yml                         # lint + typecheck + test + build
    └── gc.yml                         # 每周熵扫描
```

## 文件结构设计

以上文件结构综合了多个行业来源，并设计了清晰的优先级层次。

### 优先级层次

| 层次 | 含义 | 何时创建 |
|------|------|---------|
| **必须** | 每个 agent-ready 仓库都需要的核心脚手架 | 始终创建 — Phase 0-2 |
| **推荐** | 大多数项目都能受益的高价值文档 | 多人协作或生命周期 >3 个月的项目 |
| **条件** | 视项目类型而定 — 仅在需要时创建 | Phase 0 Discovery 阶段判断适用性 |

### 设计决策与来源

**AGENTS.md 放在仓库根目录** — 行业标准，已被 20,000+ 仓库采用（[agents.md 标准](https://agents-md.org/)）。作为任何 AI agent 的单一入口。保持 ~100 行作为索引而非百科全书 — 遵循 OpenAI 的「给 agent 一张地图」原则。

**ARCHITECTURE.md 放在根目录** — 顶层领域地图，无需深入 docs/ 即可查看。指向 `docs/architecture/LAYERS.md` 获取详情。遵循渐进式披露：根级文件是摘要，docs/ 有深度。

**docs/ 作为单一事实来源** — 将所有项目知识集中在一个可发现的位置。Agent 扫描 `docs/` 作为其主要上下文来源。这直接来自 OpenAI 的 harness engineering：「agent 看不到就不存在」。

**docs/architecture/LAYERS.md** — 权威的分层层级定义，通过边界测试（Phase 3）和 linter 规则（Phase 4）机械性强制执行。不仅是文档 — 它是工具链读取的事实来源。

**docs/golden-principles/** — 每个关注点的 30-60 行 DO/DON'T 文件（导入、命名、错误处理、测试）。短到 agent 可以完整消费，具体到能防止偏移。来自 OpenAI 的「典范模式」概念。

**docs/exec-plans/（active/completed/）** — 双来源设计：目录生命周期来自 [Harness 文章](https://openai.com/index/harness-engineering/)（active → completed + 回顾），单文件替代方案来自 [OpenAI Cookbook](https://developers.openai.com/cookbook/articles/codex_exec_plans)。活跃计划完成后移到 completed/，为下游 agent 保留上下文。

**docs/design-docs/ 采用 ADR 格式** — 架构决策记录遵循 `{NNNN-title}.md` 命名约定（[ADR 标准](https://adr.github.io/)）。`core-beliefs.md` 记录 agent 绝不能违反的不可协商决策。`index.md` 提供可导航列表。

**docs/SECURITY.md** — 将认证流程、密钥管理和威胁模型集中在一处。处理认证相关代码的 agent 需要此上下文以避免引入漏洞。

**条件文档（RELIABILITY.md、STACK.md、product-specs/、generated/）** — 仅在 Phase 0 Discovery 检测到相关项目类型时创建。RELIABILITY.md 用于有 SLA 的服务。STACK.md 以技术栈无关的名称替代 OpenAI 原始的 FRONTEND.md。product-specs/ 用于产品驱动的项目。generated/ 用于自动生成的 schema。

**QUALITY_SCORE.md 放在 docs/ 下而非根目录** — 保持仓库根目录整洁。只有 AGENTS.md 和 ARCHITECTURE.md 放在根目录，因为它们是通用入口。其他内容都放在 docs/ 中便于组织。

### 相对于 OpenAI 原始方案的变更

| OpenAI 原始方案 | harness-init | 原因 |
|----------------|-------------|------|
| FRONTEND.md | docs/STACK.md | 技术栈无关 — 适用于后端、移动端等 |
| .agent/PLANS.md | docs/exec-plans/ 或 docs/PLANS.md | 目录生命周期适合多功能项目，单文件适合简单项目 |
| 扁平 docs/ | 带优先级层次的 docs/ | Agent 知道什么是必须的，什么是可选的 |
| 无 ADR | docs/design-docs/ 采用 ADR 格式 | 为 agent 上下文捕获架构决策 |
| 无安全文档 | docs/SECURITY.md 作为必须项 | 安全上下文对 agent 安全是不可选的 |

## 上下文策略：静态 vs 动态

本 skill 区分两种类型的上下文：

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
- 质量评分自动化（提供模板，评分需手动）
- 设计文档版本管理工作流

这些能力需要运行时基础设施，超出了一个 skill 文件能提供的范围。

## 参考资料

- [Harness engineering: leveraging Codex in an agent-first world | OpenAI](https://openai.com/index/harness-engineering/)
- [Custom instructions with AGENTS.md | OpenAI Developers](https://developers.openai.com/codex/guides/agents-md)
- [Using PLANS.md for multi-hour problem solving | OpenAI Cookbook](https://developers.openai.com/cookbook/articles/codex_exec_plans)
- [Best practices | Codex](https://developers.openai.com/codex/learn/best-practices)
- [Harness Engineering | Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)

## 许可证

MIT
