---
name: lark-messages
description: >
  Read and search Lark/Feishu (飞书) group messages and summarize them.
  Use when the user asks about group messages, chat history, what happened
  in a group, important messages, unread messages, or anything about 飞书
  群消息. Trigger phrases: "看看群里有什么消息", "群里今天聊了什么",
  "有什么重要消息", "有没有人找我", "群里有什么遗漏的",
  "帮我看看飞书消息", "消息摘要", "群消息".
---

# Lark Messages — Read & Summarize

Read Feishu group messages via `lark-cli` and summarize them with AI.

**CLI**: `lark-cli` (if not found, trigger `lark-setup` skill)

## How It Works

### Step 1: Find the group

```
lark-cli im +chat-search --query "群名关键词"
```

Returns `chat_id` — save it for next step.

If unsure which group, ask the user. Common groups they may ask about:
- Work groups, project groups, announcement groups, etc.

### Step 2: Read messages

```
# Recent messages (default: ~20, returns JSON array)
lark-cli im +chat-messages-list --chat-id <chat_id>

# Use --format pretty for a readable table view
lark-cli im +chat-messages-list --chat-id <chat_id> --format pretty

# Control page size
lark-cli im +chat-messages-list --chat-id <chat_id> --page-size 50

# For pagination, use --page-token from previous response's page_token field
lark-cli im +chat-messages-list --chat-id <chat_id> --page-token <token>

# Check all flags
lark-cli im +chat-messages-list --help
```

**Message format notes** (verified by testing):
- **Always use `--format pretty`** — it outputs a human-readable table with sender names, timestamps, and message content. Do NOT parse raw JSON for sender info — the raw `sender` field only contains `{id, id_type, sender_type, tenant_key}` with NO name.
- Messages are returned in **reverse chronological order** — reverse them for summaries
- `has_more: true` means there are more pages — use `--page-token` to fetch the next page
- **There is NO `--page-all` flag** on `+chat-messages-list`. You must paginate manually with `--page-token`.
- `msg_type: "system"` messages (join/invite events) should be **filtered out**

### Step 3: Summarize with AI

This is where Cola adds value. Don't dump raw messages — summarize:

**Pre-processing before summarization:**
1. Filter out `system` type messages (group join/leave/invite)
2. Reverse the message array to chronological order (oldest first)
3. Sender names are not available in raw JSON — use `--format pretty` output for a readable summary, or note messages by time only

**Summarization categories:**
1. **Key discussions**: What topics were discussed?
2. **Action items**: Was anything assigned or decided?
3. **Questions for user**: Did anyone @mention or ask the user something?
4. **Problems reported**: Any bugs, issues, or complaints?

Format the summary as a brief digest the user can scan in 30 seconds.
If the initial fetch had `has_more: true`, mention "以上是最近 N 条消息的摘要，群里还有更早的消息". Use `--page-token` to fetch more if needed.

### Step 4 (optional): Search specific messages

```
# Search by keyword across all chats
lark-cli im +messages-search --query "关键词"

# Check --help for filtering by chat, sender, time range
lark-cli im +messages-search --help
```

## Responding to messages

**SAFETY: NEVER send a message without explicit user confirmation.** Only send messages when the user explicitly asks. Always draft and confirm first.

```
# Send to group
lark-cli im +messages-send --chat-id <chat_id> --text "content"

# Reply to a specific message
lark-cli im +messages-reply --message-id <msg_id> --text "content"
```

When the user says something like "不重要的帮我回了" or "帮我回一下":
1. Show the draft reply
2. Wait for user confirmation
3. Then send

## Important

- Run `--help` on any subcommand before guessing flags
- Messages may contain `[Image]`, `[Sticker]`, `system` events — skip these in summaries
- Use `--format pretty` for readable output
- Look for @mentions of the current user in messages — if you don't know the user's Feishu name, check with `lark-cli auth me` or ask them

## IMPORTANT: Always Include Source Links

After presenting a message summary, **always** include the group chat link so the user can jump into Feishu and see the full context:

```
https://<domain>.feishu.cn/messenger/<chat_id>
```

If a specific message is important (e.g. someone @mentioned the user, an action item), also include the direct message link if `message_id` is available:
```
https://<domain>.feishu.cn/messenger/<chat_id>?msgId=<message_id>
```

**Example output format**:
> **ColaOS 社区内测群 - 今日摘要**
> 1. 讨论了新版本发布计划...
> 2. @用户 被问到关于飞书集成的进展
>
> 打开群聊：https://xxx.feishu.cn/messenger/oc_xxx

## Feedback: Report Issues

If a command fails and recovery doesn't work, help the user submit a GitHub Issue.

### 提交 issue 流程（优先自动提交）

**Step 1: 检查 gh CLI 登录态**

```bash
gh auth status
```

**Step 2a: 如果已登录 GitHub → 直接帮用户提 issue**

整理好以下信息，展示给用户确认：
- 标题：`[lark-messages] <一句话描述问题>`
- 内容：错误日志、`node --version`、`lark-cli --version`、操作系统、复现步骤

用户确认后，执行：

```bash
gh issue create --repo heran11011/cola-lark-skills \
  --title "[lark-messages] 问题标题" \
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
