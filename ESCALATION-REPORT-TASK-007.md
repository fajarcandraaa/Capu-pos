# ESCALATION REPORT — TASK-007 (Profil Usaha, Struk, Reminder, Export)

- Tanggal: 2026-09-14
- Role: android-developer (dalam mode analisis pre-implementation)
- Repo: mobile-android (apps/capupos-android)
- Task contract: `tasks/task-mobile-android/ready/TASK-007-Profil-StruK-Reminder-Export.md`
- Jenis eskalasi: **scope / allowed_paths insufficient** (teknis & arsitektur data)
- Tujuan eskalasi: PM (scope amendment) + TL/SA (teknis & model decision)

---

## Ringkasan Eksekutif

TASK-007 tidak dapat diimplementasikan sepenuhnya dengan hanya menggunakan `allowed_paths` yang tertera di kontrak task. Empat fitur utama:
- **Profil Usaha (UbahDataUsahaUseCase)** — ubah nama, logo, kategori, deskripsi, alamat, telepon → butuh extend StoreEntity fields + repository + persistence.
- **Struk Digital (GenerateStrukUseCase)** — render order menjadi struk, share via Intent → butuh read akses & layout.
- **Reminder Backup Mingguan** — cek timestamp backup, popup wajib dismiss → butuh preferences + activity + layout.
- **Export Excel (ExportDataUseCase)** — tulis 3 sheet Excel (Transaksi, Produk, Laporan Ringkas), share via Sharesheet → butuh DAO access + custom XLSX writer.

...semuanya **memerlukan akses ke file di luar allowed_paths**.

Pola eskalasi identik dengan precedent:
- TASK-003 (2026-09-01): DECISIONS.md
- TASK-004 (2026-09-08): DECISIONS.md
- TASK-005 (2026-09-11): CONFLICT-REPORT-TASK-005.md + DECISIONS.md
- TASK-006 (2026-09-13): ESCALATION-REPORT-TASK-006.md + DECISIONS.md

---

## Status Existing Database & API

### Sudah Ada (Tidak Perlu Diubah)

**StoreEntity:**
```kotlin
@Entity(tableName = "stores")
data class StoreEntity(
    @PrimaryKey val id: Long = 1,
    val name: String,
    val address: String
)
```
- Fields saat ini: `id`, `name`, `address` saja.
- **CRITICAL GAP:** StoreEntity tidak terdaftar di AppDatabase.kt (check: AppDatabase.kt @Database(entities=[...]) tidak include StoreEntity).
- StoreDao sudah ada: `getStore()`, `insert(StoreEntity)`.

**Order / OrderDetail / Product / Category:**
- Sudah ada via TASK-005, TASK-006.
- Untuk struk & export, read-only reuse (tidak perlu diedit).

**AppDatabase v4:**
- Entities: ProductEntity, CategoryEntity, OrderEntity, OrderDetailEntity, StockHistoryEntity (dari TASK-006).
- DAOs: productDao, categoryDao, orderDao, orderDetailDao, stockHistoryDao.
- **Missing:** `storeDao()` method meskipun StoreDao.kt ada.
- Version 4 (TASK-006 baseline).

---

## Acceptance Criteria per Feature vs. Required API

### 1. Profil Usaha: Ubah Data (UbahDataUsahaUseCase)

**AC:** Ubah nama, logo, kategori, deskripsi, alamat, telepon.

**Diperlukan (tidak ada saat ini):**

