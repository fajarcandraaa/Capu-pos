# Rencana Eksekusi TASK-006 Android
## Pembayaran, Riwayat, Laporan

**Task ID:** TASK-006  
**Platform:** Android (apps/capupos-android)  
**Status:** Draft → Ready (after PM amend contract)  
**Tanggal:** 2026-09-13  
**Baseline:** TASK-005 (OrderEntity v3, OrderDao, OrderDetailEntity v3 + deskripsi field)  
**Keputusan:** DECISIONS.md [2026-09-13] — Amend allowed_paths + forbidden_paths

---

## Ringkasan Fitur (AC)

1. **Pembayaran tunai** — input nominal manual/suggestion, kembalian auto.
2. **Pembayaran non-tunai** — pilih metode, dicatat manual.
3. **Data tambahan opsional** — catatan per order.
4. **Riwayat + filter** — kategori/tanggal/metode bayar.
5. **Hapus transaksi** — soft delete (lunas), hard delete (belum bayar).
6. **Laporan overview** — card + grafik tren.
7. **Laporan stok** — histori perubahan stok.

---

## Tahapan Eksekusi

Dibagi 4 fase serial (dependen layer ke layer):

### **FASE 1: Data Layer (Entity/DAO/Migration/Repository)**

Membuat/amend database schema + repo interface + impl.

#### **1.1 StockHistoryEntity (baru)**

**File:** `data/entities/StockHistoryEntity.kt`  
**Size:** ~30 LoC  
**Dependencies:** None (pure entity)  
**Checklist:**
- [ ] Define entity: `id (PK), productId, quantityBefore, quantityAfter, reason (e.g., "order_<orderId>"), timestamp`
- [ ] Annotasi @Entity(tableName = "stock_history")
- [ ] Field `reason` String nullable (format: "order_<orderId>" untuk order, manual adjustment di luar scope TASK-006)

**Note:** Kontrak hanya butuh order-triggered reduction; manual stock adjustment (TASK-004) di luar scope.

---

#### **1.2 StockHistoryDao (baru)**

**File:** `data/dao/StockHistoryDao.kt`  
**Size:** ~40 LoC  
**Dependencies:** StockHistoryEntity  
**Checklist:**
- [ ] @Dao interface
- [ ] `insert(StockHistoryEntity): Unit` (@Insert)
- [ ] `getByProductIdAndDateRange(productId, tanggalAwal, tanggalAkhir): List<StockHistoryEntity>` (@Query)
- [ ] `getAll(): List<StockHistoryEntity>` (for laporan overview)

---

#### **1.3 MigrationV3ToV4.kt (baru)**

**File:** `data/MigrationV3ToV4.kt`  
**Size:** ~25 LoC  
**Dependencies:** None  
**Checklist:**
- [ ] Extend Migration(3, 4)
- [ ] CREATE TABLE stock_history — kolom camelCase match entity (id, productId, quantityBefore, quantityAfter, reason, timestamp)
- [ ] No @ColumnInfo annotations (DECISIONS.md rule)

**SQL pattern (dari MigrationV2ToV3):**
```sql
CREATE TABLE stock_history (
  id TEXT PRIMARY KEY NOT NULL,
  productId TEXT NOT NULL,
  quantityBefore INTEGER NOT NULL,
  quantityAfter INTEGER NOT NULL,
  reason TEXT,
  timestamp INTEGER NOT NULL
)
```

---

#### **1.4 AppDatabase.kt (edit)**

**File:** `data/AppDatabase.kt`  
**Changes:**
- [ ] Bump version: 3 → 4
- [ ] Add entity: `StockHistoryEntity::class` to @Database(entities = [...])
- [ ] Add dao provider: `abstract fun stockHistoryDao(): StockHistoryDao`
- [ ] Daftarkan migration: `AppDatabase.MIGRATION_3_4 = MigrationV3ToV4()` (static)
- [ ] `.addMigrations(AppDatabase.MIGRATION_1_2, AppDatabase.MIGRATION_2_3, AppDatabase.MIGRATION_3_4)` di DatabaseModule

**Size:** ~5 line changes

---

#### **1.5 DatabaseModule.kt (edit)**

**File:** `data/di/DatabaseModule.kt`  
**Changes:**
- [ ] Add provider: `provideStockHistoryDao(database: AppDatabase): StockHistoryDao` (@Provides, @Singleton)
- [ ] Add migration v3→v4 ke Room builder (`.addMigrations(AppDatabase.MIGRATION_3_4)`)

