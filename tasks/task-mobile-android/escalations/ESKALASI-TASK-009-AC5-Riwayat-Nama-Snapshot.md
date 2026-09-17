# Eskalasi — TASK-009-Add-Item-Name-Snapshot: Ambigu AC #5

**Task ID:** TASK-009-Add-Item-Name-Snapshot
**Ditujukan ke:** Tech-Lead / System Analyst (TL/SA)
**Role pelapor:** QA Engineer
**Tanggal:** 2026-09-15
**Status:** Menunggu klarifikasi interpretasi acceptance criteria

---

## Ringkasan

AC #5 berbunyi:

> Riwayat menampilkan nama snapshot (historis), tidak berubah meski produk diedit/hapus

Kata "riwayat menampilkan" ambigu — dua interpretasi valid, dua outcome berbeda.

## Fakta Code (terverifikasi QA)

1. **Data layer snapshot BENAR dan lengkap.**
   - `OrderDetailEntity.namaItem` persist via `OrderItem.toEntity()` (`OrderRepositoryImpl.kt:230`).
   - Terbaca balik via `OrderDetailEntity.toDomain()` (`OrderRepositoryImpl.kt:204`).
   - `productId` FK `ON DELETE SET_NULL` → produk dihapus TIDAK menghapus `namaItem`
     snapshot (tetap tersimpan). Produk di-rename juga tidak mengubah `namaItem`
     karena disalin sekali saat `simpanBill()`.

2. **UI riwayat list TIDAK menampilkan nama item.**
   - `item_riwayat_order.xml` render: subtotal, jumlah item, status, metode — tanpa nama item.
   - `RiwayatAdapter.kt:75-87` bind field yang sama — tanpa `order.items` / nama.
   - `item_belum_bayar.xml` + `BelumBayarAdapter.kt` juga tanpa nama item.

3. **Nama item hanya tampil di struk.**
   - `GenerateStrukUseCase.kt:41` → `namaItem ?: deskripsi ?: productId ?: "-"`.
   - Struk reachable hanya dari `ProfilUsahaActivity` ("Lihat Struk Terakhir"),
     BUKAN dari riwayat list (gap itu di task terpisah: TASK-009-Wire-Pembayaran-Struk).

## Dua Interpretasi

| Interpretasi | Makna "riwayat menampilkan" | AC #5 status |
|---|---|---|
| A. Via struk / detail transaksi | Snapshot nama historis terbaca saat lihat detail → data sudah benar | ✅ TERPENUHI (data-layer done) |
| B. List riwayat harus render nama item | Kolom nama item tampil langsung di list riwayat/belum-bayar | ❌ BELUM (butuh ubah `presentation/riwayat/**`) |

## Implikasi

- **Interpretasi A**: TASK-009 siap merge, tidak ada tambahan kerja.
- **Interpretasi B**: butuh ubah `presentation/riwayat/**` + `presentation/transaksi/**`
  (BelumBayarAdapter/layout) — semuanya **di luar allowed_paths TASK-009**
  (forbidden `presentation/**` kecuali TransaksiViewModel). Wajib buka task terpisah.

## Permintaan ke TL/SA

1. Tetapkan interpretasi AC #5 (A atau B).
2. Bila B: arahkan buka task baru (mis. TASK-009-Riwayat-Tampil-Nama-Item) dengan
   allowed_paths mencakup `presentation/riwayat/**` + layout terkait. QA akan
   validasi terpisah.
3. Bila A: konfirmasi AC #5 dianggap terpenuhi oleh snapshot data-layer + tampil
   via struk; catat di DECISIONS.md agar tidak re-open di QA berikutnya.

---

**Blokir:** hanya AC #5 yang menunggu klarifikasi. Data snapshot, migration,
struk, dan 5 AC lainnya sudah PASS — tidak menghalangi merge bila interpretasi A
disepakati.

---

## Keputusan TL/SA [2026-09-15]

**Status: RESOLVED — Interpretasi A. AC #5 TERPENUHI. TASK-009 tidak diblokir
merge.**

Fakta code laporan QA diverifikasi ulang langsung ke worktree — akurat
(RiwayatAdapter render subtotal/jumlah/status/metode tanpa nama item;
GenerateStrukUseCase prioritas `namaItem ?: deskripsi ?: productId`).

Ruling:

1. **SDD §5.2 (baris 127 & 167) adalah requirement data-integrity, bukan UI**:
   `nama_item` denormalized "agar riwayat transaksi tidak berubah retroaktif
   jika produk diedit/dihapus". Tidak ada ayat di SRS/SDD/UI-UX yang
   memerintahkan list riwayat render nama per-item.
2. Desain list riwayat (subtotal + jumlah item + status + metode) adalah desain
   approved TASK-006 — interpretasi B akan menciptakan requirement UI baru di
   luar SRS (scope creep).
3. Permukaan tampil riwayat transaksi yang ada saat ini = struk
   (`GenerateStrukUseCase`) — sudah memakai snapshot historis. Detail/list
   item-level via `TASK-009-Wire-Pembayaran-Struk` + `TASK-009-Edit-Detail-
   Transaksi` — saat surface itu dibangun, WAJIB membaca `namaItem` (snapshot),
   bukan nama live `Product.nama`.

Catatan untuk QA: validasi AC #5 = (a) snapshot tersimpan saat simpan, (b)
produk di-rename/di-hapus → data `namaItem` di DB tidak berubah, (c) struk
menampilkan nama snapshot. Bukan validasi render list. Detail: `DECISIONS.md`
§[2026-09-15] TASK-009 AC #5.
