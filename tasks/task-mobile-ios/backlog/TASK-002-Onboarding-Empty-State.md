# Task: TASK-002

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-14 (Cek produk kosong) + Onboarding sesuai UI/UX Flow
- Allowed paths:
  - projects/mobile-ios/capupos-ios/CappuPOS/Sources/Presentation/Onboarding/**
  - projects/mobile-ios/capupos-ios/CappuPOS/Sources/Domain/UseCase/CekProdukKosongUseCase.swift
  - projects/mobile-ios/capupos-ios/CappuPOS/Sources/Data/Repository/**
- Forbidden paths:
  - projects/mobile-ios/capupos-ios/CappuPOS/Sources/Presentation/Produk/**
- Dependency: TASK-001
- Acceptance criteria:
  - [ ] Splash screen tampil < 2 detik
  - [ ] Deteksi produk kosong benar
  - [ ] Empty state dengan CTA "Tambah produk pertama" muncul
  - [ ] Form tambah produk (foto, nama, kategori, harga, deskripsi) berfungsi
  - [ ] Setelah produk disimpan, otomatis arah ke Home
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):