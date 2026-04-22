---
name: lark-docs
description: >
  Search and read Lark/Feishu (飞书) documents and wiki. Use when the user
  asks to find a document, read a doc, search for files, or mentions 飞书文档,
  周报, 日报, 文档搜索, wiki. Trigger phrases: "帮我找一下文档", "搜一下周报",
  "上周的周报", "读一下这个文档", "飞书文档", "wiki".
  NOTE: Document search requires the search:docs:read scope. If you get a
  missing_scope error, tell the user to run the auth command shown in the error.
---

# Lark Documents

Search and read Feishu documents via `lark-cli`.

## Search Documents

```
lark-cli docs +search --query "搜索关键词"

# Check all flags
lark-cli docs +search --help
```

**Known limitation**: Search requires the `search:docs:read` scope. If you get a `missing_scope` error, tell the user:

> 文档搜索需要额外授权。请运行以下命令并在浏览器中完成授权：
> `lark-cli auth login --scope "search:docs:read"`

## Read Document Content

```
lark-cli docs +fetch --doc <doc_id>

# Check flags
lark-cli docs +fetch --help
```

After reading, summarize the key points rather than dumping the full content.

## Create a Document

```
lark-cli docs +create --title "文档标题"

# Check flags for folder placement, etc.
lark-cli docs +create --help
```

## Tips

- Document IDs can come from search results or URLs the user shares
- For long documents, summarize instead of showing everything
- Run `--help` before guessing flags

## IMPORTANT: Always Include Source Links

After presenting search results or document summaries, **always** include the original document link so the user can open it in Feishu.

**From search results**: The API response contains `url` in `result_meta`. Use it directly — it's the real link. Example: `https://my.feishu.cn/base/CIpCb0PuDaH2uisABShck3mvn0g`

If only `doc_id` / `token` is available, construct the link based on `doc_types`:
- DOCX: `https://<domain>.feishu.cn/docx/<token>`
- BITABLE: `https://<domain>.feishu.cn/base/<token>`
- SHEET: `https://<domain>.feishu.cn/sheets/<token>`
- WIKI: `https://<domain>.feishu.cn/wiki/<token>`

The `<domain>` is usually `my.feishu.cn` for personal users.

**Example output format**:
> **周报 - 2026年第15周**
> 摘要：本周完成了飞书集成 Skills 开发...
>
> 原文链接：https://my.feishu.cn/docx/ABC123

**Search result parsing notes** (from actual API response):
- `title_highlighted` contains the title with `<h>` tags for highlighting — strip the tags for display
- `result_meta.url` is the direct link
- `result_meta.doc_types` tells you what type: DOCX, BITABLE, SHEET, etc.
- `result_meta.owner_name` is the document owner

Always present links as clickable — the user may want to:
- Read the full document in Feishu
- Share it with colleagues
- Find related documents nearby
- Edit the content directly

## Feedback: Report Issues

If a command fails and recovery doesn't work, help the user submit a GitHub Issue.

### 提交 issue 流程（优先自动提交）

**Step 1: 检查 gh CLI 登录态**

```bash
gh auth status
```

**Step 2a: 如果已登录 GitHub → 直接帮用户提 issue**

整理好以下信息，展示给用户确认：
- 标题：`[lark-docs] <一句话描述问题>`
- 内容：错误日志、`node --version`、`lark-cli --version`、操作系统、复现步骤

用户确认后，执行：

```bash
gh issue create --repo heran11011/cola-lark-skills \
  --title "[lark-docs] 问题标题" \
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
