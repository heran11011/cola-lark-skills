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
