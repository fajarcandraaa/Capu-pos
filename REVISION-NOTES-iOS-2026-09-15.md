# Catatan Revisi — iOS TASK-001 s/d TASK-007 vs Dokumentasi (@docs/)

**Tanggal audit:** 2026-09-15
**Auditor:** tech-lead-system-analyst (verifikasi langsung ke code `apps/capupos-ios/CappuPOS/Sources`, main branch, bukan laporan QA/review lama)
**Metode:** 3 subagent paralel (FR-01/02/03/14, FR-04..08, FR-09..13) + verifikasi mandiri (task contract, DECISIONS.md, model data).
**Scope:** Seluruh task iOS TASK-001–TASK-007 yang diklaim selesai.

Legenda severity: **Blocker** (rilis tidak boleh jalan) · **High** (requirement eksplisit gagal end-to-end) · **Medium** (requirement parsial/UX gap) · **Low** (kosmetik/inkonsistensi arsitektur, non-fungsional).

---

## Ringkasan

| Severity | Jumlah |
|---|---|
| Blocker | 0 |
| High | 6 |
| Medium | 4 |
| Low | 5 |

Tidak ada Blocker — app secara umum fungsional. Namun 6 temuan High berarti beberapa requirement SRS tidak terpenuhi secara end-to-end meski unit/use-case-nya ada di code (fitur "dibangun tapi tidak terjangkau user").

---

## Temuan High

### H1. FR-01.1 — Kategori tidak wajib saat tambah/ubah produk & saat onboarding
- **Expected (SRS FR-01.1):** kategori adalah field wajib saat membuat/mengubah produk.
- **Actual:** `TambahProdukView.swift:19-23` (`canSave`), `UbahProdukView.swift:30-34`, `EmptyStateView.swift:326-340` — validasi hanya nama + harga>0; `selectedCategory` nullable, tidak divalidasi di layer manapun (view/use-case/repository).
- **Catatan:** DECISIONS.md [2026-09-08] poin 4 melegitimasi `categoryID = nil` HANYA sebagai akibat hapus kategori (produk existing jadi "Tanpa Kategori"), bukan izin membuat produk baru tanpa kategori. Mismatch tetap valid.
- **Dampak:** produk bisa dibuat/diedit tanpa kategori di 3 titik (tambah, ubah, onboarding pertama) — bertentangan langsung dengan SRS.
- **File:** `Presentation/Produk/TambahProdukView.swift:19-23,136`; `Presentation/Produk/UbahProdukView.swift:30-34,165`; `Presentation/Onboarding/EmptyStateView.swift:326-340`.

### H2. FR-06.4 / FR-11 — Struk digital tidak pernah ditampilkan (dead code, no entry point)
- **Expected (SRS FR-06.4, FR-11; UI/UX 5.8):** setelah pembayaran sukses → tampilkan struk digital → aksi bagikan/selesai.
- **Actual:** `GenerateStrukUseCase` + `StrukView` terimplementasi benar secara isolasi (item/subtotal/metode/nominal/kembalian/header toko lengkap), TAPI `PembayaranView.bayar()` sukses langsung `dismiss()` (`PembayaranView.swift:117`). `grep -rn 'StrukView()'` di seluruh `Sources/` = 0 hasil — tidak ada satupun caller dari Riwayat/Detail Transaksi/Pembayaran.
- **Dampak:** fitur struk digital sama sekali tidak bisa diakses user meski unit code-nya lengkap. Ini requirement inti (FR-06.4 wajib), bukan nice-to-have.
- **File:** `Presentation/Pembayaran/PembayaranView.swift:103-122`; `Domain/UseCase/GenerateStrukUseCase.swift` (tidak ada caller); `Presentation/Struk/StrukView.swift` (tidak ada caller).

