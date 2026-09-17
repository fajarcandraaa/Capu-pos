# Laporan Konflik — TASK-003 Manajemen Produk

**Tanggal:** 2026-09-01  
**Task:** TASK-003-Manajemen-Produk (android-engineer)  
**Repo:** capupos-android  
**Branch:** feat/TASK-003-Manajemen-Produk-android  
**Commit:** 312a7e6 (fix), 288cb25 (feat)  
**Status:** ✅ RESOLVED — Opsi A (Amend Kontrak), lihat bagian 8

---

## 1. Ringkasan Konflik

Implementasi TASK-003 menerapkan fix kritis (soft-delete untuk konsistensi data transaksi per SDD 5.2 + FR-08) di file **di luar `allowed_paths` Task Contract**. Per CLAUDE.md Rule Precedence (Level 2: Task Contract; Level 5: Role instructions), terjadi konflik yang wajib diputuskan oleh TL/SA atau PM, bukan diambil sendiri.

**Masalah utama:**  
- File `data/repository/ProductRepositoryImpl.kt` dan `domain/repository/ProductRepository.kt` dimodifikasi untuk fix soft-delete.  
- Kedua file **bukan** dalam `allowed_paths` Task Contract.  
- Fix logika benar dan penting untuk data integrity, tapi pelanggaran scope.

---

## 2. Detail Konflik

### 2.1 Task Contract `allowed_paths`

```
- apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/**
- apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/TambahProdukUseCase.kt, UbahProdukUseCase.kt, HapusProdukUseCase.kt
- apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/model/Produk.kt
- apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/dao/ProdukDao.kt
```

### 2.2 File yang Dimodifikasi (di luar allowed_paths)

| File | Alasan Perubahan | Severity |
|------|-----------------|----------|
| `data/repository/ProductRepositoryImpl.kt` | Fix soft-delete: `deleteProduct()` hardDelete→softDelete | CRITICAL |
| `domain/repository/ProductRepository.kt` | Tambah method `getProductById()` (efficiency) | HIGH |
| `AndroidManifest.xml` | Registrasi 3 activity produk (TambahProduk, ProductDetail, ProdukList) | HIGH |
| `res/layout/activity_product_detail.xml` | Layout detail produk view/edit/delete | MEDIUM |
| `res/layout/activity_produk_list.xml` | Layout grid + tab kategori + search | MEDIUM |
| `res/layout/activity_tambah_produk.xml` | Layout form tambah produk | MEDIUM |
| `res/values/strings.xml` | 25 string resource hardcoded UI (lint fix) | MEDIUM |

### 2.3 File yang Dimodifikasi (sesuai allowed_paths)

✅ Semua file di `presentation/produk/**` — 6 file  
✅ `domain/usecase/HapusProdukUseCase.kt`, `UbahProdukUseCase.kt`  
✅ Tidak ada `data/entity/**` yang dimodifikasi (forbidden paths aman)

---

## 3. Analisis Kebutuhan vs Kontrak

### 3.1 Soft-Delete Fix (CRITICAL)

**Requirement:** SDD 5.2 + FR-08 (Riwayat Transaksi)  
> Sistem harus melacak riwayat transaksi lengkap. Penghapusan fisik produk akan menghapus jejak transaksi, melanggar audit trail.

**Implementasi yang tepat:**  
```kotlin
// ProductRepositoryImpl.kt — File di luar allowed_paths
override suspend fun deleteProduct(productId: String) {
    productDao.softDelete(productId, System.currentTimeMillis())  // ✅ Benar
    // BUKAN: productDao.hardDelete(productId)  // ❌ Salah
}
```

**Dampak jika tidak diaplikasikan:**  
- Transaksi historis hilang saat produk dihapus → melanggar SDD & FR-08.  
- Data integrity corruption pada modul transaksi (TASK-004+).

**Dampak jika tetap diedit di luar scope:**  
- Task Contract violation → tidak memenuhi acceptance criteria "tidak ada perubahan di luar allowed_paths".

### 3.2 Efficiency Fix (Tambah getProductById)

**Requirement:** Acceptance criteria "Detail produk menampilkan informasi lengkap" harus load cepat.

**Issue tanpa fix:**  
```kotlin
// ProductDetailViewModel.kt — Dalam allowed_paths
val all = productRepository.getProducts()  // Full table scan ❌
val product = all.firstOrNull { it.id == productId }
```

