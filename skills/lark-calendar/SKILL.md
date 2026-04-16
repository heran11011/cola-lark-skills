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

```bash
# Today's events
lark-cli calendar +agenda

# Tomorrow — use --start and --end for single-day range
lark-cli calendar +agenda --start "2026-04-16T00:00:00+08:00" --end "2026-04-16T23:59:59+08:00"

# Date range (e.g. next 7 days) — use --start and --end with ISO 8601
lark-cli calendar +agenda --start "2026-04-15T00:00:00+08:00" --end "2026-04-22T00:00:00+08:00"

# Check all flags
lark-cli calendar +agenda --help
```

**IMPORTANT**: There is NO `--days` or `--date` flag. For any specific date or range, you MUST use `--start` / `--end` in ISO 8601 format with Beijing timezone (+08:00). For a single day, set start to 00:00:00 and end to 23:59:59.

Use `--format pretty` for human-readable output instead of raw JSON.

## Create an Event

```bash
lark-cli calendar +create --summary "会议标题" \
  --start "2026-04-16T14:00:00+08:00" \
  --end "2026-04-16T15:00:00+08:00"

# Check all flags for inviting attendees, etc.
lark-cli calendar +create --help
```

## Other Operations

```bash
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
