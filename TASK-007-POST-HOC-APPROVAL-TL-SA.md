# TASK-007 Post-Hoc Approval — TL/SA

**Date:** 2026-09-15  
**Task:** TASK-007 — Profil Usaha, Struk, Reminder, Export (Android)  
**Role:** Tech-Lead/System-Analyst  
**Status:** APPROVED

---

## Summary

5 deviation items yang dicatat di Catatan Sesi TASK-007 telah diverifikasi dan semuanya **APPROVED**. 
Tidak ada teknis risk, no regression, no scope creep. Deviasi adalah koreksi factual dan design-choice justified.

---

## Post-Hoc Approval Details

| # | Deviation | Root Cause | Verification | Decision |
|---|-----------|-----------|---|----------|
| **1** | `res/xml/file_paths.xml` di luar allowed_paths literal | FileProvider untuk share XLSX via Sharesheet adalah implementasi detail AC "share via Android Sharesheet". Wajib ada, bukan optional. | ✅ File ada di `app/src/main/res/xml/file_paths.xml`. Manifest line 90-98 register dengan benar (`android.support.FILE_PROVIDER_PATHS`). Cache-path "exports" sesuai output dir. | **APPROVE.** Additive, required. Amend task contract allowed_paths: tambah `res/xml/file_paths.xml`. |
| **2** | `MigrationV4ToV5`: CREATE TABLE IF NOT EXISTS, bukan ALTER TABLE ADD COLUMN | DECISIONS.md [2026-09-14] poin 1 menyebut "ALTER TABLE ADD COLUMN" sebagai contoh literal. Tapi stores table belum pernah dibuat migration sebelumnya → ALTER akan fail (table not found). CREATE TABLE yang benar. | ✅ Migration.kt pakai CREATE TABLE IF NOT EXISTS. Schema lengkap 7 kolom: id (PK), nama, alamat, logo, kategori, deskripsi, telepon (semua nullable kecuali id/nama/alamat). Retest: build successful. | **APPROVE.** Koreksi technical justified. CREATE TABLE adalah approach yang benar untuk table baru. DECISIONS.md entry oversimplified — update untuk clarity masa depan. |
| **3** | Field `kategori` bukan `kategoriUsaha` | DECISIONS.md [2026-09-14] poin 3 menyebut field `kategoriUsaha`. Implementasi gunakan `kategori` demi konsistensi konvensi existing: `kategoriId` (di Product), `kategori` (di Store) — short uniform naming, bukan verbose. | ✅ Store.kt + StoreEntity.kt: field `kategori: String?`. Consistent dengan `kategoriId` pattern existing. No @ColumnInfo — Room auto-map camelCase. | **APPROVE.** Konvensi naming > literal label. Design consistency > DECISIONS.md prescriptive name. Jangan direname. |
| **4** | `presentation/reminder/**` package unused | AC reminder = popup dismiss-wajib, 7-hari interval. Implementasi sebagai AlertDialog inline di HomeActivity.onResume() (line 216-236), bukan Activity terpisah. CekReminderBackupUseCase handle SharedPreferences `last_backup_timestamp`. Lebih ringan. | ✅ HomeActivity.kt: onResume() call cekReminderBackup() → execute() return true (past 7d) → show AlertDialog dengan 2 button ("Export Sekarang", "Nanti Saja") → both call markReminderShown() reset timestamp. Manifest no ReminderActivity entry (removed from attempt). | **APPROVE.** Design choice justified (inline popup < Activity overhead). Presentation/reminder/ package tidak dipakai OK — no dead code impact, may remove atau keep for future. |
| **5** | Export share via ACTION_SEND only; no manual "save to local storage" dialog | AC: "share/save via Android Sharesheet". Interpretasi: share (primary) = Sharesheet via FileProvider. Save (secondary) = user pilih recipient app (Sheets, Gmail, Files, Drive) — tidak perlu duplikasi manual-save UI. DECISIONS.md [2026-09-14] poin 7 already endorse "Sharesheet". | ✅ ExportActivity.kt line 67-75: shareFile(File) → Intent(ACTION_SEND) + FileProvider getUriForFile() → createChooser(). No ACTION_CREATE_DOCUMENT, no manual local save. DECISIONS.md poin 7 align. | **APPROVE.** AC satisfied. Share = primary mechanism (Sharesheet auto-provide save via each app recipient). Manual-save logic YAGNI — adds complexity without requirement. |

---

## Amendment Required

1. **Task Contract TASK-007** — `allowed_paths` tambah entry:
   ```
   - apps/capupos-android/app/src/main/res/xml/file_paths.xml
   ```

2. **DECISIONS.md [2026-09-15]** — Add entry:
   ```
   - TASK-007 post-hoc deviasi 5 item: FILE_PROVIDER_PATHS, CREATE TABLE (not ALTER),
     kategori naming, inline reminder popup, ACTION_SEND share-only.
     Semua justified & approved. Migration approach correct (table baru).
     Konvensi naming > literal label. Sharesheet implement AC correctly.
   ```

---

## Risk Assessment

| Category | Finding | Level |
|----------|---------|-------|
| Correctness | No logic bug, no data-loss risk. Build pass, kode review passed. | ✅ Low |
| Scope | All within TASK-007 AC. No cross-task impact. | ✅ Low |
| Compatibility | FileProvider standard Android pattern. SQLite migration safe. SharedPreferences standard practice. | ✅ Low |
| Future Tech Debt | Inline reminder popup OK — if future reminder 2.0 needs dedicated screen, can refactor. No scar. | ✅ Low |

---

## Recommendation

✅ **TASK-007 READY FOR MERGE.** Post-hoc approval complete.

- Worktree branch: `TASK-007-Profil-StruK-Reminder-Export-android`
- PR/commit: ready
- Code review: passed
- Build: SUCCESS
- Test coverage: manual verify (repo has no unit-test suite for these features)

Next: TL/SA sign-off + PM merge to main.

---

**TL/SA:** Approved  
**Date:** 2026-09-15  
**Action Items:** None blocking.