**Solusi:**  
```kotlin
val product = productRepository.getProductById(productId)  // Direct query ✅
// Memerlukan interface + impl di ProductRepository.kt (di luar allowed_paths)
```

**Dampak:**  
- Performa detail screen O(n) → O(1), tapi memerlukan edit di luar scope.

### 3.3 AndroidManifest & Resource Changes

**Kebutuhan:** Registrasi 3 activity + layout + string resources adalah standar Android.

**Masalah:**  
- Bukan dalam `allowed_paths`.  
- Tanpa perubahan ini, app tidak akan run (missing activity registration → crash).

---

## 4. Root Cause — Kontrak Underspecified

Task Contract hanya mendaftar file Java/Kotlin, tidak mencakup:
- `AndroidManifest.xml` (wajib register activity)  
- `res/layout/**` (resources untuk UI activity)  
- `res/values/**` (string, color, dimension constants)  

Untuk fitur lengkap (3 activity + CRUD), perubahan ini **tidak dapat dihindari**.

---

## 5. Opsi Resolusi

### Opsi A: Amend Kontrak (Direkomendasikan)

**Perluas `allowed_paths` untuk mencakup:**
```
- apps/capupos-android/app/src/main/AndroidManifest.xml
- apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/repository/**
- apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/repository/**
- apps/capupos-android/app/src/main/res/layout/activity_produk*.xml
- apps/capupos-android/app/src/main/res/layout/activity_product_detail.xml
- apps/capupos-android/app/src/main/res/values/strings.xml
```

**Keuntungan:**
- ✅ Soft-delete fix tetap berlaku → SDD 5.2 compliance.
- ✅ Efficiency fix berlaku → performa detail screen.
- ✅ Semua acceptance criteria terpenuhi.
- ✅ Branch dapat di-merge langsung.

**Kerugian:**
- Kontrak terbukti incomplete, perlu review process lebih ketat.

### Opsi B: Revert Perubahan di Luar Scope

**Revert commit 312a7e6** (fix review), keep commit 288cb25 (feat).

**Keuntungan:**
- ✅ Ketat mematuhi kontrak.
- ✅ Task "done sesuai agreement".

**Kerugian:**
- ❌ Soft-delete fix hilang → SDD 5.2 tidak terpenuhi, transaksi history tidak aman.  
- ❌ Efficiency fix hilang → ProductDetailActivity full scan O(n).  
- ❌ App tetap "berfungsi" tapi dengan design debt.  
- ❌ TASK-004+ (Transaksi) akan inherit masalah ini.

### Opsi C: Split Scope — TASK-003A + TASK-003B

**TASK-003A (current):** Sesuai kontrak asli  
- Hanya `presentation/produk/**` + 3 usecase.  
- Acceptance: list, search, tambah, ubah, hapus, detail (basic).  
- **Tanpa:** soft-delete, efficiency, resources, manifest.  

**TASK-003B (follow-up):** Data layer + fix + resources  
- Scope: `data/repository/**`, `domain/repository/**`, `AndroidManifest`, layouts, strings.  
- Tanggung jawab fix soft-delete + efficiency + Android plumbing.  

**Keuntungan:**
- ✅ TASK-003A sesuai kontrak 100%.  
- ✅ Dependency chain jelas.

**Kerugian:**
- ❌ Dua task untuk satu fitur, kompleksitas koordinasi.  
- ❌ TASK-003A tidak memenuhi requirement SDD 5.2.  
- ❌ Code freeze TASK-003 vs TASK-003B update.

---

## 6. Rekomendasi TL/SA

**Prioritas:**

1. **Soft-delete fix (CRITICAL)** → harus ada untuk SDD 5.2 compliance.  
   - Apakah SDD 5.2 berlaku untuk TASK-003 atau TASK-004?  
   - Jika TASK-003 → maka soft-delete fix wajib, kontrak harus diperluas.  
   - Jika TASK-004 → defer fix ke TASK-004, TASK-003 gunakan hard delete saat ini.

2. **Kontrak completeness** → review template agar include Manifest, resources untuk fitur dengan activity.

3. **Efficiency fix (HIGH)** → `getProductById()` perlu untuk acceptance "detail informasi lengkap" fast load.

