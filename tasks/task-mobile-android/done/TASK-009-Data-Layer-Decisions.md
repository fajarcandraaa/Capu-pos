# Task: TASK-009-Data-Layer-Decisions

- Repo: mobile-android
- Role: tech-lead-system-analyst
- Base branch: main
- Requirement ref: REVISION-NOTES-Android-2026-09-15.md (Agent C low findings) — dokumentasi keputusan, bukan task kode
- Allowed paths:
  - DECISIONS.md
- Forbidden paths:
  - apps/capupos-android/** (tidak ada perubahan kode)
- Dependency: tidak ada (bisa paralel kapan saja)
- Acceptance criteria:
  - [x] Keputusan `kategori` vs `kategoriUsaha` (StoreEntity.kt:12 vs TRD:56) dicatat — nama final ditetapkan
  - [x] `sync_status` (TRD:56,58; SDD:29,48) dicatat out-of-scope MVP1, kolom nullable saat cloud sync dikerjakan
  - [x] `profil_lokal` (email/no_hp/device_id) dicatat out-of-scope MVP1 (SRS 5.3, TRD 5.6)
  - [x] Reminder via SharedPreferences dicatat (mengacu DECISIONS.md [2026-09-14] poin 5)
  - [x] Order domain model tidak expose isHidden/isDeleted/deletedAt/createdAt/updatedAt — dicatat sebagai keputusan sadar
  - [x] Tidak ada perubahan di luar allowed paths
- Status: done
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan: tidak ada (task dokumentasi murni, tidak ada kode disentuh)
- Hasil: Entry baru ditulis di `DECISIONS.md` — `## [2026-09-17] TL/SA — TASK-009-Data-Layer-Decisions: Konfirmasi 5 Keputusan Data-Layer`. Kelima poin AC dikonfirmasi/dikonsolidasi dari keputusan existing ([2026-09-14] poin 3&5, [2026-09-15] poin 3) + REVISION-NOTES poin B & C.
- File yang berubah: `DECISIONS.md` (append entry, di luar git — gitignored per `.gitignore:10`), task contract ini (status + Catatan Sesi).
- Unresolved issue (bila ada): tidak ada.
