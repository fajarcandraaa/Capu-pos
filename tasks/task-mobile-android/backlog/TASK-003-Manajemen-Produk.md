# Task: TASK-003

- Repo: mobile-android
- Role: android-engineer
- Base branch: main
- Requirement ref: FR-01 (Manajemen Produk)
- Allowed paths:
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/**
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/TambahProdukUseCase.kt, UbahProdukUseCase.kt, HapusProdukUseCase.kt
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/model/Produk.kt
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/dao/ProdukDao.kt
- Forbidden paths:
  - projects/mobile-android/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entity/**
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