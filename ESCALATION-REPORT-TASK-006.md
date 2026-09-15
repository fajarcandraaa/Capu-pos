# ESCALATION REPORT — TASK-006 (Pembayaran, Riwayat, Laporan)

- Tanggal: 2026-09-13
- Role: android-developer (dalam mode analisis pre-implementation)
- Repo: mobile-android (apps/capupos-android)
- Task contract: `tasks/task-mobile-android/ready/TASK-006-Pembayaran-Riwayat-Laporan.md`
- Jenis eskalasi: **scope / allowed_paths insufficient** (teknis & arsitektur data)
- Tujuan eskalasi: PM (scope amendment) + TL/SA (teknis & model decision)

---

## Ringkasan Eksekutif

TASK-006 tidak dapat diimplementasikan sepenuhnya dengan hanya menggunakan `allowed_paths` yang tertera di kontrak task. Fitur **Pembayaran (BayarTransaksiUseCase)**, **Riwayat + Filter (kategori/tanggal/metode bayar)**, dan **Laporan (overview + grafik tren + histori perubahan stok)** memerlukan method baru di domain repository dan DAO yang berada **di luar allowed_paths**.

Pola eskalasi identik dengan konflik sebelumnya:
- TASK-003 (Feb 2026): DECISIONS.md [2026-09-01]
- TASK-004 (Aug 2026): DECISIONS.md [2026-09-08]
- TASK-005 (Sep 2026): CONFLICT-REPORT-TASK-005.md + DECISIONS.md [2026-09-11]

---

## Status Existing Database & API

### Sudah Ada (Tidak Perlu Diubah)

**Entities:**
- `data/entities/OrderEntity.kt` v3 — kolom: `status` (string), `statusPo` (string nullable), `metodeBayar` (string nullable), `subtotal`, `nominalDiterima`, `kembalian`, `catatan`, `tanggal`, `isHidden`, `isDeleted`, `deletedAt`, `createdAt`, `updatedAt`.
- `data/entities/OrderDetailEntity.kt` v3 — kolom: `orderId`, `productId` (nullable), `quantity`, `price`, `deskripsi` (nullable, ditambah di TASK-005).
- `data/entities/ProductEntity.kt` v3 — kolom: `kategoriId`, `lacakStok`, `jumlahStok`, `stokMinimal`, plus audit fields.
- `data/entities/CategoryEntity.kt` v3 — kolom: `id`, `nama`, `urutan`.

**DAO (methods existing):**
- `OrderDao.getBelumBayar()` → List order status `belum_bayar` + not deleted/hidden.
- `OrderDao.getById(orderId)` → single order fetch.
- `OrderDao.updatePayment(orderId, status, metode, nominal, kembalian, updatedAt)` → update payment detail (sudah ada via @Query).
- `OrderDao.softDelete(orderId, deletedAt)` → soft delete (lunas status).
- `OrderDao.hardDelete(orderId)` → hard delete (belum bayar status).
- `OrderDetailDao.getByOrder(orderId)` → list detail per order.
- `ProductDao.getActiveProducts()` → list active products.
- `CategoryDao.getAll()` → list categories.
- `OrderDao.getAllOrders()` → List all orders (not deleted).

**Repository Interface:**
```kotlin
interface OrderRepository {
    suspend fun getBelumBayar(): List<Order>        // existing
    suspend fun getOrderById(orderId: String): Order?  // existing
    suspend fun saveOrder(order: Order): String      // existing
    suspend fun updateStatus(orderId: String, status: String, statusPo: String?)  // existing
}
```

Tidak punya: `updatePayment`, `softDelete`, `hardDelete`, `getAllOrders`, `getByFilter`.

**AppDatabase.kt:**
- Version 3 (TASK-005 baseline).
- Entities: ProductEntity, CategoryEntity, OrderEntity, OrderDetailEntity.
- DAOs: productDao, categoryDao, orderDao, orderDetailDao.
- Migrations: MIGRATION_1_2, MIGRATION_2_3.

