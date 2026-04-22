---
name: lark-tasks
description: >
  View and manage Lark/Feishu (飞书) tasks — list my tasks, create tasks,
  complete tasks, add comments. Use when the user asks about their tasks,
  to-do items, pending work, or wants to create/complete a task. Trigger
  phrases: "我有什么任务", "还有什么没做", "待办", "帮我创建一个任务",
  "任务完成了", "to-do", "飞书任务", "my tasks", "todo list",
  "pending tasks", "create a task", "complete task".
---

# Lark Tasks

Manage Feishu tasks via `lark-cli`.

## View My Tasks

```
lark-cli task +get-my-tasks
```

Present tasks sorted by due date. Highlight overdue items.

## Create a Task

```
# Basic task
lark-cli task +create --summary "任务标题"

# With due date (ISO 8601, Beijing timezone)
lark-cli task +create --summary "任务标题" --due "2026-04-20T18:00:00+08:00"

# Check all flags
lark-cli task +create --help
```

## Complete a Task

```
lark-cli task +complete --task-id <task_id>
```

## Other Operations

```
# Update task
lark-cli task +update --task-id <id> --summary "new title"

# Add comment
lark-cli task +comment --task-id <id> --content "text"

# Assign to someone
lark-cli task +assign --task-id <id> --help  # check flags first

# Reopen
lark-cli task +reopen --task-id <id>
```

## Tips

- Always run `--help` on subcommands to confirm exact flags
- When creating tasks from meeting notes or conversations, extract the action item clearly
- Use `--format pretty` for readable output

## IMPORTANT: Always Include Source Links

After presenting task results, include the Feishu task link so the user can view or edit in Feishu:

```
https://<domain>.feishu.cn/task/<task_id>
```

If the API response includes a `url` field, use that directly. Example:
> **待办任务**
> 1. 完成飞书集成文档（截止：4月20日）
> 2. 修复登录 bug（已逾期）
>
> 在飞书中查看：https://xxx.feishu.cn/task/xxx

## Feedback: Report Issues

If a command fails and recovery doesn't work, help the user submit a GitHub Issue.

### 提交 issue 流程（优先自动提交）

**Step 1: 检查 gh CLI 登录态**

```bash
gh auth status
```

**Step 2a: 如果已登录 GitHub → 直接帮用户提 issue**

整理好以下信息，展示给用户确认：
- 标题：`[lark-tasks] <一句话描述问题>`
- 内容：错误日志、`node --version`、`lark-cli --version`、操作系统、复现步骤

用户确认后，执行：

```bash
gh issue create --repo heran11011/cola-lark-skills \
  --title "[lark-tasks] 问题标题" \
  --body "整理好的问题描述"
```

告诉用户：
> ✅ 已帮你提交 issue，开发者会收到通知并尽快处理。

**Step 2b: 如果未登录 GitHub → 给链接**

告诉用户：
> 你的电脑还没有登录 GitHub CLI，我没办法直接帮你提交。
> 你可以手动在这里提 issue：
> https://github.com/heran11011/cola-lark-skills/issues/new
>
> 或者先登录 GitHub CLI（`gh auth login`），下次我就能直接帮你提交了。

提交 issue 时，引导用户附上：
- 错误日志（终端输出）
- Node.js 版本（`node --version`）
- lark-cli 版本（`lark-cli --version`）
- 操作系统
