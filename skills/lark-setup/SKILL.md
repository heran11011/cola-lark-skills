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

**Design goal**: FULLY AUTOMATIC. The user does NOTHING except click twice in the browser for Feishu authorization. Cola handles every single command automatically — installing Node.js, installing lark-cli, configuring the app, and authorizing. Do NOT ask the user to run commands manually. Do NOT stop to explain what you're doing. Just do it.

**Official reference**: https://open.feishu.cn/document/no_class/mcp-archive/feishu-cli-installation-guide.md

## PRIORITY ZERO: Fix Shell on Windows

**This is the most common blocker.** On Windows, Cola's bash tool often fails with "No bash shell found" because Windows doesn't have bash. You MUST fix this FIRST before anything else.

**If your bash/shell tool returns "No bash shell found" or similar errors:**

1. Find your settings file. It is typically at one of these locations:
   - `C:\Users\<username>\.pi\agent\settings.json`
   - `C:\Users\<username>\.cola\agent\settings.json`
   Check which one exists using the file read tool.

2. Write (or update) the settings file to point to cmd.exe:
   ```json
   {
     "shellPath": "C:\\Windows\\System32\\cmd.exe"
   }
   ```

3. **After changing shellPath, you MUST tell the user to restart Cola.** The shell config is only loaded at startup. Say:
   > 我已经配好了命令行环境，需要重启一下 Cola 才能生效。请关闭 Cola 再重新打开，然后跟我说"继续连接飞书"。

4. After restart, test that commands work:
   ```
   echo hello
   ```
   If you get output → shell is working, proceed to Step 0.
   If still no output → try PowerShell path instead: `C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`

**DO NOT skip this step. DO NOT ask the user to install Git for Windows.** cmd.exe is already on every Windows machine.

## CRITICAL: Windows Command Compatibility

**Rules for ALL commands in ALL lark-* skills:**
- Do NOT use `which` — doesn't exist on Windows. Just run the command directly.
- Do NOT use `2>/dev/null` — not valid in cmd.exe.
- Do NOT chain with `&&` — not reliable cross-platform. Run commands **one at a time**.
- Do NOT use bash syntax like `$(...)`, `||`, pipes.
- `lark-cli` commands are cross-platform and work the same everywhere.
- On Windows, if `lark-cli` is not found by name, try full path: `%APPDATA%\npm\lark-cli.cmd`
- On Windows, if `npm` is not found by name, try full path: `C:\Progra~1\nodejs\npm.cmd`

**If commands run but return no output**, Cola may need to use the bat-file workaround:
1. Write a `.bat` file with the command
2. Execute the `.bat` file
3. Read the output from a result file

Example:
```
@echo off
echo STARTED > %TEMP%\lark-out.txt
call lark-cli doctor >> %TEMP%\lark-out.txt 2>&1
echo __DONE__ >> %TEMP%\lark-out.txt
```
Then read `%TEMP%\lark-out.txt`.

## Behavior: Be Proactive

When this skill is loaded, **immediately** run Step 0. If Feishu is not fully configured, **do not wait for the user to ask** — tell them:

> 我检测到你安装了飞书集成技能包，可以帮你读群消息、管任务、查日程、搜文档、查表格。
> 现在帮你连接飞书，只需要在浏览器里点两下就好。

Then proceed directly. **Do not stop between steps.** Do not explain each step. Do not ask "要继续吗？". The entire setup should feel like one continuous flow. Only speak to the user when they need to do something (click in browser).

## Step 0: Diagnose Current State

Run these one at a time:

```
node --version
```
If fails → Step 0.5

```
lark-cli --version
```
If fails → Step 1.

```
lark-cli doctor
```
**IMPORTANT**: `lark-cli doctor` does NOT support `--json` flag. Run it plain. Parse the text output (look for "pass" or "fail").

- `config_file` fail → Step 2
- `token_exists` fail or `token expired` → Step 3
- All pass → "You're Ready"

## Step 0.5: Auto-Install Node.js

Do NOT ask the user to install manually. Install it automatically.

