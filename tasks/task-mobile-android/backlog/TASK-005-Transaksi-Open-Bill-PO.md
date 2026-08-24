# Task: TASK-005

- Repo: mobile-android
- Role: android-engineer
- Base branch: main
- Requirement ref: FR-04 (Transaksi), FR-05 (Pre-order), FR-07 (Open Bill)
- Allowed paths:
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksi/**
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksimanual/**
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/SimpanTransaksiUseCase.kt, BayarTransaksiUseCase.kt, UbahStatusPOUseCase.kt
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/dao/**
- Forbidden paths:
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/pembayaran/**
- Dependency: TASK-001, TASK-004
- Acceptance criteria:
  - [ ] Pilih produk by kategori/search ke keranjang
  - [ ] Transaksi manual (input nominal + deskripsi bebas)
  - [ ] Simpan/Open Bill menyimpan transaksi tertunda
  - [ ] Mode PO: status 5 tahap (menunggu konfirmasi → diproses → siap → selesai → dibatalkan)
  - [ ] List Belum Bayar menampilkan transaksi tertunda per tanggal
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):