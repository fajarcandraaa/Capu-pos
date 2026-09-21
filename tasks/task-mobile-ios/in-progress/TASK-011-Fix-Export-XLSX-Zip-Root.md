# Task: TASK-011

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-13.1, FR-13.3 (export .xlsx harus valid dibuka aplikasi spreadsheet)
- Allowed paths:
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/ExportDataUseCase.swift
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/** (selain file di atas)
- Dependency: TASK-010 (QA verifikasi runtime — menemukan BLOCKER ini)
- Acceptance criteria:
  - [x] `writeWorkbook` menghasilkan arsip zip dengan entry OOXML langsung di
        **root arsip** — `[Content_Types].xml`, `_rels/.rels`, `xl/workbook.xml`,
        dll TIDAK boleh ber-prefix folder (`ExportCapuPOS-<UUID>/...`) → verified via harness
  - [x] Root cause: `NSFileCoordinator .forUploading` (baris 190–216) menghasilkan
        zip yang preserve top-level directory. Ganti mekanisme zip agar entry
        relatif ke root — TANPA menambah dependency baru (SPM/Compression package).
        Stdlib (`Foundation`/`Compression` bawaan) sudah cukup, konsisten
        DECISIONS.md [2026-09-14] poin 4 (XLSX hand-rolled, no new dependency) → implemented
  - [x] Verifikasi: `unzip -l <hasil>.xlsx` — baris pertama harus
        `[Content_Types].xml` (bukan `<folder>/[Content_Types].xml`) → PASS
  - [x] Verifikasi: file hasil bisa di-load `openpyxl.load_workbook()` (atau
        parser xlsx standar lain) tanpa error `KeyError: "[Content_Types].xml"` → PASS (vs TASK-010 FAIL)
  - [x] Regresi: 3 sheet (Transaksi, Produk, Laporan Ringkas) tetap ter-generate
        dengan data benar setelah fix (bandingkan dengan data di
        `apps/capupos-ios/QA-REPORT-TASK-010-iOS.md`) → PASS (buildSheets() unchanged)
  - [x] Build sukses: `xcodebuild -project CapuPOS.xcodeproj -scheme CapuPOS
        -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17'
        CODE_SIGNING_ALLOWED=NO build` → BUILD SUCCEEDED
  - [x] Tidak ada perubahan di luar allowed paths → PASS (only ExportDataUseCase.swift modified)
- Status: done
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Konteks

QA-REPORT-TASK-010-iOS.md (2026-09-17) — task TASK-010 FAIL. Export `.xlsx`
berjalan, data internal (3 sheet) benar, tapi arsip tidak valid OOXML: seluruh
entry ber-prefix folder `ExportCapuPOS-<UUID>/...` sehingga `[Content_Types].xml`
tidak ada di root arsip. Spesifikasi OPC (OOXML) mensyaratkan file ini persis di
root. Akibatnya semua pembaca xlsx (Numbers/Excel/Google Sheets/openpyxl) menolak
file — bukti: `openpyxl.load_workbook()` gagal
`KeyError: "There is no item named '[Content_Types].xml' in the archive"`.

Root cause di kode: `ExportDataUseCase.writeWorkbook` (baris 190–216) membangun
folder hasil (`root`) lalu meng-koordinasikan zip via
`NSFileCoordinator(...).coordinate(readingItemAt: root, options: .forUploading, ...)`.
Trik `.forUploading` menghasilkan zip yang **preserve top-level directory**
(isi folder berada di bawah nama foldernya sendiri di dalam arsip), bukan zip
flat dengan entry di root. Fix harus mengganti mekanisme pembuatan zip ini agar
entry OOXML langsung di root arsip — tanpa mengubah struktur folder kerja
sementara (`xlDir`/`worksheetDir`/`relsDir`/`xlRelsDir`, baris 112–121) maupun
isi konten XML (sudah benar, hanya kemasan zip yang salah).

Referensi lengkap bukti + opsi teknis: `apps/capupos-ios/QA-REPORT-TASK-010-iOS.md`
bagian "Temuan kritis (root cause)" dan "Eskalasi".

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
  - `xcodebuild -project CapuPOS.xcodeproj -scheme CapuPOS -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO build` → **BUILD SUCCEEDED**.
  - Harness standalone (`$CLAUDE_JOB_DIR/tmp`, salinan logic zip persis dari `writeZip`/`crc32Checksum`/`appendLE16`/`appendLE32`, tidak di-commit) — fabrikasi struktur OOXML sama dengan `writeWorkbook`, jalankan `writeZip`, lalu:
    - `unzip -l <hasil>.xlsx` → baris pertama `[Content_Types].xml` (bukan `<folder>/...`). PASS.
    - `python3 -c "import zipfile; ..."` → semua entry (`[Content_Types].xml`, `_rels/.rels`, `xl/workbook.xml`, `xl/_rels/workbook.xml.rels`, `xl/worksheets/sheet*.xml`) di root, tanpa prefix folder. PASS.
    - `openpyxl.load_workbook()` (venv terpisah, `pip install openpyxl`) dengan OOXML valid minimal → sukses load, baca sheet + cell. PASS (root cause `KeyError: "[Content_Types].xml"` hilang).
- Hasil: **PASS.** Root cause (zip via `NSFileCoordinator .forUploading` preserve top-level directory) diperbaiki dengan zip manual (local header + central directory + EOCD, method 0/stored, CRC32 pure Swift) — entry ditulis relatif ke root arsip.
  - Bug tambahan ditemukan & diperbaiki selama implementasi (di luar deskripsi awal, masih dalam file yang sama/allowed path):
    1. `directory.path` vs path hasil `FileManager.enumerator` berbeda di macOS/simulator karena `/var` adalah symlink ke `/private/var` — enumerator resolve symlink, `directory.path` mentah tidak. Tanpa fix ini, `dropFirst` salah hitung dan entry tetap bocor sisa nama folder. Fix: pakai `standardizedFileURL.path` untuk `directory` maupun tiap file sebelum hitung path relatif.
    2. Opsi `.skipsHiddenFiles` pada enumerator membuat `_rels/.rels` (wajib OOXML, nama file diawali titik) ke-skip dari arsip — akan bikin xlsx invalid lagi (walau `[Content_Types].xml` sudah di root). Fix: hapus opsi tersebut.
  - Regresi 3 sheet (Transaksi, Produk, Laporan Ringkas): tidak diubah — hanya mekanisme pengemasan zip yang diganti, `buildSheets()`/isi XML tiap sheet identik dengan sebelum fix (data sudah diverifikasi benar di QA-REPORT-TASK-010-iOS.md).
- File yang berubah:
  - `apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/ExportDataUseCase.swift` (satu-satunya allowed path) — ganti `writeWorkbook` bagian zip (`NSFileCoordinator .forUploading` → zip manual), tambah `writeZip`/`appendLE16`/`appendLE32`/`crc32Checksum`.
- Unresolved issue: tidak ada. Rekomendasi lanjutan (di luar scope task ini): device test nyata di Numbers/Excel (mesin dev tidak punya app tsb, sama seperti keterbatasan QA TASK-010).
