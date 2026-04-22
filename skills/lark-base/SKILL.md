---
name: lark-base
description: >
  Query and manage Lark/Feishu (飞书) Bitable (多维表格) data — list tables,
  read records, write records, query with filters. Use when the user asks
  about 多维表格, bitable, spreadsheet data, table records, DAU data, or
  any data stored in Feishu tables. Trigger phrases: "查一下表格",
  "今天DAU多少", "多维表格", "表格里的数据", "帮我加一条记录",
  "bitable", "base", "query data", "spreadsheet", "lookup table",
  "database records".
---

# Lark Bitable (多维表格)

Query and manage Feishu Bitable data via `lark-cli`.

## Prerequisites

Bitable operations need a `base_token` (the base ID) and usually a `table_id`. The user should provide these, or you can find them from the Bitable URL:

```
https://<domain>.feishu.cn/base/<base_token>?table=<table_id>
```

You can also find base_token from document search results — search results with `doc_types: "BITABLE"` contain the token in `result_meta.token`.

## List Tables

```
lark-cli base +table-list --base-token <base_token>
```

## Read Records

```
# List all records
lark-cli base +record-list --base-token <base_token> --table-id <table_id>

# Get one record
lark-cli base +record-get --base-token <base_token> --table-id <table_id> --record-id <id>

# Query with filter/aggregation
lark-cli base +data-query --help  # check flags first
```

## Write Records

```
# Create or update
lark-cli base +record-upsert --base-token <base_token> --table-id <table_id> \
  --data '{"fields":{"Name":"value","Status":"active"}}'

# Delete
lark-cli base +record-delete --base-token <base_token> --table-id <table_id> --record-id <id>
```

## List Fields (understand table structure)

```
lark-cli base +field-list --base-token <base_token> --table-id <table_id>
```

## Tips

- Always list fields first if you don't know the table structure
- Use `--format pretty` for readable output
- Run `--help` on any subcommand before guessing flags
- When presenting data, format it clearly (use tables if appropriate)

## IMPORTANT: Always Include Source Links

After presenting query results, **always** append the original Bitable link so the user can jump to the source.

Use the URL from search results if available (e.g. `https://my.feishu.cn/base/CIpCb0PuDaH2uisABShck3mvn0g`), or construct:

```
https://my.feishu.cn/base/<base_token>?table=<table_id>
```

For example:
> 查询结果如上。原始表格链接：https://my.feishu.cn/base/ABC123?table=tbl456

If you also know the `record_id`, you can link to the specific record:
```
https://my.feishu.cn/base/<base_token>?table=<table_id>&record=<record_id>
```

The user may want to:
- View the full table with all columns
- Apply their own filters
- Edit data directly
- Share the link with colleagues

## Feedback: Report Issues

If a command fails and recovery doesn't work, help the user submit a GitHub Issue.

### 提交 issue 流程（优先自动提交）

**Step 1: 检查 gh CLI 登录态**

```bash
gh auth status
```

**Step 2a: 如果已登录 GitHub → 直接帮用户提 issue**

整理好以下信息，展示给用户确认：
- 标题：`[lark-base] <一句话描述问题>`
- 内容：错误日志、`node --version`、`lark-cli --version`、操作系统、复现步骤

用户确认后，执行：

```bash
gh issue create --repo heran11011/cola-lark-skills \
  --title "[lark-base] 问题标题" \
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
