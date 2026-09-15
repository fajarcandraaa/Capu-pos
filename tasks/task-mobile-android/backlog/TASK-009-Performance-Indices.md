# Task: TASK-009-Performance-Indices

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: SRS NFR Performa (SRS:108) — REVISION-NOTES-Android-2026-09-15.md §5 (Agent C)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/OrderDetailEntity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/StockHistoryEntity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/AppDatabase.kt (bump versi bila perlu)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/MigrationV6ToV7.kt (file baru, bila perlu)
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/**
- Dependency: TASK-009-Git-Commit-Android-Complete
- Acceptance criteria:
  - [ ] `@Index` untuk `orderId` + `productId` di `OrderDetailEntity`
  - [ ] Verifikasi index `productId` di `StockHistoryEntity` (sudah ada — pastikan tidak terhapus)
  - [ ] Build log tidak lagi warning FK index untuk kedua entity
  - [ ] Migration via bump versi (bila schema berubah) atau `fallbackToDestructiveMigration` TIDAK dipakai
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
