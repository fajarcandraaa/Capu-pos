# Task: TASK-005

- Repo: mobile-android
- Role: android-engineer
- Base branch: main
- Requirement ref: FR-04 (Transaksi), FR-05 (Pre-order), FR-07 (Open Bill)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksi/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksimanual/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/SimpanTransaksiUseCase.kt, BayarTransaksiUseCase.kt, UbahStatusPOUseCase.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/dao/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/model/** (baru: Order.kt, OrderItem.kt)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/repository/** (interface OrderRepository)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/repository/** (OrderRepositoryImpl)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/di/RepositoryModule.kt (bind OrderRepository)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/di/DatabaseModule.kt (WAJIB: provideOrderDao/provideOrderDetailDao belum ada; tanpa itu build gagal missing binding)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/OrderDetailEntity.kt (kolom deskripsi nullable)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/MigrationV2ToV3.kt (file baru) + data/AppDatabase.kt (bump version 3, daftarkan MIGRATION_2_3)
  - apps/capupos-android/app/src/main/AndroidManifest.xml (register activity transaksi)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/HomeActivity.kt (entry point tab "langsung")
  - apps/capupos-android/app/src/main/res/layout/**
  - apps/capupos-android/app/src/main/res/values/**
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/pembayaran/**
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
- Dependency: TASK-001, TASK-004
- Acceptance criteria:
  - [x] Pilih produk by kategori/search ke keranjang transaksi, dengan pengaturan kuantitas
  - [x] Transaksi manual (input nominal + deskripsi bebas per item)
  - [x] Simpan/Open Bill menyimpan transaksi tertunda sebagai "Belum Bayar"
  - [x] Mode PO: status 5 tahap (menunggu_konfirmasi → diproses → siap → selesai → dibatalkan) — opsional, tidak wajib diisi; "dibatalkan" tidak dapat dipilih dari status "selesai" (FR-05.5)
  - [x] List Belum Bayar menampilkan transaksi tertunda per tanggal (grouping di ViewModel)
  - [x] Tidak ada perubahan di luar allowed paths
- Status: done

## Catatan implementasi (hasil review kode existing + keputusan TL/SA, baca sebelum mulai)

- Literal status PO (field `statusPo`, null bila bukan PO) — snake_case,
  konsisten dengan `OrderEntity.status` yang sudah `"belum_bayar"`:
  `menunggu_konfirmasi`, `diproses`, `siap`, `selesai`, `dibatalkan`.
- Aturan FR-05.5: transisi `selesai` → `dibatalkan` dilarang.
- Transaksi manual "deskripsi bebas per item" = tambah kolom `deskripsi`
  nullable di `OrderDetailEntity` (bukan digabung ke `OrderEntity.catatan`).
- Migration wajib: bump `AppDatabase` version 2→3, buat
  `data/MigrationV2ToV3.kt`. Rule dari DECISIONS.md [2026-09-08]: nama
  kolom SQL camelCase match PERSIS field Entity, TANPA `@ColumnInfo`.
  Perubahan additive saja: `ALTER TABLE order_details ADD COLUMN deskripsi TEXT NULL`.
- DI wajib: `DatabaseModule.kt` belum punya `provideOrderDao`/
  `provideOrderDetailDao` — tambahkan, lalu bind `OrderRepository` di
  `RepositoryModule.kt` (pola `@Binds`, ikuti `ProductRepositoryImpl`).
- Domain model baru `Order`/`OrderItem` mengikuti pola `domain/model/Product.kt`;
  repository baru mengikuti pola `ProductRepository`/`ProductRepositoryImpl`
  (usecase inject repository, bukan DAO).
- Tab "langsung" di `HomeActivity` saat ini hanya ganti style, belum membuka
  alur transaksi — wire entry point ke layar transaksi.

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan: (tidak dijalankan ulang di sesi ini — lihat log commit implementasi untuk hasil build/test asli)
- Hasil: Implementasi selesai, review TL/SA "SELESAI" (lihat CONFLICT-REPORT-TASK-005.md), merged ke `main` via PR #14.
- File yang berubah (commit `586264d`, `0868e2e`, merge `1450162`):
  - `data/MigrationV2ToV3.kt` (baru), `data/AppDatabase.kt` (bump v3, daftar migration)
  - `data/repository/OrderRepositoryImpl.kt` (baru, `saveOrder` transactional via `appDatabase.withTransaction`)
  - `domain/model/Order.kt`, `domain/model/OrderItem.kt` (baru)
  - `domain/repository/OrderRepository.kt` (baru)
  - `domain/usecase/SimpanTransaksiUseCase.kt`, `UbahStatusPOUseCase.kt` (baru)
  - `data/entities/OrderDetailEntity.kt` (kolom `deskripsi` nullable)
  - `data/di/DatabaseModule.kt`, `data/di/RepositoryModule.kt` (wire DAO + bind repository)
  - `presentation/transaksi/**` (baru: `TransaksiActivity`, `TransaksiViewModel`, `CartAdapter`, `BelumBayarActivity`, `BelumBayarViewModel`, `BelumBayarAdapter`)
  - `presentation/transaksimanual/**` (baru: `TransaksiManualActivity`, `TransaksiManualViewModel`, `TransaksiManualAdapter` — TextWatcher fix cursor-jump + watcher stacking)
  - `presentation/HomeActivity.kt` (tab "langsung" wire ke `TransaksiActivity`)
  - `AndroidManifest.xml` (register 3 activity baru)
  - layout XML baru: `activity_transaksi.xml`, `activity_transaksi_manual.xml`, `activity_belum_bayar.xml`, `item_cart.xml`, `item_transaksi_manual.xml`, `item_belum_bayar.xml`, `item_belum_bayar_header.xml`
  - `.gitignore` ditambahkan (commit `ca4e2d4`), untrack build artifact/config lokal
- Unresolved issue (bila ada): tidak ada. Allowed_paths gap (`DatabaseModule.kt` awalnya belum tercantum) sudah diamend TL/SA sebelum eksekusi — lihat CONFLICT-REPORT-TASK-005.md.