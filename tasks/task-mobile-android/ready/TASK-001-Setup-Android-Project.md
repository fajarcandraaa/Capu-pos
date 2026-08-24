# Task: TASK-001

- Repo: mobile-android
- Role: android-engineer
- Base branch: main
- Requirement ref: Setup project structure sesuai TRD Clean Architecture
- Allowed paths:
  - projects/mobile-android/app/src/main/java/com/mindtoscreen/cappupos/**
  - projects/mobile-android/app/src/main/resources/**
- Forbidden paths:
  - projects/mobile-android/build.gradle (hanya untuk konfigurasi build)
- Dependency: tidak ada
- Acceptance criteria:
  - [ ] Package structure mengikuti SDD: presentation/, domain/, data/
  - [ ] Room database dikonfigurasi dengan skema 8 tabel
  - [ ] Hilt DI sudah terintegrasi
  - [ ] Produk utama (Splash, Onboarding, Home) dapat dijalankan
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):