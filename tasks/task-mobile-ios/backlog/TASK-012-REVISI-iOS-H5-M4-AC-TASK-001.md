# Task: TASK-012

- Repo: mobile-ios
- Role: tech-lead-system-analyst
- Base branch: main
- Requirement ref: Governance — tutup AC TASK-001 yang belum tercentang (H5, M4)
- Allowed paths:
  - tasks/task-mobile-ios/done/TASK-001-Setup-iOS-Project.md
  - apps/capupos-ios/GOVERNANCE-AUDIT-TASK-001.md
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/** (read-only — audit, bukan implementasi)
- Dependency: tidak ada
- Acceptance criteria:
  - [ ] Jalankan build+run produk utama (Splash, Onboarding, Home) di simulator, dokumentasikan hasil (command + output)
  - [ ] Audit retroaktif seluruh commit/file yang berubah selama TASK-001 vs allowed_paths yang tercatat di task contract — catat temuan (sesuai/tidak) di GOVERNANCE-AUDIT-TASK-001.md
  - [ ] Update `tasks/task-mobile-ios/done/TASK-001-Setup-iOS-Project.md`: centang 2 AC yang sebelumnya belum tercentang, dengan bukti verifikasi (command test + hasil)
  - [ ] Bila audit menemukan pelanggaran allowed_paths nyata, catat sebagai temuan terpisah dan eskalasi ke PM — jangan modifikasi retroaktif file di luar task ini
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: ready

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