**Size:** ~10 line additions

---

#### **1.6 OrderRepository Interface (edit)**

**File:** `domain/repository/OrderRepository.kt`  
**Size:** ~30 LoC (current interface 4 methods + 5 new = 9 methods)  
**Dependencies:** Order domain model (TASK-005)  
**Checklist:**
- [ ] Add method: `updatePayment(orderId, metodeBayar, nominalDiterima, kembalian, status): Unit`
  - Signature: `suspend fun updatePayment(orderId: String, metodeBayar: String, nominalDiterima: Double, kembalian: Double): Result<Unit>`
- [ ] Add method: `softDelete(orderId): Result<Unit>` (lunas → isDeleted=1)
- [ ] Add method: `hardDelete(orderId): Result<Unit>` (belum_bayar → permanent delete)
- [ ] Add method: `getAllOrders(): List<Order>` (for riwayat list)
- [ ] Add method: `getLaporanAggregat(tanggalAwal, tanggalAkhir): LaporanOverview` (for laporan)

**Note:** LaporanOverview model definition di FASE 2.

---

#### **1.7 OrderRepositoryImpl (edit)**

**File:** `data/repository/OrderRepositoryImpl.kt`  
**Size:** ~120 LoC (4 existing methods + 5 new implementations)  
**Dependencies:** OrderDao, OrderDetailDao, StockHistoryDao (new), Order model, OrderEntity, OrderDetailEntity, StockHistoryEntity  
**Checklist:**
- [ ] Inject StockHistoryDao ke constructor
- [ ] Implement `updatePayment()`:
  ```kotlin
  // 1. Call orderDao.updatePayment(orderId, status, metode, nominal, kembalian, now)
  // 2. Fetch order detail items dari orderDetailDao
  // 3. For each detail: catat stock reduction ke stockHistoryDao
  //    - reason = "order_$orderId"
  //    - quantityBefore = current Product.jumlahStok (fetch via productDao)
  //    - quantityAfter = quantityBefore - detail.quantity
  //    - timestamp = now
  // 4. Update Product.jumlahStok di productDao (decrement)
  // 5. Return Result.success() atau Result.failure(e)
  ```
- [ ] Implement `softDelete()`: call `orderDao.softDelete(orderId, System.currentTimeMillis())`
- [ ] Implement `hardDelete()`: call `orderDao.hardDelete(orderId)`
- [ ] Implement `getAllOrders()`: call `orderDao.getAllOrders()`, map to domain Order list (toDomain mapping existing)
- [ ] Implement `getLaporanAggregat()`:
  ```kotlin
  // 1. Fetch getAllOrders()
  // 2. Filter by date range (tanggalAwal..tanggalAkhir) + status = "lunas" (paid)
  // 3. Aggregate: total penjualan (sum subtotal), count transaksi, metodeBayar terpopuler (mode), tren per hari
  // 4. Return LaporanOverview object
  ```

**Dependency catatan:** ProductDao perlu diinjeksi untuk fetch stok sebelum update (untuk histori). Check existing OrderRepositoryImpl — sudah punya ProductDao? Jika tidak, tambah.

---

### **FASE 2: Domain Layer (Models + UseCase)**

Domain models untuk presentation layer + usecase orchestration.

#### **2.1 Order Domain Model (already TASK-005, verify)**

**File:** `domain/model/Order.kt`  
**Status:** Sudah ada dari TASK-005  
**Checklist:**
- [ ] Verify fields: id, status (now "belum_bayar" or "lunas"), statusPo, metodeBayar, subtotal, nominalDiterima, kembalian, catatan, tanggal, items (List<OrderItem>)
- [ ] TASK-006 tidak perlu perubahan — Model sudah cukup.

---

#### **2.2 FilterRiwayat (baru)**

**File:** `domain/model/FilterRiwayat.kt`  
**Size:** ~20 LoC  
**Dependencies:** None  
**Checklist:**
- [ ] Data class: `kategoriId: String?, tanggalAwal: Long?, tanggalAkhir: Long?, metodeBayar: String?`
- [ ] Semua field nullable (optional filter)

---

#### **2.3 LaporanOverview (baru)**

**File:** `domain/model/LaporanOverview.kt`  
**Size:** ~25 LoC  
**Dependencies:** None  
**Checklist:**
- [ ] Data class fields:
  ```kotlin
  - periodAwal: Long
  - periodAkhir: Long
  - totalPenjualan: Double
  - jumlahTransaksi: Int
  - metodeBayarTerpopuler: String? (nullable)
  - trendPerHari: List<DailyTrend> // data class dengan date + amount
  ```

