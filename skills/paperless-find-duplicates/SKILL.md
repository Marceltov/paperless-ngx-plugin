---
name: paperless-find-duplicates
description: Find duplicate documents in Paperless-ngx (byte-identical copies flagged by has_duplicates, and same-content copies such as a scan and a PDF of the same invoice), pick which copy to keep, and move the others to the trash after the user confirms. Use when the user asks to find or remove duplicates, when an import ran twice, or when clean-up-inbox finds many copies.
---

# Find Duplicates

If more than one Paperless instance is connected, resolve which one first, see [Working with multiple instances](reference/shared-rules.md#working-with-multiple-instances).

## 1. Byte-identical copies

1. `documents_list has_duplicates=true page_size=200 fields=["id","title","original_file_name","added","created","tags","correspondent","document_type"] ordering=original_file_name`. Add the user's filter (for example `is_in_inbox=true`) if they only want part of the archive; the other copy may still be outside it.
2. Group the copies. The `duplicate_documents` field is often empty through the API, so group by `original_file_name` plus title context. Watch for generic file names (`AGB.pdf`, `Rechnung.pdf`, `Policy Document.pdf`): the same name from different senders is not a duplicate; use the sender and date to split such groups.
3. Typical causes: a mail rule that ran twice, a mail with the same attachment sent again as a reminder, standard attachments (terms, privacy notices) on every order mail.

## 2. Same content, different file

Not flagged by Paperless, but common: a paper scan and the emailed PDF of the same invoice, JPG and PNG of the same picture, two scans of one letter, an appointment list mailed twice. Find them by identical invoice or order numbers (`content__icontains`), identical titles, or while reading documents in `paperless-clean-up-inbox`. Different documents that merely belong together (invoice, reminder and dunning letter; quote and order) are **not** duplicates.

## 3. Pick the keeper per group

Keep, in this order of preference:

1. The copy other systems reference: tagged as booked in accounting, linked from a custom field, or with notes.
2. The copy with curated metadata (real title, correspondent, type) over a fresh import.
3. The original digital PDF over a scan.
4. Otherwise the oldest (lowest ID).

Never trash a copy that is referenced elsewhere just to keep the newer one.

## 4. Confirm, then trash

Show the user a compact table: what will be trashed, what is kept, and what the group is. Mention that trashed documents can be restored from the Paperless trash until it is emptied. Only after an explicit yes, call `bulk_edit` `method=delete` with the IDs to trash (it moves them to the trash). Then report the count.

Blank scan pages found along the way can go in the same confirmation round.
