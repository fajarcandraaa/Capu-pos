# Task: TASK-003-Hotfix — iOS Stuck di Splash Screen

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-01 (Manajemen Produk) + temuan testing manual user 2026-09-01
- Allowed paths:
  - apps/capupos-ios/CappuPOS/Sources/App/AppEntry.swift
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/Data/Database/**
  - apps/capupos-ios/CappuPOS/Sources/Domain/**
  - apps/capupos-ios/CappuPOS/Sources/Presentation/** (kecuali disebut allowed_paths)
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
- Dependency: TASK-003 (done)
- Status: in-progress

## Problem Statement

Testing manual user 2026-09-01: app stuck permanen di splash screen (hanya teks "CappuPOS" +
loading indicator), tidak pernah lanjut ke onboarding atau halaman utama. Blocker total — app
tidak bisa dipakai sama sekali untuk kondisi data kosong (kasus umum: install baru / hasil
testing TASK-003 dengan database kosong).

## Root Cause (hasil analisa TL/SA 2026-09-01)

`AppEntry.swift` baris 20-45, method `checkIfFirstTime()`:

```swift
if useCase.isEmpty() {
    await MainActor.run { showOnboarding = true }
} else {
    await MainActor.run { showSplash = false }
}
```

Branch `isEmpty() == true` (produk kosong) hanya set `showOnboarding = true`, tidak pernah set
`showSplash = false`. Di `body`, `Group` mengecek `showSplash` lebih dulu — selama `showSplash`
tetap `true`, `showOnboarding` tidak pernah dievaluasi, splash render selamanya.

## Acceptance criteria

- [ ] Install baru / database kosong: splash berpindah ke Onboarding (bukan stuck)
- [ ] Database sudah ada produk: splash berpindah ke halaman utama seperti sebelumnya (regresi
      dicek — jangan sampai fix untuk kasus kosong merusak kasus terisi)
- [ ] Tidak ada state race/flicker (splash tidak sempat tampil ulang setelah onboarding muncul)
- [ ] Build sukses: `xcodegen generate` + `xcodebuild -project CapuPOS.xcodeproj -scheme CapuPOS
      -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator'
      build` (sebutkan hasil apa adanya di Catatan Sesi)
- [ ] Tidak ada perubahan di luar allowed paths

## Plan

1. Di branch `isEmpty() == true` (baris ~38-45), tambahkan `showSplash = false` bersamaan dengan
   `showOnboarding = true` — minimal fix, satu baris.
2. Opsional (bila waktu izin, tidak wajib): refactor dua `Bool` (`showSplash`/`showOnboarding`)
   jadi satu state enum (`.splash` / `.onboarding` / `.home`) supaya kombinasi state yang saling
   override tidak bisa terjadi lagi ke depan. Boleh diskip bila menambah risiko diff di luar scope
   minimal — catat di Catatan Sesi bila diskip.
3. Test manual 2 skenario: fresh install (DB kosong) dan DB terisi (regresi).
4. Build, verifikasi acceptance criteria, isi Catatan Sesi.

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
  - `xcodegen generate`
  - `xcodebuild -project CappuPOS/CapuPOS.xcodeproj -scheme CapuPOS -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build`
- Hasil: `** BUILD SUCCEEDED **`
- File yang berubah:
  - `apps/capupos-ios/CappuPOS/Sources/App/AppEntry.swift` (fix satu blok, +4/-1)
  - `pbxproj` di-revert (xcodegen ubah code signing jadi Automatic — di luar allowed_paths)
- Unresolved issue (bila ada):
  - SourceKit ghost diagnostic `Cannot find 'ListProdukView' in scope` (baris 64) — bukan error compile, build succeeded. Muncul karena indexing SourceKit, tidak mempengaruhi hasil.
