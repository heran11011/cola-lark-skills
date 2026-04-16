---
name: lark-setup
description: >
  Set up Lark/Feishu (飞书) integration for Cola — install lark-cli, configure
  app credentials, authorize permissions. Use when the user wants to connect
  Feishu, set up Lark, or when any lark-* skill fails because lark-cli is
  not installed or not configured. Trigger phrases: "连接飞书", "接入飞书",
  "配置飞书", "飞书设置", "lark setup", "connect feishu",
  "lark-cli not found", "飞书授权".
  Also trigger when you detect lark-cli errors like "command not found",
  "no config", "missing_scope", or "token expired".
  PROACTIVE: If lark-cli is not installed or not configured, start this
  setup flow immediately without waiting for user to ask. Tell the user
  what Feishu skills are available and begin installation in one go.
---

# Lark Setup — Connect Cola to Feishu

**Design goal**: zero friction. The user should never have to ask "how do I set up Feishu" — Cola detects the state automatically and drives the entire setup. The user only clicks in the browser.

## Behavior: Be Proactive

When this skill is loaded, **immediately** run Step 0 to check the current state. If Feishu is not fully configured, **do not wait for the user to ask** — tell them what's available and start the setup right away:

> 我检测到你安装了飞书集成技能包，可以帮你读群消息、管任务、查日程、搜文档、查表格。
> 现在帮你连接飞书，只需要在浏览器里点两下就好。

Then proceed directly to whichever step is needed.

## Step 0: Diagnose Current State

```bash
which lark-cli 2>/dev/null && lark-cli --version 2>&1 && lark-cli doctor --json 2>&1 || echo "LARK_CLI_NOT_FOUND"
```

Based on output, jump to the right step:
- `LARK_CLI_NOT_FOUND` → Step 1
- `config_file` fail → Step 2
- `token_exists` fail or `token expired` → Step 3
- All pass → "You're Ready"

**Do not stop between steps.** Once you finish one step, immediately proceed to the next. The entire setup should feel like one continuous flow.

## Step 1: Install lark-cli

```bash
npm install -g @larksuite/cli
```

If npm is not available, tell the user to install Node.js first (https://nodejs.org). Otherwise, install and immediately proceed to Step 2.

## Step 2: Create App (Auto-detect completion)

Use `--new` which opens a browser for app creation. Run it **in background** so Cola can continue talking to the user:

```bash
# Run in background — it blocks until user completes browser flow
lark-cli config init --new --brand feishu
```

Tell the user:
> 我帮你打开了飞书应用创建页面，你在浏览器里点击确认就行。我会自动检测你是否完成。

**Auto-detect**: While the background command is running, periodically check:
```bash
lark-cli doctor --json 2>&1
```
When `config_file` and `app_resolved` both show `pass`, the app is created. **Immediately** move to Step 3.

## Step 3: Authorize + Permissions (Auto-detect completion)

Use the **non-blocking device flow** so Cola can monitor progress:

```bash
# Step 3a: Initiate authorization (returns immediately)
lark-cli auth login --no-wait --domain all --json
```

This returns JSON with:
- `verification_url` — the URL to show the user
- `device_code` — for polling completion
- `expires_in` — timeout in seconds (usually 600)

Tell the user:
> 请打开这个链接完成飞书授权：
> [显示 verification_url]
> 登录飞书账号并点击"授权"就好，我会自动检测授权结果。

```bash
# Step 3b: Poll for completion (run in background, blocks until authorized)
lark-cli auth login --device-code "<device_code from 3a>"
```

Run this in background. When it completes successfully, authorization is done. **Immediately** proceed to Step 4.

**Alternative**: If you prefer active polling instead of background blocking:
```bash
# Check every few seconds
lark-cli doctor --json 2>&1
```
When `token_exists` and `token_verified` both show `pass`, authorization is complete.

## Step 4: Verify and Report

```bash
lark-cli doctor --json 2>&1
```

If all checks pass, run a smoke test:
```bash
lark-cli calendar +agenda --format pretty 2>&1
```

## You're Ready

> 飞书已连接成功！你现在可以直接跟我说：
> - "看看群里有什么重要消息" — 读取飞书群消息并摘要
> - "我有什么任务" — 查看飞书待办
> - "明天有什么会" — 查看日程
> - "帮我搜一下周报" — 搜索飞书文档
> - "查一下表格里的数据" — 查询多维表格
>
> 试试看？比如我现在就可以帮你看看今天有什么日程。

## Error Recovery

| 错误 | 解决 |
|------|------|
| `command not found: lark-cli` | `npm install -g @larksuite/cli` |
| `no config found` | `lark-cli config init --new --brand feishu` |
| `token expired` | Run Step 3 again (non-blocking device flow) |
| `missing_scope: xxx` | `lark-cli auth login --no-wait --scope "xxx" --json` → get URL → poll with `--device-code` |
| `app not found` | `lark-cli config init --new --brand feishu` |

For `missing_scope`, use the same non-blocking pattern:
1. `lark-cli auth login --no-wait --scope "xxx" --json` → get verification_url
2. Show URL to user
3. `lark-cli auth login --device-code "<code>"` in background
4. Auto-retry the original command when authorization completes
