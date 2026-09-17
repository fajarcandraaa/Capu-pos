# Task: TASK-008

- Repo: mobile-android
- Role: android-engineer
- Base branch: main
- Requirement ref: FR-01.1, FR-01.2 (Manajemen Produk) — konsistensi kategori dengan FR-02 (Manajemen Kategori, TASK-004)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/TambahProdukActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/TambahProdukViewModel.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/ProductDetailActivity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/ProductDetailViewModel.kt
  - apps/capupos-android/app/src/main/res/layout/activity_tambah_produk.xml
  - apps/capupos-android/app/src/main/res/layout/activity_product_detail.xml
  - apps/capupos-android/app/src/main/res/values/strings.xml
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/AppDatabase.kt (khusus untuk seed default kategori — lihat Acceptance Criteria)
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/KategoriConstants.kt (hapus file ini, jangan diedit)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/SimpanProdukUseCase.kt
- Dependency: TASK-004 (Manajemen Kategori-Stok) — ✅ **sudah merged ke `main` repo `apps/capupos-android`** (commit `c4c65be` Merge PR #11). Base branch siap.

## Context

TASK-004 implementasi kategori dinamis dari database (tabel `categories`, `CategoryRepository`). Home screen sudah pakai `CategoryRepository.getKategories()` (chip dinamis). Tapi form tambah/edit produk masih hardcode kategori via `KategoriConstants` (3 entries: Makanan/Minuman/Penyedap). Kategori baru yang ditambah lewat TASK-004 tidak muncul di dropdown form produk — bug usability lintas fitur.

## Root Cause — Legacy kategoriId Mismatch (temuan PM, wajib ditangani)

`KategoriConstants.kt` hardcode id **string literal** (`"makanan"`, `"minuman"`, `"penyedap"`). Produk lama menyimpan `kategoriId` dengan nilai ini. Tapi `CategoryEntity` (TASK-004) generate id via `UUID.randomUUID()` — kategori baru tidak akan pernah punya id `"makanan"`. Dua konsekuensi:

1. Produk lama tidak resolve ke kategori manapun di DB kalau tabel `categories` diisi murni via TASK-004 flow (tambah kategori manual, semua UUID).
2. Fresh install: tabel `categories` kosong (tidak ada seed) → dropdown form produk kosong sampai user bikin kategori manual dulu.

**Keputusan resolusi (PM+user, jangan diubah tanpa eskalasi TL/SA)**: seed 3 kategori default saat inisialisasi DB, dengan `id` eksplisit string lama (bukan UUID) — `"makanan"` → "Makanan", `"minuman"` → "Minuman", `"penyedap"` → "Penyedap". Ini membuat produk legacy langsung resolve, dan fresh install tidak kosong.

## Requirement

Ganti hardcode `KategoriConstants` dengan kategori dinamis dari DB di:
- `TambahProdukActivity` → dropdown kategori ke-populate dari `CategoryRepository`
- `ProductDetailActivity` → dropdown kategori ke-populate dari `CategoryRepository`

## Acceptance Criteria

- [ ] `TambahProdukViewModel` inject `CategoryRepository`, tambah `StateFlow<List<Kategori>>`, load kategori saat init (ViewModel ini sebelumnya tanpa StateFlow — tambahkan pola sesuai `HomeViewModel`/TASK-004)
- [ ] `ProductDetailViewModel` inject `CategoryRepository`, load kategori + load produk by ID (pola sudah ada via `loadProduct`)
- [ ] `TambahProdukActivity` bind kategori spinner dari ViewModel state (bukan `KategoriConstants`); spinner item berbasis `Kategori` object (bukan `String`), bukan lagi map nama↔id manual; submit tetap via `SimpanProdukUseCase`
- [ ] `ProductDetailActivity` bind kategori spinner dari ViewModel state; edit tetap via usecase yang ada (`UbahProdukUseCase`)
- [ ] **Seed default kategori**: saat `categories` kosong (fresh install / upgrade dari versi tanpa kategori), insert 3 kategori default dengan id eksplisit `"makanan"`, `"minuman"`, `"penyedap"` — bukan `UUID.randomUUID()`. Seed wajib idempotent (cek kosong dulu, jangan insert ulang tiap start).
- [ ] Produk dengan `kategoriId` lawas (`"makanan"`/`"minuman"`/`"penyedap"`) tetap ter-resolve dan bisa dibuka/diedit di `ProductDetailActivity` (verifikasi lewat seed di atas, bukan fallback map terpisah)
- [ ] Tambah produk dengan kategori baru (dibuat via TASK-004 `KategoriListActivity`) langsung muncul & bisa dipilih di form
- [ ] `KategoriConstants.kt` dihapus (pastikan tidak ada referensi lain sebelum hapus — cek dengan grep)
- [ ] Tidak ada perubahan di luar allowed paths

## Catatan Implementasi

- `Kategori.kt` domain model + `CategoryRepository` interface sudah ada di TASK-004 — reuse, jangan buat ulang.
- Pola StateFlow + collect UI sudah ada di codebase (`HomeViewModel`/`HomeActivity` dari TASK-004) — ikuti pola yang sama.
- Case penting: spinner item == `Kategori` object (bukan string) — mapping ke domain model atau buat adapter/wrapper untuk display name.
- Lokasi seed default: taruh di `AppDatabase.kt` (callback `onCreate`/`onOpen`) atau di `CategoryRepositoryImpl` — pilih yang paling minim blast radius; koordinasi dengan TL/SA kalau ragu pola mana yang konsisten dengan arsitektur existing.
- Test: pastikan produk lama tetap bisa buka/edit (`kategoriId` lama resolve ke UI), tambah produk dengan kategori baru langsung jalan, fresh install (DB kosong) spinner tidak kosong.

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
  - `./gradlew :app:compileDebugKotlin` — BUILD SUCCESSFUL
  - `./gradlew :app:assembleDebug` — BUILD SUCCESSFUL
- Hasil: compile + assemble debug lulus. Kategori dropdown di form tambah/edit produk kini dari DB (`CategoryRepository`), spinner item berbasis `Kategori` object. Seed 3 kategori default id eksplisit (`makanan`/`minuman`/`penyedap`) via `RoomDatabase.Callback` — idempotent, cover fresh install + upgrade.
- File yang berubah:
  - `app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/TambahProdukViewModel.kt` — inject `CategoryRepository`, `StateFlow<List<Kategori>>`, load saat init
  - `app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/ProductDetailViewModel.kt` — inject `CategoryRepository`, `StateFlow<List<Kategori>>`, load saat init
  - `app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/TambahProdukActivity.kt` — bind spinner dari ViewModel, adapter custom `ArrayAdapter<Kategori>` (tampil `nama`), submit pakai id object
  - `app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/ProductDetailActivity.kt` — bind spinner, resolve kategori by id, edit pakai id object
  - `app/src/main/java/com/mindtoscreen/cappupos/data/AppDatabase.kt` — `RoomDatabase.Callback` seed default kategori (onCreate + onOpen, cek kosong dulu)
  - `app/src/main/java/com/mindtoscreen/cappupos/data/di/DatabaseModule.kt` — wire `.addCallback(AppDatabase.CALLBACK)` (1 baris, di luar allowed_paths — **disetujui user** via opsi A sebelum eksekusi)
  - `app/src/main/java/com/mindtoscreen/cappupos/presentation/produk/KategoriConstants.kt` — dihapus (grep verifikasi, tak ada referensi kode tersisa)
- Unresolved issue (bila ada): tidak ada.

- Status: done
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->
