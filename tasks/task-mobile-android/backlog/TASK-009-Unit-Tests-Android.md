# Task: TASK-009-Unit-Tests-Android

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: TRD §5.2 (Clean Architecture, business rules mudah diverifikasi terpisah dari UI) — REVISION-NOTES-Android-2026-09-15.md §2
- Allowed paths:
  - apps/capupos-android/app/src/test/**
  - apps/capupos-android/app/src/androidTest/**
  - apps/capupos-android/app/build.gradle (dependensi test: JUnit, Mockito/MockK, Room testing)
- Forbidden paths:
  - apps/capupos-android/app/src/main/** (kode produksi tidak diubah — read-only)
- Dependency: TASK-009-Git-Commit-Android-Complete (butuh baseline ter-commit untuk diff test)
- Acceptance criteria:
  - [ ] 15 use case di `domain/usecase/*` punya unit test (positif + negatif)
  - [ ] Core repository logic teruji (mapping entity↔domain, soft/hard delete)
  - [ ] Aturan soft delete vs hard delete teruji (produk/transaksi)
  - [ ] State machine PO (blok selesai→dibatalkan, FR-05.5) teruji
  - [ ] `./gradlew testDebugUnitTest` berjalan dan exit 0
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
