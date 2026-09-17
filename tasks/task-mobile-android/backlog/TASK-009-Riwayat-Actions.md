# Task: TASK-009-Riwayat-Actions

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: FR-07.3, FR-07.4 + BR-05 — REVISION-NOTES-Android-2026-09-15.md §7 (Agent B)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/riwayat/RiwayatActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/riwayat/RiwayatAdapter.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/riwayat/RiwayatViewModel.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksi/BelumBayarAdapter.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/repository/OrderRepository.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/repository/OrderRepositoryImpl.kt
  - apps/capupos-android/app/src/main/res/layout/item_riwayat_order.xml
  - apps/capupos-android/app/src/main/res/layout/item_belum_bayar.xml
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/dao/** (DAO `hide()` sudah ada — read-only)
- Dependency: TASK-009-Git-Commit-Android-Complete
- Acceptance criteria:
  - [ ] `RiwayatViewModel` punya `tandaiLunas(orderId)` (FR-07.4)
  - [ ] `RiwayatViewModel` punya `toggleSembunyikan(orderId)` (FR-07.3)
  - [ ] `OrderRepository.hide(orderId)` diekspos (DAO `OrderDao.hide()` sudah ada, di-wire ke RepoImpl)
  - [ ] Tombol "Sembunyikan" + "Tandai Lunas" tersedia di adapter riwayat/belum bayar
  - [ ] "Sembunyikan" reversible (BR-05) dan tidak mempengaruhi perhitungan laporan
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
