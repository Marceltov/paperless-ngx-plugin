---
name: paperless-search-documents
description: Find Paperless-ngx documents by full text, title, correspondent, type, tag, date, custom field or ID while keeping results small, using documents_list and search_retrieve. Use when the user asks to find, list, count or look up documents ("where is my rental contract", "how many invoices from 2025", "show everything tagged insurance").
---

# Search Paperless Documents

Every document carries its full OCR text in `content`, often thousands of characters. A careless `documents_list` call returns pages of it and floods the context. This skill is about asking the server precise questions.

If more than one Paperless instance is connected, resolve which one first, see [Working with multiple instances](reference/shared-rules.md#working-with-multiple-instances).

## Steps

1. **Resolve names to IDs.** Filters take IDs. Look up whatever the user named with `correspondents_list`, `document_types_list`, `tags_list`, `storage_paths_list` or `custom_fields_list` and `name__icontains`. If nothing matches, say so and show close names instead of guessing.

2. **Pick the narrowest filter** on `documents_list`:
   - Full text: `query` (ranked, each hit gets a `__search_hit__` snippet) or `title_content`.
   - Text in one field: `title__icontains`, `content__icontains`, `original_filename__icontains`.
   - Metadata: `correspondent__id`, `document_type__id`, `storage_path__id` (or `__id__in`, `__isnull=true` for "not set"); `tags__id__all` (every tag), `tags__id__in` (any), `tags__id__none`; `is_in_inbox`, `is_tagged`.
   - Dates: `created__date__gte` / `__lte` (the document's own date), `added__…` (import time), `created__year`.
   - Duplicates: `has_duplicates=true`.
   - Custom fields: `custom_field_query`, `has_custom_fields`.

3. **Keep the result small**: always pass `fields` without `content` (e.g. `["id","title","created","correspondent","document_type","tags"]`), a `page_size` that fits the question, and an `ordering` such as `-created`. For "how many", use `page_size=1` and read `count`.

4. **Read a document's text** only once you know which one: `documents_retrieve` with `fields=["content"]`, one document at a time. When you need the text of several, request them with `id__in` and `fields` including `content`; if the result is saved to a file because it's too large (Claude Code does this), read it with `jq` and cut each text to its first ~1000 characters; otherwise ask for fewer documents per call:

       jq -r '.results[] | "=== \(.id) | \(.title)\n\(.content[0:1000])"' FILE

5. **Present results** as a short list or table: ID, title, date, correspondent and type by **name** (map the IDs back), plus the snippet when a full-text query produced one. Don't dump JSON.

## When nothing is found

Say which filters you used. Common causes: the date filter used `added` instead of `created` (or the other way round), the document's correspondent was never set, or the OCR text is empty because the PDF is password protected (see `paperless-unlock-pdfs`).
