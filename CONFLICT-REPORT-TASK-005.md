# CONFLICT REPORT — TASK-005 (Transaksi Open Bill / PO)

- Tanggal: 2026-09-11
- Role: android-engineer
- Repo: mobile-android (apps/capupos-android)
- Task contract: `tasks/task-mobile-android/ready/TASK-005-Transaksi-Open-Bill-PO.md`
- Jenis konflik: **scope / allowed_paths under-specified** (teknis pendukung)
- Eskalasi: PM (scope) + TL/SA (teknis)

## Ringkasan

TASK-005 tidak bisa diimplementasikan hanya dalam `allowed_paths` yang tertulis.
Fitur memerlukan pembuatan/penyuntingan file di luar whitelist. Pola identik dengan
konflik TASK-003 (`CONFLICT-REPORT-TASK-003.md`) dan amendemen TASK-004 yang sudah
dicatat di `DECISIONS.md` [2026-09-08].

## Allowed paths (tertulis di kontrak)

- `presentation/transaksi/**`
- `presentation/transaksimanual/**`
- `domain/usecase/SimpanTransaksiUseCase.kt, BayarTransaksiUseCase.kt, UbahStatusPOUseCase.kt`
- `data/dao/**`

Forbidden: `presentation/pembayaran/**`

## Yang sudah ada (tidak perlu disentuh)

- `data/entities/OrderEntity.kt` — status, statusPo, metodeBayar, subtotal, catatan,
  tanggal, isHidden/isDeleted. Cukup untuk PO + open bill.
- `data/entities/OrderDetailEntity.kt` — orderId, productId(nullable), quantity, price.
- `data/dao/OrderDao.kt` — getBelumBayar, insert, updatePayment, updateStatus, hide, soft/hardDelete.
- `data/dao/OrderDetailDao.kt` — getByOrder, insert, insertAll, deleteByOrder, getSubtotal.
- `data/AppDatabase.kt` v2 — orderDao + orderDetailDao sudah terdaftar.

## Gap: file wajib dibuat/diedit DI LUAR allowed_paths

| File | Alasan |
|------|--------|
| `domain/model/Order.kt` (baru) | Domain model transaksi, dibutuhkan usecase |
| `domain/model/OrderItem.kt` (baru) | Domain model baris transaksi |
| `domain/repository/OrderRepository.kt` (baru) | Interface, pola MVVM existing (usecase inject repository, bukan DAO) |
| `data/repository/OrderRepositoryImpl.kt` (baru) | Impl pemetaan entity↔domain |
| `data/di/RepositoryModule.kt` (edit) | Bind OrderRepository (Hilt) |
| `AndroidManifest.xml` (edit) | Register activity transaksi/transaksimanual |
| `presentation/HomeActivity.kt` (edit) | Entry point: tab "langsung" saat ini hanya ganti style, belum membuka alur transaksi |
| `res/layout/activity_home.xml` / `res/values/strings.xml` (mungkin edit) | Navigasi/label bila butuh tombol baru |
| `data/entities/OrderDetailEntity.kt` (mungkin edit) | Transaksi manual (nominal + deskripsi bebas) butuh field nama/deskripsi per baris; field ini tidak ada |

## Catatan teknis

1. `OrderDetailEntity` tidak punya kolom `nama`/`deskripsi`. Acceptance criterion
   "Transaksi manual (input nominal + deskripsi bebas)" tidak terwakili oleh schema.
   `OrderEntity.catatan` hanya satu per order, bukan per baris. Perlu keputusan: tambah
   field deskripsi di `order_details`, atau simpan manual sebagai satu baris dengan
   `productId = null` + `catatan` di order.
2. `OrderDao.getBelumBayar()` tidak mengelompokkan per tanggal — "List Belum Bayar per
   tanggal" bisa dikerjakan di layer ViewModel, tidak wajib ubah DAO.

## Rekomendasi

Amend `allowed_paths` TASK-005 agar sejajar keputusan DECISIONS.md [2026-09-08]
("model Order/OrderItem dibuat di TASK-005"), menambah:
- `domain/model/**`
- `domain/repository/**`
- `data/repository/**`
- `data/di/RepositoryModule.kt`
- `AndroidManifest.xml`
- `presentation/HomeActivity.kt`
- `res/layout/` + `res/values/` (bila dibutuhkan navigasi/label)
- `data/entities/**` (bila diputuskan menambah field deskripsi baris transaksi)

## Status

Menunggu keputusan PM/TL-SA. Belum ada perubahan kode.

---

## [PM Cross-check 2026-09-11] — Konsolidasi Temuan PM + Android + iOS

- Role: project-manager
- Verifikasi dilakukan terhadap kode aktual kedua platform (read-only).
- Kesimpulan: **TASK-005 Android & iOS belum siap dieksekusi** sampai TL/SA
  memutuskan amendemen di bawah. Laporan android-engineer di atas TERVERIFIKASI
  benar oleh PM.

### Hasil cross-check

1. **Overlap Android ~90%** — temuan PM identik dengan laporan android-engineer
   (entities/DI/repo/Manifest/HomeActivity/res). Satu tambahan penting yang
   PM verifikasi di kode: **tab "langsung" di `HomeActivity` memang belum
   membuka alur transaksi** (hanya ganti style tab) — butuh entry point baru.
