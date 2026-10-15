---
name: clean-up-inbox
description: Review the Paperless-ngx inbox (or any selection of documents) one document at a time and fix what automatic import got wrong: useless titles (email subjects, scanner file names), wrong or import-day dates, wrong correspondents, document types and tags. Marks every reviewed document, removes duplicates on request, and ends with a report of follow-ups (open payment reminders, possible business receipts, documents that need a human). Use when the user asks to clean up, sort, review, tidy or process their Paperless inbox, or says many documents have wrong dates, correspondents, tags or types.
---

# Clean Up the Inbox

Imports (mail rules, scanners, consume folder) often leave documents with the email subject or `BRWxxxx_000905` as title, the import day as date, and correspondents, types and tags guessed by Paperless's automatic matching from too little training data. This skill fixes them carefully, because every correction also trains the matching.

If more than one Paperless instance is connected, resolve which one first, see [Working with multiple instances](../README.md#working-with-multiple-instances). Read the shared rules there too.

## 1. Survey

1. Count the selection: `documents_list is_in_inbox=true page_size=1` → `count` (or the user's own filter).
2. List it without content: `fields=["id","title","created","correspondent","document_type","tags"]`, `page_size=100`, `ordering=-added`, all pages. Patterns to look for: many documents dated the import day, scanner titles, a mail-import tag on most of them, the same subject several times.
3. Load the taxonomy once: `tags_list`, `correspondents_list`, `document_types_list` (all pages, `page_size` large). Note tag parents and which auto-assigned values look wrong (the same correspondent or type on unrelated documents is the typical sign).
4. Check duplicates early: `documents_list has_duplicates=true` (byte-identical copies). Repeated mail-rule runs often import the same attachments several times. If there are many, run `find-duplicates` first so you don't clean up copies.

## 2. Agree on conventions (one question round)

Ask the user, with sensible defaults, before writing anything:

- **Marking reviewed documents.** Default: create a tag such as `claude-reviewed` (`matching_algorithm: 0`, so auto-matching never assigns it) and add it to every reviewed document, leaving the inbox tag for the user to clear. Alternative: remove the inbox tag when done.
- **Duplicates and pure newsletters.** Trash after listing them for confirmation, tag them, or treat them like everything else.
- **Approach for large inboxes** (more than ~60 documents): work in batches in this session, or fan out to parallel subagents (step 5). Fan-out needs the user's explicit OK.
- **Anything archive-specific** the user wants respected: title language and style, documents that must not be touched (for example ones already booked in accounting), tags for business vs. private.

Don't ask whether to turn off automatic matching. It learns from the corrected data, which is the point.

## 3. Review in batches of 8 to 10

1. Fetch the batch with content: `documents_list id__in=[…]` and `fields=["id","title","created","correspondent","document_type","tags","original_file_name","custom_fields","content"]`. The result usually overflows into a file; read it with `jq`, about 1000 characters per document:

       jq -r '.results[] | "=== \(.id) | \(.title) | \(.original_file_name) | created=\(.created) corr=\(.correspondent) type=\(.document_type) tags=\(.tags) rel=\(.custom_fields|map(.value)|tostring)\n\(.content[0:1000]|gsub("\n+";" ¶ "))"' FILE

   Custom fields that link documents (mail-rule setups often link all attachments of one email) give context for a document that is unclear on its own.

2. Decide per document, following `edit-document-metadata` for title, date, correspondent, type and tags. Then:
   - **No date on the document, or the date is the import day:** if a mail connector (for example Gmail `search_threads`) is available, search for the email by distinctive subject words, order or invoice numbers, `has:attachment`, metadata-only view, and use the email's date. One search with `OR` can cover several documents.
   - **Empty content:** the PDF is likely password protected. Tag it (for example `passwortgeschützt` / `password-protected`), fill in what the title and filename tell you, and offer `unlock-pdfs` at the end. The email that delivered it often says where the password comes from.
   - **Blank or unreadable scan:** title it as such and list it for the user; don't guess.

3. Write: `documents_partial_update` for title and date (plus correspondent, type and the full tag list with the review tag), `bulk_edit` for clearing fields and for changes shared by many documents. Remember the traps in `edit-document-metadata`, above all that `null` doesn't clear a field in `documents_partial_update`.

4. Create correspondents and types only for real senders and kinds of documents, after checking for spelling variants, with `matching_algorithm: 6`.

5. After each batch, tell the user in one or two lines what was done and what's next.

## 4. Things to collect for the report

While reading, note:

- Payment reminders, dunning letters and debt-collection threats that may still be open (amount, latest date).
- Documents that could be business expenses if the user runs a business, but aren't marked as such.
- Possible duplicates that aren't byte-identical (same invoice as scan and PDF, a document attached to several emails).
- Documents you could not classify, blank scans, mixed scans containing several documents.
- Sensitive content worth knowing about (activation codes, ID copies).

## 5. Fan-out to subagents (only with the user's OK)

For a few hundred documents, split the remaining IDs into 3 to 4 chunks and start one `general-purpose` subagent per chunk in a single message, so they run in parallel. Before that:

1. Create the correspondents that several chunks will need anyway (the big recurring senders), so parallel agents don't create the same one twice.
2. Write a brief from [agent-brief.md](agent-brief.md) into the scratchpad, filled in with this archive's IDs and the conventions agreed in step 2, and give each agent its ID list plus the brief's path.

When the agents report back:

- Check that no selected document is still missing the review tag (`tags__id__none=<review tag>` with the same filter).
- Check `correspondents_list ordering=name` for doubles created in parallel, and merge them with `tidy-metadata`.

## 6. Final report

Keep it short:

- Totals: trashed, reviewed, created correspondents, types and tags.
- Open reminders and payments in a table (what, amount, latest reminder).
- Possible business documents, for the user to decide.
- Duplicates and blank scans still present, with the offer to trash them (after confirmation, see `find-duplicates`).
- Password-protected documents, with the offer to unlock them.
- Whether the import itself should change (a mail rule that runs twice, a filter that imports newsletters).
