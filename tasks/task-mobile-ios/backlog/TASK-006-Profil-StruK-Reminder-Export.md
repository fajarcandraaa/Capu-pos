# Task: TASK-006

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-10, FR-11, FR-12, FR-13 (Profil Usaha, Struk, Reminder, Export)
- Allowed paths:
  - projects/mobile-ios/CappuPOS/Sources/Presentation/ProfilUsaha/**
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Struk/**
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Reminder/**
  - projects/mobile-ios/CappuPOS/Sources/Presentation/Export/**
  - projects/mobile-ios/CappuPOS/Sources/Domain/UseCase/**
- Forbidden paths:
  - projects/mobile-ios/CappuPOS/Sources/Data/Model/**
- Dependency: TASK-001, TASK-005
- Acceptance criteria:
  - [ ] Profil usaha: ubahNama, logo, kategori, deskripsi, alamat, telepon
  - [ ] Struk digital: item, subtotal, metode bayar, kembalian, share (UIActivityViewController)
  - [ ] Reminder backup mingguan: popup wajib dismiss, pilih "Export Sekarang" atau "Nanti Saja"
  - [ ] Export Excel: 3 sheet (Transaksi, Produk, Laporan Ringkas), share/save via iOS Share Sheet
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):