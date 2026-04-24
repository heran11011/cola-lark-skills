---
name: lark-calendar
description: >
  View and manage Lark/Feishu (飞书) calendar — check today's agenda,
  upcoming meetings, create events. Use when the user asks about meetings,
  calendar, schedule, agenda, or events. Trigger phrases: "明天有什么会",
  "今天的日程", "这周有什么安排", "帮我建个会议", "日程", "日历",
  "有什么会议", "agenda", "schedule".
---

# Lark Calendar

View and manage Feishu calendar via `lark-cli`.

## View Agenda

```
# Today's events
lark-cli calendar +agenda

# Tomorrow — use --start and --end for single-day range (replace <YYYY-MM-DD> with actual date)
lark-cli calendar +agenda --start "<YYYY-MM-DD>T00:00:00+08:00" --end "<YYYY-MM-DD>T23:59:59+08:00"

# Date range (e.g. next 7 days) — calculate start and end dates
lark-cli calendar +agenda --start "<today>T00:00:00+08:00" --end "<7 days later>T00:00:00+08:00"

# This week (Monday to Sunday) — calculate this week's Monday and next Monday
lark-cli calendar +agenda --start "<this Monday>T00:00:00+08:00" --end "<next Monday>T00:00:00+08:00"

# Check all flags
lark-cli calendar +agenda --help
```

**IMPORTANT**: There is NO `--days` or `--date` flag. For any specific date or range, you MUST use `--start` / `--end` in ISO 8601 format with Beijing timezone (+08:00). For a single day, set start to 00:00:00 and end to 23:59:59.

Use `--format pretty` for human-readable output instead of raw JSON.

## Create an Event

```
lark-cli calendar +create --summary "会议标题" \
  --start "<YYYY-MM-DD>T14:00:00+08:00" \
  --end "<YYYY-MM-DD>T15:00:00+08:00"

# Check all flags for inviting attendees, etc.
lark-cli calendar +create --help
```

## Other Operations

```
# Check someone's availability
lark-cli calendar +freebusy --help

# RSVP to an event
lark-cli calendar +rsvp --help

# Suggest meeting times
lark-cli calendar +suggestion --help
```

## Tips

- All times use Beijing timezone (+08:00)
- When the user says "明天", calculate tomorrow's date
- Run `--help` before guessing flags
- Use `--format pretty` for readable output

## Feedback: Report Issues

If a command fails and recovery doesn't work, help the user submit a GitHub Issue.

### 提交 issue 流程（优先自动提交）

**Step 1: 检查 gh CLI 登录态**

```bash
gh auth status
```

**Step 2a: 如果已登录 GitHub → 直接帮用户提 issue**

整理好以下信息，展示给用户确认：
- 标题：`[lark-calendar] <一句话描述问题>`
- 内容：错误日志、`node --version`、`lark-cli --version`、操作系统、复现步骤

用户确认后，执行：

```bash
gh issue create --repo heran11011/cola-lark-skills \
  --title "[lark-calendar] 问题标题" \
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


---

## ⚠️ Security / 安全提示

When constructing shell commands, always sanitize user input to prevent command injection. Wrap dynamic values in single quotes and escape any embedded single quotes. Never pass raw user input directly into shell command strings.

构造 shell 命令时，务必对用户输入进行转义以防止命令注入。用单引号包裹动态值，并转义其中的单引号。不要将原始用户输入直接拼接到命令字符串中。
