> ⚠️ **Disclaimer / 免责声明**
> 
> This is a community project, NOT officially maintained by Feishu (Lark) or ByteDance.
> Use at your own risk. The author is not responsible for any data loss or security issues.
> 
> 本项目为社区作品，**非飞书（Feishu/Lark）/ 字节跳动官方提供或维护**。使用风险自负，作者不对任何数据丢失或安全问题承担责任。

# Cola Lark Skills - 飞书集成技能包

> v1.0.0

[English](#english) | [中文](#中文)

---

## 中文

### 简介

为 [Cola](https://cola.dev) 打造的飞书（Lark）集成技能包。安装后，你可以用自然语言让 Cola 帮你操作飞书——读消息、查日程、管任务、搜文档、查表格，一句话搞定。

### 包含的 Skills

| Skill | 功能 | 触发示例 |
|-------|------|---------|
| **lark-setup** | 飞书连接引导 | "帮我连接飞书" |
| **lark-messages** | 群消息阅读与摘要 | "看看群里有什么重要消息" |
| **lark-tasks** | 任务管理 | "我有什么任务" |
| **lark-calendar** | 日历/日程查看 | "明天有什么会" |
| **lark-docs** | 文档搜索与阅读 | "帮我搜一下周报" |
| **lark-base** | 多维表格查询 | "查一下表格里的数据" |

### 安装

#### 方法一：一键安装（推荐）

**macOS / Linux：**
```bash
git clone https://github.com/heran11011/cola-lark-skills.git
cd cola-lark-skills
chmod +x install.sh
./install.sh
```

**Windows：**
```cmd
git clone https://github.com/heran11011/cola-lark-skills.git
cd cola-lark-skills
install.bat
```

#### 方法二：手动安装

把 `skills/` 目录下的 6 个文件夹复制到 Cola 的 skills 目录：

| 系统 | 路径 |
|------|------|
| macOS / Linux | `~/.cola/mods/default/skills/` |
| Windows | `%USERPROFILE%\.cola\mods\default\skills\` |

### 前置条件

- [Cola](https://cola.dev)
- [Node.js](https://nodejs.org)（lark-cli 依赖）

不需要提前安装 lark-cli——对 Cola 说"帮我连接飞书"，它会自动引导你完成所有配置。

### 使用

安装后直接对 Cola 说：

```
帮我连接飞书
```

Cola 会自动：
1. 安装 lark-cli（如果没装）
2. 在浏览器里引导你创建飞书应用（一键）
3. 完成授权和权限配置（一键）
4. 自动检测每一步的完成状态

全程你只需要在浏览器里点两次确认。

连接成功后，试试这些：
- "看看群里有什么重要消息"
- "我有什么任务"
- "这周有什么会"
- "帮我搜一下周报"
- "查一下表格里的数据"

---

## English

### Introduction

Lark/Feishu integration skill pack for [Cola](https://cola.dev). After installation, use natural language to let Cola help you with Feishu — read messages, check calendar, manage tasks, search documents, and query tables.

### Included Skills

| Skill | Function | Trigger Example |
|-------|----------|----------------|
| **lark-setup** | Feishu connection setup | "connect to Feishu" |
| **lark-messages** | Group message reading & summary | "what's new in the group chat" |
| **lark-tasks** | Task management | "what are my tasks" |
| **lark-calendar** | Calendar & schedule | "any meetings tomorrow" |
| **lark-docs** | Document search & reading | "search for weekly reports" |
| **lark-base** | Bitable (spreadsheet) queries | "check the data in the table" |

### Installation

#### Option 1: Quick Install (Recommended)

**macOS / Linux:**
```bash
git clone https://github.com/heran11011/cola-lark-skills.git
cd cola-lark-skills
chmod +x install.sh
./install.sh
```

**Windows:**
```cmd
git clone https://github.com/heran11011/cola-lark-skills.git
cd cola-lark-skills
install.bat
```

#### Option 2: Manual Install

Copy the 6 folders under `skills/` to Cola's skills directory:

| OS | Path |
|----|------|
| macOS / Linux | `~/.cola/mods/default/skills/` |
| Windows | `%USERPROFILE%\.cola\mods\default\skills\` |

### Prerequisites

- [Cola](https://cola.dev)
- [Node.js](https://nodejs.org) (required by lark-cli)

No need to install lark-cli in advance — just tell Cola "connect to Feishu" and it will guide you through the entire setup automatically.

### Usage

After installation, just tell Cola:

```
帮我连接飞书
```

Cola will automatically:
1. Install lark-cli (if not present)
2. Guide you to create a Feishu app in the browser (one click)
3. Complete authorization and permission setup (one click)
4. Auto-detect completion of each step

You only need to click twice in the browser.

Once connected, try:
- "看看群里有什么重要消息" (check important group messages)
- "我有什么任务" (what are my tasks)
- "这周有什么会" (any meetings this week)
- "帮我搜一下周报" (search for weekly reports)
- "查一下表格里的数据" (query table data)

---

### 相关项目 / Related Projects

| 项目 | 说明 |
|------|------|
| [cola-lark-skills](https://github.com/heran11011/cola-lark-skills)（本仓库） | Cola 连接飞书，帮你操作飞书（Cola → 飞书） |
| [cola-feishu-bridge](https://github.com/heran11011/cola-feishu-bridge) | 在飞书中直接跟 Cola 对话（飞书 → Cola） |
| [cola-dingtalk-skills](https://github.com/heran11011/cola-dingtalk-skills) | Cola 连接钉钉，帮你操作钉钉（Cola → 钉钉） |

三者可以同时安装、互不冲突。

---

## ⚠️ 安全提示 / Security Notes

- **OAuth 授权**：连接飞书时会打开浏览器授权页面，请确认 URL 为飞书官方域名（`open.feishu.cn`），不要在非官方页面输入密码
- **Token 过期**：如果遇到"权限不足"或"token expired"错误，重新执行 `lark-cli auth login --recommend` 即可。可用 `lark-cli auth status` 检查状态
- **消息发送确认**：所有发送消息的操作都会先让你确认内容，不会自动发送
- **输入安全**：本技能包通过 shell 命令与 lark-cli 交互，所有用户输入会经过转义处理
- **OAuth Security**: When connecting Feishu, verify the browser URL is an official domain (`open.feishu.cn`) before entering credentials
- **Token Expiry**: If you encounter "permission denied" or "token expired" errors, re-run `lark-cli auth login --recommend`. Check status with `lark-cli auth status`
- **Message Confirmation**: All message-sending operations require your explicit approval before sending
- **Input Safety**: This skill pack interacts with lark-cli via shell commands; all user inputs are sanitized

---

## License

MIT
