# CONFLICT REPORT — TASK-007 iOS (Profil Usaha, Struk, Reminder, Export)

- Tanggal: 2026-09-14
- Role: ios-developer
- Repo: mobile-ios (apps/capupos-ios)
- Task contract: `tasks/task-mobile-ios/ready/TASK-007-Profil-StruK-Reminder-Export.md` (Status: **draft**)
- Jenis konflik: **scope / allowed_paths under-specified** (pola berulang ke-5: TASK-003, TASK-004, TASK-005, TASK-006)
- Eskalasi: PM (scope) + TL/SA (teknis, model baru + entry point)

## Ringkasan

TASK-007 tidak bisa diimplementasikan hanya dalam `allowed_paths` tertulis.
FR-10 (Profil Usaha) butuh entity persisten baru yang menabrak `forbidden_paths`
secara langsung. Seluruh empat folder `allowed_paths`
(`ProfilUsaha/`, `Struk/`, `Reminder/`, `Export/`) **belum ada sama sekali** —
karena project TIDAK pakai file-system-synchronized group, setiap file baru
wajib didaftarkan manual di `project.pbxproj` (di luar allowed_paths), sama
seperti gap yang sudah dikonfirmasi di TASK-006.

## Allowed paths (tertulis di kontrak)

- `Sources/Presentation/ProfilUsaha/**`
- `Sources/Presentation/Struk/**`
- `Sources/Presentation/Reminder/**`
- `Sources/Presentation/Export/**`
- `Sources/Domain/UseCase/**`

Forbidden: `Sources/Data/Model/**` (catatan: nama folder aktual `Data/Models/`
jamak, bukan `Data/Model/` — kontrak salah eja path, tidak mengubah maksud).

## Yang sudah ada (tidak perlu disentuh) — cukup untuk FR-11, FR-12, FR-13

- `Order`, `OrderItem`, `Product` sudah lengkap untuk struk digital (item,
  subtotal, metode bayar, nominal diterima, kembalian) — FR-11.1 bisa dipenuhi
  hanya baca lewat `OrderRepository.fetchById` + `ProductRepository.fetchById`
  (keduanya publik, tidak perlu diedit).
- `FetchLaporanUseCase`/`LaporanOverview` sudah ada untuk sheet "Laporan
  Ringkas" export (FR-13.1) — tinggal dipanggil dari UseCase export baru.
