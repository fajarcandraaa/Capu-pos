# Eskalasi Tambahan — TASK-009-Add-Item-Name-Snapshot: DatabaseModule.kt

**Task ID:** TASK-009-Add-Item-Name-Snapshot
**Status:** In-progress — menemukan gap mitigasi sebelum build
**Ditujukan ke:** Tech-Lead / System Analyst (TL/SA)

---

## Gap Ditemukan Saat Implementasi

Setelah mengedit 8 file (entity + domain + repository + usecase + viewmodel + database + migration baru), verifikasi keputusan TL/SA menemukan **file ke-9 yang WAJIB disentuh**:

```
apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/di/DatabaseModule.kt
```

File ini mendaftarkan semua migration ke Room builder:

```kotlin
.addMigrations(
    AppDatabase.MIGRATION_1_2,
    AppDatabase.MIGRATION_2_3,
    AppDatabase.MIGRATION_3_4,
    AppDatabase.MIGRATION_4_5,
    AppDatabase.MIGRATION_5_6  // <-- HARUS ditambah di sini
)
```

**Tanpa edit ini:** `MigrationV5ToV6` buat daftar di `AppDatabase.kt`, tapi Room tidak pernah jalankan. DB version bump 5→6 tapi kolom `namaItem` tidak pernah `ALTER TABLE`. Migration fails runtime → AC #3 gagal.

## Penyebab Gap

DECISIONS.md [2026-09-15] poin 8 menyatakan: "satu-satunya konektor yang wajib disentuh di luar contract adalah repository mapper". Verifikasi TL/SA lalu: "tidak ada file lain yang perlu ditambah (DAO insert generic, use-case sudah tercakup)".

**Terlewatkan:** DI module (DatabaseModule) yang menjalankan registration migration — bukan "file lain biasa", tapi **kritis untuk correctness** migration.

## Permintaan

1. **Amend allowed_paths lagi** — tambah `data/di/DatabaseModule.kt` ke TASK-009.
2. **Catatan amend:** "Gap #2: DI module wajib didaftarkan migration di addMigrations() builder (poin 2026-09-15 tidak mengcakup DI layer)."

---

**Action:** Task tetap in-progress + tunggu amend, atau — apabila TL/SA percaya assessment ini benar — developer lanjut edit DatabaseModule (sudah dikerjakan di worktree), push commit, dan TL/SA confirm post-hoc.

Developer sudah siap amend jika approved.

---

## Keputusan TL/SA [2026-09-15]

**Status: RESOLVED — Opsi A disetujui (amend kedua, post-hoc confirm).**

Verifikasi langsung ke worktree `task-009-item-name-snapshot` mengonfirmasi
klaim 100%: `MigrationV5ToV6` benar (camelCase, additive), `AppDatabase`
version 6, mapping lengkap, snapshot benar, dan `DatabaseModule.kt` di
worktree SUDAH mendaftarkan `MIGRATION_5_6` di `addMigrations()`.

- `DatabaseModule.kt` ditambahkan ke allowed_paths (amend TL/SA #2) — lihat
  task contract `TASK-009-Add-Item-Name-Snapshot.md` + `DECISIONS.md`
  §[2026-09-15] amend kedua.
- **android-developer: LANJUTKAN kerja di worktree existing.** Edit
  DatabaseModule sudah valid post-hoc, tidak perlu revert. Sisa langkah:
  build + verifikasi AC, isi Catatan Sesi, push commit/branch, lalu QA.
- Koreksi catatan TL/SA amend #1: pernyataan "tidak ada file lain yang perlu
  ditambah" terbukti keliru — DI migration registration adalah bagian
  migration pipeline. Checklist migration ke depan (dicatat di DECISIONS.md):
  migration file + AppDatabase version/companion + DatabaseModule
  addMigrations = satu unit kerja.
