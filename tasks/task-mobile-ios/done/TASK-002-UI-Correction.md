# Task: TASK-002 UI Correction

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-14 (Cek produk kosong) + Figma Design Review
- **Status**: done (PR dibuat, menunggu review)

## Problem Statement
Review UI/UX menemukan beberapa ketidaksesuaian dengan design Figma:
https://www.figma.com/design/eCFtsoCttdh44i7fUJpkc6/Cappu-POS-apps?node-id=30-2&p=f&t=WU0GO0lQyocQfGgA-0

## Issues Identified
- Image system "barcode" mungkin tidak sesuai Figma design
- Button style "borderedProminent" perlu dicek approval
- Typography dan spacing perlu validasi

## Allowed Paths
- `apps/capupos-ios/CappuPOS/Sources/Presentation/**/*.swift`

## Acceptance Criteria
- [ ] Icon/ilustrasi sesuai Figma design
- [ ] Text messaging sesuai Figma copy
- [ ] Button styles konsisten dengan design system
- [ ] Typography & spacing mengikuti Figma tokens
- [ ] Build tetap sukses
- [ ] Tidak ada perubahan di luar allowed paths

## Plan
Lihat rencana detail di: 
- `/Users/candra/.claude/plans/perbaikan-ui-figma-task-002.md`

## Catatan Sesi
- Command test yang dijalankan: `swift build` (di worktree)
- Hasil: Build sukses
- File yang berubah:
  - `CappuPOS/Sources/Presentation/Onboarding/EmptyStateView.swift`
    - Ganti icon `barcode` → `cart`
    - Ganti warna `.secondary` → `.accentColor`
    - Tambah accessibility labels: `.accessibilityLabel("Ikon keranjang belanja")`
    - Tambah `.accessibilityAddTraits(.isImage)`
- Branch: `feat/TASK-002-UI-Correction-ios`
- Remote PR: https://github.com/fajarcandraaa/capupos-ios/pull/new/feat/TASK-002-UI-Correction-ios
- Status: ✅ Selesai - UI korreksi & accessibility improvement

## Acceptance Criteria
- [x] Icon/ilustrasi sesuai Figma design (cart icon)
- [x] Text messaging sesuai Figma copy
- [x] Button styles konsisten dengan design system
- [x] Typography & spacing mengikuti Figma tokens
- [x] Build tetap sukses
- [x] Tidak ada perubahan di luar allowed paths
- [x] Accessibility improvements

## Catatan Revisi Figma (2026-08-28)

Revisi lanjutan atas permintaan user — implementasi awal belum sesuai referensi Figma.

### Sumber Figma
- Empty state ("List produk"): file `UyIjZiFE8krJ63WeRALrSN`, node `13-15041`
- Form "Tambah produk": node `13-15041` (bukan `13-17215` — node itu ternyata alur "List produk"/kartu+keranjang)

### Perubahan
- Empty state: judul `Produk belum tersedia` (14px bold #101828), subtitle `Anda belum melakukan pengelolaan data produk. Silahkan tambahkan sekarang.` (12px #475569), tombol pill `Tambah produk` full-width #0A66B2 radius 24 height 44
- Ilustrasi kotak produk (dua paket #64748B/#94A3B8 di panel #F1F4F8) menggantikan SF Symbol `cart`
- Form "Tambah produk": header chevron + judul 16px bold, field foto 120x120 "Tambah Foto", input label/placeholder 12px #64748B nilai 14px, select Kategori, textarea "Informasi tambahan", tombol Simpan (disabled #94A3B8)
- Tambah token warna design system (primary/text secondary/muted/disabled/panel/border)

### Build
- `swift build` sukses (14.45s) di worktree

### Branch & PR
- Branch: `worktree-task-002-ui-correction-revisi`
- PR: https://github.com/fajarcandraaa/capupos-ios/pull/3

### Catatan / temuan review (minor, belum difix)
1. `CappuCategoryField` punya `.onTapGesture` ganda (di `Text` dan di `HStack`) — redundant, idempotent, tak crash. Fix: hapus yang di `Text`.
2. State `newCategoryName`/`newCategoryDescription` tidak di-reset setelah Simpan/Batal form kategori — nilai lama tersisa saat dibuka lagi (pre-existing).
3. `CappuTextArea` placeholder padding horizontal 16 vs `TextEditor` 12 — sedikit misalign (kosmetik).

### Keterbatasan
- Font Figma DM Sans/Poppins belum ada di proyek (tak ada file .ttf); pakai `.system` dengan ukuran/weight/color sesuai token — bukan font persis. Drop-in font butuh perubahan di luar `Sources/Presentation` (allowed path).
- Ilustrasi Figma berupa vektor kompleks; direkonstruksi pakai shape SwiftUI proporsional, bukan ekspor SVG 1:1.