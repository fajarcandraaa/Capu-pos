# Task: TASK-009-Cleanup

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: REVISION-NOTES-Android-2026-09-15.md §8 + Agent A low findings
- Allowed paths:
  - apps/capupos-android/gradlew.new (dihapus)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/MainActivity.kt
  - apps/capupos-android/app/src/main/res/layout/activity_home.xml
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/**
- Dependency: TASK-009-Git-Commit-Android-Complete
- Acceptance criteria:
  - [ ] `gradlew.new` dihapus (isi "404: Not Found")
  - [ ] Splash delay sesuai spek: `< 2 detik` (TASK-002.md:15) — saat ini 2000ms (MainActivity.kt:19-22)
  - [ ] Empty-state Home (hasil filter kosong) punya CTA jelas (PRD:106) — activity_home.xml:199-236
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
