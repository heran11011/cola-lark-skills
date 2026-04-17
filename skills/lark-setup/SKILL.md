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

## CRITICAL: Windows Shell Compatibility

Cola on Windows may use cmd.exe, PowerShell, or bash. You MUST handle all cases:

**Rules for ALL commands in ALL lark-* skills:**
- Do NOT use `which` — it doesn't exist on Windows. Just run the command and check if it errors.
- Do NOT use `2>/dev/null` — not valid in cmd.exe. Just let errors appear.
- Do NOT chain with `&&` — not reliable cross-platform. Run commands **one at a time**.
- Do NOT use `bash` syntax like `$(...)`, `||`, pipes, etc.
- `lark-cli` commands themselves are cross-platform and work the same everywhere.
- On Windows, `lark-cli` may be installed at `%APPDATA%\npm\lark-cli.cmd`. If `lark-cli` is not found, try the full path.
- On Windows, if direct commands don't work, Cola may need to write a `.bat` file, execute it, and read the output file. This is expected behavior — the Skill should not assume direct command execution always works.

**Windows bat file pattern** (for when direct shell execution fails):
```
@echo off
lark-cli doctor > %TEMP%\lark-result.txt 2>&1
type %TEMP%\lark-result.txt
```

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
If fails → try full path on Windows: `%APPDATA%\npm\lark-cli.cmd --version`. If still fails → Step 1.

```
lark-cli doctor
```
**IMPORTANT**: `lark-cli doctor` does NOT support `--json` flag. Run it without any flags. Parse the text output to check status (look for "pass" or "fail" in each line).

- `config_file` fail → Step 2
- `token_exists` fail or `token expired` → Step 3
- All pass → "You're Ready"

## Step 0.5: Auto-Install Node.js

Do NOT ask the user to install Node.js. Install it automatically.

**Windows:**
```
winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
```
If `winget` is not available, tell the user:
> 需要安装 Node.js 运行环境。请打开 https://nodejs.org 下载安装，安装完成后告诉我。

**macOS:**
```
curl -fsSL https://nodejs.org/dist/v22.15.0/node-v22.15.0.pkg -o /tmp/node.pkg && sudo installer -pkg /tmp/node.pkg -target /
```

After install, verify:
```
node --version
```

**Important**: After installing Node.js on Windows, you may need to restart the shell or open a new terminal for `node` and `npm` to be available in PATH. If `node --version` still fails after install, ask the user to restart Cola.

Tell the user:
> 正在安装运行环境，稍等一下...

Then immediately proceed to Step 1.

## Step 1: Install lark-cli

```
npm install -g @larksuite/cli
```

If `npm` is not found on Windows, try the full path:
```
C:\Progra~1\nodejs\npm.cmd install -g @larksuite/cli
```

Verify:
```
lark-cli --version
```

If `lark-cli` is not found after install, on Windows it may be at:
- `%APPDATA%\npm\lark-cli.cmd`
- `C:\Users\<username>\AppData\Roaming\npm\lark-cli.cmd`

Then immediately proceed to Step 2.

## Step 2: Create App (Auto-detect completion)

```
lark-cli config init --new --brand feishu
```

This command blocks until the user completes the browser flow (scan QR code or click link). It may show a QR code in the terminal and a URL link.

Tell the user:
> 我帮你打开了飞书应用创建页面。你可以扫描终端里的二维码，或者点击链接完成配置。

**Timeout handling**: This command polls up to 200 times (~10 minutes). If it times out with "max poll attempts reached", just run it again — the second attempt usually works because the user already created the app.

**Auto-detect**: After the command completes, verify:
```
lark-cli doctor
```
When output shows `config_file` and `app_resolved` both "pass" → **immediately** move to Step 3.

## Step 3: Authorize + Permissions (Auto-detect completion)

```
lark-cli auth login --no-wait --domain all --json
```

This returns JSON with `verification_url` and `device_code`.

Tell the user:
> 请打开这个链接完成飞书授权：
> [显示 verification_url]
> 登录飞书账号并点击"授权"就好，我会自动检测授权结果。

Poll for completion:
```
lark-cli auth login --device-code "<device_code>"
```

This command blocks until the user authorizes. When done, it prints the result.

When done → **immediately** proceed to Step 4.

## Step 4: Verify and Report

```
lark-cli doctor
```

Check that `token_exists` and `token_verified` both show "pass".

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
| `winget` not found | Ask user to install Node.js from https://nodejs.org |
| `npm` not found | Node.js not in PATH — try full path `C:\Progra~1\nodejs\npm.cmd` or restart shell |
| `lark-cli` not found | `npm install -g @larksuite/cli`, then check `%APPDATA%\npm\lark-cli.cmd` |
| `no config found` | `lark-cli config init --new --brand feishu` |
| `token expired` | Run Step 3 again |
| `missing_scope: xxx` | `lark-cli auth login --no-wait --scope "xxx" --json` → poll |
| `app not found` | `lark-cli config init --new --brand feishu` |
| `max poll attempts reached` | Just retry the same command — user may have already completed in browser |
| shell errors on Windows | Try writing commands to a .bat file, execute it, read the output file |