---

#### **2.4 BayarTransaksiUseCase (baru)**

**File:** `domain/usecase/BayarTransaksiUseCase.kt`  
**Size:** ~50 LoC  
**Dependencies:** OrderRepository  
**Checklist:**
- [ ] Constructor: `OrderRepository`
- [ ] Method: `suspend fun execute(orderId: String, metodeBayar: String, nominalDiterima: Double): Result<Unit>`
- [ ] Logic:
  ```kotlin
  // 1. Fetch order via repository
  // 2. Validate: nominalDiterima >= subtotal (pembayaran cukup)
  // 3. Hitung kembalian = nominalDiterima - subtotal
  // 4. Call repository.updatePayment() — status jadi "lunas", catat metodeBayar, nominalDiterima, kembalian
  // 5. Return Result.success() atau Result.failure(e)
  ```
- [ ] Error handling: nominalDiterima < subtotal → Result.failure(exception)

---

#### **2.5 HapusTransaksiUseCase (baru)**

**File:** `domain/usecase/HapusTransaksiUseCase.kt`  
**Size:** ~45 LoC  
**Dependencies:** OrderRepository  
**Checklist:**
- [ ] Constructor: `OrderRepository`
- [ ] Method: `suspend fun execute(orderId: String): Result<Unit>`
- [ ] Logic:
  ```kotlin
  // 1. Fetch order via repository
  // 2. If status == "lunas": call repository.softDelete(orderId)
  // 3. If status == "belum_bayar": call repository.hardDelete(orderId)
  // 4. Return Result.success() atau Result.failure(e)
  ```

---

#### **2.6 GenerateLaporanUseCase (baru)**

**File:** `domain/usecase/GenerateLaporanUseCase.kt`  
**Size:** ~60 LoC  
**Dependencies:** OrderRepository, ProductRepository, CategoryRepository  
**Checklist:**
- [ ] Constructor: inject above repositories
- [ ] Method: `suspend fun execute(tanggalAwal: Long, tanggalAkhir: Long): Result<LaporanOverview>`
- [ ] Logic:
  ```kotlin
  // 1. Fetch repository.getLaporanAggregat(tanggalAwal, tanggalAkhir) — sudah aggregate, tinggal wrap
  // 2. Return Result.success(laporan)
  // 3. Error handling: Result.failure(e)
  ```

**Note:** Agregasi (sum, mode, tren per hari) sudah terjadi di repository.getLaporanAggregat(), usecase hanya orchestrate.

---

### **FASE 3: Presentation Layer (Activity/ViewModel/Adapter)**

UI layers untuk tiga fitur: Pembayaran, Riwayat, Laporan.

#### **3.1 PembayaranActivity (baru)**

**File:** `presentation/pembayaran/PembayaranActivity.kt`  
**Size:** ~150 LoC  
**Dependencies:** PembayaranViewModel, ActivityPembayaranBinding  
**Checklist:**
- [ ] @AndroidEntryPoint (Hilt)
- [ ] Receive `orderId` via Intent extra
- [ ] Fetch order detail (nama produk, subtotal) via ViewModel
- [ ] UI elements:
  - Order summary card (subtotal, tanggal)
  - Metode bayar spinner/radio (Tunai, Transfer, Kartu Kredit, E-wallet, dst — TBD scope)
  - Input field: "Nominal diterima" (EditText, numeric keyboard)
  - Display kembalian auto-calculated
  - Button "Bayar" (call ViewModel)
  - Progress bar + Toast untuk success/error
- [ ] Layout: `res/layout/activity_pembayaran.xml`

---

#### **3.2 PembayaranViewModel (baru)**

**File:** `presentation/pembayaran/PembayaranViewModel.kt`  
**Size:** ~100 LoC  
**Dependencies:** BayarTransaksiUseCase, OrderRepository  
**Checklist:**
- [ ] @HiltViewModel
- [ ] Inject: BayarTransaksiUseCase, OrderRepository
- [ ] UiState data class:
  ```kotlin
  data class PembayaranUiState(
    val orderId: String? = null,
    val orderSummary: Order? = null,
    val metodeBayar: String = "tunai",
    val nominalDiterima: Double = 0.0,
    val kembalian: Double = 0.0,
    val loading: Boolean = false,
    val successMessage: String? = null,
    val error: String? = null
  )
  ```
