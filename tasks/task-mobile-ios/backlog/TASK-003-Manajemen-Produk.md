# Task: TASK-003

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-01 (Manajemen Produk)
- Allowed paths:
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Produk/**
  - projects/mobile-ios/CappuPOS/Sources/Domain/UseCase/TambahProdukUseCase.swift, UbahProdukUseCase.swift, HapusProdukUseCase.swift
  - projects/mobile-ios/CappuPOS/Sources/Domain/Model/Produk.swift
  - projects/mobile-ios/CappuPOS/Sources/Data/Model/ProdukModel.swift
- Forbidden paths:
  - projects/mobile-ios/CappuPOS/Sources/Data/Database/**
- Dependency: TASK-001, TASK-002
- Acceptance criteria:
  - [ ] List produk grid + tab kategori berfungsi
  - [ ] Search produk di list berhasil
  - [ ] Tambah produk (foto, nama, kategori, harga, deskripsi) berhasil
  - [ ] Ubah produk memungkinkan edit semua field
  - [ ] Hapus produk menghasilkan konfirmasi dialog
  - [ ] Detail produk menampilkan informasi lengkap
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):