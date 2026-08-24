# Task: TASK-001

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: Setup project structure sesuai TRD Clean Architecture
- Allowed paths:
  - projects/mobile-ios/CappuPOS/Sources/Presentation/**
  - projects/mobile-ios/CappuPOS/Sources/Domain/**
  - projects/mobile-ios/CappuPOS/Sources/Data/**
  - projects/mobile-ios/CappuPOS/Resources/**
- Forbidden paths:
  - projects/mobile-ios/CappuPOS/Tests/**
- Dependency: tidak ada
- Acceptance criteria:
  - [ ] Package structure mengikuti SDD: Presentation/, Domain/, Data/
  - [ ] SwiftData database dikonfigurasi dengan skema 8 tabel
  - [ ] Dependency injection sudah terintegrasi (native Swift DI)
  - [ ] Produk utama (Splash, Onboarding, Home) dapat dijalankan di simulator
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):