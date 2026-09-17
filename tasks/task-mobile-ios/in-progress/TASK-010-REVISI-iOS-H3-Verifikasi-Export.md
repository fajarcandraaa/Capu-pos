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
  - [x] Jalankan export .xlsx di simulator/device, ambil file hasil export via Share Sheet
  - [ ] Buka file di minimal 2 aplikasi (mis. Numbers dan salah satu dari Excel/Google Sheets) — buktikan file valid dan bisa dibuka tanpa error/corrupt
  - [x] Verifikasi 3 sheet (Transaksi, Produk, Laporan Ringkas) muncul dengan data benar
  - [x] Tulis hasil verifikasi (screenshot/log) di QA-REPORT-TASK-010-iOS.md, termasuk kesimpulan PASS/FAIL
  - [x] Bila FAIL: eskalasi ke ios-developer dengan detail error untuk task lanjutan
  - [x] Tidak ada perubahan di luar allowed paths
- Status: in_progress

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
  - `xcodebuild -project CapuPOS.xcodeproj -scheme CapuPOS -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO build` → BUILD SUCCEEDED
  - Harness Swift (`swiftc`) reuse source produksi asli + `ModelContainer` SwiftData in-memory, jalankan `ExportDataUseCase.execute()` → file `.xlsx` ter-generate (3795 bytes, magic PK)
  - `unzip -t` → OK (kompresi zip utuh)
  - `openpyxl.load_workbook` → FAIL `KeyError: "[Content_Types].xml"`
- Hasil: **FAIL** — export berjalan + 3 sheet + data internal benar, tapi arsip xlsx corrupt (OPC violation: `[Content_Types].xml` tidak di root zip karena `NSFileCoordinator .forUploading` memberi prefix folder)
- File yang berubah: `apps/capupos-ios/QA-REPORT-TASK-010-iOS.md` (baru, allowed path)
- Unresolved issue (bila ada): BLOCKER — file .xlsx corrupt; eskalasi ke ios-developer (fix `ExportDataUseCase.writeWorkbook` baris 190–216)
