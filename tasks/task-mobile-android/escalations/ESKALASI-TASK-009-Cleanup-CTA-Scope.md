# Eskalasi — TASK-009-Cleanup: CTA Empty-State Butuh File di Luar allowed_paths

**Task ID:** TASK-009-Cleanup
**Ditujukan ke:** Tech-Lead / System Analyst (TL/SA)
**Role pelapor:** android-developer
**Tanggal:** 2026-09-16
**Status:** RESOLVED — Opsi A disetujui, HomeActivity.kt diamend ke allowed_paths, button CTA wired (PR #20 merged 9dee5f7)

---

## Ringkasan

AC #3 "Empty-state Home punya CTA jelas (PRD:106)" tidak bisa dipenuhi fungsional
tanpa edit `HomeActivity.kt`. Task contract `allowed_paths` hanya:

- `gradlew.new` (dihapus)
- `MainActivity.kt`
- `activity_home.xml`

Button CTA ditambahkan ke `activity_home.xml` (dalam allowed_paths), tapi
click handler wajib hidup di `HomeActivity.kt` (di luar allowed_paths).
Hasil sekarang: tombol tampil, klik tidak berbuat apa-apa.

## Fakta Code

1. **Button CTA sudah ada di layout** — `activity_home.xml` id `@+id/btn_empty_state_cta`.
2. **Empty state toggled di `HomeActivity.observeState()`** (line 206):
   `binding.emptyState.isVisible = isEmpty`.
3. **FAB tambah produk sudah wired di `HomeActivity.setupFAB()`** (line 171-175):
   `binding.fabTambah.setOnClickListener { startActivity(Intent(this, TambahProdukActivity::class.java)) }`.
4. **`HomeActivity.kt`** tidak masuk forbidden_paths (forbidden = `data/**` + `domain/**`),
   tapi juga tidak masuk allowed_paths.
5. Tidak ada cara wire klik tanpa edit `HomeActivity.kt`: `android:onClick` tetap
   butuh method di Activity; data binding tidak dipakai (view binding `ActivityHomeBinding`).

## Dua Opsi

| Opsi | Aksi | Konsekuensi |
|------|------|-------------|
| A (rekomendasi) | Amend allowed_paths + `HomeActivity.kt`, tambah `binding.btnEmptyStateCta.setOnClickListener` → `TambahProdukActivity` (identik FAB) | CTA fungsional, AC #3 terpenuhi penuh, root-cause fix |
| B | Terima button UI-only, catat unresolved | CTA visual tanpa aksi, langgar maksud PRD:106 "CTA jelas", AC #3 setengah jalan |

## Rekomendasi

Opsi A. Satu blok tambahan di `setupFAB()`, reuse intent yang sudah ada, diff
minimal (+3 baris). Tidak menyentuh data/domain layer.

Butuh keputusan TL/SA sebelum amend task contract.

---

## Keputusan TL/SA [2026-09-16]

**Status: RESOLVED — Opsi A disetujui.**

Verifikasi langsung ke worktree `feat-TASK-009-Cleanup-android` mengonfirmasi
klaim 100%: button `btn_empty_state_cta` ada di layout (line 237-244, style
`Widget.Cappu.Button.Pill`), belum wired di `HomeActivity.kt` (grep kosong),
`setupFAB()` (line 171-175) hanya wire FAB, import `TambahProdukActivity`
sudah ada (line 25).

- `HomeActivity.kt` ditambahkan ke allowed_paths (amend TL/SA) — lihat task
  contract `TASK-009-Cleanup.md` + `DECISIONS.md` §[2026-09-16].
- **android-developer: LANJUTKAN** — tambah
  `binding.btnEmptyStateCta.setOnClickListener { startActivity(Intent(this,
  TambahProdukActivity::class.java)) }`, identik pola FAB. Tidak boleh
  menyentuh `data/**` / `domain/**` (tetap forbidden).
- AC #3 dan AC #4 di task contract di-reset ke `[ ]` — wire selesai =
  re-verify keduanya, isi Catatan Sesi (command test + hasil apa adanya).
