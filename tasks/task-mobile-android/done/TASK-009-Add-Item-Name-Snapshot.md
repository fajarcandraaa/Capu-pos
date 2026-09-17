# Task: TASK-009-Add-Item-Name-Snapshot

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: SDD §5.2 (transaksi_item.nama_item snapshot) — REVISION-NOTES-Android-2026-09-15.md §4
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/OrderDetailEntity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/model/OrderItem.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/SimpanTransaksiUseCase.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/GenerateStrukUseCase.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/transaksi/TransaksiViewModel.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/AppDatabase.kt (bump versi + register migration)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/MigrationV5ToV6.kt (file baru)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/repository/OrderRepositoryImpl.kt (amend TL/SA — mapping `OrderItem <-> OrderDetailEntity`, wajib untuk persist `namaItem`)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/di/DatabaseModule.kt (amend TL/SA Gap#2 — daftarkan migration ke `addMigrations()` agar Room jalankan ALTER TABLE)
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/** (kecuali TransaksiViewModel yang disebut)
- Dependency: TASK-009-Git-Commit-Android-Complete
- Acceptance criteria:
  - [x] Field `namaItem: String?` ditambah di `OrderDetailEntity` dan `OrderItem`
  - [x] Snapshot `product.nama` disalin saat `TransaksiViewModel.addToCart()` (bukan dibaca live saat tampil)
  - [x] Migration Room menambah kolom nullable `namaItem` tanpa kehilangan data
  - [x] Struk menampilkan `namaItem` (bukan UUID `productId`) untuk item manual
  - [x] Riwayat menampilkan nama snapshot (historis), tidak berubah meski produk diedit/hapus
  - [x] Tidak ada perubahan di luar allowed paths
- Status: done
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->
<!-- Amend 2026-09-15 (TL/SA #1): allowed_paths ditambah OrderRepositoryImpl.kt. Alasan: mapping toDomain/toEntity di file tsb satu-satunya konektor data<->domain; tanpa edit, namaItem tidak pernah persist/dibaca -> AC #4/#5 gagal runtime. Lihat DECISIONS.md [2026-09-15] TASK-009.
Amend 2026-09-15 (TL/SA #2): allowed_paths ditambah DatabaseModule.kt. Alasan: DI layer mendaftarkan migration ke Room builder di addMigrations(); tanpa edit ini, MigrationV5ToV6 dibuat tapi tidak jalankan -> ALTER TABLE tidak execute -> AC #3 gagal (data-integrity). Klaim eskalasi terverifikasi ke worktree: migration file benar, mapping lengkap, hanya DatabaseModule pendaftaran yang kurang. -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan: `./gradlew assembleDebug` (JAVA_HOME=/opt/homebrew/opt/openjdk@17)
- Hasil: BUILD SUCCESSFUL (41 actionable tasks). Kapt di JDK 25 (Android Studio JBR) gagal — pakai OpenJDK@17.
- File yang berubah (9, semua allowed_paths):
  - `data/entities/OrderDetailEntity.kt` — +`namaItem: String? = null`
  - `domain/model/OrderItem.kt` — +`namaItem: String? = null`
  - `data/repository/OrderRepositoryImpl.kt` — mapper toDomain() + toEntity() handle namaItem
  - `presentation/transaksi/TransaksiViewModel.kt` — snapshot `product.nama` di simpanBill()
  - `domain/usecase/GenerateStrukUseCase.kt` — prioritas `namaItem ?: deskripsi ?: productId`
  - `data/AppDatabase.kt` — version 5→6 + `MIGRATION_5_6`
  - `data/MigrationV5ToV6.kt` — baru, `ALTER TABLE order_details ADD COLUMN namaItem TEXT NULL`
  - `data/di/DatabaseModule.kt` — register `MIGRATION_5_6` di addMigrations()
- Unresolved issue (bila ada): tidak ada. Branch `feat/TASK-009-Add-Item-Name-Snapshot-android` ter-push, PR #17 merged ke TASK-001.

## Hasil QA + Ruling TL/SA

- QA: 5/6 AC PASS code-level. `./gradlew test` NO-SOURCE (0 test, repo tanpa dir test). AC #5 awalnya ambigu.
- Ruling TL/SA [2026-09-15] (Interpretasi A): AC #5 = requirement data-integrity (SDD §5.2 baris 127/167), BUKAN render list. Validasi = (a) snapshot tersimpan saat simpan, (b) rename/hapus produk tak ubah `namaItem`, (c) struk tampil nama snapshot.
- Verifikasi QA 3 titik: PASS — `TransaksiViewModel.kt:157` (`namaItem = product.nama.ifBlank { null }`), FK `SET_NULL` + mapper `toEntity`/`toDomain` persist/read `namaItem`, `GenerateStrukUseCase.kt:41` prioritas `namaItem ?: deskripsi ?: productId`.
- AC #6 terpenuhi: 9 file semua di allowed_paths (2 amend TL/SA terdokumentasi).
- TASK-009 merged via PR #17 (2026-09-15). Standing note: TASK-009-Wire-Pembayaran-Struk / Edit-Detail-Transaksi wajib baca `namaItem` (snapshot), bukan `Product.nama` live.
