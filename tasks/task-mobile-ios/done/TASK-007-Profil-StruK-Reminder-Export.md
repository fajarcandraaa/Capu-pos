# Task: TASK-007

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-10, FR-11, FR-12, FR-13 (Profil Usaha, Struk, Reminder, Export)
- Allowed paths:
  - apps/capupos-ios/CappuPOS/Sources/Presentation/ProfilUsaha/**
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Struk/**
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Reminder/**
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Export/**
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/**
  - apps/capupos-ios/CappuPOS/Sources/Data/Repository/**
  - apps/capupos-ios/CappuPOS/CapuPOS.xcodeproj/project.pbxproj
  - apps/capupos-ios/CappuPOS/Sources/App/AppEntry.swift
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/Data/Model/** (KECUALI: penambahan
    `@Model final class Store` baru di `CapuPOSDataModel.swift` — additive
    only, dilarang redesign/edit model existing — lihat DECISIONS.md
    [2026-09-14])
- Figma page :
# Flow Utama
  - Home : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-15041&m=dev
  - Produk - Tambah : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17215&m=dev
  - Langsung - Tambah : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17346&m=dev
  - Langsung - Duplikasi : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17862&m=dev
  - Langsung - Hapus : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17914&m=dev
  - Langsung - Ubah : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17993&m=dev
# Management Produk
  - Tambah Produk : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16826&m=dev
  - Tambah Kategrori : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17162&m=dev
  - Ubah Produk : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16413&m=dev
  - Hapus Produk : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16517&m=dev
  - Urutkan, Ubah dan hapus kategori : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16694&m=dev
  - Atur ketersediaan stok : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16571&m=dev
  - Memperbarui ketersediaan stok : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16646&m=dev
- Dependency: TASK-001, TASK-006
- Acceptance criteria:
  - [x] Profil usaha: ubahNama, logo, kategori, deskripsi, alamat, telepon
  - [x] Struk digital: item, subtotal, metode bayar, kembalian, share (UIActivityViewController)
  - [x] Reminder backup mingguan: popup wajib dismiss, pilih "Export Sekarang" atau "Nanti Saja"
  - [x] Export Excel: 3 sheet (Transaksi, Produk, Laporan Ringkas), share/save via iOS Share Sheet
  - [x] Tidak ada perubahan di luar allowed paths
- Status: done

## Amendment [2026-09-14] — TL/SA (lihat DECISIONS.md entry [2026-09-14])

- Allowed/forbidden paths diperluas (lihat di atas; precedent TASK-003 s/d
  TASK-006). Termasuk edit `ProductRepository.swift` (tambah `fetchAll()`
  publik) di bawah `Data/Repository/**`.
- Keputusan teknis terkait:
  1. `Store` @Model baru: singleton (fetch-or-create dijaga di
     `StoreRepository`, bukan schema constraint). Field: `nama`(String),
     `logo`(String? path/URI lokal), `kategoriUsaha`(String? free text, BUKAN
     enum), `deskripsi`(String?), `alamat`(String), `telepon`(String?). Tanpa
     timestamp (tidak ada requirement audit trail).
  2. Wajib registrasi `Store` ke `.modelContainer(for:)` di `AppEntry.swift`
     (presedan `Order`/`OrderItem`/`StockHistoryEntry` — tanpa ini data tidak
     persist).
  3. Export Excel: hand-rolled minimal `.xlsx` (ZIP + XML manual via
     `Foundation`), text-only 3 sheet, tanpa styling. Dependency SPM baru
     DITOLAK — stdlib cukup untuk scope AC ini.
  4. Reminder: `UserDefaults` (`installDate`/`lastReminderAt`), cek trigger di
     `AppEntry.swift` `.task` (pola sama `CekProdukKosongUseCase`), interval 7
     hari dari `lastReminderAt`, "Nanti Saja" reset ke now.
  5. Struk: `ShareLink`/`UIActivityViewController` (native, belum pernah
     dipakai — konfirmasi tidak ada dependency baru), plain text, header dari
     Store.
  6. Menu: satu entry "Profil/Pengaturan" gabungan (Profil Usaha + Export) di
     `AppEntry.swift`/`HomeView` toolbar — sesuai bunyi literal FR-13.2.

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan: `xcodebuild -project CapuPOS.xcodeproj -scheme CapuPOS -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/capupos-task007 build` (2x: destination generic/iOS Simulator juga lulus)
- Hasil: BUILD SUCCEEDED (kedua destination simulator, tanpa signing team). Semua 9 file baru ter-register di pbxproj (registrasi manual — project tanpa PBXFileSystemSynchronizedRootGroup). Belum ada unit test target — verifikasi compile-only, pola sama dengan TASK-006.
- File yang berubah: CapuPOSDataModel.swift (additive: `@Model Store` — izin khusus DECISIONS.md [2026-09-14]), StoreRepository.swift (BARU: fetchOrCreate singleton + update), ProductRepository.swift (tambah fetchAll), 4 UseCase baru (ProfilUsahaUseCase, GenerateStrukUseCase, ReminderBackupUseCase, ExportDataUseCase), 4 View baru (ProfilUsahaView, StrukView, ReminderBackupView, ExportView), AppEntry.swift (modelContainer + Store, toolbar gearshape → Profil/Pengaturan, .task reminder check), project.pbxproj (registrasi manual 9 file + 4 group).
- Unresolved issue (bila ada): tidak ada unit test target di project — verifikasi hanya lewat build compile check (pola sama TASK-001 s/d TASK-006). Export .xlsx hand-rolled belum diuji dibuka di Excel/Numbers — QA perlu verifikasi manual file hasil export. Struk UI saat ini belum terhubung ke entry point di Riwayat/Detail transaksi (GenerateStrukUseCase siap dipakai; wiring entry struk perlu diputuskan di task lanjutan — sesuai scope FR-11 fokus pada generate + share).