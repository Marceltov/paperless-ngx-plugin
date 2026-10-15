---
name: paperless-unlock-pdfs
description: Remove the password from encrypted PDFs in Paperless-ngx with documents_remove_password so Paperless can extract their text, then fix their metadata. Use when documents have empty content because they are password protected (bank statements, health insurance and government mail often are), or when the user asks to unlock, decrypt or remove passwords from documents.
---

# Unlock PDFs

Encrypted PDFs are stored but not OCRed: their `content` is empty, `page_count` is null, and nothing about them is searchable.

If more than one Paperless instance is connected, resolve which one first, see [Working with multiple instances](reference/shared-rules.md#working-with-multiple-instances).

## 1. Find them

- Documents already tagged as password protected, or
- `documents_list` with `fields=["id","title","created","original_file_name","page_count"]` and look for `page_count: null` on PDFs; filenames often say so (`…_verschlüsselt.pdf`, `…_encrypted.pdf`).

## 2. Find the password

Don't guess blindly. The email that delivered the PDF usually says what the password is. If a mail connector is available, open that email (search by the document's subject or order number) and read the hint. Common schemes:

- **Postal code** of the address at the time (some banks). It changes when the user moves, so ask for the postal code valid at the document's date.
- **Date of birth** in a given format (`DDMMYYYY` and similar).
- **A code sent by SMS**, or a booking code. These can't be derived; tell the user and suggest the sender's online mailbox instead.

Ask the user for the actual values. Don't store passwords anywhere.

## 3. Unlock one document first

Call `documents_remove_password` with `documents=[one id]`, `password`, and `update_document: true`:

- `update_document: true` stores the unlocked file as a **new version of the same document**, keeping title, tags and everything else. With the default `false`, Paperless creates a separate new document instead.
- It runs in the background. Check the result with `documents_list id=<id> fields=["id","page_count","content","versions"]` a little later: content appears once OCR has run.

## 4. Then the rest, one call per document

Send each document in its own call. A call with several documents fails as a whole with HTTP 400 as soon as one password is wrong, but documents processed before the failure are unlocked anyway, so a retry can add a second, identical version. One document per call makes failures clear.

A 400 for a single document means the password is wrong (or the PDF isn't encrypted). Try the user's other candidates; then stop and report.

## 5. Finish

For each unlocked document: remove the password-protected tag (`bulk_edit remove_tag`), and now that the text is readable, give it a proper title, date and correspondent (see `paperless-edit-document-metadata`). Report which documents stay locked and why.
