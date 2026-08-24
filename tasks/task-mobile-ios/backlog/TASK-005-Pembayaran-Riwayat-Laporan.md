# Task: TASK-005

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-06, FR-07, FR-09 (Pembayaran, Riwayat, Laporan)
- Allowed paths:
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Pembayaran/**
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Riwayat/**
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Laporan/**
  - projects/mobile-ios/CappuPOS/Sources/Domain/UseCase/**
- Forbidden paths:
  - projects/mobile-ios/CappuPOS/Sources/Data/Model/**
- Dependency: TASK-001, TASK-004
- Acceptance criteria:
  - [ ] Pembayaran tunai: input nominal manual/suggestion, kembalian auto
  - [ ] Pembayaran non-tunai: pilih metode, dicatat manual
  - [ ] Data tambahan opsional dapat ditambahkan
  - [ ] List belum bayar & riwayat dengan filter (kategori/tanggal/metode bayar)
  - [ ] Hapus transaksi: soft delete (lunas), hard delete (belum bayar)
  - [ ] Laporan overview card + grafik tren (Swift Charts)
  - [ ] Laporan kelola stok: histori perubahan stok
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):