- [ ] StateFlow `uiState` + MutableStateFlow `_uiState`
- [ ] Method: `loadOrder(orderId: String)` — fetch via repository
- [ ] Method: `onNominalChanged(nominal: Double)` — update state, auto-calc kembalian
- [ ] Method: `onMetodeBayarChanged(metode: String)` — update state
- [ ] Method: `bayarOrder()` — call BayarTransaksiUseCase
- [ ] Error: validate nominalDiterima >= subtotal

---

#### **3.3 RiwayatActivity (baru)**

**File:** `presentation/riwayat/RiwayatActivity.kt`  
**Size:** ~180 LoC  
**Dependencies:** RiwayatViewModel, ActivityRiwayatBinding, RiwayatAdapter  
**Checklist:**
- [ ] @AndroidEntryPoint
- [ ] UI elements:
  - Filter bar: kategori dropdown, date range picker (awal/akhir), metode bayar checkbox/radio
  - Button "Terapkan filter"
  - RecyclerView untuk list transaksi (grouped by tanggal)
  - Empty state
  - Progress bar
- [ ] Adapter: RiwayatAdapter (group by tanggal + list transaksi per grup)
- [ ] Observe ViewModel uiState → update adapter
- [ ] Long-click order → show dialog hapus? (confirm soft/hard delete based on status)
- [ ] Layout: `res/layout/activity_riwayat.xml`, layout item group header, layout item order

---

#### **3.4 RiwayatViewModel (baru)**

**File:** `presentation/riwayat/RiwayatViewModel.kt`  
**Size:** ~150 LoC  
**Dependencies:** OrderRepository, ProductRepository, CategoryRepository, HapusTransaksiUseCase  
**Checklist:**
- [ ] @HiltViewModel
- [ ] UiState:
  ```kotlin
  data class RiwayatUiState(
    val groups: List<RiwayatGroup> = emptyList(), // grouped by tanggal
    val loading: Boolean = true,
    val filterKategoriId: String? = null,
    val filterTanggalAwal: Long? = null,
    val filterTanggalAkhir: Long? = null,
    val filterMetodeBayar: String? = null,
    val successMessage: String? = null,
    val error: String? = null
  )
  
  data class RiwayatGroup(
    val tanggal: String,
    val orders: List<Order>
  )
  ```
- [ ] Method: `loadRiwayat()` — fetch getAllOrders, filter in-memory, group by tanggal
- [ ] Method: `applyFilter(kategoriId, tanggalAwal, tanggalAkhir, metodeBayar)` — update state, re-filter
- [ ] Method: `hapusTransaksi(orderId)` — call HapusTransaksiUseCase, reload
- [ ] Filter logic (in-memory):
  ```kotlin
  // 1. Filter by tanggal: order.tanggal in [tanggalAwal, tanggalAkhir]
  // 2. Filter by metodeBayar: order.metodeBayar == filterMetodeBayar (atau null = semua)
  // 3. Filter by kategoriId: join Order → OrderDetail → Product → kategoriId
  //    (Fetch products sekalian untuk dapat kategoriId)
  // 4. Group result by tanggal (format: "dd MMMM yyyy")
  // 5. Sort descending by tanggal
  ```

---

#### **3.5 RiwayatAdapter (baru)**

**File:** `presentation/riwayat/RiwayatAdapter.kt`  
**Size:** ~120 LoC  
**Dependencies:** RiwayatViewModel, RiwayatGroup  
**Checklist:**
- [ ] RecyclerView.Adapter<RecyclerView.ViewHolder>
- [ ] Two view types:
  - TYPE_HEADER: tanggal group header
  - TYPE_ORDER: individual order row
- [ ] ViewHolder classes:
  - HeaderViewHolder: display tanggal
  - OrderViewHolder: display order (nomor, status, subtotal, metode bayar)
    - Long-click listener (callback ke Activity untuk hapus)
    - Show status dengan warna (belum_bayar = yellow, lunas = green)
- [ ] Method: `updateData(groups: List<RiwayatGroup>)` — flatten + update dataset

---

#### **3.6 LaporanActivity (baru)**

**File:** `presentation/laporan/LaporanActivity.kt`  
**Size:** ~180 LoC  
**Dependencies:** LaporanViewModel, ActivityLaporanBinding  
**Checklist:**
- [ ] @AndroidEntryPoint
- [ ] UI elements:
  - Date range picker (awal/akhir bulan)
  - Button "Lihat Laporan"
  - Overview cards:
    - Total Penjualan (format Rp)
    - Jumlah Transaksi
    - Metode Bayar Terpopuler
  - Chart area (untuk tren per hari) — render via ViewModel data
  - Tab/Spinner untuk switch: Laporan Overview ↔ Laporan Stok
  - Progress bar + error toast
