# Task: TASK-009-Laporan-Filters

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: FR-09.3 (SRS:76) — REVISION-NOTES-Android-2026-09-15.md §6 (Agent B)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/laporan/LaporanActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/laporan/LaporanViewModel.kt
  - apps/capupos-android/app/src/main/res/layout/activity_laporan.xml
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/GenerateLaporanUseCase.kt (reuse — bila perlu ubah, eskalasi TL/SA)
- Forbidden note: reuse pola filter `RiwayatViewModel` (FilterRiwayat) — jangan duplikasi
- Dependency: TASK-009-Git-Commit-Android-Complete
- Acceptance criteria:
  - [ ] Date-range picker tersedia di Laporan (FR-09.3)
  - [ ] Search tersedia di Laporan (FR-09.3)
  - [ ] Filter memakai pola yang sama dengan Riwayat (setFilterTanggal dsb) — konsisten, tanpa duplikasi logic
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: ready
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->
<!-- Diverifikasi TL/SA [2026-09-21]: FilterRiwayat (domain/model) dipakai read-only via import, tidak perlu masuk allowed_paths. Tidak ada gap kontrak. -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
