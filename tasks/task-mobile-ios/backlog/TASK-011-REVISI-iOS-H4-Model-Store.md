# Task: TASK-011

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: NFR 5.2 (Ekstensibilitas Skema Store)
- Allowed paths:
  - apps/capupos-ios/CappuPOS/Sources/Data/Models/CapuPOSDataModel.swift
  - apps/capupos-ios/CappuPOS/Sources/Data/Repository/StoreRepository.swift
  - apps/capupos-ios/CappuPOS/Sources/Presentation/ProfilUsaha/ProfilUsahaView.swift
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/Domain/**
- Dependency: TASK-007
- Acceptance criteria:
  - [ ] Model `Store`: tambahkan field `email: String?` dan `no_hp: String?` (nullable)
  - [ ] Migrasi Additive: pastikan penambahan field tidak merusak data Store yang sudah tersimpan (SwiftData otomatis menangani penambahan field opsional)
  - [ ] Update Repository: sesuaikan method simpan/update untuk menampung dua field baru tersebut
  - [ ] Update View: tambahkan input field email dan nomor HP di ProfilUsahaView (sesuaikan UI/UX agar tetap rapi)
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: ready

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