- [ ] Layout: `res/layout/activity_laporan.xml`, card layout untuk overview

**Chart library:** Check build.gradle — MPAndroidChart? Jika ada, gunakan. Jika tidak, custom Canvas atau simple bar chart dengan View.

---

#### **3.7 LaporanViewModel (baru)**

**File:** `presentation/laporan/LaporanViewModel.kt`  
**Size:** ~120 LoC  
**Dependencies:** GenerateLaporanUseCase, LaporanStokUseCase (baru atau via repository)  
**Checklist:**
- [ ] @HiltViewModel
- [ ] UiState:
  ```kotlin
  data class LaporanUiState(
    val overview: LaporanOverview? = null,
    val loading: Boolean = false,
    val successMessage: String? = null,
    val error: String? = null
  )
  ```
- [ ] Method: `generateLaporan(tanggalAwal, tanggalAkhir)` — call GenerateLaporanUseCase
- [ ] Method: `generateLaporanStok(tanggalAwal, tanggalAkhir)` — fetch stok history, aggregate

**Note:** Laporan stok (histori perubahan stok) — DAO query `getByProductIdAndDateRange()` atau aggregate di repository. Simple: fetch all stok history in date range, display table.

---

#### **3.8 LaporanStokActivity (baru, atau fragment dalam LaporanActivity)**

**File:** `presentation/laporan/LaporanStokActivity.kt` (or fragment)  
**Size:** ~120 LoC  
**Dependencies:** LaporanStokViewModel, ActivityLaporanStokBinding  
**Checklist:**
- [ ] List view atau table: product → stok history entries (tanggal, sebelum, sesudah, reason)
- [ ] Filter: product dropdown, date range
- [ ] UI: RecyclerView with stok history items

**Design note:** Bisa juga implement sebagai tab di LaporanActivity (ViewPager + Fragment) atau separate activity. Keputusan: separate activity simpler, fokus di laporan overview dulu.

---

#### **3.9 HomeActivity (edit)**

**File:** `presentation/HomeActivity.kt`  
**Changes:**
- [ ] Tab "Langsung" sudah ada dan membuka TransaksiActivity ✓ (no change needed for pembayaran entry)
- [ ] Tambah button/menu item: "Riwayat" → start RiwayatActivity
- [ ] Tambah button/menu item: "Laporan" → start LaporanActivity
- [ ] Navigation: HomeActivity → (Transaksi Activity) → [Pembayaran Activity belum entry disini, akan dari BelumBayarActivity]
- [ ] Or: add tab ketiga "Kelola" dengan submenu Riwayat/Laporan/Stok

**Size:** ~15 line additions (buttons + intent)

---

### **FASE 4: DI/Manifest/Resources**

Dependency injection, activity registration, string resources.

#### **4.1 RepositoryModule.kt (verify/no change)**

**File:** `data/di/RepositoryModule.kt`  
**Status:** OrderRepository binding sudah ada (TASK-005)  
**Checklist:**
- [ ] Verify: `bindOrderRepository(orderRepositoryImpl: OrderRepositoryImpl): OrderRepository` exists
- [ ] No change needed (OrderRepositoryImpl edit di Fase 1 tidak perlu modul change)

---

#### **4.2 AndroidManifest.xml (edit)**

**File:** `app/src/main/AndroidManifest.xml`  
**Changes:**
- [ ] Add activity: `PembayaranActivity` (android:exported="false")
- [ ] Add activity: `RiwayatActivity` (android:exported="false")
- [ ] Add activity: `LaporanActivity` (android:exported="false")
- [ ] Add activity: `LaporanStokActivity` (android:exported="false") — jika separate activity

**Size:** ~12 lines

---

#### **4.3 strings.xml (edit)**

