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
  - [ ] Keputusan `kategori` vs `kategoriUsaha` (StoreEntity.kt:12 vs TRD:56) dicatat — nama final ditetapkan
  - [ ] `sync_status` (TRD:56,58; SDD:29,48) dicatat out-of-scope MVP1, kolom nullable saat cloud sync dikerjakan
  - [ ] `profil_lokal` (email/no_hp/device_id) dicatat out-of-scope MVP1 (SRS 5.3, TRD 5.6)
  - [ ] Reminder via SharedPreferences dicatat (mengacu DECISIONS.md [2026-09-14] poin 5)
  - [ ] Order domain model tidak expose isHidden/isDeleted/deletedAt/createdAt/updatedAt — dicatat sebagai keputusan sadar
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
