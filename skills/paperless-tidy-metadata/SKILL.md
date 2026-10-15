---
name: paperless-tidy-metadata
description: Clean up Paperless-ngx correspondents, document types and tags: merge doubles (spelling variants, the same sender created twice), remove unused entries, fix tag hierarchies, and adjust matching rules. Use when the user asks to merge or deduplicate correspondents, types or tags, remove unused ones, or after a bulk cleanup created entries in parallel.
---

# Tidy Correspondents, Types and Tags

If more than one Paperless instance is connected, resolve which one first, see [Working with multiple instances](reference/shared-rules.md#working-with-multiple-instances).

## 1. Survey

List all entries with `correspondents_list`, `document_types_list` or `tags_list` (`page_size` large, `ordering=name`). Each comes with `document_count`. Look for:

- **Doubles**: spelling variants and abbreviations (`DB` / `Deutsche Bahn`, `Media Markt` / `MediaMarkt`), the same sender with and without legal form, names created twice by parallel work.
- **Unused**: `document_count: 0`.
- **Misplaced**: a document type that is really a correspondent (or the other way round), tags whose parent gives them a different meaning than their name.

## 2. Propose

Show the user a short table per kind: which entry survives, which ones merge into it and how many documents move, which unused ones would be deleted. Prefer the clearest full name as the survivor. Wait for confirmation before deleting anything.

## 3. Merge

For each entry to merge into a survivor:

1. Find its documents: `documents_list correspondent__id=<old>` (or `document_type__id`, `tags__id__all`) with `fields=["id"]` and a large `page_size`.
2. Move them: `bulk_edit set_correspondent {"correspondent": <survivor>}` (or `set_document_type`; for tags `modify_tags {add_tags: [survivor], remove_tags: [old]}`).
3. Check that `document_count` of the old entry is now 0, then delete it with `correspondents_destroy` / `document_types_destroy` / `tags_destroy`, or several at once with `bulk_edit_objects` (`object_type`, `objects`, `operation: delete`). Deleting a correspondent, type or tag is permanent: there is no trash for them, and any document still using one loses it.

## Matching rules

New entries should use `matching_algorithm: 6` (automatic) so Paperless learns from assigned documents. Marker tags that only a person or a skill should set (a "reviewed" tag, a "password-protected" tag, an accounting tag) need `matching_algorithm: 0` (none), or auto-matching will start assigning them. Don't switch existing entries away from automatic matching just because they produced wrong guesses; correcting the documents is what trains them. Only set an explicit rule (`match` with any word, exact match or regex) when the user asks for one.
