# Task: TASK-009-Onboarding-Form-Kategori

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: FR-01.1 + UI/UX Flow:59-60 — REVISION-NOTES-Android-2026-09-15.md (Agent A)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/onboarding/AddProductActivity.kt
  - apps/capupos-android/app/src/main/res/layout/activity_add_product.xml
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/**
- Dependency: TASK-009-Git-Commit-Android-Complete
- Acceptance criteria:
  - [ ] Spinner kategori dinamis tersedia di `AddProductActivity` (reuse pola kategori TASK-008)
  - [ ] Opsi "+ Tambah Kategori" inline tersedia di form (UI/UX:60)
  - [ ] Produk onboarding disimpan dengan `kategoriId` (kategori wajib, FR-01.1)
  - [ ] Form onboarding dan `TambahProdukActivity` konsisten (kategori tidak hilang di salah satu)
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: ready
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->
<!-- Diverifikasi TL/SA [2026-09-21]: semua allowed_paths sudah ada di source, tidak ada gap kontrak. -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