### H3. FR-13.1/13.3 — File .xlsx (zip hand-rolled) belum pernah diverifikasi bisa dibuka
- **Expected:** satu file Excel valid (3 sheet: Transaksi/Produk/Laporan Ringkas) yang bisa dibuka dan dibagikan.
- **Actual:** format OOXML 3-sheet benar secara struktur (`ExportDataUseCase.swift:44-104`), tapi mekanisme zip pakai `NSFileCoordinator.coordinate(readingItemAt: .forUploading)` (`:190-217`) — trik non-standar. QA report (`QA-REPORT-TASK-007-iOS.md:51,59,63`) dan review (`REVIEW-TASK-007-iOS.md:72-75,116`) SAMA-SAMA menyatakan verifikasi manual (buka di Excel/Numbers) WAJIB dilakukan sebelum rilis, tapi task contract mencatatnya sebagai **unresolved issue** (`TASK-007-...md:77`) — tidak ada bukti pernah dijalankan.
- **Dampak:** gate rilis utama TASK-007 tidak pernah ditutup secara nyata; risiko file export korup/tidak bisa dibuka di device user.
- **File:** `Domain/UseCase/ExportDataUseCase.swift:190-217`; `apps/capupos-ios/QA-REPORT-TASK-007-iOS.md`; `apps/capupos-ios/REVIEW-TASK-007-iOS.md`.

### H4. NFR "Ekstensibilitas Skema" — field email/no_hp hilang dari model Store
- **Expected (SRS NFR 5.2 + entitas Data "Profil Lokal"):** field `email` (nullable) dan `no_hp` (nullable) harus ada di model data sejak MVP1 untuk menjaga ekstensibilitas skema, meski belum ditampilkan di UI.
- **Actual:** `Store` model (`CapuPOSDataModel.swift:220-251`) hanya punya 6 field: id, nama, logo, kategoriUsaha, deskripsi, alamat, telepon — TIDAK ADA email/no_hp.
- **Dampak:** requirement non-fungsional eksplisit dilanggar; migrasi skema di kemudian hari jadi tidak "additive-safe" sesuai desain awal.
- **File:** `Data/Models/CapuPOSDataModel.swift:220-251`.

### H5. TASK-001 — Acceptance criteria belum terpenuhi tapi status ditandai selesai
- **Expected:** semua AC task contract tercentang sebelum task dipindah ke `done/`.
- **Actual:** `tasks/task-mobile-ios/done/TASK-001-Setup-iOS-Project.md` punya 2 AC tidak tercentang: "Produk utama (Splash, Onboarding, Home) dapat dijalankan di simulator" dan "Tidak ada perubahan di luar allowed paths". Catatan sesi eksplisit menyebut "Simulator testing belum dilakukan".
- **Dampak:** governance gap — task ditandai selesai tanpa bukti verifikasi runtime dasar, menular ke resiko semua task berikutnya (TASK-002–007) yang dibangun di atasnya.
- **File:** `tasks/task-mobile-ios/done/TASK-001-Setup-iOS-Project.md`.

