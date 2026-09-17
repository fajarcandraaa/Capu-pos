# CONFLICT REPORT — TASK-006 iOS (Pembayaran, Riwayat, Laporan)

- Tanggal: 2026-09-13
- Role: ios-developer
- Repo: mobile-ios (apps/capupos-ios)
- Task contract: `tasks/task-mobile-ios/backlog/TASK-006-Pembayaran-Riwayat-Laporan.md` (Status: **draft**, belum di-review PM/TL seperti TASK-004/005)
- Jenis konflik: **scope / allowed_paths under-specified** (pola berulang ke-4: TASK-003, TASK-004, TASK-005)
- Eskalasi: PM (scope) + TL/SA (teknis, model baru + migration)

## Ringkasan

TASK-006 tidak bisa diimplementasikan hanya dalam `allowed_paths` tertulis.
Requirement FR-06/FR-07/FR-09 (+ FR-08 hapus transaksi, disebut di acceptance
criteria walau tidak di `Requirement ref`) butuh perubahan di tiga tempat
di luar whitelist, satu di antaranya menabrak `forbidden_paths` secara langsung.

## Allowed paths (tertulis di kontrak)

- `Sources/Presentation/Pembayaran/**`
- `Sources/Presentation/Riwayat/**`
- `Sources/Presentation/Laporan/**`
- `Sources/Domain/UseCase/**`

Forbidden: `Sources/Data/Model/**`

## Yang sudah ada (tidak perlu disentuh)

- `Order` model — `status`, `statusPo`, `metodeBayar`, `nominalDiterima`, `kembalian`,
  `catatan`, `isHidden`, `isDeleted`, `deletedAt` sudah lengkap untuk FR-06/07/08,
  KECUALI literal status "Lunas" (lihat gap #1).
- `OrderRepository.softDelete()` — sudah ada untuk FR-08.1 (lunas → soft delete).
- `OrderStatus`/`StatusPO` enum — pola literal sudah mapan, tinggal ditambah.

## Gap #1 (BLOCKER — tabrak forbidden_paths langsung)

`Data/Models/CapuPOSDataModel.swift` **tidak punya** literal status `"lunas"` di
`OrderStatus` (hanya `belumBayar` yang didefinisikan) — dibutuhkan FR-06.4
("ubah status transaksi menjadi Lunas"). File ini eksplisit di `forbidden_paths`.

`FR-09.2` ("laporan histori perubahan stok") **tidak punya representasi data sama
sekali** — tidak ada entity `StockHistory`/histori mutasi stok di manapun (`Product`
hanya simpan `stockQuantity` terkini, tidak ada log perubahan). Fitur ini butuh
`@Model` baru di `Data/Models/` — **langsung menabrak forbidden_paths**, bukan
sekadar under-specified.

## Gap #2 (allowed_paths tidak sebut file wajib diedit)

| File | Alasan |
|------|--------|
| `Data/Repository/OrderRepository.swift` (edit) | Perlu method baru: `bayar(orderID:metodeBayar:nominalDiterima:kembalian:)` (FR-06.1–06.4, FR-07.4), `hardDelete(orderID:)` (FR-08.2 — repository baru punya `softDelete`, belum ada hard delete), fetch berfilter (kategori/tanggal/metode — FR-07.1) dan fetch riwayat lunas (belum ada, hanya `fetchBelumBayar`) |
| `Data/Repository/ProductRepository.swift` (edit, mungkin) | Bila histori stok dicatat saat produk terjual (kurangi `stockQuantity` per item transaksi) — repository ini belum punya method pengurangan stok sama sekali |
| `CapuPOS.xcodeproj/project.pbxproj` (edit) | Project TIDAK pakai `PBXFileSystemSynchronizedRootGroup` (folder sync otomatis) — tiap file `.swift` baru wajib didaftarkan manual (`PBXBuildFile` + `PBXFileReference` + group entry), diverifikasi dari entry existing (`TransaksiView.swift`, `BelumBayarListView.swift`). Folder `Presentation/Pembayaran/`, `Presentation/Riwayat/`, `Presentation/Laporan/` **belum ada sama sekali** — task ini pasti bikin banyak file baru |
| `Sources/App/AppEntry.swift` (edit, mungkin) | Entry point navigasi: `HomeView` saat ini cuma punya tombol "cart" (TransaksiView) dan "clock" (BelumBayarListView) via `.sheet`; tidak ada entry point ke Riwayat/Laporan/Pembayaran |

## Catatan teknis tambahan

1. `Requirement ref` di kontrak cuma sebut FR-06/07/09, tapi acceptance criteria
   poin "Hapus transaksi: soft delete (lunas), hard delete (belum bayar)" itu FR-08
   (lihat SRS `docs/06. SRS...md` baris 69–71). Tidak masalah teknis, hanya catatan
   traceability untuk QA.
2. FR-07.1 filter "kategori" butuh join `OrderItem.productID → Product.categoryID`
   (Order tidak simpan kategori langsung) — bisa dikerjakan di layer UseCase tanpa
   ubah schema, TAPI butuh akses ke `ProductRepository`/`CategoryRepository` dari
   UseCase baru (sudah publik, tidak masalah, hanya dicatat karena lintas domain).
3. FR-09.1 grafik tren pakai Swift Charts — framework native Apple, tidak perlu
   dependency baru, tidak melanggar prinsip simplification.

## Rekomendasi

Amend `allowed_paths` TASK-006, precedent DECISIONS.md `[2026-09-11]` (TASK-005)
dan `[2026-09-08]` (TASK-004):

- `Sources/Data/Repository/OrderRepository.swift`
- `Sources/Data/Repository/ProductRepository.swift` (bila TL/SA putuskan histori
  stok dicatat otomatis saat transaksi lunas)
- `CapuPOS.xcodeproj/project.pbxproj`
- `Sources/App/AppEntry.swift`

Keputusan teknis yang perlu TL/SA:

1. Tambah literal `"lunas"` ke `OrderStatus` — additive, aman untuk
   forbidden_paths bila diizinkan sebagai pengecualian eksplisit (bukan
   perubahan struktural model).
2. Bentuk histori stok: entity `@Model` baru (mis. `StockHistoryEntry`:
   productID, perubahan, alasan/sumber, timestamp) di `Data/Models/`, trigger
   dari mana (otomatis saat order lunas, dan/atau manual dari layar stok
   TASK-004 — di luar scope TASK-006 bila manual dari layar produk).
3. Konfirmasi field tambahan opsional (FR-06.3) cukup reuse `Order.catatan`
   existing, atau perlu field baru.

## Status

Menunggu keputusan PM/TL-SA. **Tidak ada perubahan kode dilakukan** — TASK-006
masih berstatus `draft`, belum layak dieksekusi sesuai precedent yang sama
diterapkan ke TASK-003/004/005.
