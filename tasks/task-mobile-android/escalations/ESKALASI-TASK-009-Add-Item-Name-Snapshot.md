# Eskalasi — TASK-009-Add-Item-Name-Snapshot

**Task ID:** TASK-009-Add-Item-Name-Snapshot
**Platform:** Android (apps/capupos-android)
**Ditujukan ke:** Tech-Lead / System Analyst (TL/SA)
**Role pelapor:** Android Developer
**Tanggal:** 2026-09-15
**Status:** Menunggu keputusan — task tidak bisa diselesaikan penuh tanpa amend contract

---

## Ringkasan Konflik

Task contract `TASK-009-Add-Item-Name-Snapshot.md` menambah field `namaItem` di
`OrderDetailEntity` (data layer) dan `OrderItem` (domain model), tapi **tidak
mencantumkan file mapping** di antara keduanya:

```
apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/repository/OrderRepositoryImpl.kt
```

Mapping `OrderItem <-> OrderDetailEntity` tinggal di `OrderRepositoryImpl.kt`:

- `OrderDetailEntity.toDomain()` (baris 204-212)
- `OrderItem.toEntity()` (baris 230-239)

Tanpa edit file itu, field `namaItem`:

1. Tidak pernah **ditulis** ke DB (`OrderItem.toEntity()` tidak menyalin `namaItem`).
2. Tidak pernah **dibaca** balik (`OrderDetailEntity.toDomain()` tidak memetakan `namaItem`).

Akibatnya acceptance criteria #4 (struk menampilkan nama) dan #5 (riwayat
menampilkan snapshot historis) **gagal runtime** — `namaItem` selalu null di
domain layer, struk/riwayat tetap fallback ke `productId` (UUID) atau nama live.

## Klasifikasi Konflik (per CLAUDE.md Rule Precedence)

- **Level 2 (Task Contract):** `allowed_paths` TIDAK memuat `OrderRepositoryImpl.kt`.
- **Level 4/5 (requirement task):** SDD §5.2 + revision notes §4 mensyaratkan
  snapshot nama tersimpan & tampil di struk/riwayat.

Dua level saling bertentangan. CLAUDE.md mewajibkan: **berhenti, jangan memilih
sendiri, tulis laporan konflik, eskalasi ke TL/SA**. Ini laporan tersebut.

## Evidence

### allowed_paths task contract (7 file, TIDAK termasuk repository)

1. `data/entities/OrderDetailEntity.kt`
2. `domain/model/OrderItem.kt`
3. `domain/usecase/SimpanTransaksiUseCase.kt`
4. `domain/usecase/GenerateStrukUseCase.kt`
5. `presentation/transaksi/TransaksiViewModel.kt`
6. `data/AppDatabase.kt`
7. `data/MigrationV5ToV6.kt` (baru)

### Kode yang wajib disentuh (di luar allowed_paths)

`data/repository/OrderRepositoryImpl.kt`:

```kotlin
// baris 204-212 — baca dari DB
private fun OrderDetailEntity.toDomain(): OrderItem {
    return OrderItem(
        id = this.id,
        productId = this.productId,
        deskripsi = this.deskripsi,
        quantity = this.quantity,
        price = this.price
        // <-- namaItem hilang, harus ditambah di sini
    )
}

// baris 230-239 — tulis ke DB
private fun OrderItem.toEntity(orderId: String): OrderDetailEntity {
    return OrderDetailEntity(
        id = this.id ?: UUID.randomUUID().toString(),
        orderId = orderId,
        productId = this.productId,
        quantity = this.quantity,
        price = this.price,
        deskripsi = this.deskripsi
        // <-- namaItem hilang, harus ditambah di sini
    )
}
```

## Opsi Penyelesaian

### Opsi A (rekomendasi) — Amend allowed_paths

Tambahkan `OrderRepositoryImpl.kt` ke `allowed_paths` task contract.

- Diff kecil (+1 file, 2 line mapping).
- Root-cause fix: snapshot benar-benar tersimpan & terbaca.
- Konsisten dengan preseden TASK-006 (escalations/RENCANA-EKSEKUSI-TASK-006.md)
  yang juga meng-amend allowed_paths lewat PM/SA.

### Opsi B — Pertahankan contract, terima AC parsial

Kerjakan hanya 7 file di allowed_paths, tapi:

- `namaItem` jadi dead field (tidak pernah persist).
- AC #4 dan #5 TIDAK tercapai.
- Struk tetap tampil UUID, riwayat tetap baca nama live.
- Menghasilkan symptom-patch, melanggar prinsip root-cause fix (CLAUDE.md).

Opsi B tidak disarankan.

## Permintaan ke TL/SA

1. Putuskan: Opsi A (amend allowed_paths tambah `OrderRepositoryImpl.kt`) atau arahkan lain.
2. Bila setuju Opsi A, konfirmasi agar developer melanjutkan edit repository mapping.
3. Bila ada file mapping lain yang juga relevan (mis. DAO/query join), mohon ditambahkan sekalian.

---

**Blokir sampai keputusan TL/SA.** Task status tetap `draft` (belum `in_progress`)
sesuai alur, menunggu amend contract.

---

## Keputusan TL/SA [2026-09-15]

**Status: RESOLVED — Opsi A disetujui.**

`data/repository/OrderRepositoryImpl.kt` ditambahkan ke allowed_paths task
contract (`TASK-009-Add-Item-Name-Snapshot.md`). Mapping gap terverifikasi
langsung ke kode (line number akurat), `namaItem` dikonfirmasi belum ada
di manapun di codebase. Detail keputusan: `DECISIONS.md` §[2026-09-15]
TL/SA — TASK-009-Add-Item-Name-Snapshot.

Task masih status `draft` — menunggu PM pindahkan ke `ready` sebelum
android-developer lanjut eksekusi.
