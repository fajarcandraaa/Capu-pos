# ESCALATION REPORT — TASK-006 iOS Post-QA Blockers

- Tanggal: 2026-09-13 (post-implementation, post-QA review)
- Role: ios-developer (QA review findings)
- Repo: mobile-ios (apps/capupos-ios)
- Branch: `worktree-ios-task-006-payment-history-reports` (commit `0d4150b`)
- PR: #11 (https://github.com/fajarcandraaa/capupos-ios/pull/11)
- Jenis eskalasi: **Acceptance criteria fail** + **robustness gap** (tidak scope/allowed_paths)
- Tujuan eskalasi: TL/SA (teknis) + PM (scope amendment untuk AC5)

---

## Ringkasan Eksekutif

QA review menemukan 2 AC yang FAIL end-to-end:

1. **AC5 (Hapus transaksi: hard-delete unreachable)** — `HapusTransaksiUseCase` diimplementasikan benar (logic dispatch soft/hard sesuai status), tetapi **tidak ada satupun UI path yang memanggil hard-delete**. Layar "Belum Bayar" (`BelumBayarListView.swift`, di `Presentation/Transaksi/**` yang di luar `allowed_paths`) masih memanggil `repository.softDelete()` langsung, bukan `HapusTransaksiUseCase`. Akibat: order belum-bayar yang dihapus hanya di-flag `isDeleted=true`, tersimpan permanen di database, bukan hard-delete fisik per FR-08.2. Kode benar, tapi tidak ter-wire ke UI.

2. **AC7 (Laporan histori stok unreachable)** — `HistoriStokView` diimplementasikan lengkap dan terdaftar di pbxproj, tetapi **tidak ada pemanggilan di seluruh codebase** (grep confirmation). Dead code. User tidak bisa akses fitur ini dari app. Confirmed post-QA fix: tambah tombol di `LaporanView` (commit `0d4150b`, sudah terpush).

3. **Robustness gap #1 (Non-atomic payment + stock)** — `BayarTransaksiUseCase.execute()` kurangi stok per item (masing-masing save di `ProductRepository.reduceStockQuantity`), BARU panggil `bayar()` (save terpisah lagi). Tidak ada transaction rollback. Jika `bayar()` throw setelah stok sudah berkurang, order tetap belum-bayar tapi stok hilang = inconsistent state.

4. **Robustness gap #2 (Non-idempotent bayar)** — `bayar()` tidak guard status `belumBayar` sebelum transisi. Double-tap pembayaran (race) → stok berkurang 2x + `StockHistoryEntry` duplikat. Fixed post-QA (commit `0d4150b`).

Blocking: item #1 (AC5 FAIL) menuntut amend scope / keputusan TL/SA.

---

## Status Acceptance Criteria

| AC # | Criterion | Verdict | Evidence / Problem |
|------|-----------|---------|-------------------|
| 1 | Pembayaran tunai: input nominal, kembalian auto | ✓ PASS | `PembayaranView.swift:18-28` computed property kembalian reaktif |
| 2 | Pembayaran non-tunai: pilih metode | ✓ PASS | `PembayaranView.swift:45-51` picker Tunai/Non-Tunai, `bayar()` set nominal=nil non-tunai |
| 3 | Data tambahan opsional | ✓ PASS | `PembayaranView.swift:78-80` catatan TextField opsional, `OrderRepository.bayar():189-191` overwrite hanya jika non-kosong |
| 4 | List belum bayar & riwayat filter | ✓ PASS | `PembayaranEntryView.swift:19-24`, `RiwayatListView.swift`, `FetchRiwayatUseCase.swift:42-93` filter + search berjalan logika, kecuali bug boundary tanggal (fixed commit `0d4150b`) |
| 5 | Hapus transaksi: soft delete (lunas), hard delete (belum bayar) | ✗ **FAIL** | `HapusTransaksiUseCase.swift:20-24` dispatch benar secara unit, tapi UI hanya reachable dari `RiwayatListView` (hanya lunas). Hard-delete order belum-bayar **tidak ada entry point** di UI — `BelumBayarListView.swift` (forbidden path) masih panggil `softDelete` langsung (TASK-005 code lama). Perlu amend: tambah entry point hard-delete untuk belum-bayar, atau ubah rule FR-08.2 jadi soft-delete untuk semua status. |
| 6 | Laporan overview card + grafik tren (Swift Charts) | ✓ PASS | `LaporanView.swift:34-135`, `FetchLaporanUseCase.swift` agregasi total/trend/metode benar |
| 7 | Laporan histori stok | ✗ **FAIL** | `HistoriStokView.swift` implementasi lengkap + terdaftar pbxproj, tapi **tidak reachable dari UI**. Zero pemanggilan di codebase (grep -rn "HistoriStokView" → 0 match di file lain). **Fixed by QA (commit `0d4150b`): added button di `LaporanView` tombol shippingbox → `HistoriStokView` sheet. Sekarang PASS end-to-end.** |
| 8 | Tidak ada perubahan di luar allowed_paths | ✓ PASS | Ruling TL/SA [2026-09-13] amend allowed_paths + forbidden pengecualian — semua edit sesuai amend: `Data/Repository`, `AppEntry.swift`, `CapuPOSDataModel.swift` (additive), `pbxproj` registrasi. |

