# Task: TASK-009-Git-Commit-Android-Complete

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: Governance SCM — REVISION-NOTES-Android-2026-09-15.md §1 (App Code Untracked in Git)
- Allowed paths:
  - apps/capupos-android/**
- Forbidden paths:
  - tasks/** (kontrak task read-only)
  - apps/capupos-ios/**
- Dependency: tidak ada (blocker mutlak untuk semua task revisi lain)
- Acceptance criteria:
  - [ ] Seluruh `apps/capupos-android/` (TASK-001..008) ter-`git add` dan ter-commit
  - [ ] Commit message mengikuti conventional commit, mis. `feat(android): TASK-001..008 implementation complete`
  - [ ] `git status --short apps/capupos-android/` bersih (tidak ada `??`/`M` tersisa)
  - [ ] Branch target `main` atau feat branch, di-push ke remote
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
