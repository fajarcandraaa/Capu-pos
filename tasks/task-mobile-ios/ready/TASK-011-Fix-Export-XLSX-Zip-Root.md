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
  - [ ] `writeWorkbook` menghasilkan arsip zip dengan entry OOXML langsung di
        **root arsip** — `[Content_Types].xml`, `_rels/.rels`, `xl/workbook.xml`,
        dll TIDAK boleh ber-prefix folder (`ExportCapuPOS-<UUID>/...`)
  - [ ] Root cause: `NSFileCoordinator .forUploading` (baris 190–216) menghasilkan
        zip yang preserve top-level directory. Ganti mekanisme zip agar entry
        relatif ke root — TANPA menambah dependency baru (SPM/Compression package).
        Stdlib (`Foundation`/`Compression` bawaan) sudah cukup, konsisten
        DECISIONS.md [2026-09-14] poin 4 (XLSX hand-rolled, no new dependency).
  - [ ] Verifikasi: `unzip -l <hasil>.xlsx` — baris pertama harus
        `[Content_Types].xml` (bukan `<folder>/[Content_Types].xml`)
  - [ ] Verifikasi: file hasil bisa di-load `openpyxl.load_workbook()` (atau
        parser xlsx standar lain) tanpa error `KeyError: "[Content_Types].xml"`
  - [ ] Regresi: 3 sheet (Transaksi, Produk, Laporan Ringkas) tetap ter-generate
        dengan data benar setelah fix (bandingkan dengan data di
        `apps/capupos-ios/QA-REPORT-TASK-010-iOS.md`)
  - [ ] Build sukses: `xcodebuild -project CapuPOS.xcodeproj -scheme CapuPOS
        -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17'
        CODE_SIGNING_ALLOWED=NO build`
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: ready
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
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