### H6. UI/UX 5.13 — Aksi "Cetak" di Detail Transaksi tidak diimplementasikan
- **Expected (UI/UX Flow 5.13):** Detail Transaksi punya aksi Ubah/Sembunyikan/Hapus/Bayar/**Cetak**.
- **Actual:** tidak ada implementasi cetak (print) di Detail Transaksi manapun — konsisten dengan H2 (struk tidak pernah ditampilkan, apalagi dicetak).
- **Dampak:** requirement UI/UX eksplisit tidak terpenuhi; terkait langsung dengan H2, kemungkinan bisa diperbaiki dalam task revisi yang sama.
- **File:** tidak ditemukan di `Presentation/Transaksi/` maupun `Presentation/Riwayat/`.

---

## Temuan Medium

### M1. FR-02.2 — Reorder kategori pakai tombol, bukan drag & drop
SRS eksplisit minta "drag & drop"; code pakai tombol chevron up/down (`KategoriListView.swift:177-192`). Persistensi urutan (`Category.order`) sudah benar, hanya interaksi UI yang beda dari spec.

### M2. FR-12.1 — Reminder pertama muncul saat app dibuka pertama kali, bukan 7 hari sejak install
SRS FR-12.1 + BR-06: kemunculan pertama dihitung dari tanggal install. Code (`ReminderBackupUseCase.swift:18-21`) return `true` begitu key absen → reminder muncul di buka pertama (hari 0). Tidak ada tracking installDate sama sekali (grep = 0 match). DECISIONS [2026-09-14] poin 5 hanya mengatur rolling interval, tidak pernah menyetujui kemunculan di hari 0.

### M3. FR-09.3 — Search laporan tidak ter-wire di UI
Filter laporan (reuse `RiwayatFilterView`) sudah jalan, tapi `searchText` (`LaporanView.swift:14,26`) tidak terhubung ke `TextField`/`.searchable` manapun — user tidak bisa mengetik query pencarian di layar Laporan.

### M4. TASK-001 — governance follow-up untuk H5
Perlu task terpisah/lanjutan untuk menutup 2 AC yang belum tercentang di TASK-001 sebelum dianggap final (simulator run + audit allowed_paths).

---

## Temuan Low

### L1. `ArurKetersediaanStokView` mem-bypass pola UseCase
Mutasi `Product` langsung di view (`ArurKetersediaanStokView.swift:123-137`), tidak lewat use-case seperti fitur lain. Inkonsistensi arsitektur, tidak mempengaruhi fungsi.

### L2. `UbahStatusPOUseCase` didefinisikan tapi tidak pernah dipanggil
`OrderDetailEditView.swift:161-165` memanggil `repository.updateStatusPo()` langsung. Business rule FR-05.5 tetap tertegakkan (guard ada di repository), murni inkonsistensi layer use-case.

### L3. FR-12.3 — Reminder berpotensi muncul >1x/7 hari bila app di-force-quit sebelum dismiss
Counter hanya diset saat tombol ditekan (`ReminderBackupView.swift:70-79`). Force-quit tanpa dismiss → reminder muncul lagi di buka berikutnya meski masih dalam window 7 hari. Edge case sempit (dismiss aktif wajib via `interactiveDismissDisabled`), literal FR-12.3 tidak terjaga penuh.

### L4. Komentar kode mislabel nomor FR
`ReminderBackupUseCase.swift:3,5`, `ReminderBackupView.swift:4`, `AppEntry.swift:97-98,165` menulis "FR-10.3" (seharusnya FR-12.x); `GenerateStrukUseCase.swift:3,5,18` menulis "FR-10.2" untuk struk (seharusnya FR-11). Tidak mempengaruhi behavior, menyesatkan audit/traceability berikutnya.

### L5. Export XLSX blocking main thread saat generate
`ExportView` menjalankan `ExportDataUseCase.execute()` (zip + tulis file) secara sinkron di main thread; `ProgressView` tidak sempat tampil, UI freeze sesaat saat export. Kosmetik, tidak melanggar requirement fungsional.

---

## FR yang sudah SESUAI (verified, untuk referensi — tidak perlu revisi)

FR-01.2, FR-01.3, FR-02.1, FR-02.2 (persistensi), FR-03.1, FR-03.2, FR-03.3, FR-14.1 (deteksi), FR-14.2, FR-04, FR-05.1–05.4, FR-05.5, FR-06.1–06.3, FR-07.1–07.4, FR-08.1, FR-08.2 (termasuk fix AC5 TASK-006 — sudah benar, tidak seperti dilaporkan di ESCALATION-REPORT-TASK-006-iOS-QA.md lama), FR-09.1, FR-09.2, FR-10.1, FR-12.2, FR-12 storage/trigger, FR-13.2, FR-13.3 (mekanisme share), Store singleton, format export (XLSX bukan CSV, sesuai DECISIONS).

---

## Rekomendasi task revisi (untuk PM)

1. **[High] Wajibkan kategori di semua entry pemilihan produk** (H1) — TambahProduk, UbahProduk, EmptyState onboarding.
2. **[High] Wire struk digital ke flow pembayaran + tambahkan aksi Cetak di Detail Transaksi** (H2 + H6) — satu task gabungan, akar masalah sama.
3. **[High] Verifikasi runtime file .xlsx export** (H3) — buka aktual di Excel/Numbers/Google Sheets, tutup gate rilis TASK-007.
4. **[High] Tambah field email/no_hp nullable ke model Store** (H4) — migrasi additive SwiftData.
5. **[High+Medium] Tutup AC TASK-001** (H5+M4) — jalankan di simulator, audit allowed_paths retroaktif.
6. **[Medium] Reorder kategori jadi drag & drop** (M1) — atau ajukan amend DECISIONS bila tombol dianggap cukup.
7. **[Medium] Reminder backup: hitung hari pertama dari install date** (M2).
8. **[Medium] Wire search box di Laporan** (M3).
9. **[Low, opsional/batch kecil]** L1–L5 — bisa digabung jadi satu task cleanup teknikal jika prioritas rendah.
