# Task: TASK-009-Pembayaran-Catatan

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: FR-06.3 (SRS:60) — REVISION-NOTES-Android-2026-09-15.md (Agent B)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/pembayaran/PembayaranActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/pembayaran/PembayaranViewModel.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/BayarTransaksiUseCase.kt
  - apps/capupos-android/app/src/main/res/layout/activity_pembayaran.xml
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
- Dependency: TASK-009-Wire-Pembayaran-Struk (satu layar sama — hindari conflict, dikerjakan setelahnya)
- Acceptance criteria:
  - [ ] EditText catatan tersedia di UI pembayaran
  - [ ] Isi catatan tersimpan ke `Order.catatan` via `BayarTransaksiUseCase`
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
