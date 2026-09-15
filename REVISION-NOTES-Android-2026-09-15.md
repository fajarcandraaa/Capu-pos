# Revision Notes — Android TASK-001 to TASK-008

**Date:** 2026-09-15  
**Reviewer Role:** Tech-Lead-System-Analyst  
**Reviewed Against:** BRD, PRD, SRS, TRD, SDD, UI/UX Flow, Task Contracts  
**Source:** apps/capupos-android (canonical), docs/

---

## Executive Summary

8 Android tasks marked DONE in repo. Codebase builds successfully (last `./gradlew assembleDebug` exit 0). Review found **4 CRITICAL gaps** requiring revision tasks, **3 MEDIUM issues** for quick fix, **1 LOW housekeeping item**. Governance blocker: app code never committed to git (`??` status); task contracts declare done without version control evidence.

---

## Critical Findings

### 1. [BLOCKER] App Code Untracked in Git  
**Severity:** HIGH (Governance)  
**Area:** Version Control / SCM  
**Issue:** `apps/capupos-android/` shows `??` in git status. All 8 tasks marked DONE; code exists locally but never committed. No git history, blame, or rollback capability; no evidence of completion for audit.  
**Docs Ref:** CLAUDE.md rule precedence §2 (Task Contract requires allowed_paths tracked/versioned)  
**Code Ref:** `git status --short apps/capupos-android/ → ??`  
**Fix:** `git add apps/capupos-android/; git commit -m "feat(android): TASK-001..008 implementation complete"` → push to main or feat branch.  
**Task:** TASK-009-Git-Commit-Android-Complete (blocK all follow-up tasks)