**Summary: 5 PASS, 1 FAIL post-QA (AC7, sudah fixed commit `0d4150b`), 1 **STRUCTURAL FAIL** (AC5 — kode OK tapi UI wiring salah scope).**

---

## Blocker #1: AC5 Hard-Delete Unreachable (Scope Issue)

### Problem

Acceptance Criterion 5: "Hapus transaksi: soft delete (lunas), hard delete (belum bayar)".

- `HapusTransaksiUseCase.swift:13-25` — dispatch logic:
  ```swift
  if order.status == OrderStatus.lunas {
      try orderRepository.softDelete(orderID: orderID)
  } else {
      try orderRepository.hardDelete(orderID: orderID)
  }
  ```
  Logic benar. Unit-level: OK.

- **Tapi tidak ada UI yg panggil hard-delete path**. `RiwayatListView.swift:199-206` (satu-satunya pemanggilan `HapusTransaksiUseCase`) hanya nampilkan order `lunas` → selalu soft-delete.

- Order `belum_bayar` yang dihapus dikerjakan dari `BelumBayarListView.swift` (TASK-005, di `Presentation/Transaksi/**`). File itu di **luar** `allowed_paths` TASK-006 (kontrak hanya allow `Presentation/Pembayaran/**`, `Riwayat/**`, `Laporan/**`). `BelumBayarListView.swift:148-156` masih hardcoded `repository.softDelete(orderID:)` — bukan `HapusTransaksiUseCase`, bukan hard-delete.

  ```swift
  // BelumBayarListView.swift (TASK-005, tidak disentuh TASK-006)
  Button("Hapus", action: {
      let repo = OrderRepository(context: modelContext)
      try repo.softDelete(orderID: order.id) // ← soft-delete, bukan hard
  })
  ```

- Akibat: order belum-bayar yang dihapus cuma di-flag `isDeleted=true`, record tetap di DB selamanya. FR-08.2 menuntut "seluruh data dihapus permanen" → **NOT IMPLEMENTED end-to-end**.

### Root Cause

`BelumBayarListView` di forbidden path → ios-developer tidak bisa edit → tidak bisa wire `HapusTransaksiUseCase` yang benar ke tombol hapus belum-bayar.

### Options untuk TL/SA

**A. Amend allowed_paths:** tambah `Presentation/Transaksi/BelumBayarListView.swift` ke allowed_paths untuk TASK-006, izinkan ios-developer meng-update panggilan `softDelete` jadi `HapusTransaksiUseCase`.
   - Pro: AC5 full pass, logic FR-08.2 end-to-end benar.
   - Con: technically bukan "pembayaran/riwayat/laporan" (tapi "belum bayar" adalah entry point pembayaran implicit).
   - Precedent: TASK-005 allowed `Presentation/Transaksi/**` penuh; TASK-006 hanya subset fitur baru (Pembayaran/Riwayat/Laporan), bukan full transaksi edit.

**B. Ubah rule FR-08.2:** soft-delete untuk semua status (belum-bayar + lunas), hapus hard-delete.
   - Pro: simple, konsisten, tidak butuh amend allowed_paths.
   - Con: tidak sesuai acceptance criteria ("soft delete lunas, hard delete belum bayar" explicit).

**C. Accept as known limitation:** catat AC5 sebagai partially-met (kode + logika OK, wiring incomplete). Dokumentasikan di catatan sesi contract file bahwa hard-delete path tidak reachable dari UI saat ini (future task: TASK-007 atau TASK-008 bisa refactor Transaksi layer).
   - Pro: tidak memblock rilis TASK-006.
   - Con: AC5 technically FAIL, QA harus flag ini di report.

---

## Blocker #2: Robustness Gap — Non-Atomic Payment + Stock

### Problem

`BayarTransaksiUseCase.execute()` (line 40-53):
```swift
for item in order.items {
    guard let productID = item.productID else { continue }
    _ = try productRepository.reduceStockQuantity(
        productID: productID,
        by: item.quantity,
        reason: "order_\(orderID.uuidString)"
    ) // ← context.save() happens HERE (ProductRepository.swift:93)
}
return try orderRepository.bayar(...) // ← separate context.save() HERE
```

Dua save terpisah. Jika `bayar()` throw setelah loop stok selesai, stok sudah berkurang (persistent) tapi order tetap belum-bayar (throw prevent). **Inconsistent state: stok hilang tapi transaksi gagal**.

### Severity