---

## Acceptance Criteria per Feature vs. Required API

### 1. Pembayaran Tunai (BayarTransaksiUseCase)

**AC:** Input nominal manual/suggestion, kembalian auto.

**Diperlukan (tidak ada saat ini):**
- `OrderRepository.updatePayment(orderId, metodeBayar, nominalDiterima, kembalian, status)` → call `OrderDao.updatePayment()`.
- UseCase: `BayarTransaksiUseCase` (file baru).
  - Input: `orderId`, `metodeBayar`, `nominalDiterima`.
  - Logic: hitung `kembalian = nominalDiterima - order.subtotal`.
  - Panggil repository.
  - Output: Result<Unit> (sukses/error).

**File yang harus dibuat/diedit:**
- `domain/usecase/BayarTransaksiUseCase.kt` ✓ (allowed)
- `domain/repository/OrderRepository.kt` ✗ (NOT in allowed_paths; needs edit to add method signature)
- `data/repository/OrderRepositoryImpl.kt` ✗ (NOT in allowed_paths; needs edit to add implementation)

---

### 2. Pembayaran Non-Tunai (Manual Record)

**AC:** Pilih metode, dicatat manual.

**Diperlukan:**
- Same as #1 — use `BayarTransaksiUseCase`.

---

### 3. Hapus Transaksi (HapusTransaksiUseCase)

**AC:**
- Soft delete (lunas): mark `isDeleted=1`, set `deletedAt=now`.
- Hard delete (belum bayar): permanent delete.

**Diperlukan:**
- `OrderRepository.softDelete(orderId)` → call `OrderDao.softDelete()`.
- `OrderRepository.hardDelete(orderId)` → call `OrderDao.hardDelete()`.
- UseCase: `HapusTransaksiUseCase` (file baru).
  - Input: `orderId`.
  - Logic: check order status → if `lunas`, softDelete; if `belum_bayar`, hardDelete.
  - Output: Result<Unit>.

**File yang harus dibuat/diedit:**
- `domain/usecase/HapusTransaksiUseCase.kt` ✓ (allowed)
- `domain/repository/OrderRepository.kt` ✗ (NOT in allowed_paths)
- `data/repository/OrderRepositoryImpl.kt` ✗ (NOT in allowed_paths)

---

### 4. Riwayat + Filter (Kategori / Tanggal / Metode Bayar)

**AC:** List belum bayar & riwayat (lunas) dengan filter.

**Diperlukan:**
- `OrderRepository.getAllOrders(filters?: FilterRiwayat)` → call `OrderDao.getAllOrders()` + return as `List<Order>`.
- FilterRiwayat domain model (baru): `kategoriId`, `tanggalAwal`, `tanggalAkhir`, `metodeBayar` (nullable — filter ke subtotal > 0).
- ViewModel logic: group result by tanggal, filter by kategoriId (melalui OrderDetail→Product→kategoriId).
- Adapter/UI: display grouped list.

**Gap dalam DB:**
- `OrderDao.getAllOrders()` ada, tapi tidak punya overload dengan filter — DAO masih di luar allowed_paths.
- Histori produk yang dipakai dalam order hilang jika produk dihapus (ProductEntity.isDeleted tidak ter-track di OrderDetail).
- Stok history: **TIDAK ADA TABLE** `stok_histori` atau sejenisnya. Produk hanya punya `ProductEntity.jumlahStok` + `lacakStok` (boolean).

