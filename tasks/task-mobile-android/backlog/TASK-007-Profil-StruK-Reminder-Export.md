# Task: TASK-007

- Repo: mobile-android
- Role: android-engineer
- Base branch: main
- Requirement ref: FR-10 (Profil Usaha), FR-11 (Struk), FR-12 (Reminder), FR-13 (Export)
- Allowed paths:
  - projects/mobile-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/profilusaha/**
  - projects/mobile-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/struk/**
  - projects/mobile-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/reminder/**
  - projects/mobile-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/export/**
  - projects/mobile-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/UbahDataUsahaUseCase.kt, GenerateStrukUseCase.kt, CekReminderBackupUseCase.kt, ExportDataUseCase.kt
- Forbidden paths:
  - projects/mobile-android/app/src/main/java/com/mindtoscreen/cappupos/data/entity/**
- Dependency: TASK-001, TASK-006
- Acceptance criteria:
  - [ ] Profil usaha: ubah nama, logo, kategori, deskripsi, alamat, telepon
  - [ ] Struk digital: item, subtotal, metode bayar, kembalian, share
  - [ ] Reminder backup mingguan: popup wajib dismiss, pilih "Export Sekarang" atau "Nanti Saja"
  - [ ] Export Excel: 3 sheet (Transaksi, Produk, Laporan Ringkas), share/save via Android Sharesheet
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):