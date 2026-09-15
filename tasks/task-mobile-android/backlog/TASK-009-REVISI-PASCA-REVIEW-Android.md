# Task: TASK-009-REVISI-PASCA-REVIEW-Android

- Repo: mobile-android
- Role: project-manager (dokumen ini = handoff planning, BUKAN task contract implementasi tunggal)
- Base branch: main
- Requirement ref: Seluruh temuan di `REVISION-NOTES-Android-2026-09-15.md` (review TL/SA terhadap BRD/PRD/SRS/TRD/SDD/UI-UX Flow vs kode Android TASK-001..008)
- Allowed paths:
  - tasks/task-mobile-android/backlog/TASK-009-REVISI-PASCA-REVIEW-Android.md (dokumen ini saja)
- Forbidden paths:
  - apps/capupos-android/** (PM tidak mengedit kode — task contract turunan yang mengedit, dikerjakan role-agent lain)
  - REVISION-NOTES-Android-2026-09-15.md (read-only, sudah final dari TL/SA)
- Dependency: tidak ada (dokumen planning). Task-task turunan di bawah punya dependency masing-masing — lihat tabel.
- Status: draft
<!-- Status: draft -> ready -> in-progress -> done -->

## Tujuan Dokumen

Memecah 16 usulan task revisi (`REVISION-NOTES-Android-2026-09-15.md` §"Proposed Revision Tasks") jadi
urutan eksekusi dengan prioritas, dependency, dan taksiran effort kasar. TL/SA yang menuliskan
keputusan paralel/non-paralel final per task contract turunan (field `Dependency` di masing-masing
task); PM di sini hanya menyusun urutan bisnis (mana dulu, mana nanti) dan effort kasar.

Setiap baris di bawah adalah **calon task contract terpisah** (dibuat via `./scripts/new-task.sh
TASK-009-<nama>` saat mulai dikerjakan) — dokumen ini bukan pengganti task contract individual,
melainkan peta prioritas & urutan.

## Rencana Eksekusi (urutan wajib dikerjakan sesuai nomor)

### Fase 0 — Blocker (harus selesai duluan, memblokir semua fase berikut)

| # | Task ID | Ringkasan | Dependency | Effort kasar |
|---|---------|-----------|-------------|---------------|
| 1 | TASK-009-Git-Commit-Android-Complete | Commit `apps/capupos-android/` ke git (TASK-001..008 belum pernah ter-commit) | Tidak ada | S (< 1 jam, governance saja) |
| 2 | TASK-009-Unit-Tests-Android | Unit test domain/usecase (15 use case) + core repository logic, soft/hard delete, state PO | #1 (butuh baseline ter-commit utk diff test) | L (2-3 hari, coverage luas) |

Catatan: #2 sebaiknya dikerjakan ulang/diperluas setelah fase High selesai (agar test menutupi
fix baru sekaligus), tapi skeleton test harness boleh mulai paralel dengan fase High bila TL/SA
menilai aman (lihat keputusan paralelisasi TL/SA).

### Fase 1 — High (feature gap / bug logic inti, prioritas setelah blocker)

| # | Task ID | Ringkasan | Dependency (bisnis) | Effort kasar |
|---|---------|-----------|----------------------|---------------|
| 3 | TASK-009-Fix-Reminder-First-Launch | Seed timestamp first-launch, reminder tidak muncul hari-1 (FR-12.1/BR-06) | #1 | S |
| 4 | TASK-009-Add-Item-Name-Snapshot | Field `namaItem` snapshot di `OrderDetailEntity` (SDD §5.2) — migration Room | #1 | M (perlu migration + touch struk/riwayat) |
| 5 | TASK-009-Onboarding-Form-Kategori | Field kategori + kategori-inline di `AddProductActivity`; konsolidasi form Tambah Produk (FR-01.1, UI/UX:59-60) | #1 | M |
| 6 | TASK-009-Wire-Pembayaran-Struk | Wire `PembayaranActivity` dari adapter riwayat/belum-bayar; tampilkan struk pasca bayar; guard kembalian non-tunai (FR-06, FR-06.4, FR-11.1) | #1 | M |
| 7 | TASK-009-Transaksi-Manual-Merge | Gabung item manual + produk terdaftar dalam 1 transaksi (FR-04.3) | #1 | M |
| 8 | TASK-009-Riwayat-Actions | Implement "Sembunyikan" (FR-07.3) + "Tandai Lunas" (FR-07.4) — `OrderRepository.hide()` sudah ada di DAO, tinggal expose + UI | #1 | S-M |
| 9 | TASK-009-Laporan-Filters | Date-range picker + search di Laporan (FR-09.3), reuse pola filter Riwayat | #1 | M |

Urutan internal Fase 1 disusun berdasarkan dampak user (#6 Wire-Pembayaran-Struk paling kritis —
fitur bayar tak terjangkau dari UI sama sekali — dikerjakan lebih dulu dari sisanya bila kapasitas
role-agent terbatas dan harus sekuensial). #8 dan #4 saling terkait (Riwayat menampilkan nama item)
— TL/SA yang menentukan apakah boleh paralel atau perlu urut.

### Fase 2 — Medium (polish, setelah semua High selesai)

| # | Task ID | Ringkasan | Dependency | Effort kasar |
|---|---------|-----------|-------------|---------------|
| 10 | TASK-009-Performance-Indices | Tambah `@Index` FK `orderId`/`productId` di `OrderDetailEntity`, `StockHistoryEntity` | #1 | XS (< 1 jam) |
| 11 | TASK-009-Pembayaran-Catatan | Expose field catatan di UI pembayaran (FR-06.3) | #6 (satu layar sama, hindari conflict) | XS |
| 12 | TASK-009-Edit-Detail-Transaksi | Klarifikasi intent desain (edit penuh vs status-saja) dulu ke TL/SA/UI-UX, baru implement atau update docs | #1 | S (klarifikasi) + S/M (implementasi, tergantung hasil) |
| 13 | TASK-009-Onboarding-Foto | Foto picker di onboarding (ganti placeholder Toast) | #5 (satu form yang sama) | S |

### Fase 3 — Low (housekeeping / confirmasi, bisa disisipkan kapan saja setelah #1)

| # | Task ID | Ringkasan | Dependency | Effort kasar |
|---|---------|-----------|-------------|---------------|
| 14 | TASK-009-Cleanup | Hapus `gradlew.new`; splash delay sesuai spek (`< 2 detik`); empty-state Home + CTA | #1 | XS |
| 15 | TASK-009-Export-Correctness | Reset reminder counter hanya saat share sukses; label periode di sheet Laporan Ringkas; filter `isHidden` di export (perlu konfirmasi TL/SA dulu poin filter) | #1, klarifikasi TL/SA (isHidden) | S |
| 16 | TASK-009-Data-Layer-Decisions | Bukan task kode — dokumentasikan keputusan di `DECISIONS.md`: `kategori` vs `kategoriUsaha`, `sync_status`/`profil_lokal` out-of-scope MVP1, reminder via SharedPreferences, Order domain model field exposure | Tidak ada (bisa paralel kapan saja, dikerjakan TL/SA) | XS |

## Ringkasan Prioritas & Dependency Utama

- **Blocker mutlak:** TASK-009-Git-Commit-Android-Complete (#1) — semua 15 task lain bergantung
  padanya karena tanpa commit, tidak ada baseline diff/rollback yang valid untuk task lanjutan.
- **Setelah #1**, Fase 1 (High, 7 task: #3-#9) jadi prioritas utama karena menyangkut fitur inti yang
  belum ter-wire (pembayaran, struk, riwayat, laporan, onboarding, transaksi manual).
- **Unit test (#2)** idealnya paralel/menyusul Fase 1 selesai agar sekaligus meng-cover fix baru,
  tapi skeleton awal boleh dimulai lebih awal — keputusan paralelisasi teknis diserahkan ke TL/SA.
- **Fase 2 (Medium, 4 task)** dan **Fase 3 (Low, 3 task kode + 1 task dokumentasi)** dikerjakan
  setelah Fase 1 stabil, kecuali #16 (Data-Layer-Decisions) yang murni dokumentasi dan bisa
  dikerjakan TL/SA kapan saja tanpa menunggu kode.
- Task yang menyentuh file/layar yang sama disarankan **tidak paralel** untuk hindari conflict:
  #6 & #11 (PembayaranActivity), #5 & #13 (form Tambah Produk onboarding), #4 & #8 (Riwayat +
  snapshot nama item) — keputusan final paralel/sekuensial tetap wewenang TL/SA via field
  `Dependency` di task contract masing-masing.

## Total Scope

- 16 calon task (2 blocker, 7 high, 4 medium, 3 low kode + 1 low dokumentasi).
- Effort kasar total: ~1-2 minggu kerja role-agent android-developer (asumsi sekuensial penuh);
  bisa lebih cepat bila TL/SA mengizinkan sebagian paralel pada task yang tidak bersinggungan file.

## Next Steps

1. TL/SA membuat task contract resmi (via `./scripts/new-task.sh`) untuk tiap baris di atas,
   isi `allowed_paths`/`forbidden_paths` sesuai file yang disebut di `REVISION-NOTES-Android-2026-09-15.md`,
   dan menetapkan field `Dependency` final (termasuk keputusan paralel/tidak).
2. PM memindahkan task contract dari `backlog/` ke `ready/` sesuai urutan fase di atas begitu
   dependency-nya terpenuhi.
3. #12 dan #15 butuh klarifikasi TL/SA/UI-UX sebelum masuk `ready/` (masing-masing: intent desain
   edit transaksi; kebijakan export vs transaksi tersembunyi).

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan: tidak ada (dokumen planning, tidak ada kode yang diubah).
- Hasil: dokumen rencana eksekusi TASK-009-* tersusun berdasarkan `REVISION-NOTES-Android-2026-09-15.md`.
- File yang berubah: tasks/task-mobile-android/backlog/TASK-009-REVISI-PASCA-REVIEW-Android.md (dokumen ini).
- Unresolved issue: menunggu TL/SA membuat task contract resmi per sub-task dan konfirmasi paralelisasi.
- Status: draft