**Keputusan yang diusulkan:**
- ✅ **Pilih Opsi A (Amend Kontrak)** jika SDD 5.2 berlaku TASK-003.  
- ⚠️ **Pilih Opsi C (Split) + defer soft-delete ke TASK-004** jika hard delete oke untuk MVP.  
- ❌ **Hindari Opsi B (Revert)** — meninggalkan design debt.

---

## 7. Attachment: File Checklist

**Files dalam scope (allowed_paths) — OK:**
```
presentation/produk/KategoriConstants.kt ✓
presentation/produk/ProductDetailActivity.kt ✓
presentation/produk/ProductDetailViewModel.kt ✓
presentation/produk/ProdukGridAdapter.kt ✓
presentation/produk/ProdukListActivity.kt ✓
presentation/produk/ProdukListViewModel.kt ✓
presentation/produk/TambahProdukActivity.kt ✓
presentation/produk/TambahProdukViewModel.kt ✓
domain/usecase/UbahProdukUseCase.kt ✓
domain/usecase/HapusProdukUseCase.kt ✓
```

**Files di luar scope (allowed_paths) — CONFLICT:**
```
AndroidManifest.xml ✗
data/repository/ProductRepositoryImpl.kt ✗ (soft-delete fix, getProductById impl)
domain/repository/ProductRepository.kt ✗ (getProductById interface)
res/layout/activity_product_detail.xml ✗
res/layout/activity_produk_list.xml ✗
res/layout/activity_tambah_produk.xml ✗
res/values/strings.xml ✗
```

**Tidak ada perubahan di forbidden_paths (data/entity/) — OK**

---

## 8. Status — ✅ RESOLVED

**Tanggal Resolusi:** 2026-09-01  
**Diputuskan oleh:** TL/SA (Technical Lead & System Architect)  
**Keputusan:** Opsi A (Amend Kontrak)

### 8.1 Perubahan Efektif

✅ **allowed_paths TASK-003 diperluas** mencakup:
- `AndroidManifest.xml` (khusus registrasi 3 activity produk)
- `data/repository/ProductRepositoryImpl.kt` (khusus soft-delete + getProductById)
- `domain/repository/ProductRepository.kt` (khusus interface getProductById)
- `res/layout/activity_product_detail.xml`, `activity_produk_list.xml`, `activity_tambah_produk.xml`
- `res/values/strings.xml`

Lihat: `tasks/task-mobile-android/in-progress/TASK-003-Manajemen-Produk.md` (line 12-16, diupdate 2026-09-01)

✅ **Soft-delete tetap dipertahankan** — bukan di-revert ke hard-delete  
Alasan: TASK-004/005 (Transaksi) akan bergantung pada perilaku soft-delete untuk audit trail.

✅ **Kode tidak perlu perubahan tambahan** — commit 312a7e6 & 288cb25 tetap berlaku.

### 8.2 Follow-up Items (Non-blocker)

⚠️ **Gap fungsional:** Render foto di detail & grid masih pending  
- File `presentation/produk/**` masih dalam allowed_paths, bisa diedit tanpa kontrak baru.
- Acceptance "detail produk menampilkan informasi lengkap" + "tambah produk dengan foto" saat ini parsial.
- Rekomendasi: implementasi Glide/setImageURI di ProductDetailActivity + ProdukGridAdapter (follow-up TASK-003 atau TASK-004).

⚠️ **Peningkatan template Task Contract**  
- PM perlu update template agar selalu eksplisit include `AndroidManifest.xml`/`Info.plist` + `res/layout/**`/`res/values/**` ketika task menambah activity/screen baru.

### 8.3 Aksi Selesai

| Item | Owner | Status |
|------|-------|--------|
| Amend kontrak allowed_paths | TL/SA | ✅ DONE |
| Soft-delete fix dipertahankan | TL/SA | ✅ DONE |
| Kode tidak perlu perubahan | android-engineer | ✅ N/A (sudah tepat) |
| Merge branch feat/TASK-003-... | TL | ✅ APPROVED (lanjut ke code review) |

---

## 9. Contact

**Reported by:** QA Engineer  
**Date:** 2026-09-01  
**Escalation to:** TL/SA ✅ **RESOLVED**  
**Decision log:** DECISIONS.md (entry [2026-09-01])

---

**Status akhir: ✅ CONFLICT RESOLVED — TASK-003 approved untuk lanjut review/merge.**

Dokumen ini bersifat internal decision log. Tidak untuk deliver ke user/client tanpa approval TL/SA.
