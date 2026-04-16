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

```bash
lark-cli docs +search --query "搜索关键词"

# Check all flags
lark-cli docs +search --help
```

**Known limitation**: Search requires the `search:docs:read` scope. If you get a `missing_scope` error, tell the user:

> 文档搜索需要额外授权。请运行以下命令并在浏览器中完成授权：
> `lark-cli auth login --scope "search:docs:read"`

## Read Document Content

```bash
lark-cli docs +fetch --doc <doc_id>

# Check flags
lark-cli docs +fetch --help
```

After reading, summarize the key points rather than dumping the full content.

## Create a Document

```bash
lark-cli docs +create --title "文档标题"

# Check flags for folder placement, etc.
lark-cli docs +create --help
```

## Tips

- Document IDs can come from search results or URLs the user shares
- For long documents, summarize instead of showing everything
- Run `--help` before guessing flags

## IMPORTANT: Always Include Source Links

After presenting search results or document summaries, **always** include the original document link so the user can open it in Feishu:

**From search results**: The API response should contain `url` or `doc_id`. If only `doc_id` is available, construct the link:
```
https://<domain>.feishu.cn/docx/<doc_id>
```

**Example output format**:
> **周报 - 2026年第15周**
> 摘要：本周完成了飞书集成 Skills 开发...
>
> 原文链接：https://xxx.feishu.cn/docx/ABC123

Always present links as clickable — the user may want to:
- Read the full document in Feishu
- Share it with colleagues
- Find related documents nearby
- Edit the content directly
