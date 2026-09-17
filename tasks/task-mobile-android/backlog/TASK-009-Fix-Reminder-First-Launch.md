# Task: TASK-009-Fix-Reminder-First-Launch

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: SRS FR-12.1 + BR-06 — REVISION-NOTES-Android-2026-09-15.md §3
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/AppApplication.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/CekReminderBackupUseCase.kt
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/** (kecuali tidak dibutuhkan)
- Dependency: TASK-009-Git-Commit-Android-Complete
- Acceptance criteria:
  - [ ] `lastReminderAt` di-seed ke `System.currentTimeMillis()` saat first launch (Application.onCreate) bila key belum ada
  - [ ] `CekReminderBackupUseCase.execute()` tidak return `true` saat `lastReminderAt == 0L`
  - [ ] Reminder muncul hanya bila `now - lastReminderAt >= INTERVAL_MILLIS` (7 hari)
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