**File:** `app/src/main/res/values/strings.xml`  
**Additions:**
- [ ] `app_name` — verify existing (jangan ubah)
- [ ] `pembayaran_title` = "Pembayaran"
- [ ] `riwayat_title` = "Riwayat Transaksi"
- [ ] `laporan_title` = "Laporan"
- [ ] `laporan_stok_title` = "Histori Stok"
- [ ] `metode_bayar_label` = "Metode Pembayaran"
- [ ] `nominal_diterima_label` = "Nominal Diterima"
- [ ] `kembalian_label` = "Kembalian"
- [ ] `filter_kategori` = "Kategori"
- [ ] `filter_tanggal` = "Tanggal"
- [ ] `filter_metode` = "Metode Bayar"
- [ ] `total_penjualan` = "Total Penjualan"
- [ ] `jumlah_transaksi` = "Jumlah Transaksi"
- [ ] `metode_populer` = "Metode Terpopuler"
- [ ] `btn_bayar` = "Bayar"
- [ ] `btn_hapus` = "Hapus"
- [ ] `btn_filter` = "Terapkan Filter"
- [ ] `confirm_hapus_title` = "Hapus Transaksi?"
- [ ] `confirm_hapus_msg` = "Transaksi akan dihapus. Lanjutkan?"
- [ ] `btn_yes` = "Ya"
- [ ] `btn_no` = "Tidak"
- [ ] `error_nominal_kurang` = "Nominal kurang dari subtotal"
- [ ] `success_pembayaran` = "Pembayaran berhasil"
- [ ] `success_hapus` = "Transaksi terhapus"
- [ ] `loading` = "Memuat..."
- [ ] `empty_riwayat` = "Belum ada riwayat transaksi"

**Size:** ~30 lines

---

#### **4.4 res/layout/* (baru)**

**Files:**
- [ ] `activity_pembayaran.xml` (~80 lines)
  - CardView order summary
  - Spinner/RadioGroup metode bayar
  - EditText nominal diterima
  - TextView kembalian (display auto-calc)
  - Button bayar
- [ ] `activity_riwayat.xml` (~60 lines)
  - Filter bar (kategori, date range, metode)
  - Button terapkan filter
  - RecyclerView list
  - Empty state
- [ ] `item_riwayat_group_header.xml` (~20 lines)
  - TextView tanggal (larger, bold)
- [ ] `item_riwayat_order.xml` (~40 lines)
  - Order nomor/ID
  - Status badge (warna)
  - Subtotal
  - Metode bayar
  - Timestamp
  - Icon/button hapus (long-click)
- [ ] `activity_laporan.xml` (~80 lines)
  - Date range picker
  - Button generate
  - Overview cards (4 buah)
  - Chart area (placeholder atau integrated)
- [ ] `item_laporan_stok.xml` (~35 lines)
  - Product nama
  - Tanggal
  - Qty sebelum → sesudah
  - Reason

**Total layout size:** ~315 lines

---

#### **4.5 res/drawable/* (new, optional)**

May reuse existing — check if need badge/status color drawables:
- [ ] `bg_status_belum_bayar.xml` (yellow background) — reuse if exists
- [ ] `bg_status_lunas.xml` (green background) — reuse if exists

---

### **FASE 5: Testing & Verification**

Before final submit.

#### **5.1 Unit Test (optional per CLAUDE.md simplification)**

**Decision:** Minimal test untuk critical path (BayarTransaksiUseCase, HapusTransaksiUseCase).
- [ ] Test BayarTransaksiUseCase.execute() — input < subtotal → Result.failure
- [ ] Test BayarTransaksiUseCase.execute() — input >= subtotal → call repository
- [ ] Test HapusTransaksiUseCase.execute() — status "lunas" → softDelete
- [ ] Test HapusTransaksiUseCase.execute() — status "belum_bayar" → hardDelete

**File:** `app/src/test/java/com/mindtoscreen/cappupos/domain/usecase/`
- BayarTransaksiUseCaseTest.kt (~60 LoC)
- HapusTransaksiUseCaseTest.kt (~60 LoC)

---

#### **5.2 Build & Compile**

- [ ] `./gradlew build` — no error
- [ ] Check migration compile (AppDatabase bump version)
- [ ] Verify all activity declared di AndroidManifest

---

#### **5.3 Manual Test**

- [ ] Pembayaran:
  - [ ] Open Transaksi → Simpan Bill → status "belum_bayar"
  - [ ] BelumBayarActivity → tap order → open PembayaranActivity
  - [ ] Input nominal < subtotal → error toast
  - [ ] Input nominal >= subtotal → kembalian auto-calc
  - [ ] Pilih metode → Bayar → success toast, status jadi "lunas"
  - [ ] Verify di DB: order.status="lunas", order.metodeBayar, order.nominalDiterima, order.kembalian set
  - [ ] Verify stock_history table terisi (quantityBefore, quantityAfter, reason="order_<id>")

