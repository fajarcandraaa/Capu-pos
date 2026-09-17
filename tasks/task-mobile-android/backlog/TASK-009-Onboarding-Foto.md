# Task: TASK-009-Onboarding-Foto

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: TASK-002 unresolved — REVISION-NOTES-Android-2026-09-15.md (Agent A)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/onboarding/AddProductActivity.kt
  - apps/capupos-android/app/src/main/res/layout/activity_add_product.xml
  - apps/capupos-android/app/src/main/AndroidManifest.xml (permission/capability picker bila perlu)
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/**
- Dependency: TASK-009-Onboarding-Form-Kategori (satu form sama — hindari conflict, dikerjakan setelahnya)
- Acceptance criteria:
  - [ ] Foto picker fungsional di onboarding (bukan placeholder Toast)
  - [ ] Foto tersimpan dan tampil di detail produk
  - [ ] Toast "Fitur upload foto belum tersedia" dihapus
  - `AddProductActivity.kt:53-55` tidak lagi menampilkan Toast placeholder
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
