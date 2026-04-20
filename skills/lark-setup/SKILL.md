---
name: lark-setup
description: >
  Use when the user wants to connect Feishu, set up Lark integration,
  or when any lark-* skill fails. Trigger on: "连接飞书", "接入飞书",
  "配置飞书", "飞书设置", "lark setup", "connect feishu", "飞书授权",
  or lark-cli errors like "command not found", "no config", "missing_scope",
  "token expired". Also trigger proactively when lark-cli is missing or
  unconfigured — start setup immediately without waiting for user to ask.
---

# Lark Setup — Connect Cola to Feishu

## Overview

Fully automatic Feishu integration setup. The user only clicks browser links for authorization — Cola handles Node.js installation, lark-cli setup, app configuration, and permission grants as one continuous flow. Only speak to the user when they need to act.

Official reference: https://open.feishu.cn/document/no_class/mcp-archive/feishu-cli-installation-guide.md

## When to Use

- User asks to connect Feishu or set up Lark
- Any lark-* skill fails with missing CLI or auth errors
- `lark-cli doctor` shows failures
- Proactively: skill pack is installed but lark-cli isn't configured

When loaded, immediately run Step 0 and tell the user:

> 我检测到你安装了飞书集成技能包，可以帮你读群消息、管任务、查日程、搜文档、查表格。
> 现在帮你连接飞书，只需要在浏览器里点两下就好。

## Quick Reference

| 状态 | 跳转 |
|------|------|
| `node` not found | Step 0.5 |
| `lark-cli` not found | Step 1 |
| config_file: fail | Step 2 |
| app_resolved: fail | Step 2 |
| token_exists: fail | Step 3 |
| token expired | Step 3 |
| 全部 pass | 完成 |

## Verify Shell First

Many Windows machines don't have bash — test before anything else:

```
echo hello
```

If output is "hello", proceed. If errors or no output, read [references/windows-compat.md](./references/windows-compat.md) for shell configuration (setting shellPath to cmd.exe, restart Cola, etc).

## Step 0: Diagnose

Run each separately (`lark-cli doctor` doesn't support `--json`, parse text output for "pass"/"fail"):

```
node --version
lark-cli --version
lark-cli doctor
```

Use Quick Reference table above for routing.

## Step 0.5: Install Node.js

Install silently — don't ask user to do this.

**Windows:**
```
winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
```
If `winget` is not available (older Windows), download the latest LTS installer from https://nodejs.org and run it silently:
```
$nodeUrl = (Invoke-WebRequest -Uri "https://nodejs.org/dist/index.json" -UseBasicParsing | ConvertFrom-Json | Where-Object { $_.lts } | Select-Object -First 1).version
Invoke-WebRequest -Uri "https://nodejs.org/dist/$nodeUrl/node-$nodeUrl-x64.msi" -OutFile "$env:TEMP\node-install.msi"
Start-Process msiexec -ArgumentList "/i","$env:TEMP\node-install.msi","/quiet","/norestart" -Wait
```

**macOS:**
```
brew install node
```
If `brew` is not available, download the latest LTS `.pkg` from https://nodejs.org and install:
```
curl -fsSL https://nodejs.org/en/download/ -o /dev/null
```
Tell the user: "请前往 https://nodejs.org 下载最新 LTS 版本安装"

If `node` still not found after install, PATH hasn't refreshed — tell user to restart Cola once.

## Step 1: Install lark-cli

```
npx @larksuite/cli@latest install
```

If that fails:
```
npm install -g @larksuite/cli
```

Verify: `lark-cli --version`. If "not found", see [references/windows-compat.md](./references/windows-compat.md) for full path alternatives.

## Step 2: Create App

This command blocks while waiting for browser authorization. If run directly, shell timeout kills it and the callback server dies with it — user completes auth but config never writes. Use background execution.

**Bash / Git Bash:**
```bash
nohup lark-cli config init --new > /tmp/lark-init-output.txt 2>&1 &
sleep 5 && cat /tmp/lark-init-output.txt
```

**cmd.exe** — see [references/windows-compat.md](./references/windows-compat.md) for `start /b` pattern.

Extract the authorization URL and tell the user (first interaction):
> 请点击下面的链接完成飞书应用配置（或扫码）：
> [URL]
> 完成后我会自动继续。

After user clicks, re-read output file. "应用配置成功" or "OK" = success. Still waiting = wait a few more seconds. "max poll attempts reached" = re-run command.

Verify: `lark-cli doctor` — `config_file` and `app_resolved` both pass → Step 3.

## Step 3: Authorize Permissions

Same background pattern as Step 2:

```bash
nohup lark-cli auth login --recommend > /tmp/lark-auth-output.txt 2>&1 &
sleep 5 && cat /tmp/lark-auth-output.txt
```

Tell user (second interaction):
> 最后一步，点击下面的链接完成授权：
> [URL]

### Supplement search scope

`--recommend` doesn't include `search:docs:read`, which lark-docs needs. After recommend auth succeeds:

```bash
nohup lark-cli auth login --scope "search:docs:read" > /tmp/lark-search-scope.txt 2>&1 &
sleep 5 && cat /tmp/lark-search-scope.txt
```

Send link to user. If already covered by `--recommend`, command auto-skips.

## Step 4: Verify

```
lark-cli auth status
lark-cli doctor
```

All pass → done.

## You're Ready

> 飞书已连接成功！你现在可以直接跟我说：
> - "看看群里有什么重要消息" — 读取飞书群消息并摘要
> - "我有什么任务" — 查看飞书待办
> - "明天有什么会" — 查看日程
> - "帮我搜一下周报" — 搜索飞书文档
> - "查一下表格里的数据" — 查询多维表格
>
> 试试看？

## Common Mistakes

| 错误 | 原因与解决 |
|------|-----------|
| No bash shell found | Windows 没有 bash，配置 shellPath 为 cmd.exe 后重启 Cola（见 [windows-compat.md](./references/windows-compat.md)） |
| 命令执行无输出 | cmd.exe 偶发问题，用 bat 文件中转（见 [windows-compat.md](./references/windows-compat.md)） |
| 授权成功但 config 没写入 | 命令被超时杀掉了，callback server 一起死了。用后台执行模式重试 |
| `missing_scope: xxx` | `lark-cli auth login --recommend` 补权限 |
| `max poll attempts reached` | 直接重试同一条命令 |
| 安装后命令仍找不到 | PATH 未刷新，重启 Cola 或用完整路径（见 [windows-compat.md](./references/windows-compat.md)） |
| 网络超时 / ETIMEOUT | 检查网络，必要时 `npm config set proxy http://...` |