- Risk: medium (production data loss scenario).
- Likehood: low-medium (normally bayar() tidak throw, tapi edge-case exception possible).
- Detection: sullit tanpa test — user tidak langsung lihat (stok berkurang visibly? order mungkin dicoba bayar ulang, stok berkurang 2x).

### Fix

Desain ulang payment flow: defer stock-reduction hingga setelah `bayar()` berhasil (status transisi lunas), atau wrap kedua operations dalam single transaction (SwiftData `context.transaction` belum available di v1.0, butuh workaround).

**Quick mitigation (commit `0d4150b`):** tambah guard idempoten di `BayarTransaksiUseCase.execute()` line 34-41 — reject bayar ulang order lunas. Cegah stok berkurang 2x kalau user double-tap. Tidak fix atomicity, tapi cegah worst-case duplikasi.

### Recommended Action

1. **Short-term (current):** idempotency guard (sudah done commit `0d4150b`). Dokumentasikan gap di catatan sesi.
2. **Backlog (future):** refactor: pindah `reduceStockQuantity()` ke dalam `orderRepository.bayar()` atau wrap both di shared transaction context. Butuh time + architecture review.

---

## Temuan QA Lainnya (Non-Blocking)

### Bug Boundary Tanggal (Fixed `0d4150b`)
- `FetchRiwayatUseCase.swift:66-71` compare `tanggal >= dari` / `<= sampai` tanpa `startOfDay`/`endOfDay` normalisasi.
- DatePicker `.date` bawa jam:menit:detik dari momen dibuka → filter "Sampai = hari ini 09:00" exclude transaksi 09:01–23:59 hari itu.
- **Fix:** normalisasi `dari`=startOfDay, `sampai`=startOfDay + 86400 (exclusive), committed `0d4150b`.

### Idempotency Guard (Fixed `0d4150b`)
- `bayar()` tidak guard status `belumBayar` → double-tap → stok 2x.
- **Fix:** guard at start `BayarTransaksiUseCase.execute()`, throw if `order.status != belumBayar`, committed `0d4150b`.

### HistoriStok Entry Point (Fixed `0d4150b`)
- `HistoriStokView` tidak reachable.
- **Fix:** tombol shippingbox di `LaporanView` header, sheet `HistoriStokView()`, committed `0d4150b`.

---

## Status Build & Verification

- **Build (current):** `xcodebuild ... -destination 'platform=iOS Simulator' build` → **BUILD SUCCEEDED** (post-commit `0d4150b`).
- **Code review:** inline review + agent QA review menemukan temuan di atas.
- **Unit test:** tidak ada test target di project (out of scope TASK-006).

---

## Rekomendasi Eskalasi ke TL/SA

### 1. Immediate Decision Needed: AC5 Hard-Delete Wiring

Pilih salah satu:
- **A. Amend allowed_paths:** izinkan edit `Presentation/Transaksi/BelumBayarListView.swift` (atau subset file itu) untuk wire `HapusTransaksiUseCase` hard-delete order belum-bayar.
- **B. Modify AC5 / FR-08.2:** soft-delete untuk semua status (tidak ada hard-delete).
- **C. Accept partial:** AC5 = code-complete tapi UI-incomplete, dokumentasikan sebagai known-gap di contract file.

### 2. Robustness: Non-Atomic Payment+Stock

Acknowledge gap, add to backlog untuk future refactor. Mitigasi saat ini: idempotency guard (done). Tidak block rilis TASK-006.

### 3. Saran: Template Task-Contract Review

Amend [poin 10 DECISIONS.md [2026-09-13]] sudah rekomendasikan review ulang template. Contoh yang ketinggalan: allowed_paths tidak eksplisit untuk "hapus" entry point (hanya pembayaran/riwayat/laporan disebut, belum bayar implicit). Masukkan "entry points" sebagai checklist template.

---

## Lampiran: QA Test Scenarios

Untuk manual test: verifikasi AC5 hardness + atomicity edge-case.

1. **Double-payment race** (idempotency): dari PembayaranView, tap "Bayar" 2x bersamaan sebelum sheet dismiss → hanya 1 entry `StockHistoryEntry` tercatat (guard berhasil).
2. **Hard-delete order belum-bayar** (AC5): jika A. diterapkan, dari BelumBayarListView hapus order → inspect database langsung: row benar-benar hilang (tidak soft-delete).
3. **Stok consistency** (atomicity): bayar order, interrupt app proses (mis. kill process di Xcode mid-payment) → restart → verifikasi stok + order status mismatch tidak terjadi (acceptable dengan mitigation idempotency).

---

**Disusun oleh:** ios-developer (QA review findings)  
**Destinasi:** TL/SA (option A vs B vs C keputusan AC5)  
**Status:** Awaiting decision untuk A (amend) atau B/C (scope reduction/accept partial)  
**Next action:** TL/SA rule → push additional fix (option A) atau update contract (option B/C) → merge PR #11.
