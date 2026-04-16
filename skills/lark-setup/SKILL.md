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

**Design goal**: FULLY AUTOMATIC. Do not ask the user to download or install anything manually. Cola detects what's missing and installs everything by itself. The user only clicks in the browser for Feishu authorization.

## Cross-Platform Notes

Cola runs in PowerShell on Windows and bash/zsh on macOS/Linux. All commands must work on both.
- Do NOT use `which`, `2>/dev/null`, or `&&` chaining — not cross-platform safe
- Run commands **one at a time**
- `lark-cli` commands are cross-platform, no changes needed

## Behavior: Be Proactive

When this skill is loaded, **immediately** run Step 0. If Feishu is not fully configured, **do not wait for the user to ask** — tell them what's available and start setup right away:

> 我检测到你安装了飞书集成技能包，可以帮你读群消息、管任务、查日程、搜文档、查表格。
> 现在帮你连接飞书，只需要在浏览器里点两下就好。

Then proceed directly. **Do not stop between steps.** The entire setup should feel like one continuous flow.

## Step 0: Diagnose Current State

Run these one at a time:

```
node --version
```
If fails → Step 0.5

```
lark-cli --version
```
If fails → Step 1

```
lark-cli doctor --json
```
- `config_file` fail → Step 2
- `token_exists` fail or `token expired` → Step 3
- All pass → "You're Ready"

## Step 0.5: Auto-Install Node.js

Do NOT ask the user to install Node.js. Install it automatically.

**Windows (PowerShell):**
```
winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
```
If `winget` is not available (older Windows), fall back to direct download:
```
Invoke-WebRequest -Uri "https://nodejs.org/dist/v22.15.0/node-v22.15.0-x64.msi" -OutFile "$env:TEMP\node-install.msi"
Start-Process msiexec -ArgumentList "/i","$env:TEMP\node-install.msi","/quiet","/norestart" -Wait
```

**macOS:**
```
curl -fsSL https://nodejs.org/dist/v22.15.0/node-v22.15.0.pkg -o /tmp/node.pkg && sudo installer -pkg /tmp/node.pkg -target /
```

After install, verify:
```
node --version
```

Tell the user:
> 正在安装运行环境，稍等一下...

Then immediately proceed to Step 1.

## Step 1: Install lark-cli

```
npm install -g @larksuite/cli
```

Verify:
```
lark-cli --version
```

Then immediately proceed to Step 2.

## Step 2: Create App (Auto-detect completion)

```
lark-cli config init --new --brand feishu
```

Run in background. Tell the user:
> 我帮你打开了飞书应用创建页面，你在浏览器里点击确认就行。我会自动检测你是否完成。

**Auto-detect**: Periodically check:
```
lark-cli doctor --json
```
When `config_file` and `app_resolved` both show `pass` → **immediately** move to Step 3.

## Step 3: Authorize + Permissions (Auto-detect completion)

```
lark-cli auth login --no-wait --domain all --json
```

Returns JSON with `verification_url` and `device_code`.

Tell the user:
> 请打开这个链接完成飞书授权：
> [显示 verification_url]
> 登录飞书账号并点击"授权"就好，我会自动检测授权结果。

Poll for completion in background:
```
lark-cli auth login --device-code "<device_code>"
```

When done → **immediately** proceed to Step 4.

## Step 4: Verify and Report

```
lark-cli doctor --json
```

Smoke test:
```
lark-cli calendar +agenda --format pretty
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
| `node` not found | Auto-install: winget (Win) / curl+installer (Mac) |
| `winget` not found | Fall back to MSI silent install |
| `npm` not found | Node.js not in PATH — restart shell or use full path |
| `lark-cli` not found | `npm install -g @larksuite/cli` |
| `no config found` | `lark-cli config init --new --brand feishu` |
| `token expired` | Run Step 3 again |
| `missing_scope: xxx` | `lark-cli auth login --no-wait --scope "xxx" --json` → poll |
| `app not found` | `lark-cli config init --new --brand feishu` |
