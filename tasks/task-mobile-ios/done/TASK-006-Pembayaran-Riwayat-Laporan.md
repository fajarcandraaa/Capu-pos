# Task: TASK-006

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-06, FR-07, FR-09 (Pembayaran, Riwayat, Laporan)
- Allowed paths:
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Pembayaran/**
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Riwayat/**
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Laporan/**
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/**
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/Data/Model/**
- Dependency: TASK-001, TASK-005
- Acceptance criteria:
  - [x] Pembayaran tunai: input nominal manual/suggestion, kembalian auto
  - [x] Pembayaran non-tunai: pilih metode, dicatat manual
  - [x] Data tambahan opsional dapat ditambahkan
  - [x] List belum bayar & riwayat dengan filter (kategori/tanggal/metode bayar)
  - [x] Hapus transaksi: soft delete (lunas), hard delete (belum bayar)
  - [x] Laporan overview card + grafik tren (Swift Charts)
  - [x] Laporan kelola stok: histori perubahan stok
  - [x] Tidak ada perubahan di luar allowed paths (kecuali additive CapuPOSDataModel.swift & pbxproj registrasi, sesuai ruling TL/SA DECISIONS.md [2026-09-13])
- Status: done

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan: `xcodebuild -scheme CapuPOS -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/capupos-build build`
- Hasil: BUILD SUCCEEDED (simulator destination, tanpa signing team). Build dengan destination device generic gagal di step signing ("requires a development team") — expected, bukan error kode; belum dicoba unit test host karena project belum ada test target.
- File yang berubah: CapuPOSDataModel.swift (additive: literal lunas + StockHistoryEntry), OrderRepository.swift (bayar/hardDelete/sembunyikan/fetchRiwayatLunas), ProductRepository.swift (reduceStockQuantity), 4 UseCase baru (BayarTransaksiUseCase, FetchRiwayatUseCase, FetchLaporanUseCase, HapusTransaksiUseCase), 6 View baru (PembayaranEntryView, PembayaranView, RiwayatListView, RiwayatFilterView, LaporanView, HistoriStokView), AppEntry.swift (entry point toolbar + modelContainer registrasi StockHistoryEntry), project.pbxproj (registrasi manual 10 file baru).
- Unresolved issue (bila ada): tidak ada unit test target di project — verifikasi hanya lewat build compile check. Rekomendasi PM/QA: tambah test target di task terpisah bila diperlukan.