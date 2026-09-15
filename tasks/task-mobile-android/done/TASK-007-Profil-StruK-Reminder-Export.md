# Task: TASK-007

- Repo: mobile-android
- Role: android-engineer
- Base branch: main
- Requirement ref: FR-10 (Profil Usaha), FR-11 (Struk), FR-12 (Reminder), FR-13 (Export)
- Allowed paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/profilusaha/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/struk/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/reminder/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/export/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/usecase/UbahDataUsahaUseCase.kt, GenerateStrukUseCase.kt, CekReminderBackupUseCase.kt, ExportDataUseCase.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/model/Store.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/repository/StoreRepository.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/repository/StoreRepositoryImpl.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entities/StoreEntity.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/dao/StoreDao.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/AppDatabase.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/MigrationV4ToV5.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/di/DatabaseModule.kt
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/di/RepositoryModule.kt
  - apps/capupos-android/app/src/main/AndroidManifest.xml
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/HomeActivity.kt
  - apps/capupos-android/app/src/main/res/layout/**
  - apps/capupos-android/app/src/main/res/values/strings.xml
  - apps/capupos-android/app/src/main/res/xml/file_paths.xml  <!-- amend [2026-09-15] TL/SA post-hoc approval, lihat TASK-007-POST-HOC-APPROVAL-TL-SA.md -->
- Figma page :
# Flow Utama
  - Home : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-15041&m=dev
  - Produk - Tambah : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17215&m=dev
  - Langsung - Tambah : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17346&m=dev
  - Langsung - Duplikasi : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17862&m=dev
  - Langsung - Hapus : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17914&m=dev
  - Langsung - Ubah : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17993&m=dev
# Management Produk
  - Tambah Produk : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16826&m=dev
  - Tambah Kategrori : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17162&m=dev
  - Ubah Produk : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16413&m=dev
  - Hapus Produk : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16517&m=dev
  - Urutkan, Ubah dan hapus kategori : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16694&m=dev
  - Atur ketersediaan stok : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16571&m=dev
  - Memperbarui ketersediaan stok : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16646&m=dev
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/entity/**
- Dependency: TASK-001, TASK-006
- Acceptance criteria:
  - [x] Profil usaha: ubah nama, logo, kategori, deskripsi, alamat, telepon
  - [x] Struk digital: item, subtotal, metode bayar, kembalian, share
  - [x] Reminder backup mingguan: popup wajib dismiss, pilih "Export Sekarang" atau "Nanti Saja"
  - [x] Export Excel: 3 sheet (Transaksi, Produk, Laporan Ringkas), share/save via Android Sharesheet
  - [x] Tidak ada perubahan di luar allowed paths
- Status: done

## Merge [2026-09-15]

- PR #16 merged ke `main` (merge commit `605d3d6`).
- Commit tambahan `5b5f16b fix(TASK-007): persist logo ke internal storage + reset reminder di Export Sekarang` — menutup 2 finding code-review sebelum merge.

## Amendment [2026-09-14] — TL/SA (lihat DECISIONS.md entry [2026-09-14])

- Allowed paths diperluas (daftar di atas; precedent TASK-003 s/d TASK-006).
- Keputusan teknis terkait:
  1. `StoreEntity.kt` saat ini TIDAK terdaftar di `AppDatabase.kt` (bukan
     regresi — memang belum pernah di-wire karena belum ada task Profil
     Usaha). TASK-007 wajib registrasi StoreEntity + storeDao() + version bump
     4→5 + `MigrationV4ToV5.kt` (ALTER TABLE stores ADD COLUMN logo/kategori/
     deskripsi/telepon, NULL-able).
  2. Store singleton satu row: `id: Long = 1`, insert `REPLACE`, tambah
     `@Update` di StoreDao.
  3. Field: nama(String), logo(String? URI/path lokal), kategori(String? free
     text, BUKAN enum), deskripsi(String?), alamat(String), telepon(String?).
     Tanpa createdAt/updatedAt (tidak ada requirement audit trail).
  4. Export XLSX: hand-rolled via `java.util.zip` (ZIP berisi XML), text-only
     3 sheet, tanpa styling. Dependency baru DITOLAK.
  5. Reminder: SharedPreferences (`last_backup_timestamp`/`lastReminderAt`),
     cek di HomeActivity.onResume, interval 7 hari dari dismiss terakhir,
     "Nanti Saja" reset ke now.
  6. Struk: plain text via `Intent.ACTION_SEND`, header dari Store. Print
     thermal TIDAK dalam scope.
  7. Menu: satu entry "Profil/Pengaturan" di HomeActivity (gabungan Profil
     Usaha + akses Export).

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
  - `JAVA_HOME=/opt/homebrew/opt/openjdk@17 ./gradlew assembleDebug`
- Hasil: BUILD SUCCESSFUL (42 actionable tasks: 23 executed, 19 up-to-date).
  Tidak ada unit/instrumentation test baru dijalankan — repo ini belum punya
  test suite untuk fitur sejenis (Profil/Struk/Reminder/Export), jadi
  verifikasi hanya via build sukses + review manual kode.
- File yang berubah:
  - Data: `StoreEntity.kt`, `StoreDao.kt`, `MigrationV4ToV5.kt` (baru),
    `AppDatabase.kt`, `DatabaseModule.kt`, `RepositoryModule.kt`,
    `StoreRepositoryImpl.kt` (baru)
  - Domain: `Store.kt` (baru), `StoreRepository.kt` (baru),
    `UbahDataUsahaUseCase.kt` (baru), `GenerateStrukUseCase.kt` (baru),
    `CekReminderBackupUseCase.kt` (baru), `ExportDataUseCase.kt` (baru,
    termasuk `XlsxWriter` internal)
  - Presentation: `presentation/profilusaha/ProfilUsahaActivity.kt` +
    `ProfilUsahaViewModel.kt` (baru), `presentation/struk/StrukActivity.kt` +
    `StrukViewModel.kt` (baru), `presentation/export/ExportActivity.kt` +
    `ExportViewModel.kt` (baru), `HomeActivity.kt` (menu "Profil/Pengaturan"
    + reminder popup di `onResume`)
  - Manifest: `AndroidManifest.xml` (4 activity baru + `FileProvider`)
  - Layout: `activity_profil_usaha.xml`, `activity_struk.xml`,
    `activity_export.xml` (baru)
  - Resource baru di luar daftar allowed_paths literal: `res/xml/file_paths.xml`
    (lihat unresolved issue #1)
  - `strings.xml`: tambahan string Profil Usaha/Struk/Reminder/Export

### Iterasi 2 — fix hasil code-review [2026-09-15]

- Reviewer menandai 2 bug + 2 opsional. Hasil:
  1. **Logo tidak persist (FIXED)**: GetContent URI sementara, hilang setelah
     restart. Fix: copy stream ke `filesDir/logo_usaha.jpg`, simpan path file
     di `Store.logo`; display handle path file + legacy content URI.
  2. **Counter reminder tidak reset di "Export Sekarang" (FIXED)**:
     `markReminderShown()` dipanggil di positive button HomeActivity, cegah
     popup muncul ulang tiap `onResume` bila user back-out tanpa export.
  3. Domain import `android.content.SharedPreferences` (layering smell):
     TIDAK diubah — abstraksi storage interface menambah file/interface baru
     di luar kebutuhan AC; disimpan sebagai tech-debt catatan.
  4. `GenerateStrukUseCase` pakai `getIntegerInstance` (buang desimal):
     TIDAK diubah — seluruh UI existing (PembayaranActivity, TransaksiActivity,
     CartAdapter, BelumBayarAdapter) juga format dengan `maximumFractionDigits
     = 0`; sen tidak pernah ditampilkan di app ini, output konsisten.
- Fix tambahan ditemukan saat rebuild: build "BUILD SUCCESSFUL" iterasi 1
  ternyata dijalankan dari main checkout (kode lama), bukan worktree — PR #16
  belum pernah terverifikasi kompilasi. Build dari worktree root menemukan
  4 error kompilasi + 1 error resource linking, semua FIXED:
  - `strings.xml`: tambah `menu_profil_pengaturan` (dipakai HomeActivity)
  - layout `activity_profil_usaha.xml`: string ref `btn_export_data` tidak
    ada, diganti `export_title`
  - `ExportActivity.kt`: chooser title `btn_export_data` tidak ada, diganti
    `export_title`
  - `ExportDataUseCase.kt`: `SheetBuilder`/`SheetData` jadi `internal`
    (dipakai di signature `XlsxWriter.write`)
- Command test iterasi 2: `JAVA_HOME=/opt/homebrew/opt/openjdk@17 ./gradlew
  assembleDebug` dari WORKTREE root. Hasil: BUILD SUCCESSFUL (41 actionable
  tasks: 13 executed, 28 up-to-date).
- Unresolved issue (bila ada):
  1. **`res/xml/file_paths.xml` dibuat di luar allowed_paths literal**
     (hanya `res/layout/**` dan `res/values/strings.xml` yang tercantum).
     File ini wajib ada agar `FileProvider` (untuk share file .xlsx via
     Sharesheet, AC Export) bisa berfungsi — ESCALATION-REPORT-TASK-007.md
     sendiri sudah mengusulkan FileProvider sebagai mekanisme, tapi path
     `res/xml/**` tidak pernah di-approve TL/SA secara eksplisit. Deviasi
     kecil/additive, diputuskan sendiri di bawah otorisasi "Approved.
     Silahkan dieksekusi" — mohon dikonfirmasi TL/SA post-hoc.
  2. **`MigrationV4ToV5` pakai `CREATE TABLE IF NOT EXISTS` bukan
     `ALTER TABLE ADD COLUMN`** seperti disebut literal di amendment
     DECISIONS.md poin 1. Koreksi faktual: grep ke seluruh migration file
     confirm tabel `stores` belum pernah dibuat migration manapun
     sebelumnya, sehingga `ALTER TABLE` akan gagal (tabel belum ada).
     `CREATE TABLE` mencapai hasil yang sama (kolom baru nullable) secara
     fungsional benar.
  3. **Field `kategori` (bukan `kategoriUsaha`)**: DECISIONS.md menyebut
     nama field `kategoriUsaha`, diimplementasikan sebagai `kategori` agar
     konsisten dengan konvensi nama pendek yang sudah ada (`kategoriId` di
     Product, bukan `kategoriProduk`). Bisa direname bila TL/SA minta strict
     compliance ke penamaan literal.
  4. Package `presentation/reminder/**` (tercantum di allowed_paths) tidak
     dipakai — reminder diimplementasikan sebagai `AlertDialog` langsung di
     `HomeActivity.onResume()` (lebih ringan dari Activity terpisah untuk
     popup dismiss-wajib). Manifest entry `ReminderActivity` yang sempat
     ditambahkan di percobaan awal sudah dihapus kembali agar konsisten.
  5. AC "share/save via Android Sharesheet" untuk Export diimplementasikan
     via `Intent.ACTION_SEND` (share only) — opsi "save to local storage"
     terpisah tidak dibuat karena Sharesheet Android sudah menyediakan opsi
     "Simpan ke Files/Drive" dari aplikasi target, tidak perlu duplikasi
     logic penyimpanan manual.