**File yang harus dibuat/diedit:**
- `presentation/riwayat/RiwayatActivity.kt` (baru) ✓ (allowed)
- `presentation/riwayat/RiwayatViewModel.kt` (baru) ✓ (allowed)
- `presentation/riwayat/RiwayatAdapter.kt` (baru) ✓ (allowed)
- `domain/model/FilterRiwayat.kt` (baru) ✗ (NOT in allowed_paths — domain/model bukan allowed)
- `domain/repository/OrderRepository.kt` ✗ (need new method)
- `data/repository/OrderRepositoryImpl.kt` ✗ (need new implementation)
- `data/dao/OrderDao.kt` ✗ (might need new @Query method for efficient filtering)
- `res/layout/activity_riwayat.xml` (baru) — unclear if res/** in allowed_paths

---

### 5. Laporan Overview + Grafik Tren

**AC:** Laporan overview card + grafik tren.

**Diperlukan:**
- `OrderRepository.getLaporanAggregat(tanggalAwal, tanggalAkhir): LaporanOverview`.
  - Aggregate queries: total penjualan, jumlah transaksi, metode bayar terpopuler, trend per hari.
- Domain model `LaporanOverview` (baru): fields untuk card display + chart data.
- UseCase: `GenerateLaporanUseCase` (file baru).
  - Input: date range.
  - Output: Result<LaporanOverview>.
- ViewModel + UI: display card, render chart (MPAndroidChart atau sejenisnya).

**File yang harus dibuat/diedit:**
- `domain/usecase/GenerateLaporanUseCase.kt` ✓ (allowed, explicitly named)
- `domain/model/LaporanOverview.kt` (baru) ✗ (NOT in allowed_paths)
- `presentation/laporan/LaporanActivity.kt` (baru) ✓ (allowed)
- `presentation/laporan/LaporanViewModel.kt` (baru) ✓ (allowed)
- `domain/repository/OrderRepository.kt` ✗ (need new method)
- `data/repository/OrderRepositoryImpl.kt` ✗ (need new implementation)
- `data/dao/OrderDao.kt` ✗ (might need aggregate @Query)
- `res/layout/activity_laporan.xml`, charts, etc. — unclear if allowed

---

### 6. Laporan Kelola Stok: Histori Perubahan Stok

**AC:** Histori perubahan stok.

**Diperlukan:**
- New entity `StockHistoryEntity` (baru): `id`, `productId`, `jumlahSebelum`, `jumlahSesudah`, `perubahan`, `alasan`, `timestamp`.
- New DAO `StockHistoryDao` (baru): insert, query by productId + date range.
- Database migration v3→v4 (atau jika belum direncanakan v3 untuk TASK-005, mungkin langsung v4).
- AppDatabase update: add entity, DAO, migration.
- UseCase logic: fetch stock history, possibly aggregate by product.
- ViewModel + UI: display table or list.

**File yang harus dibuat/diedit:**
- `data/entities/StockHistoryEntity.kt` (baru) ✗ (forbidden — data/entities/**)
- `data/dao/StockHistoryDao.kt` (baru) ✗ (NOT in allowed_paths)
- `data/AppDatabase.kt` ✗ (NOT in allowed_paths; need to add entity + dao + migration)
- `data/MigrationV3ToV4.kt` (baru) ✗ (NOT in allowed_paths)
- `presentation/laporan/LaporanStokHistoriActivity.kt` (baru) ✓ (allowed)
- `presentation/laporan/LaporanStokHistoriViewModel.kt` (baru) ✓ (allowed)
- etc.

---

## Allowed Paths di Kontrak vs. Kebutuhan Teknis

| Kategori | Path | Status | Problem |
|----------|------|--------|---------|
| **Allowed** | `presentation/pembayaran/**` | ✓ | — |
| **Allowed** | `presentation/riwayat/**` | ✓ | — |
| **Allowed** | `presentation/laporan/**` | ✓ | — |
| **Allowed** | `domain/usecase/BayarTransaksiUseCase.kt` | ✓ | — |
| **Allowed** | `domain/usecase/HapusTransaksiUseCase.kt` | ✓ | — |
| **Allowed** | `domain/usecase/GenerateLaporanUseCase.kt` | ✓ | — |
| **REQUIRED** | `domain/model/**` | ✗ NOT listed | Need `Order`, `FilterRiwayat`, `LaporanOverview` (already have Order from TASK-005, but NOT at domain/model) |
| **REQUIRED** | `domain/repository/OrderRepository.kt` (edit) | ✗ NOT listed | Add method signatures: `updatePayment`, `softDelete`, `hardDelete`, `getAllOrders`, `getLaporanAggregat` |
| **REQUIRED** | `data/repository/OrderRepositoryImpl.kt` (edit) | ✗ NOT listed | Implement above methods |
| **REQUIRED** | `data/entities/StockHistoryEntity.kt` (new) | ✗ FORBIDDEN | Forbidden: `data/entities/**` — BLOCKER |
| **REQUIRED** | `data/dao/StockHistoryDao.kt` (new) | ✗ NOT listed | Not in allowed_paths |
| **REQUIRED** | `data/dao/OrderDao.kt` (possibly edit) | ✗ NOT listed | Might need new @Query for filtering |
| **REQUIRED** | `data/AppDatabase.kt` (edit) | ✗ NOT listed | Add new entity, dao, migration |
| **REQUIRED** | `data/MigrationV3ToV4.kt` (new) | ✗ NOT listed | New migration for stock history table |
| **Forbidden** | `data/entities/**` | ✗ | Explicitly forbidden — but StockHistoryEntity needs to go there |

---

## Temuan Kritis

### 1. Allowed Paths Missing Domain Layer

`domain/model/**` dan `domain/repository/**` **tidak tercantum** di allowed_paths, padahal:
- UseCase `BayarTransaksiUseCase`, `HapusTransaksiUseCase`, `GenerateLaporanUseCase` akan inject repository (pola existing TASK-005).
- Repository interface perlu method baru untuk payment, delete, filtering, reporting.
- Domain models (`Order`, `FilterRiwayat`, `LaporanOverview`) perlu dibuat atau extend.

**Consequence:** Usecase tidak bisa dikerjakan tanpa me-edit file di luar allowed_paths.

---

### 2. Stock History: Entity Forbidden

Kontrak melarang: `data/entities/**`
Kebutuhan: `StockHistoryEntity` (new entity untuk histori stok).

**Consequence:** Laporan stok histori **tidak bisa diimplementasikan sesuai AC** (AC: "Histori perubahan stok").

**Options:**
- A. Amend forbidden paths: hapus `data/entities/**` dari forbidden, izinkan entity baru.
- B. Scope down: abaikan "histori perubahan stok", laporkan sebagai TODO/unresolved.
- C. Alternatif design: simpan histori di file/cache lokal (tidak recommended untuk data transaksi).

---

### 3. Repository Interface Under-Exposed

`OrderRepository` interface saat ini hanya punya 4 method:
- `getBelumBayar()`
- `getOrderById()`
- `saveOrder()`
- `updateStatus()`

**Missing untuk TASK-006:**
- `updatePayment(orderId, metodeBayar, nominalDiterima, kembalian, status)` → untuk pembayaran.
- `softDelete(orderId)` → untuk hapus lunas.
- `hardDelete(orderId)` → untuk hapus belum bayar.
- `getAllOrders()` → untuk riwayat list.
- `getLaporanAggregat(tanggalAwal, tanggalAkhir)` → untuk laporan.

**DAO sudah punya method** (`updatePayment`, `softDelete`, `hardDelete`, `getAllOrders`), tapi tidak exposed via repository interface.

---

### 4. Filter Riwayat Kompleks

**AC: Filter kategori/tanggal/metode bayar**

Untuk filter kategori, diperlukan:
- Join Order → OrderDetail → Product → Category.

Ini bisa dikerjakan di:
- **Option A (DAO level):** Tambah @Query complex SQL di OrderDao.
- **Option B (ViewModel level):** Fetch getAllOrders, filter in-memory per category (via OrderDetail→Product relationship).

**TASK-005 tidak termasuk relasi di repository** (Order belum di-hydrate dengan full Product data per detail). Jadi filtering by category harus dikerjakan di VM atau extend repository.

---

### 5. Database Version Conflict

TASK-005 membawa DB version 2→3 (`MigrationV2ToV3.kt` + `data/entities/OrderDetailEntity.kt` + `deskripsi` field).

TASK-006 perlu version 3→4 (`StockHistoryEntity` + migration).

**Jika allowed_paths tidak include data/entities/StockHistoryEntity**, maka v3→v4 tidak bisa berjalan, dan laporan stok histori jadi **NOT IMPLEMENTABLE**.

---

## Rekomendasi Eskalasi

### Untuk PM (Scope Amendment)

Amend `allowed_paths` TASK-006 agar sejajar dengan presedent [2026-09-08] TASK-004 dan [2026-09-11] TASK-005 + temuan baru untuk stok histori:

**Tambahkan ke allowed_paths:**
1. `domain/model/**` (Order, FilterRiwayat, LaporanOverview, StockChange mungkin dibutuhkan)
2. `domain/repository/OrderRepository.kt` (edit interface)
3. `data/repository/OrderRepositoryImpl.kt` (edit implementation)
4. `data/entities/StockHistoryEntity.kt` (NEW; butuh amend forbidden juga)
5. `data/dao/OrderDao.kt` (possibly; untuk efficient filtering @Query, tapi bisa juga di-skip jika filtering di ViewModel)
6. `data/dao/StockHistoryDao.kt` (NEW)
7. `data/AppDatabase.kt` (edit; add entity + dao + migration v3→v4)
8. `data/MigrationV3ToV4.kt` (NEW)
9. `AndroidManifest.xml` (edit; register pembayaran/riwayat/laporan activities)
10. `presentation/HomeActivity.kt` (edit; navigation entry point)
11. `res/layout/**` + `res/values/**` (edit/new; layout & label untuk 3 activity baru)

**Amend forbidden_paths:**
- Hapus atau ubah `data/entities/**` → `data/entities/{only non-StockHistory files}` (read-only).

Atau lebih sederhana: ubah forbidden jadi `data/entities/PaymentEntity.kt, CustomerEntity.kt, EmployeeEntity.kt, StoreEntity.kt` (eksplisit file yang read-only, bukan wildcard `**`).

---

### Untuk TL/SA (Teknis & Model Decision)

**1. Setujui amendemen allowed_paths** di atas (presedent: TASK-003, TASK-004, TASK-005 semua diamend dengan pola sama).

**2. Tentukan desain StockHistoryEntity:**
   - Simple: `id, productId, quantityBefore, quantityAfter, reason, timestamp`.
   - Track source (order delete? manual adjustment?).
   - Retention policy: simpan selamanya atau archive lama?

**3. Tentukan FilterRiwayat design:**
   - Apakah kategorisasi auto via Product.kategoriId saat fetch, atau user input kategoriId di UI?
   - Date range: open-ended atau bulan tertentu (performa query)?
   - Metode bayar: filter ke row dengan `metodeBayar IS NOT NULL` dan `status = 'lunas'`?

**4. Tentukan LaporanOverview scope:**
   - Cards: total penjualan, jumlah transaksi, metode terpopuler, rata-rata per transaksi?
   - Chart: tren penjualan per hari, per kategori, per metode bayar?
   - Time range: hari ini, minggu ini, bulan ini, custom?

**5. Presisi acceptance criteria:**
   - Laporan stok histori: scope apa exactly? (ledger semua produk, atau per-produk saja?)
   - "Grafik tren" — type chart apa? (line, bar, pie?)
   - Hard delete vs soft delete — apakah user bisa *lihat* transaksi soft-deleted di riwayat? (lakukan soft-delete dari riwayat activity saja?)

---

## Analisis Kecepatan Implementasi

### Skenario A: Approved Amendment (Rekomendasi)

Waktu: ~3-4 hari (anggap android-developer berpengalaman).
- Domain model + repository: 4 jam.
- 3 usecase + repository impl: 4 jam.
- 3 activity + adapter + VM + filtering logic: 8 jam.
- Laporan overview + chart: 8 jam.
- Stok history entity + dao + migration + laporan stok activity: 8 jam.
- Testing + fix: 4 jam.

**Total: ~2-3 hari kerja penuh.**

---

### Skenario B: Tidak Diamend (Tidak Direkomendasikan)

Android-developer harus:
1. Bikin usecase hanya dengan repository method existing (4) → tidak bisa implement pembayaran, hapus, filter, laporan.
2. Tulis stubs/TODO di presentasi → acceptance criteria jadi NOT MET.
3. Report unresolved issue ke QA → task FAIL review.

**Consequence:** TASK-006 diklasifikasi INCOMPLETE, bukan DONE. Perlu reopen + rework di sprint berikutnya.

---

## Status & Rekomendasi Eskalasi

**Apa yang sudah done (analisis):**
- ✓ Baca kontrak + codebase.
- ✓ Identifikasi gap.
- ✓ Dokumentasi temuan.

**Apa yang blocked (pending eskalasi):**
- ⏳ PM amend allowed_paths + forbidden_paths.
- ⏳ TL/SA setujui amendemen + tentukan desain StockHistoryEntity + FilterRiwayat + LaporanOverview.

**Rekomendasi:**
- **Eskalasi ke: PM + TL/SA** sesuai dokumen ini.
- **Timeline: Next 24 jam** — perlu keputusan sebelum android-developer dimulai coding.
- **Presedent untuk persetujuan cepat:** TASK-003 & TASK-004 & TASK-005 semua sudah diamend dengan pola serupa; tidak ada preseden penolakan.

---

## Lampiran: Mapping Acceptance Criteria vs. Required API

| AC # | Acceptance Criterion | Usecase | Diperlukan dari Repository | Status |
|------|----------------------|---------|---------------------------|--------|
| 1 | Pembayaran tunai: input nominal manual/suggestion, kembalian auto | BayarTransaksiUseCase | `updatePayment()` | ⏳ Need repo method |
| 2 | Pembayaran non-tunai: pilih metode, dicatat manual | BayarTransaksiUseCase | `updatePayment()` | ⏳ Need repo method |
| 3 | Data tambahan opsional dapat ditambahkan | Implicit di BayarTransaksiUseCase (order.catatan) | None (sudah ada) | ✓ Ready |
| 4 | List belum bayar & riwayat dengan filter (kategori/tanggal/metode bayar) | VM filtering logic | `getAllOrders()` + joined data | ⏳ Need repo method |
| 5 | Hapus transaksi: soft delete (lunas), hard delete (belum bayar) | HapusTransaksiUseCase | `softDelete()`, `hardDelete()` | ⏳ Need repo methods |
| 6 | Laporan overview card + grafik tren | GenerateLaporanUseCase + VM + UI | `getLaporanAggregat()` | ⏳ Need repo method |
| 7 | Laporan kelola stok: histori perubahan stok | Laporan stok activity | `getStockHistory()` + StockHistoryEntity | ⏳ Need entity + dao + repo method |

---

## Catatan Akhir

Dokumen ini adalah hasil analisis pre-implementation. Tidak ada kode yang dimodifikasi. Semua temuan didasarkan pada:
- Read codebase existing (OrderEntity, OrderDao, OrderRepository, AppDatabase v3 dari TASK-005).
- Acceptance criteria TASK-006.
- Presedent amendemen TASK-003, TASK-004, TASK-005 (lihat DECISIONS.md).
- Rule CLAUDE.md section "Rule Precedence" → eskalasi untuk konflik scope/allowed_paths.

---

**Disusun oleh:** Android Developer Agent (analisis pre-dispatch)
**Destinasi:** PM (scope) + TL/SA (teknis)
**Status:** Awaiting decision
**Next action:** Terapkan amendemen atau keputusan alternatif → ubah TASK-006 status → lanjut ke execution.
