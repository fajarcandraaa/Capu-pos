# Laporan Eskalasi — ke PM

**Dari:** tech-lead-system-analyst
**Kepada:** project-manager
**Tanggal:** 2026-09-15
**Subjek:** Permintaan pembuatan task revisi iOS pasca-review keseluruhan TASK-001 s/d TASK-007

---

## Ringkasan

Seluruh task iOS (TASK-001–TASK-007) telah diklaim selesai. Review menyeluruh codebase terhadap dokumentasi di `@docs/` (SRS, UI/UX Flow, SDD, DECISIONS.md) menemukan **15 temuan mismatch** (6 High, 4 Medium, 5 Low — lihat detail lengkap di `REVISION-NOTES-iOS-2026-09-15.md`).

Tidak ada Blocker, namun 6 temuan High adalah requirement SRS yang tidak terpenuhi end-to-end — mayoritas berupa fitur yang unit-code-nya ada tapi tidak ter-wire ke user (dead code) atau gate verifikasi yang tidak pernah ditutup.

## Permintaan

Mohon dibuatkan **task contract revisi baru** (di bawah `tasks/task-mobile-ios/`) untuk item berikut. Saya sarankan grouping:

### Task revisi yang disarankan (prioritas)

| # | Judul usulan | Severity | FR terkait | Rujukan detail |
|---|---|---|---|---|
| R1 | Wajibkan kategori di Tambah/Ubah/Onboarding produk | High | FR-01.1 | H1 |
| R2 | Wire struk digital ke flow pembayaran + aksi Cetak di Detail Transaksi | High | FR-06.4, FR-11, UI/UX 5.13 | H2 + H6 |
| R3 | Verifikasi runtime file .xlsx export (buka di Excel/Numbers) | High | FR-13.1/13.3 | H3 |
| R4 | Tambah field email/no_hp nullable ke model Store | High | NFR 5.2 | H4 |
| R5 | Tutup AC TASK-001 yang belum tercentang (simulator + allowed_paths) | High/Medium | TASK-001 | H5 + M4 |
| R6 | Reorder kategori jadi drag & drop (atau amend DECISIONS) | Medium | FR-02.2 | M1 |
| R7 | Reminder backup: hitung hari pertama dari install date | Medium | FR-12.1 | M2 |
| R8 | Wire search box di layar Laporan | Medium | FR-09.3 | M3 |
| R9 | Cleanup teknikal batch (L1–L5: use-case bypass, mislabel FR, blocking main thread) | Low | — | L1–L5 |

### Catatan untuk PM

- R1–R4 blocking rilis; R5 governance gap yang menular ke semua task di atasnya.
- R6–R8 bisa digabung jadi satu task "Medium revisi" bila ingin kurangi jumlah task.
- R9 opsional; bisa ditunda atau digabung.
- Detail file:line dan alasan lengkap ada di `REVISION-NOTES-iOS-2026-09-15.md`.

## Referensi dokumen

- `REVISION-NOTES-iOS-2026-09-15.md` — catatan revisi lengkap (semua 15 temuan + FR yang sudah sesuai).
- Source of truth: `docs/06. SRS`, `docs/05. UI:UX Flow.md`, `docs/08. SDD`, `DECISIONS.md`.
- Kode iOS: `apps/capupos-ios/CappuPOS/Sources/`.

---

**Tindak lanjut yang diminta:** buat task contract baru + assign role-agent yang relevan. Konfirmasi balik bila ada scope yang perlu diklarifikasi (misal R6: amend spec vs implementasi drag & drop).
