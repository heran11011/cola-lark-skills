---
name: lark-base
description: >
  Query and manage Lark/Feishu (飞书) Bitable (多维表格) data — list tables,
  read records, write records, query with filters. Use when the user asks
  about 多维表格, bitable, spreadsheet data, table records, DAU data, or
  any data stored in Feishu tables. Trigger phrases: "查一下表格",
  "今天DAU多少", "多维表格", "表格里的数据", "帮我加一条记录",
  "bitable", "base".
---

# Lark Bitable (多维表格)

Query and manage Feishu Bitable data via `lark-cli`.

## Prerequisites

Bitable operations need a `base_token` (the base ID) and usually a `table_id`. The user should provide these, or you can find them from the Bitable URL:

```
https://xxx.feishu.cn/base/<base_token>?table=<table_id>
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
