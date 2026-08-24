# Task: TASK-006

- Repo: mobile-android
- Role: android-engineer
- Base branch: main
- Requirement ref: FR-06 (Pembayaran), FR-07 (Riwayat), FR-09 (Laporan)
- Allowed paths:
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/pembayaran/**
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/riwayat/**
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/laporan/**
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/BayarTransaksiUseCase.kt, HapusTransaksiUseCase.kt, GenerateLaporanUseCase.kt
- Forbidden paths:
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entity/**
- Dependency: TASK-001, TASK-005
- Acceptance criteria:
  - [ ] Pembayaran tunai: input nominal manual/suggestion, kembalian auto
  - [ ] Pembayaran non-tunai: pilih metode, dicatat manual
  - [ ] Data tambahan opsional dapat ditambahkan
  - [ ] List belum bayar & riwayat dengan filter (kategori/tanggal/metode bayar)
  - [ ] Hapus transaksi: soft delete (lunas), hard delete (belum bayar)
  - [ ] Laporan overview card + grafik tren
  - [ ] Laporan kelola stok: histori perubahan stok
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):