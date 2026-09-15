# Task: TASK-006

- Repo: mobile-android
- Role: android-engineer
- Base branch: main
- Requirement ref: FR-06 (Pembayaran), FR-07 (Riwayat), FR-09 (Laporan)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/pembayaran/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/riwayat/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/laporan/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/BayarTransaksiUseCase.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/HapusTransaksiUseCase.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/GenerateLaporanUseCase.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/model/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/repository/OrderRepository.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/repository/OrderRepositoryImpl.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/StockHistoryEntity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/dao/StockHistoryDao.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/dao/ProductDao.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/AppDatabase.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/MigrationV3ToV4.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/di/DatabaseModule.kt
  - apps/capupos-android/app/src/main/AndroidManifest.xml
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/HomeActivity.kt
  - apps/capupos-android/app/src/main/res/layout/**
  - apps/capupos-android/app/src/main/res/values/**
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/PaymentEntity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/CustomerEntity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/EmployeeEntity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/StoreEntity.kt
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
- Dependency: TASK-001, TASK-005
- Acceptance criteria:
  - [x] Pembayaran tunai: input nominal manual/suggestion, kembalian auto
  - [x] Pembayaran non-tunai: pilih metode, dicatat manual
  - [x] Data tambahan opsional dapat ditambahkan
  - [x] List belum bayar & riwayat dengan filter (kategori/tanggal/metode bayar)
  - [x] Hapus transaksi: soft delete (lunas), hard delete (belum bayar)
  - [x] Laporan overview card + grafik tren
  - [x] Laporan kelola stok: histori perubahan stok
  - [x] Tidak ada perubahan di luar allowed paths
- Status: done

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan: `./gradlew assembleDebug` (JAVA_HOME=JDK 17 homebrew; JBR Android Studio ber-version 25 tidak kompatibel kapt Kotlin 2.0.0)
- Hasil: BUILD SUCCESSFUL. Kompilasi penuh (kapt + Kotlin + resource link).
- File yang berubah:
  - Data: StockHistoryEntity.kt, StockHistoryDao.kt, MigrationV3ToV4.kt (DB v3→v4), ProductDao.kt (+updateStok), AppDatabase.kt, DatabaseModule.kt, OrderRepositoryImpl.kt (updatePayment transaksional + reduceStock + softDelete/hardDelete + getAllOrders + getLaporanAggregat + getStokHistori)
  - Domain: OrderRepository.kt (+5 method), FilterRiwayat.kt, LaporanOverview.kt, StokHistoriItem.kt, BayarTransaksiUseCase.kt, HapusTransaksiUseCase.kt, GenerateLaporanUseCase.kt
  - Presentation: pembayaran/ (Activity+VM+layout), riwayat/ (Activity+VM+Adapter+3 layout), laporan/ (LaporanActivity+VM, LaporanStokActivity+VM+Adapter, TrendChartView custom, 3 layout), HomeActivity.kt (menu: Kategori/Riwayat/Laporan), AndroidManifest.xml (+4 activity), strings.xml (+~55 string)
- Unresolved issue (bila ada): tidak ada. Catatan: getStokHistori ditaruh di OrderRepository (bukan ProductRepository) karena ProductRepository tidak ada di allowed_paths; LaporanStok feature ditaruh di package presentation/laporan (bukan laporanstok) dengan alasan sama. Tidak ada dependency baru (grafik = custom Canvas View).
- Merged ke `main` via PR #15 (https://github.com/fajarcandraaa/capupos-android/pull/15).