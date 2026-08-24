# Task: TASK-004

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-02 (Kategori), FR-03 (Stok), FR-04, FR-05, FR-07 (Transaksi)
- Allowed paths:
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Kategori/**
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Stok/**
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Transaksi/**
  - projects/mobile-ios/CappuPOS/Sources/Presentation/TransaksiManual/**
- Forbidden paths:
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Pembayaran/**
- Dependency: TASK-001, TASK-003
- Acceptance criteria:
  - [ ] Kelola kategori: tambah, ubah nama, hapus, reorder
  - [ ] Atur stok: aktif/nonaktifkan pelacakan, set stok minimal, update stok
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