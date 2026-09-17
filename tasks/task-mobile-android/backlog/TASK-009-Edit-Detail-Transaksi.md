# Task: TASK-009-Edit-Detail-Transaksi

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: UI/UX 5.9 ("Ubah → Edit item/nominal/status") — REVISION-NOTES-Android-2026-09-15.md (Agent B)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksi/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/UbahStatusPOUseCase.kt
  - apps/capupos-android/app/src/main/res/layout/activity_transaksi.xml
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
- Dependency: TASK-009-Git-Commit-Android-Complete; KONFIRMASI TL/SA/UI-UX sebelum implementasi
- Acceptance criteria:
  - [ ] Klarifikasi intent desain selesai ke TL/SA/UI-UX (edit penuh item/nominal vs status-saja)
  - [ ] Bila edit penuh: item + nominal dapat diubah dari detail transaksi PO
  - [ ] Bila status-saja: docs (UI/UX Flow 5.9) diperbarui mencerminkan desain status-saja
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
