# Task: TASK-009-Transaksi-Manual-Merge

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: FR-04.3 (SRS:47) + UI/UX 5.4-5.5 — REVISION-NOTES-Android-2026-09-15.md (Agent B)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksimanual/TransaksiManualActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksimanual/TransaksiManualViewModel.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksi/TransaksiActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksi/TransaksiViewModel.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/SimpanTransaksiUseCase.kt
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
- Dependency: TASK-009-Git-Commit-Android-Complete
- Acceptance criteria:
  - [ ] Item manual dan produk terdaftar dapat digabung dalam 1 transaksi (FR-04.3)
  - [ ] Keranjang dari TransaksiActivity dapat diteruskan ke TransaksiManualActivity (dan sebaliknya arah merge jelas)
  - [ ] Merge terjadi sebelum `SimpanTransaksiUseCase` — tidak ada Order terpisah untuk item manual
  - [ ] `TransaksiManualViewModel.kt:91` tidak lagi langsung simpan Order terpisah
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