### 2. [BLOCKER] Zero Automated Tests  
**Severity:** HIGH (Testing/QA)  
**Area:** Test Coverage  
**Issue:** No `app/src/test/` or `app/src/androidTest/` directories. 8 tasks span complex business logic (transactions, soft/hard delete, PO status flow, export Excel, reminder 7-day rolling, kategori management). Zero unit/instrumentation tests means acceptance criteria unverifiable, regressions undetectable, deployment risk high.  
**Docs Ref:** TRD §5.2 Clean Architecture mandates business rules "mudah diverifikasi terpisah dari UI" — no tests = impossible to verify.  
**Code Ref:** `find apps/capupos-android/app/src -type d \( -name test -o -name androidTest \) → (empty)`  
**Fix:** Add test dirs + write unit tests for: domain/usecase/* (all 15 use cases), core repository logic, soft/hard delete rules, PO state transitions.  
**Task:** TASK-009-Unit-Tests-Android (depend on TASK-009-Git-Commit)

### 3. Reminder Calculation Bug — FR-12.1 Violation  
**Severity:** HIGH (Feature Logic)  
**Area:** Reminder Backup / First Launch  
**Issue:** SRS FR-12.1 states reminder first occurrence = "7 hari sejak aplikasi pertama kali diinstall". Implementation: `CekReminderBackupUseCase.execute()` returns `true` immediately when `lastReminderAt == 0L` (never set before), triggering popup on app launch day 1. Popup should NOT appear until day 7 post-install.  
**Docs Ref:** SRS FR-12.1 "Reminder pertama: 7 hari sejak aplikasi pertama kali diinstall" + BR-06 "Interval reminder backup dihitung rolling dari kejadian reminder terakhir"  
**Code Ref:** `domain/usecase/CekReminderBackupUseCase.kt:22-24`  
```kotlin
val lastReminderAt = sharedPreferences.getLong(KEY_LAST_REMINDER, 0L)
if (lastReminderAt == 0L) return true  // ← BUG: should return false on first 7 days, return true only if 7+ days elapsed
```
**Logic Fix:** Seed `lastReminderAt = System.currentTimeMillis()` on first app launch (MainActivity onCreate check); only return true if `now - lastReminderAt >= INTERVAL_MILLIS`.  
**Task:** TASK-009-Fix-Reminder-First-Launch

### 4. Missing Item Name Snapshot in Transaksi  
**Severity:** HIGH (Data Integrity)  
**Area:** Order Details / Struk / Riwayat  
**Issue:** SDD §5.2 defines `transaksi_item.nama_item TEXT NOT NULL` as snapshot: "disalin saat transaksi dibuat (histori harga/nama tidak berubah meski produk diedit nanti)". Android `OrderDetailEntity` lacks `namaItem` field; stores only `productId` FK. Consequence: (1) Struk shows product UUID when item manual → confusing; (2) Riwayat shows current product name (not historical name) if product renamed/deleted → inaccurate history.  
**Docs Ref:** SDD §5.2 schema `transaksi_item (nama_item TEXT NOT NULL, ...)`  
**Code Ref:** `data/entities/OrderDetailEntity.kt:14-23` — no `namaItem` field. `TransaksiViewModel.kt:155` creates `OrderItem(productId=..., quantity=..., price=...)` without deskripsi/name copy.  
**Affected Code Flow:**  
- `TransaksiViewModel.kt:155` → builds `OrderItem` without item name  
- `domain/usecase/SimpanTransaksiUseCase.kt` → saves to DB  
- `presentation/struk/GenerateStrukUseCase.kt:42` → displays `item.deskripsi ?: item.productId ?: "-"` → shows UUID for products  
**Fix:** (1) Add `namaItem: String?` field to `OrderDetailEntity` + `OrderItem` domain model; (2) Snapshot product.nama at save time in `TransaksiViewModel.addToCart()` → store in OrderItem.deskripsi or explicit field; (3) Migration: add nullable column.  
**Task:** TASK-009-Add-Item-Name-Snapshot

---

## Medium Findings (3 issues, can be batched into 1 revision task)

### 5. Foreign Key Index Warnings  
**Severity:** MEDIUM (Performance)  
**Issue:** Build log warns: `orderId`, `productId` (OrderDetailEntity, StockHistoryEntity) are FK but lack indices. Room recommends indices to avoid full table scans on parent updates.  
**Code Ref:** `build.log` kapt warnings + `data/entities/OrderDetailEntity.kt:16-25`, `StockHistoryEntity.kt`  
**Fix:** Add `@Index(value = ["orderId"], name = "idx_order_detail_orderId")` to foreign key columns in entities, or create indices via migration.  
**Included in:** TASK-009-Performance-Indices

### 6. Laporan Search/Filter Not Implemented (FR-09.3)  
**Severity:** MEDIUM (Feature Gap)  
**Issue:** SRS FR-09.3 "Sistem harus menyediakan filter dan search pada tampilan laporan". LaporanViewModel/LaporanActivity show no filter/search UI or logic. Riwayat has FilterRiwayat + setFilterKategori/setFilterTanggal/setFilterMetode — Laporan does not.  
**Docs Ref:** SRS §FR-09 "FR-09.3: Sistem harus menyediakan filter dan search pada tampilan laporan"  
**Code Ref:** `presentation/laporan/LaporanViewModel.kt` → grep 'filter\|search' → (no matches)  
**Fix:** Port filter pattern from RiwayatViewModel; add date range + kategori filters to LaporanViewModel/LaporanActivity.  
**Included in:** TASK-009-Laporan-Filters

### 7. Riwayat "Tandai Lunas" & "Sembunyikan" Features Missing  
**Severity:** MEDIUM (Feature Gap)  
**Issue:** SRS FR-07.3 "Sistem harus memungkinkan pengguna menyembunyikan transaksi dari tampilan list (tanpa mempengaruhi perhitungan laporan)" + FR-07.4 "menandai transaksi belum bayar sebagai lunas secara langsung". RiwayatViewModel has `hapusTransaksi()` but no `tandaiLunas()` or `sembunyikan()` methods.  
**Docs Ref:** SRS FR-07.3, FR-07.4 + BR-05 "Fitur 'Sembunyikan' bersifat reversible"  
**Code Ref:** `presentation/riwayat/RiwayatViewModel.kt` → grep 'tandai\|sembunyikan' → (no matches)  
**Fix:** Add `tandaiLunas(orderId)` + `toggleSembunyikan(orderId)` to RiwayatViewModel; wire UI buttons in RiwayatActivity.  
**Included in:** TASK-009-Riwayat-Actions

---

## Low Findings (1 item)

### 8. Stray File: gradlew.new  
**Severity:** LOW (Housekeeping)  
**Issue:** `apps/capupos-android/gradlew.new` contains "404: Not Found" (incomplete/corrupt download).  
**Fix:** `rm apps/capupos-android/gradlew.new`  
**Included in:** TASK-009-Git-Cleanup

---

## Findings Pending Agent Review

Review delegated to 4 parallel Explore agents (Sonnet model retry):
- **Data Layer** (DB, migrations, DI, repositories) vs SDD/TRD
- **Onboarding + Produk + Kategori/Stok** vs BRD/PRD  
- **Transaksi + Pembayaran + Riwayat + Laporan** vs BRD/SRS  
- **Profil + Struk + Reminder + Export** vs BRD/SRS + TASK-007 post-hoc amend

Agent reports will be appended here upon completion. Preliminary synthesis shows 4 HIGH + 3 MEDIUM + 1 LOW issues above; agents may surface additional issues per specific acceptance criteria vs code.

---

## Agent Review Findings

### A. Onboarding + Produk + Kategori + Stok (agent selesai)

- `[high]` **Onboarding — AddProductActivity tanpa field kategori.** Form onboarding membuat `Product` tanpa `kategoriId`; FR-01.1 (SRS:32) + UI/UX Flow:59 menyebut kategori wajib. TASK-002.md:18 mencentang `[x]` padahal tidak lengkap. — Kode: `AddProductActivity.kt:67-73`, `activity_add_product.xml` tanpa spinner kategori. — Fix: tambah spinner kategori dinamis (reuse pola TASK-008) atau redirect onboarding CTA ke TambahProdukActivity.
- `[high]` **"Tambah Kategori inline dari form produk" tidak ada di manapun** (UI/UX Flow:60). TambahProdukActivity & AddProductActivity hanya observe kategoriList, tanpa opsi `+ Tambah Kategori`. — Fix: tambah opsi inline add kategori di form produk.
- `[medium]` **Upload foto onboarding = Toast placeholder** ("Fitur upload foto belum tersedia"), foto tidak pernah disimpan. Kontradiksi checkbox TASK-002 `[x]` vs catatan sesinya sendiri (TASK-002.md:37 unresolved). — Kode: `AddProductActivity.kt:53-55`.
- `[medium]` **Dua form Tambah Produk tidak setara**: onboarding/AddProductActivity (tanpa kategori, tanpa foto) vs produk/TambahProdukActivity (kategori dinamis + foto picker). User pertama vs existing dapat pengalaman beda. — Fix: konsolidasi jadi satu form.
- `[low]` Splash delay 2000ms; TASK-002.md:15 menulis `< 2 detik`. — Kode: `MainActivity.kt:19-22`.
- `[low]` Empty state Home (hasil filter kosong) tanpa CTA — PRD:106 "CTA jelas di setiap layar". — Kode: `activity_home.xml:199-236`.
- `[none]` Kategori CRUD + reorder drag&drop persisten (TASK-004) ✓; hapus kategori → produk jadi "Tanpa Kategori" sesuai DECISIONS ✓; atur stok + badge stok menipis (FR-03) ✓; kategori dinamis TASK-008 ✓ (`KategoriConstants` sudah terhapus); soft-delete produk ✓.

### B. Transaksi + Pembayaran + Riwayat + Laporan (agent selesai)

- `[high]` **PembayaranActivity unreachable dari UI** — tidak ada pemanggil `startActivity` dari adapter/list manapun. FR-06 (SRS:57-62) tidak pernah bisa dipakai user dari alur nyata. — Kode: `PembayaranActivity.kt` (no callers). — Fix: wire tombol "Bayar" di BelumBayarAdapter/RiwayatAdapter ke `PembayaranActivity.EXTRA_ORDER_ID`.
- `[high]` **Transaksi manual + produk terdaftar tidak bisa digabung dalam 1 transaksi** (FR-04.3, SRS:47; UI/UX 5.4-5.5). TransaksiManualViewModel.kt:91 langsung simpan Order terpisah, tanpa merge keranjang. — Fix: pass keranjang dari TransaksiActivity, merge sebelum simpan.
- `[high]` **Struk tidak tampil setelah pembayaran** (FR-06.4, SRS:61; UI/UX 5.8). PembayaranActivity.kt:148-153 langsung kembali ke BelumBayarActivity, tanpa buka StrukActivity. — Fix: panggil `StrukActivity.createIntent` setelah BayarTransaksiUseCase sukses.
- `[high]` **Sembunyikan transaksi = stub** (FR-07.3, SRS:66). `OrderDao.hide()` ada (OrderDao.kt:32-33) tapi tidak diekspos di OrderRepository dan tidak ada tombol UI. Memperkuat temuan #7. — Fix: `OrderRepository.hide(orderId)` + aksi "Sembunyikan" di adapter riwayat.
- `[high]` **Laporan filter/search tidak lengkap** (FR-09.3, SRS:76). Hanya tombol periode hari/minggu/bulan; tanpa date-range picker, tanpa search. Memperkuat temuan #6. — Kode: `LaporanActivity.kt`.
- `[medium]` **Tandai Lunas langsung tidak ada** (FR-07.4). BelumBayarAdapter.kt:77 hanya tombol "Ubah Status"; tidak ada aksi bayar-langsung dari list/detail. Memperkuat temuan #7.
- `[medium]` **Field catatan tidak exposed di UI pembayaran** (FR-06.3, SRS:60). `Order.catatan` ada di domain/DB, tapi activity_pembayaran.xml tanpa EditText. — Fix: tambah input catatan, pass ke BayarTransaksiUseCase.
- `[medium]` **Edit detail transaksi (item/nominal) tidak ada** — UI/UX 5.9 menyebut "Ubah → Edit item/nominal/status"; UbahStatusPOUseCase hanya ubah status. Perlu klarifikasi intent desain (edit penuh vs status saja) → update docs bila status-saja.
- `[low]` Order domain model tidak expose isHidden/isDeleted/deletedAt/createdAt/updatedAt (ada di entity, difilter DAO). Bisa diterima sebagai desain — dokumentasikan sebagai keputusan sadar.
- `[none]` Riwayat filter kategori/tanggal/metode (SRS:64-65) ✓; laporan card+tren (SRS:74) ✓; soft/hard delete hapus transaksi (FR-08.1/08.2) ✓; grouping list belum bayar per tanggal ✓; state machine PO blok selesai→dibatalkan (FR-05.5) ✓.

### C. Data Layer (agent selesai)

- `[medium]` **FK index missing OrderDetailEntity.orderId & .productId** — full table scan risk saat parent table dimodifikasi. TRD/SDD tidak eksplisit require index, tapi SRS NFR "Performa" (SRS:108) menyebut volume transaksi skala menengah. StockHistoryEntity.productId sudah ada index. — Kode: `OrderDetailEntity.kt:8-24` (build.log warning). — Fix: tambah `indices = [Index("orderId"), Index("productId")]` di @Entity (murah, root-cause).
- `[low]` **ProductEntity/OrderEntity/CategoryEntity — field `sync_status` (TRD:56,58; SDD:29,48) tidak ada di entity Android.** TRD sendiri katakan "disiapkan fase depan" (TRD 5.6), bukan wajib MVP1. — Fix: acceptable gap, catat di DECISIONS.md, tambah kolom nullable saat cloud sync dikerjakan (additive migration).
- `[low]` **StoreEntity field `kategori` vs TRD `kategoriUsaha`** — TRD:56 pakai nama kategoriUsaha, kode pakai kategori (StoreEntity.kt:12). DECISIONS.md [2026-09-14] poin 3 sebut kategoriUsaha tapi kode pakai kategori. — Fix: konfirmasi TL/SA apakah penamaan final (kategori) atau perlu rename sesuai decision literal.
- `[low]` **profil_lokal (email/no_hp/device_id) tidak diimplementasi** — SRS 5.3 & TRD 5.6 poin Multi-user/Login. TRD eksplisit "non-implementasi MVP1". — Fix: catat out-of-scope di DECISIONS.md agar jelas bukan miss.
- `[none]` Versi migration konsisten (AppDatabase @Database version 5 vs MIGRATION_1_2..4_5 semua registered + wired DatabaseModule) ✓; field entity utama cocok SRS/TRD/task contract ✓; reminder_log via SharedPreferences (bukan DB) sudah documented DECISIONS.md [2026-09-14 poin 5] + approved TL/SA ✓; cloud sync & multi-user out-of-scope TRD ✓.

### D. Profil + Struk + Reminder + Export (agent selesai)

- `[high]` **Reminder pertama = hari install, bukan 7 hari (memperkuat temuan #3).** Tidak ada penyimpanan tanggal install sama sekali (grep `installDate`/first-launch = 0 match; AppApplication.kt kosong). `CekReminderBackupUseCase.kt:21-24` return true bila `last_backup_timestamp == 0`. — Ref: SRS FR-12.1 (SRS:88) + BR-06 (SRS:132) + DECISIONS.md [2026-09-14] poin 5. — Fix: seed `lastReminderAt` = timestamp first-launch di Application.onCreate bila key belum ada.
- `[medium]` **Struk menampilkan "Diterima/Kembalian Rp 0" untuk metode non-tunai.** FR-11.1: kembalian hanya "jika tunai" (SRS:83). Non-tunai di-set nominal=subtotal, kembalian=0 (`PembayaranActivity.kt:122-126`), struk tetap cetak baris Diterima/Kembalian (`GenerateStrukUseCase.kt:49-50`). — Fix: guard `if (order.metodeBayar == "tunai")` sebelum blok Diterima/Kembalian.
- `[medium]` **Struk tidak reachable dari alur natural** (memperkuat temuan agent B). Setelah bayar sukses → langsung BelumBayarActivity (`PembayaranActivity.kt:142-147`); tidak ada aksi "Cetak Struk" di Riwayat/Belum Bayar (UI/UX 5.9, 05:173). Satu-satunya jalur: tombol "Lihat Struk Terakhir" di ProfilUsahaActivity. — Fix: tampilkan struk saat `state.paid` + aksi struk di Riwayat.
- `[low]` **"Export Sekarang" reset counter reminder sebelum export benar-benar terjadi** (`HomeActivity.kt:236` reset saat dialog, `ExportActivity.kt:68` reset lagi saat share sukses). User yang back-out dari ExportActivity tidak diingatkan 7 hari. Keputusan bug-fix yang disetujui post-hoc, tapi semantiknya "dismiss tanpa backup". — Fix: reset hanya di share sukses + flag "dialog tampil" per sesi.
- `[low]` **Sheet "Laporan Ringkas" export tanpa label periode** — selalu aggregate all-time (`ExportDataUseCase.kt:31` `getLaporanAggregat(0L, now)`), beda dari PRD (04:123) yang menyatakan merangkum laporan berperiode. — Fix: tambah baris label periode atau konsisten pakai default periode Laporan.
- `[low]` **Export menyertakan transaksi tersembunyi** — `getAllOrders` hanya filter `isDeleted=0` (`OrderDao.kt:14-15`), tidak filter `isHidden`. Ambigu vs BR-05 (yang hanya mengatur perhitungan laporan, bukan export). — Perlu konfirmasi TL/SA: apakah export harus exclude `isHidden=1`.
- `[low]` `CekReminderBackupUseCase` (domain) import `android.content.SharedPreferences` langsung — tech-debt, sudah dicatat di task contract. Opsional: abstraksi interface storage.
- `[none]` FR-12.2 popup dismiss wajib ✓; FR-12.3 maks 1x per 7 hari ✓; reminder di HomeActivity sesuai amend ✓; FR-10.1/10.2 profil usaha lengkap ✓; logo persist + backward-compat ✓; FR-11.2 share struk ACTION_SEND ✓; FR-13.1 Excel 3 sheet tanpa dependency baru ✓; FR-13.2 akses dari Profil ✓; FR-13.3 FileProvider + Sharesheet ✓. Semua keputusan amend post-hoc (FileProvider, CREATE TABLE, field `kategori`, inline popup) konsisten kode vs approval.

---

## Proposed Revision Tasks (To Be Escalated to PM)

### Blocker (Governance / QA)
1. **TASK-009-Git-Commit-Android-Complete** — commit `apps/capupos-android/` ke git (blokir semua task berikut)
2. **TASK-009-Unit-Tests-Android** — unit test domain/usecase + core logic (depend on #1)

### High (Feature Gap — Core Flow)
3. **TASK-009-Fix-Reminder-First-Launch** — seed timestamp first-launch, fix 7-day delay (FR-12.1/BR-06)
4. **TASK-009-Add-Item-Name-Snapshot** — field `namaItem` di OrderDetailEntity, snapshot saat simpan (SDD 5.2)
5. **TASK-009-Onboarding-Form-Kategori** — tambah field kategori + kategori-inline di AddProductActivity (FR-01.1, UI/UX:59-60), konsolidasi form Tambah Produk
6. **TASK-009-Wire-Pembayaran-Struk** — wire PembayaranActivity dari adapter + tampilkan struk setelah bayar (FR-06, FR-06.4); guard kembalian non-tunai (FR-11.1)
7. **TASK-009-Transaksi-Manual-Merge** — gabung item manual + produk terdaftar dalam 1 transaksi (FR-04.3)
8. **TASK-009-Riwayat-Actions** — implement "Sembunyikan" (FR-07.3) + "Tandai Lunas" (FR-07.4)
9. **TASK-009-Laporan-Filters** — date-range picker + search di Laporan (FR-09.3)

### Medium (Polish)
10. **TASK-009-Performance-Indices** — FK index OrderDetailEntity.orderId/productId
11. **TASK-009-Pembayaran-Catatan** — expose field catatan di UI pembayaran (FR-06.3)
12. **TASK-009-Edit-Detail-Transaksi** — klarifikasi + implement edit item/nominal (UI/UX 5.9) atau update docs bila status-saja
13. **TASK-009-Onboarding-Foto** — foto picker di onboarding (bukan placeholder)

### Low (Housekeeping / Confirmasi)
14. **TASK-009-Cleanup** — hapus gradlew.new; splash delay; empty-state Home CTA
15. **TASK-009-Export-Correctness** — reset reminder counter hanya saat share sukses; label periode; filter isHidden
16. **TASK-009-Data-Layer-Decisions** — konfirmasi TL/SA: kategori vs kategoriUsaha, sync_status/profil_lokal out-of-scope, reminder via SharedPreferences, Order domain model fields — catat di DECISIONS.md

---

## Next Steps

1. Await agent review reports (ETA ~5-10 min)
2. Compile final revision notes with agent findings
3. Escalate to PM with proposed revision tasks + effort estimates
4. Prioritize by blocker → high → medium; create formal task contracts

---

*Document updated: 2026-09-15 (in-progress, awaiting agent completion)*