- [ ] Riwayat:
  - [ ] HomeActivity → Riwayat → list transaksi lunas grouped by tanggal
  - [ ] Filter by kategori → only orders with detail produk in kategori shown
  - [ ] Filter by date range → only in range
  - [ ] Filter by metode → only matching metodeBayar
  - [ ] Long-click order → hapus → soft/hard delete per status
  - [ ] Verify: soft-deleted tidak muncul di list (isDeleted=1, isHidden=1)

- [ ] Laporan:
  - [ ] HomeActivity → Laporan → input date range
  - [ ] Generate → overview cards show (total penjualan, count, metode terpopuler)
  - [ ] Chart rendered (trend per hari)
  - [ ] Tab Laporan Stok → show stock history items
  - [ ] Filter by product/date → verify accuracy

---

## Dependency Tree & Serial Order

```
FASE 1: Data Layer
├─ 1.1 StockHistoryEntity
├─ 1.2 StockHistoryDao (dep: 1.1)
├─ 1.3 MigrationV3ToV4
├─ 1.4 AppDatabase.kt (dep: 1.1, 1.2, 1.3)
├─ 1.5 DatabaseModule.kt (dep: 1.2, 1.3)
├─ 1.6 OrderRepository interface (dep: TASK-005 Order model)
└─ 1.7 OrderRepositoryImpl (dep: 1.2, 1.6, all DAO)

FASE 2: Domain Layer
├─ 2.1 Order model (TASK-005, verify)
├─ 2.2 FilterRiwayat
├─ 2.3 LaporanOverview
├─ 2.4 BayarTransaksiUseCase (dep: 1.6)
├─ 2.5 HapusTransaksiUseCase (dep: 1.6)
└─ 2.6 GenerateLaporanUseCase (dep: 1.6)

FASE 3: Presentation Layer
├─ 3.1 PembayaranActivity (dep: 3.2, 4.1 layout)
├─ 3.2 PembayaranViewModel (dep: 2.4)
├─ 3.3 RiwayatActivity (dep: 3.4, 3.5, 4.1 layout)
├─ 3.4 RiwayatViewModel (dep: 1.6, 2.5)
├─ 3.5 RiwayatAdapter (dep: 3.4)
├─ 3.6 LaporanActivity (dep: 3.7, 4.1 layout)
├─ 3.7 LaporanViewModel (dep: 2.6)
├─ 3.8 LaporanStokActivity (dep: 1.2)
└─ 3.9 HomeActivity edit (dep: none — just add intent)

FASE 4: DI/Manifest/Resources
├─ 4.1 RepositoryModule (verify)
├─ 4.2 AndroidManifest.xml
├─ 4.3 strings.xml
├─ 4.4 res/layout/* (dep: 3.1-3.8)
└─ 4.5 res/drawable/* (optional)

FASE 5: Testing
└─ 5.1 Unit test (dep: 2.4, 2.5)
```

**Serial execution order (minimum sequential):**
1. FASE 1 (data layer) — all 7 files (can parallelize 1.1-1.3 vs 1.6)
2. FASE 2 (domain models + usecase) — all 6 files (can parallelize 2.2-2.3 vs 2.4-2.6)
3. FASE 3 (presentation) — all 9 files (can parallelize by activity group)
4. FASE 4 (config) — all 5 files (can parallelize layout* with code)
5. FASE 5 (test) — last

**Estimated effort (total):**
- Data layer: 12 files, ~400 LoC → 4 hours
- Domain layer: 6 files, ~200 LoC → 3 hours
- Presentation: 9 files (5 activity+vm + 4 adapter/layout), ~800 LoC + 315 layout → 8 hours
- Config: 5 files, ~400 LoC + layouts → 2 hours
- Testing: 2 files, ~120 LoC → 1.5 hours
- Manual test: ~2 hours
- **Total: ~20.5 hours** (single developer) or ~10 hours (if parallelize phases 1-2)

---

## Key Decisions & Notes