1. **Extend StoreEntity fields** (data/entities/StoreEntity.kt):
   ```kotlin
   data class StoreEntity(
       @PrimaryKey val id: Long = 1,
       val name: String,
       val logo: String? = null,           // URI/path, e.g., "file:///..."
       val kategori: String? = null,       // "warung", "restoran", etc.
       val deskripsi: String? = null,
       val alamat: String,
       val telepon: String? = null,
       val createdAt: Long = 0L,
       val updatedAt: Long = System.currentTimeMillis()
   )
   ```
   - File ini **tidak listed di allowed_paths TASK-007** (data/entities/** tidak ada).
   - File ini **tidak forbidden** di TASK-007 (forbidden hanya data/entity/**, bukan data/entities/).
   - Tapi tidak eksplisit allowed → ambiguous status.

2. **Add @Update method to StoreDao** (data/dao/StoreDao.kt):
   ```kotlin
   @Update
   suspend fun update(store: StoreEntity)
   ```
   - File ini juga **NOT in allowed_paths TASK-007**.

3. **Extend AppDatabase.kt**:
   - Register StoreEntity jika belum.
   - Register storeDao() jika belum.
   - Version bump? (saat ini v4; logo/kategori/deskripsi/telepon columns butuh migration v4→v5 jika existing installs).

4. **Domain layer:**
   - `domain/model/Store.kt` (NEW) — domain model untuk profil usaha.
   - `domain/repository/StoreRepository.kt` (NEW) — interface `getStore()`, `updateStore(store: Store)`.
   - `domain/usecase/UbahDataUsahaUseCase.kt` (allowed) — implementation.

5. **Data layer:**
   - `data/repository/StoreRepositoryImpl.kt` (NEW) — call dao.
   - **Register di data/di/RepositoryModule.kt** — inject StoreRepository.
   - **Register di data/di/DatabaseModule.kt** — provide storeDao.

6. **Presentation layer:**
   - `presentation/profilusaha/ProfilUsahaActivity.kt` (NEW, allowed).
   - `presentation/profilusaha/ProfilUsahaViewModel.kt` (NEW, allowed).
   - `res/layout/activity_profil_usaha.xml` (NEW, **NOT in allowed_paths**).
   - `res/values/strings.xml` (edit, **NOT in allowed_paths**).
   - Image picker library usage (built-in Intent.ACTION_PICK).

7. **AndroidManifest.xml:**
   - Register `ProfilUsahaActivity` (**NOT in allowed_paths**).

8. **HomeActivity.kt:**
   - Add menu entry → ProfilUsahaActivity (**NOT in allowed_paths**).

---

### 2. Struk Digital: Generate & Share (GenerateStrukUseCase)

**AC:** Item, subtotal, metode bayar, kembalian, share.

**Diperlukan:**

1. **Domain layer:**
   - `domain/usecase/GenerateStrukUseCase.kt` (allowed) — input Order, output formatted struk (string/HTML).
   - May reuse Order model (from domain/model, read-only).

2. **Presentation layer:**
   - `presentation/struk/StrukActivity.kt` (NEW, allowed).
   - `presentation/struk/StrukViewModel.kt` (NEW, allowed).
   - `res/layout/activity_struk.xml`, `res/layout/item_struk.xml` (**NOT in allowed_paths**).
   - `res/values/strings.xml` (edit, **NOT in allowed_paths**).

3. **AndroidManifest.xml:**
   - Register `StrukActivity` (**NOT in allowed_paths**).

4. **Share mechanism:**
   - `Intent.ACTION_SEND` (built-in Android, no dependency).
   - Send struk text + optional image (render via Canvas or screenshot WebView).

---

### 3. Reminder Backup Mingguan (CekReminderBackupUseCase)

**AC:** Popup wajib dismiss, pilih "Export Sekarang" atau "Nanti Saja".

**Diperlukan:**

1. **SharedPreferences key:**
   - `"last_backup_timestamp"` — track timestamp backup terakhir (set saat export selesai).
   - **No new entity/dao needed** — SharedPreferences cukup.

2. **Domain layer:**
   - `domain/usecase/CekReminderBackupUseCase.kt` (allowed) — check: `now - lastBackup > 7 days`?

3. **Presentation layer:**
   - `presentation/reminder/ReminderDialogFragment.kt` atau `ReminderActivity.kt` (NEW, allowed).
   - `res/layout/dialog_reminder_backup.xml` (**NOT in allowed_paths**).
   - `res/values/strings.xml` (edit, **NOT in allowed_paths**).

4. **Trigger:**
   - `HomeActivity.kt` onResume → call CekReminderBackupUseCase → show dialog if reminder due (**NOT in allowed_paths**).

---

### 4. Export Excel: 3 Sheets (ExportDataUseCase)

**AC:** 3 sheet (Transaksi, Produk, Laporan Ringkas), share/save via Android Sharesheet.

**Diperlukan:**

1. **Data fetching:**
   - `OrderRepository.getAllOrders()` — fetch semua orders (read-only, allowed via allowed_paths TASK-006/007 domain/repository; but TASK-007 doesn't explicitly allow it).
   - `ProductRepository.getProducts()` — fetch semua produk.
   - `OrderRepository.getLaporanAggregat(tanggalAwal, tanggalAkhir)` — fetch laporan summary.
   - Files: `data/repository/*.kt` — **NOT in TASK-007 allowed_paths** (allowed hanya presentation/export & domain/usecase files).

2. **XLSX writer (no new dependency):**
   - Custom `SimpleXlsxWriter` class (NEW, can go di presentation/export or utils):
     ```kotlin
     // Pseudo-code
     class SimpleXlsxWriter {
         fun writeXlsx(file: File, sheets: Map<String, List<List<String>>>)
         // Gunakan java.util.zip.ZipOutputStream
         // Tiap sheet = XML dengan hardcoded namespace, rows, cells
         // Zip semua XML + [Content_Types].xml + .rels files
     }
     ```
   - Library: `java.util.zip` (built-in, no new dependency).
   - Reference: OOXML spec minimal (xlsx = zip of XML files).

3. **Domain layer:**
   - `domain/usecase/ExportDataUseCase.kt` (allowed) — aggregate data, call custom writer, return File path.

4. **Presentation layer:**
   - `presentation/export/ExportActivity.kt` (NEW, allowed).
   - `presentation/export/ExportViewModel.kt` (NEW, allowed).
   - `res/layout/activity_export.xml` (**NOT in allowed_paths**).
   - `res/values/strings.xml` (edit, **NOT in allowed_paths**).

5. **Share mechanism:**
   - `Intent.ACTION_SEND` or `Intent.ACTION_SEND_MULTIPLE` (built-in).
   - FileProvider (built-in via androidx.core, for sharing file URIs safely).

6. **Storage:**
   - `getExternalFilesDir()` atau `getFilesDir()` (built-in Android, private app storage; no Runtime.WRITE_EXTERNAL_STORAGE needed untuk private storage).

---

## Allowed Paths di Kontrak vs. Kebutuhan Teknis

| Kategori | Path | Status | Problem |
|----------|------|--------|---------|
| **Allowed** | `presentation/profilusaha/**` | ✓ | — |
| **Allowed** | `presentation/struk/**` | ✓ | — |
| **Allowed** | `presentation/reminder/**` | ✓ | — |
| **Allowed** | `presentation/export/**` | ✓ | — |
| **Allowed** | `domain/usecase/UbahDataUsahaUseCase.kt` | ✓ | — |
| **Allowed** | `domain/usecase/GenerateStrukUseCase.kt` | ✓ | — |
| **Allowed** | `domain/usecase/CekReminderBackupUseCase.kt` | ✓ | — |
| **Allowed** | `domain/usecase/ExportDataUseCase.kt` | ✓ | — |
| **REQUIRED** | `domain/model/Store.kt` | ✗ NOT listed | Need Store domain model |
| **REQUIRED** | `domain/repository/StoreRepository.kt` | ✗ NOT listed | Need StoreRepository interface |
| **REQUIRED** | `data/repository/StoreRepositoryImpl.kt` | ✗ NOT listed | Need implementation |
| **REQUIRED** | `data/entities/StoreEntity.kt` (edit: extend fields) | ⚠ AMBIGUOUS | Not forbidden, but not explicitly allowed |
| **REQUIRED** | `data/dao/StoreDao.kt` (edit: add @Update) | ✗ NOT listed | Extend existing DAO |
| **REQUIRED** | `data/AppDatabase.kt` (edit: register StoreEntity + storeDao) | ✗ NOT listed | Critical: StoreEntity not registered currently |
| **REQUIRED** | `data/di/DatabaseModule.kt` (edit or create) | ✗ NOT listed | Provide storeDao to DI |
| **REQUIRED** | `data/di/RepositoryModule.kt` (edit: add StoreRepository binding) | ✗ NOT listed | Provide StoreRepository to DI |
| **REQUIRED** | `AndroidManifest.xml` (edit: register 4 activities) | ✗ NOT listed | Register ProfilUsahaActivity, StrukActivity, ReminderActivity, ExportActivity |
| **REQUIRED** | `presentation/HomeActivity.kt` (edit: add menu entries + reminder check) | ✗ NOT listed | Navigation entry point |
| **REQUIRED** | `res/layout/**` (new XML files for 4 activities + dialogs) | ✗ NOT listed | UI layouts |
| **REQUIRED** | `res/values/strings.xml` (edit: add string resources) | ✗ NOT listed | Labels, hints, messages |
| **CRITICAL GAP** | StoreEntity registration in AppDatabase | ✗ MISSING | Currently StoreEntity.kt exists but not in @Database(entities=[...]) |

---

## Temuan Kritis

### 1. Critical: StoreEntity Not Registered in AppDatabase

**Fakta:** 
- `StoreEntity.kt` exists (data/entities/StoreEntity.kt).
- `StoreDao.kt` exists (data/dao/StoreDao.kt).
- **AppDatabase.kt @Database(entities=[...]) TIDAK include StoreEntity.**
- **AppDatabase companion object TIDAK have abstract fun storeDao().**

**Consequence:** 
- Saat app run, Room tidak create `stores` table.
- `StoreDao.getStore()` akan crash saat runtime (table not found).
- **This is a pre-existing bug dari TASK-001 setup atau missing TASK-002 work.**

**Impact untuk TASK-007:**
- Profil usaha feature akan fail saat access StoreEntity.
- **MUST FIX** AppDatabase.kt + add migration (v4→v5 atau skip migration jika fresh DB).

---

### 2. Allowed Paths Missing Domain & Data Layers

Kontrak TASK-007 allowed_paths hanya specify presentation-layer + 4 usecase files. Tidak ada:
- `domain/model/**` (need Store)
- `domain/repository/**` (need StoreRepository)
- `data/repository/**` (need StoreRepositoryImpl)
- `data/di/**` (need DatabaseModule + RepositoryModule edit)
- `data/AppDatabase.kt` (CRITICAL for StoreEntity registration)

**Consequence:**
- Usecase tidak bisa inject dependency (StoreRepository, OrderRepository).
- No DI provider untuk repository.
- No database schema management.

---

### 3. Android Manifest & Resources Missing

Contract tidak allow:
- `AndroidManifest.xml` → tidak bisa register 4 activity baru → app won't launch them.
- `res/layout/**`, `res/values/**` → tidak bisa bikin UI → activity akan crash saat inflate layout.

**Consequence:** 
- Fitur tersedia (code exists) tapi tidak accessible dari UI (activity tidak registered).
- Strings/labels hardcoded atau missing.

---

### 4. HomeActivity Navigation Entry Missing

Contract tidak allow:
- `presentation/HomeActivity.kt` edit → tidak bisa add menu entry untuk Profil Usaha.
- No navigation wiring → user tidak bisa akses fitur baru.

**Consequence:**
- AC "user dapat ubah profil usaha" tidak terpenuhi — interface not available.

---

### 5. Database Schema Mismatch

**Current:** StoreEntity v1 (id, name, address).
**AC requirement:** Tambah logo, kategori, deskripsi, telepon.

**Migration path:**
- Option A: Fresh install → no migration needed (new schema langsung).
- Option B: Existing install → ALTER TABLE stores ADD COLUMN logo TEXT, ... (migration v4→v5).

**File needed:**
- `data/MigrationV4ToV5.kt` (NEW) — if migrations needed.
- **Depends on:** AppDatabase.kt edit (allowed_paths NOT).

---

### 6. Export Excel — No New Dependency (Design Decision)

**AC requires:** "Export Excel: 3 sheet".

**Challenge:** 
- Apache POI (standard Excel library) → new dependency → violates simplification principle "jangan tambah dependency tanpa alasan kuat".
- `build.gradle` edit (NOT in allowed_paths) needed untuk add POI.

**Solution proposed:** 
- Hand-rolled XLSX writer using `java.util.zip.ZipOutputStream` (built-in).
- XLSX adalah ZIP file berisi XML — bisa ditulis manually dengan:
  1. Create XML for each sheet (rows, cells, values).
  2. Create [Content_Types].xml, .rels files (OOXML spec minimal).
  3. Zip semua files → .xlsx output.
- **Precedent:** TASK-006 decision untuk chart — "gunakan library yang sudah ter-install, jangan tambah dependency baru tanpa alasan".

**Trade-off:**
- No formatting / styling (text only, cells unformatted).
- Works dengan Excel, Google Sheets, LibreOffice (basic .xlsx format).
- Code ~300-500 lines (manageable, no complex logic).

---

## Rekomendasi Eskalasi

### Untuk PM (Scope Amendment)

Amend `allowed_paths` TASK-007 agar sejajar dengan presedent TASK-004, TASK-005, TASK-006:

**Tambahkan ke allowed_paths:**
1. `domain/model/Store.kt` (NEW)
2. `domain/repository/StoreRepository.kt` (NEW)
3. `data/repository/StoreRepositoryImpl.kt` (NEW)
4. `data/entities/StoreEntity.kt` (edit; extend fields: logo, kategori, deskripsi, telepon)
5. `data/dao/StoreDao.kt` (edit; add @Update method)
6. `data/AppDatabase.kt` (edit; register StoreEntity + storeDao, version bump if needed)
7. `data/MigrationV4ToV5.kt` (NEW; if migrations needed)
8. `data/di/DatabaseModule.kt` (edit or create)
9. `data/di/RepositoryModule.kt` (edit; add StoreRepository binding)
10. `AndroidManifest.xml` (edit; register 4 activities)
11. `presentation/HomeActivity.kt` (edit; menu entries + reminder check onResume)
12. `res/layout/**` (new/edit; layouts untuk 4 activity + dialog)
13. `res/values/strings.xml` (edit; add string resources)

---

### Untuk TL/SA (Teknis & Model Decision)

**1. Fix pre-existing bug — StoreEntity registration in AppDatabase.**

AppDatabase.kt saat ini tidak register StoreEntity meskipun entity + DAO sudah ada. Pilihan:
- **Option A (Rekomendasi):** Include dalam TASK-007 — edit AppDatabase.kt, add StoreEntity to @Database, add storeDao() method, create migration v4→v5.
- **Option B:** Create hotfix task terpisah sebelum TASK-007 (tapi delay rilis feature).

---

**2. Approve Export Excel design — hand-rolled XLSX writer.**

Proposal: Gunakan `java.util.zip` (built-in) untuk generate minimal valid XLSX (3 sheets, text only). 
- Alignment dengan DECISIONS.md [2026-09-13] TASK-006 chart design: "pilih library yang sudah ter-install, jangan tambah dependency baru tanpa alasan".
- No new dependency.
- Scope: basic 3-sheet export (tanpa pivot, formatting, styling).
- Accept/Reject?

---

**3. Tentukan desain Store domain model:**
   - Fields: id, name, logo (URI string), kategori (enum atau string?), deskripsi, alamat, telepon, timestamps?
   - Logo storage: save URI ke DB saja, atau duplex ke file storage?
   - Validation: kategori dari fixed list atau free text?

---

**4. Tentukan reminder backup trigger & snooze logic:**
   - Cek setiap app start (onResume HomeActivity)?
   - Snooze duration (7 hari, atau user input)?
   - Storage: SharedPreferences atau preferences DataStore?

---

**5. Presisi acceptance criteria Struk Digital:**
   - Format struk: plain text, HTML, atau image (Canvas render)?
   - Share: text only, text + image, atau email attachment?
   - Apakah bisa print ke thermal printer, atau hanya digital share?

---

## Analisis Kecepatan Implementasi

### Skenario A: Approved Amendment (Rekomendasi)

Waktu: ~4-5 hari (android-developer berpengalaman).
- Domain model (Store) + repository interface: 2 jam.
- Data layer (extend StoreEntity, DAO, impl, DI): 4 jam.
- UbahDataUsahaUseCase + activity + ViewModel: 4 jam.
- GenerateStrukUseCase + activity: 3 jam.
- CekReminderBackupUseCase + dialog: 2 jam.
- ExportDataUseCase + custom XLSX writer: 6 jam (XLSX writer complex).
- UI layouts + strings + AndroidManifest + HomeActivity nav: 8 jam.
- Fix StoreEntity AppDatabase registration + migration: 2 jam.
- Testing + fix: 4 jam.

**Total: ~3-4 hari kerja penuh.**

---

### Skenario B: Tidak Diamend (Tidak Direkomendasikan)

Android-developer hanya bisa:
1. Implement 4 usecase + presentation/export/** etc → tapi tidak bisa wire data layer (no allowed_paths).
2. Tidak bisa register activity di manifest → app crash saat launch.
3. Tidak bisa create layouts → compile error atau hardcoded UI.
4. Report: AC NOT MET, task FAIL QA review.

**Consequence:** TASK-007 incomplete, perlu reopen + rework.

---

## Status & Rekomendasi Eskalasi

**Apa yang sudah done (analisis):**
- ✓ Baca kontrak + codebase.
- ✓ Identifikasi gap + bug pre-existing (StoreEntity not registered).
- ✓ Dokumentasi temuan.

**Apa yang blocked (pending eskalasi):**
- ⏳ PM amend allowed_paths (+12 file/path).
- ⏳ TL/SA fix StoreEntity registration bug + approve XLSX design + tentukan Store model + reminder logic.

**Rekomendasi:**
- **Eskalasi ke: PM + TL/SA** sesuai dokumen ini.
- **Timeline: Next 24 jam** — perlu keputusan sebelum android-developer mulai coding.
- **Presedent untuk persetujuan cepat:** TASK-003, TASK-004, TASK-005, TASK-006 semua sudah diamend dengan pola serupa; tidak ada preseden penolakan.
- **Urgency:** TASK-007 dependency chain — TASK-005 & TASK-006 sudah done, TASK-007 next di queue.

---

## Lampiran: Mapping Acceptance Criteria vs. Required API

| AC # | Acceptance Criterion | Fitur | Diperlukan dari | Status |
|------|----------------------|-------|-----------------|--------|
| 1 | Profil usaha: ubah nama, logo, kategori, deskripsi, alamat, telepon | UbahDataUsahaUseCase | Store model + StoreRepository + extend StoreEntity | ⏳ Need amendment |
| 2 | Struk digital: item, subtotal, metode bayar, kembalian, share | GenerateStrukUseCase | StrukActivity + layout + share intent | ⏳ Need layout + manifest |
| 3 | Reminder backup mingguan: popup wajib dismiss, "Export Sekarang"/"Nanti Saja" | CekReminderBackupUseCase | ReminderActivity/Dialog + SharedPreferences + HomeActivity nav | ⏳ Need layout + manifest + HomeActivity edit |
| 4 | Export Excel: 3 sheet (Transaksi, Produk, Laporan Ringkas), share via Sharesheet | ExportDataUseCase | Custom XLSX writer + OrderRepository access + ExportActivity | ⏳ Need XLSX design approval + layout + manifest |

---

## Catatan Akhir

Dokumen ini adalah hasil analisis pre-implementation. Tidak ada kode yang dimodifikasi. Semua temuan didasarkan pada:
- Read codebase existing (StoreEntity, StoreDao, AppDatabase v4 dari TASK-001/TASK-006).
- Acceptance criteria TASK-007.
- Presedent amendemen TASK-003, TASK-004, TASK-005, TASK-006 (lihat DECISIONS.md).
- Rule CLAUDE.md section "Rule Precedence" → eskalasi untuk konflik scope/allowed_paths.
- Pre-existing bug discovery (StoreEntity not registered in AppDatabase).

---

**Disusun oleh:** Android Developer Agent (analisis pre-dispatch)
**Destinasi:** PM (scope) + TL/SA (teknis)
**Status:** Awaiting decision
**Next action:** Terapkan amendemen atau keputusan alternatif → ubah TASK-007 status → lanjut ke execution.

---

## RESOLUSI TL/SA [2026-09-14]

Laporan ini sudah ditangani — lihat `DECISIONS.md` entry `[2026-09-14]` dan
amendemen di `tasks/task-mobile-android/ready/TASK-007-Profil-StruK-Reminder-Export.md`
(status: ready).

- Amend allowed_paths: **DISETEJUJUI** (daftar final ada di kontrak, sedikit
  lebih hemat dari usulan — tanpa `createdAt/updatedAt` di StoreEntity karena
  tidak ada requirement audit trail).
- **Koreksi temuan #1 (Critical Gap "StoreEntity not registered = pre-existing
  bug"):** tidak akurat. Laporan membaca campuran worktree lama di
  `.claude/worktrees/`. `AppDatabase.kt` main tree (version 4) memang belum
  pernah meregistrasi StoreEntity/storeDao() — bukan regresi TASK-001/002,
  karena belum ada task sebelumnya yang butuh Profil Usaha. Kesimpulan
  operasional sama (wajib register + migration v4→5), tapi kategorinya "kerja
  baru TASK-007", bukan "hotfix bug lama".
- XLSX hand-rolled: **DISETUJUI** (kedua platform, text-only, tanpa styling,
  tanpa dependency baru).
- Store model, reminder logic, struk format, entry point menu: keputusan final
  ada di DECISIONS.md [2026-09-14] poin 2-7.
