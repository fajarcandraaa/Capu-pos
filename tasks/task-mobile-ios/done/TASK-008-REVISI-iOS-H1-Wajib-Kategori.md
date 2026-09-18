# Task: TASK-008

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-01.1 (Kategori Wajib)
- Allowed paths:
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Produk/TambahProdukView.swift
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Produk/UbahProdukView.swift
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Onboarding/EmptyStateView.swift
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/Domain/**
  - apps/capupos-ios/CappuPOS/Sources/Data/**
- Dependency: TASK-003, TASK-004
- Acceptance criteria:
  - [x] Tambah Produk: tombol Simpan disable bila kategori belum dipilih
  - [x] Ubah Produk: tombol Simpan disable bila kategori kosong (hasil edit)
  - [x] Onboarding (EmptyState): validasi pemilihan kategori sebelum lanjut ke step berikutnya
  - [x] Tidak ada perubahan di luar allowed paths
- Status: done

## Catatan Sesi (diisi role-agent yang mengerjakan)

- PR: #14 (merged)
- Merge commit: `3c1467d` (via PR #14)
- QA report: `apps/capupos-ios/QA-REPORT-TASK-008-iOS.md` — static + build PASS
- Command test yang dijalankan:
  - `xcodebuild -scheme CapuPOS -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build` — **BUILD SUCCEEDED**
  - `xcodebuild -scheme CapuPOS -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO test` — **gagal: Scheme CapuPOS is not currently configured for the test action** (skema tidak punya test target; bukan kegagalan kode)
- Hasil: 3 file berubah, build sukses, test action tidak tersedia di skema
- File yang berubah:
  - CappuPOS/Sources/Presentation/Produk/TambahProdukView.swift
  - CappuPOS/Sources/Presentation/Produk/UbahProdukView.swift
  - CappuPOS/Sources/Presentation/Onboarding/EmptyStateView.swift
- Unresolved issue (bila ada): Skema CapuPOS belum punya test target terdaftar, sehingga `xcodebuild test` tidak bisa dijalankan.