### Chart Library
- **Decision:** Check build.gradle — no chart library added yet.
- **Action:** If MPAndroidChart already included, use it. Else, render tren per hari as simple bar chart via custom View/Canvas (DON'T add new dependency).
- **Fallback:** Simple table view instead of chart if time limited.

### Stock History Trigger
- **Decision:** Reduction only on payment (order status → "lunas"), not on manual stock adjust (TASK-004 scope).
- **Implementation:** In OrderRepositoryImpl.updatePayment(), after status update, iterate OrderDetails and decrement Product.jumlahStok, then insert StockHistoryEntry.
- **Note:** Manual stock adjustment from TASK-004 (AturStokActivity) does NOT trigger stock_history — explicit per DECISIONS.md [2026-09-13] poin 7.

### Filtering Strategy
- **Kategori filter:** Join in-memory (fetch Order → fetch OrderDetails → fetch Products → check kategoriId).
- **Date range:** Simple Long comparison (order.tanggal >= awal && order.tanggal <= akhir).
- **Metode bayar:** String match (order.metodeBayar == filter || filter == null).
- **No DAO change:** Non-complex, volume small (POS single outlet) → in-memory filter sufficient, avoid bloating DAO.

### Status Terminology
- **"Belum Bayar"** → status = "belum_bayar" (from TASK-004/005)
- **"Lunas"** → status = "lunas" (NEW in TASK-006, replaces paid/completed semantics)
- **Soft delete:** isDeleted = 1, deletedAt = now (status must be "lunas")
- **Hard delete:** permanent delete (status must be "belum_bayar")
- **UI display:** Soft-deleted orders hidden by default (filter WHERE isDeleted = 0 in repository getAllOrders)

### Migration Validation
- **Rule:** Kolom SQL camelCase match entity field names (DECISIONS.md [2026-09-08])
- **MigrationV3ToV4:** `stock_history` table — columns: id, productId, quantityBefore, quantityAfter, reason, timestamp (all camelCase, no @ColumnInfo)
- **Verify:** After migration, Room schema validation must pass (test with `testDatabaseMigration()` if test infrastructure exists)

---

## Checklist Before Starting Coding

- [ ] PM amend TASK-006 allowed_paths + forbidden_paths per DECISIONS.md [2026-09-13]
- [ ] Task status changed: draft → ready
- [ ] Base branch: main (latest from origin)
- [ ] Create branch: `feat/TASK-006-Pembayaran-Riwayat-Laporan-android`
- [ ] Verify build.gradle chart library availability (MPAndroidChart or fallback plan)
- [ ] Verify AppDatabase current version is 3 (from TASK-005)
- [ ] Verify OrderEntity.status field supports "lunas" string value (no enum restriction)

---

## Success Criteria (Acceptance Criteria Verification)

| AC # | Criterion | Implementation File(s) | Verified? |
|------|-----------|------------------------|-----------|
| 1 | Pembayaran tunai: input nominal, kembalian auto | PembayaranActivity, ViewModel, BayarTransaksiUseCase | — |
| 2 | Pembayaran non-tunai: metode pilihan, dicatat | PembayaranActivity (spinner metode), OrderEntity.metodeBayar | — |
| 3 | Data tambahan opsional | OrderEntity.catatan (existing), PembayaranActivity add catatan input | — |
| 4 | Riwayat + filter (kategori/tanggal/metode) | RiwayatActivity, ViewModel, FilterRiwayat model | — |
| 5 | Hapus transaksi: soft (lunas) / hard (belum_bayar) | HapusTransaksiUseCase, OrderRepository.softDelete/hardDelete | — |
| 6 | Laporan overview card + grafik tren | LaporanActivity, LaporanOverview, chart rendering | — |
| 7 | Laporan stok histori | LaporanStokActivity, StockHistoryEntity, StockHistoryDao | — |

---

## Risk & Mitigation

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Migration v3→v4 fail (schema mismatch) | HIGH | Verify kolom camelCase match entity, test locally before submit |
| Chart library missing | MEDIUM | Fallback: table view atau custom canvas bar chart (no new dep) |
| Stock reduction not triggered | MEDIUM | Write test untuk updatePayment → verify stock_history insert |
| Soft-deleted visible di riwayat | LOW | Add WHERE isDeleted = 0 di getAllOrders, test list display |
| Filter kategori N+1 query | LOW | fetch products once, cache dalam ViewModel, reuse untuk all filter |
| Date format inconsistency | LOW | Use SimpleDateFormat("dd MMMM yyyy", Locale("in", "ID")) everywhere |

---

## Next Steps (After Approval)

1. **PM:** Amend task contract TASK-006 file (allowed_paths + forbidden_paths).
2. **PM:** Move task status: draft → ready.
3. **Android Developer:** Start FASE 1 after branch created.
4. **Testing:** QA review after submit (AC verification, migration test, manual smoke test).

---

**Document version:** 1.0  
**Created:** 2026-09-13  
**Author:** Android Developer (pre-implementation planning)  
**Status:** Awaiting PM contract amendment approval
