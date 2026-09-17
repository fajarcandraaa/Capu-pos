# Task: TASK-009-Export-Correctness

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: FR-12/BR-06 + PRD 04:123 + BR-05 — REVISION-NOTES-Android-2026-09-15.md (Agent D)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/HomeActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/export/ExportActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/ExportDataUseCase.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/CekReminderBackupUseCase.kt
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
- Dependency: TASK-009-Git-Commit-Android-Complete; KONFIRMASI TL/SA untuk kebijakan isHidden di export
- Acceptance criteria:
  - [ ] Reset counter reminder hanya saat share export sukses (bukan saat dialog tampil — HomeActivity.kt:236)
  - [ ] Flag "dialog tampil" per sesi agar back-out dari ExportActivity tidak menghilangkan reminder
  - [ ] Sheet "Laporan Ringkas" export memuat label periode (PRD 04:123), tidak all-time
  - [ ] Filter `isHidden` di export sesuai keputusan TL/SA (terdokumentasi di DECISIONS.md bila diubah)
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