- `OrderRepository.fetchAllOrders()` cukup untuk sheet "Transaksi", perlu
  fetch produk via `ProductRepository` (belum ada `fetchAll()` publik — lihat
  Gap #2) untuk sheet "Produk".
- Reminder (FR-12) tidak butuh entity SwiftData — cukup `UserDefaults`
  (native, stdlib) untuk simpan tanggal install + tanggal reminder terakhir
  dismiss. Sepenuhnya bisa dikerjakan di `Domain/UseCase/**` +
  `Presentation/Reminder/**`, tidak ada gap.

## Gap #1 (BLOCKER — tabrak forbidden_paths langsung)

FR-10.1 ("pengaturan data usaha: nama, logo, kategori usaha, deskripsi, alamat,
telepon") **tidak punya representasi data sama sekali** di
`Data/Models/CapuPOSDataModel.swift` — tidak ada entity `Store`/`BusinessProfile`
atau field setara di manapun (`grep -rni 'profil\|store\|usaha\|logo\|alamat\|telepon'`
di seluruh `Sources/` hanya menemukan `Image("CappuPOSLogo")` — asset statis,
bukan data usaha). Fitur ini butuh `@Model` baru di `Data/Models/` —
**langsung menabrak forbidden_paths**, sama persis pola Gap #1 TASK-006
(StockHistoryEntry) yang sudah diselesaikan lewat amend.

FR-10.2 ("data usaha tersimpan otomatis ditampilkan pada header struk digital")
bergantung pada entity ini — bila Gap #1 tidak diamend, FR-10 dan bagian struk
FR-11 yang menampilkan header profil usaha sama-sama tidak bisa dikerjakan.

## Gap #2 (allowed_paths tidak sebut file wajib diedit)

| File | Alasan |
|------|--------|
| `Data/Repository/` — repository baru (mis. `StoreRepository.swift`) | CRUD entity `Store` (Gap #1) butuh repository, pola konsisten dengan `CategoryRepository`/`ProductRepository`/`OrderRepository` yang sudah ada. Tidak ada repository existing yang bisa direuse. |
| `Data/Repository/ProductRepository.swift` (edit) | Belum ada method `fetchAll()` publik (hanya `fetchById`, `add`, `update`, `delete`, `reduceStockQuantity`) — dibutuhkan sheet "Produk" pada export Excel (FR-13.1). |
| `CapuPOS.xcodeproj/project.pbxproj` (edit) | Project TIDAK pakai `PBXFileSystemSynchronizedRootGroup` (dikonfirmasi ulang: `grep -n 'fileSystemSynchronized'` nihil, semua file `.swift` terdaftar manual via `PBXBuildFile`+`PBXFileReference`+group entry — pola sama persis TASK-006). Berbeda dengan TASK-006 (3 dari 4 folder `Presentation/` sudah ada sebagian file), **keempat folder TASK-007 (`ProfilUsaha/`, `Struk/`, `Reminder/`, `Export/`) belum ada sama sekali** — task ini pasti 100% file baru, tanpa akses pbxproj task ini benar-benar tidak bisa dibangun/di-compile sama sekali. |
| `Sources/App/AppEntry.swift` (edit) | Entry point navigasi: `HomeView` saat ini punya tombol cart/clock/banknote/riwayat/laporan via `.sheet`, tidak ada entry point ke Profil/Struk/Reminder/Export. FR-13.2 eksplisit minta akses "dari menu Profil/Pengaturan" — menu itu sendiri belum ada. Reminder (FR-12.1) juga perlu trigger check saat app dibuka — titik pemasangannya logis di `AppEntry.swift` (`ContentView.task` sudah ada pola serupa untuk `CekProdukKosongUseCase`). |
| `Sources/App/AppEntry.swift` (edit, `.modelContainer(for:)`) | Entity `Store` baru (Gap #1) wajib didaftarkan ke `.modelContainer(for:)` sama seperti presedan `Order`/`OrderItem`/`StockHistoryEntry` — tanpa ini data profil usaha tidak persist (BLOCK, presedan DECISIONS.md [2026-09-11] poin 2). |

## Catatan teknis tambahan

1. FR-11.2 dan FR-13.3 ("share/save mekanisme standar platform") — `UIActivityViewController`
   dikonfirmasi belum pernah dipakai di codebase (`grep -rn 'UIActivityViewController\|ShareLink'`
   nihil). Native `UIKit`/SwiftUI `ShareLink`, tidak perlu dependency baru — sejalan prinsip
   simplification.
2. FR-13.1 (export Excel 3 sheet) — tidak ada library Excel writer terpasang di project
   (SPM packages belum dicek eksplisit, tapi tidak ada import `xlsx`/`CoreXLSX` di kode manapun).
   Perlu keputusan TL/SA: tulis format `.xlsx` minimal manual (OOXML zip terbatas, kompleks) vs
   pakai `CSV` per-sheet dianggap cukup (lebih murah, tapi tidak sesuai literal "satu file Excel
   berisi tiga jenis data" bila diinterpretasi ketat sebagai satu file `.xlsx` multi-sheet) vs
   izinkan tambah 1 dependency SPM ringan (mis. `CoreXLSX` read-only tidak cukup, butuh writer —
   candidate: `xlsxwriter`-equivalent Swift package). Prinsip simplification (CLAUDE.md) melarang
   tambah dependency tanpa alasan jelas — tapi native Foundation tidak punya XLSX writer, jadi
   ini kasus dependency yang **terukur diperlukan** bila format `.xlsx` asli wajib.
3. FR-12.1 rolling reminder (7 hari sejak install ATAU sejak dismiss terakhir) — logic murni,
   tidak ada gap data, hanya dicatat karena butuh dua timestamp (`installDate`, `lastReminderAt`)
   disimpan di `UserDefaults` (bukan SwiftData, tidak masuk forbidden_paths sama sekali).

## Rekomendasi

Amend `allowed_paths` TASK-007, precedent DECISIONS.md `[2026-09-13]` (TASK-006),
`[2026-09-11]` (TASK-005), `[2026-09-08]` (TASK-004), `[2026-09-01]` (TASK-003):

- `Sources/Data/Repository/**` (baru: `StoreRepository.swift`; edit:
  `ProductRepository.swift` tambah `fetchAll()`)
- `CapuPOS.xcodeproj/project.pbxproj`
- `Sources/App/AppEntry.swift`
- Pengecualian eksplisit di `Data/Models/CapuPOSDataModel.swift` HANYA untuk
  tambah `@Model final class Store` baru (field: nama, logo, kategoriUsaha,
  deskripsi, alamat, telepon) — additive, bukan redesign model existing
  (pola sama persis pengecualian TASK-006 poin 4 untuk `StockHistoryEntry`).

Keputusan teknis yang perlu TL/SA:

1. Skema field `Store`: apakah singleton (satu row selalu, karena app ini
   single-outlet) atau perlu constraint eksplisit mencegah lebih dari satu
   row tercipta.
2. Format export Excel: `.xlsx` asli (butuh dependency SPM baru, alasan
   terukur — tidak ada XLSX writer native) vs CSV per-sheet vs 3 file
   terpisah di-zip. Menentukan apakah dependency baru disetujui.
3. Entry point menu "Profil/Pengaturan" — apakah jadi satu layar gabungan
   (Profil Usaha + tombol Export) sesuai FR-13.2 ("menu Profil/Pengaturan"),
   atau dua entry point terpisah di `HomeView` toolbar.

## Status

**TERTANGANI — RESOLUSI TL/SA [2026-09-14]:** lihat `DECISIONS.md` entry
`[2026-09-14]` dan amendemen di
`tasks/task-mobile-ios/ready/TASK-007-Profil-StruK-Reminder-Export.md`
(status: ready). Tidak ada perubahan kode dilakukan oleh ios-developer.

- Amend allowed_paths + pengecualian terbatas `@Model Store`: **DISETUJUI**
  (pola pengecualian sama dengan `StockHistoryEntry` [2026-09-13]).
- Keputusan TL/SA untuk 3 pertanyaan teknis laporan ini:
  1. Skema `Store`: singleton satu row, constraint fetch-or-create dijaga di
     `StoreRepository` (bukan schema constraint SwiftData).
  2. Format export: `.xlsx` asli, hand-rolled via `Foundation` (ZIP+XML
     manual), text-only 3 sheet, tanpa styling — dependency SPM DITOLAK.
  3. Entry point: satu layar "Profil/Pengaturan" gabungan (Profil Usaha +
     Export) sesuai literal FR-13.2.
- Catatan laporan: 5 hukum teknis yang dirinci (pbxproj manual registration,
  AppEntry `.modelContainer`, `ProductRepository.fetchAll()`, `UserDefaults`
  untuk reminder, `ShareLink` native) — semua dikonfirmasi dan diakomodasi
  dalam amendemen.