2. **Temuan iOS (tidak ada di laporan android-engineer, scope mereka Android):**
   - `Sources/App/AppEntry.swift` TIDAK di allowed_paths, tapi wajib diedit:
     model Order baru harus didaftarkan ke `.modelContainer(for:)` agar
     SwiftData persist. **BLOCK.**
   - `Data/Models/CapuPOSDataModel.swift` memang belum punya model Order
     (terverifikasi) — catatan implementasi di task akurat.
3. **Schema gap terkonfirmasi:** `OrderDetailEntity` tidak punya kolom untuk
   "deskripsi bebas" transaksi manual. Keputusan sudah diambil (2026-09-11):
   **tambah kolom `deskripsi` nullable per item**, bukan digabung ke
   `catatan` level Order. Konsekuensi: migration DB v2→v3 +
   `data/MigrationV2ToV3.kt` (file baru).
4. **Paritas AC lemah:** AC Android tidak menyebut pengaturan kuantitas dan
   aturan FR-05.5 ("Dibatalkan" tidak dapat dipilih dari "Selesai") yang
   eksplisit di AC iOS. Perlu diselaraskan.

### Amendemen allowed_paths yang dimintakan ke TL/SA

**Android (gabungan temuan PM + android-engineer):**
- `domain/model/**` (file baru: `Order.kt`, `OrderItem.kt`)
- `domain/repository/**` (interface `OrderRepository`)
- `data/repository/**` (`OrderRepositoryImpl`)
- `data/di/RepositoryModule.kt` (bind OrderRepository; `DatabaseModule.kt`
  kemungkinan tidak perlu — DAO sudah terdaftar, tapi diizinkan bila perlu)
- `data/entities/OrderDetailEntity.kt` (kolom `deskripsi`)
- `data/MigrationV2ToV3.kt` (file baru) + `data/AppDatabase.kt`
  (bump version 3 + daftarkan migration)
- `AndroidManifest.xml` (register activity transaksi)
- `presentation/HomeActivity.kt` (entry point)
- `res/layout/**` + `res/values/**` (layout & label)

**iOS:**
- `Sources/App/AppEntry.swift` (registrasi model Order ke modelContainer)

### Usulan keputusan teknis untuk TL/SA

1. **Approve amendemen allowed_paths** di atas — precedent:
   DECISIONS.md [2026-09-08] "PM Review TASK-004" sudah mengamendemen
   allowed_paths dengan pola identik (domain/model+repository,
   data/repository, AppDatabase, HomeActivity, Manifest + res), dan
   DECISIONS.md [2026-09-08] juga sudah mencatat "model Order/OrderItem
   dibuat di TASK-005". Ini pola berulang, bukan keputusan baru.
2. **Literal status PO 5 tahap lintas platform** (field `statusPo`,
   null bila bukan PO): `menunggu_konfirmasi`, `diproses`, `siap`,
   `selesai`, `dibatalkan`. Diterapkan di kedua platform agar tidak
   divergensi.
3. **Rule migration wajib ditaati** di `MigrationV2ToV3.kt` (dari
   DECISIONS.md [2026-09-08] "TL/SA — Migration Schema Mismatch"):
   nama kolom SQL camelCase match PERSIS field Entity, TANPA `@ColumnInfo`.
4. **AC Android diselaraskan dengan iOS:** tambah "dengan pengaturan
   kuantitas" dan aturan FR-05.5.
5. **Non-issue dikonfirmasi:** grouping "List Belum Bayar per tanggal"
   cukup di layer ViewModel — tidak perlu ubah `OrderDao`.

### Status setelah cross-check

Menunggu keputusan TL/SA atas 5 poin usulan di atas. Tidak menugaskan
android-developer / ios-developer sampai PM mengamendemen kedua file
TASK-005 sesuai keputusan resmi TL/SA.

---

## [TL/SA Ruling 2026-09-11]

- Role: tech-lead-system-analyst
- Keputusan lengkap dicatat di `DECISIONS.md`
  `[2026-09-11] TL/SA — TASK-005 Transaksi/Open Bill/PO: Amend Kontrak
  Lintas Platform + Literal Status PO + Migration v3`.
- Ringkasan: **Semua 5 poin usulan PM DISETUJUI**, plus 1 temuan tambahan
  verifikasi kode: `data/di/DatabaseModule.kt` WAJIB masuk allowed_paths
  Android (bukan opsional seperti ditandai PM) — `RepositoryModule.kt`
  pakai pola `@Binds`, tapi `DatabaseModule.kt` belum punya
  `provideOrderDao`/`provideOrderDetailDao`; tanpa itu Hilt gagal resolve
  binding `OrderDao` saat `OrderRepositoryImpl` di-construct, build gagal.
- Literal status PO ditetapkan: `menunggu_konfirmasi`, `diproses`, `siap`,
  `selesai`, `dibatalkan` (field `statusPo`, snake_case konsisten dengan
  `status` existing).
- Rule migration [2026-09-08] (kolom SQL camelCase match Entity, tanpa
  `@ColumnInfo`) berlaku wajib di `MigrationV2ToV3.kt`.
- Status konflik: **SELESAI**. PM lanjut menerapkan amendemen ke kedua
  file kontrak TASK-005, ubah Status draft → ready, baru serahkan ke
  android-developer dan ios-developer.