**Windows:**
```
winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
```
If `winget` fails, try:
```
powershell -Command "Start-BitsTransfer -Source 'https://nodejs.org/dist/v22.15.0/node-v22.15.0-x64.msi' -Destination '$env:TEMP\node-install.msi'; Start-Process msiexec -ArgumentList '/i','$env:TEMP\node-install.msi','/quiet','/norestart' -Wait"
```

**macOS:**
```
curl -fsSL https://nodejs.org/dist/v22.15.0/node-v22.15.0.pkg -o /tmp/node.pkg && sudo installer -pkg /tmp/node.pkg -target /
```

After install on Windows, **PATH may not update until shell restarts**. If `node --version` still fails, tell user to restart Cola (one time only).

Immediately proceed to Step 1.

## Step 1: Install lark-cli and Feishu Skills

**Method A — Recommended (one command):**
```
npx @larksuite/cli@latest install
```
This installs lark-cli globally and adds Feishu skill components in one step.

**Method B — If Method A fails:**
Run two commands in order, one at a time:
```
npm install -g @larksuite/cli
```
```
npx -y skills add https://open.feishu.cn --skill -y
```

Verify:
```
lark-cli --version
```

If commands fail with "not found", try Windows full paths:
- `C:\Progra~1\nodejs\npm.cmd install -g @larksuite/cli`
- `C:\Progra~1\nodejs\npx.cmd @larksuite/cli@latest install`

Immediately proceed to Step 2.

## Step 2: Create App

```
lark-cli config init --new
```

**IMPORTANT**: Run this command in background (with a timeout). The command will output an authorization URL. Extract that URL and send it to the user.

Tell the user (this is the FIRST time you need to talk to them):
> 请点击下面的链接完成飞书应用配置（或扫码）：
> [paste the authorization URL from command output]
> 完成后我会自动继续。

**If timeout** ("max poll attempts reached"): just run the command again.

Verify:
```
lark-cli doctor
```
When `config_file` and `app_resolved` both "pass" → immediately Step 3.

## Step 3: Login and Authorize

```
lark-cli auth login --recommend
```

**IMPORTANT**: Same pattern as Step 2 — run in background, the command outputs an authorization URL. Extract and send to user.

Tell the user (SECOND and last time):
> 最后一步，点击下面的链接完成授权：
> [paste the authorization URL from command output]

Immediately proceed to Step 4.

## Step 4: Verify

```
lark-cli auth status
```

```
lark-cli doctor
```

If all pass → done.

## You're Ready

> 飞书已连接成功！你现在可以直接跟我说：
> - "看看群里有什么重要消息" — 读取飞书群消息并摘要
> - "我有什么任务" — 查看飞书待办
> - "明天有什么会" — 查看日程
> - "帮我搜一下周报" — 搜索飞书文档
> - "查一下表格里的数据" — 查询多维表格
>
> 试试看？

## Error Recovery

| 错误 | 解决 |
|------|------|
| No bash shell found | **Priority Zero**: 配置 shellPath 为 cmd.exe，然后重启 Cola |
| Commands run but no output | 用 bat 文件中转：写 bat → 执行 → 读结果文件 |
| `node` not found | winget install 或 msi 静默安装 |
| `npm` / `npx` not found | 试完整路径 `C:\Progra~1\nodejs\npm.cmd` |
| `lark-cli` not found | 先试 `npx @larksuite/cli@latest install`；失败则 `npm install -g @larksuite/cli` |
| `no config found` | `lark-cli config init --new` |
| `token expired` | `lark-cli auth login --recommend` |
| `missing_scope: xxx` | `lark-cli auth login --recommend`（会自动补充所需权限） |
| `max poll attempts reached` | 直接重试同一条命令 |
| `EACCES` / permission denied (npm) | 加 `--prefix` 或用管理员权限运行 |
| 安装后 `lark-cli` 仍找不到 | PATH 未刷新，重启 Cola 或用完整路径 `%APPDATA%\npm\lark-cli.cmd` |
| 网络超时 / ETIMEOUT | 检查网络连接，必要时设置 npm 代理：`npm config set proxy http://...` |
