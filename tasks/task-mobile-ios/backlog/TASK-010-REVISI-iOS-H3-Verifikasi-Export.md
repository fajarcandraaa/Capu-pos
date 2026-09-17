# Task: TASK-010

- Repo: mobile-ios
- Role: qa-engineer
- Base branch: main
- Requirement ref: FR-13.1, FR-13.3 (verifikasi runtime file .xlsx export)
- Allowed paths:
  - apps/capupos-ios/QA-REPORT-TASK-010-iOS.md
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/** (read-only — task ini verifikasi, bukan implementasi)
- Dependency: TASK-007
- Acceptance criteria:
  - [ ] Jalankan export .xlsx di simulator/device, ambil file hasil export via Share Sheet
  - [ ] Buka file di minimal 2 aplikasi (mis. Numbers dan salah satu dari Excel/Google Sheets) — buktikan file valid dan bisa dibuka tanpa error/corrupt
  - [ ] Verifikasi 3 sheet (Transaksi, Produk, Laporan Ringkas) muncul dengan data benar
  - [ ] Tulis hasil verifikasi (screenshot/log) di QA-REPORT-TASK-010-iOS.md, termasuk kesimpulan PASS/FAIL
  - [ ] Bila FAIL: eskalasi ke ios-developer dengan detail error untuk task lanjutan
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: ready

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
