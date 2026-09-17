# Task: TASK-009-Wire-Pembayaran-Struk

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: FR-06, FR-06.4, FR-11.1 — REVISION-NOTES-Android-2026-09-15.md (Agent B & D)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/pembayaran/PembayaranActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksi/BelumBayarAdapter.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/riwayat/RiwayatAdapter.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/struk/StrukActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/GenerateStrukUseCase.kt
  - apps/capupos-android/app/src/main/res/layout/item_belum_bayar.xml
  - apps/capupos-android/app/src/main/res/layout/item_riwayat_order.xml
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
- Dependency: TASK-009-Git-Commit-Android-Complete
- Acceptance criteria:
  - [ ] `PembayaranActivity` reachable dari `BelumBayarAdapter` / `RiwayatAdapter` via `EXTRA_ORDER_ID` (FR-06)
  - [ ] Struk ditampilkan setelah `BayarTransaksiUseCase` sukses (FR-06.4), tidak langsung kembali
  - [ ] Guard kembalian: baris "Diterima/Kembalian" hanya dicetak bila `metodeBayar == "tunai"` (FR-11.1)
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
