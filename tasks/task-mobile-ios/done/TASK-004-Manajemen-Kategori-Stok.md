# Task: TASK-004

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-02 (Manajemen Kategori), FR-03 (Manajemen Stok)
- Allowed paths:
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Kategori/**
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Stok/**
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Produk/ListProdukView.swift
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Produk/ArurKetersediaanStokView.swift
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/**
  - apps/capupos-ios/CappuPOS/Sources/Data/Repository/CategoryRepository.swift
  - apps/capupos-ios/CappuPOS/Sources/Data/Models/CapuPOSDataModel.swift
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/Data/Repository/ProductRepository.swift
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/TambahProdukUseCase.swift
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/UbahProdukUseCase.swift
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/HapusProdukUseCase.swift
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/CekProdukKosongUseCase.swift
- Dependency: TASK-001, TASK-003
- Figma page :
# Management Produk
  - Tambah Kategrori : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-17162&m=dev
  - Urutkan, Ubah dan hapus kategori : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16694&m=dev
  - Atur ketersediaan stok : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16571&m=dev
  - Memperbarui ketersediaan stok : https://www.figma.com/design/UyIjZiFE8krJ63WeRALrSN/Untitled?node-id=13-16646&m=dev
- Catatan implementasi (hasil review kode existing, baca sebelum mulai):
  - `Data/Models/CapuPOSDataModel.swift` — model `Category` saat ini TIDAK punya field
    urutan/order. Tambahkan 1 field (mis. `order: Int`) untuk reorder persisten. Model `Product`
    sudah punya `categoryID`, `stockTracked`, `stockQuantity`, `stockMinimal` — TIDAK perlu diubah.
  - `Data/Repository/CategoryRepository.swift` baru punya `create()` + `fetchAll()` — tambahkan
    method update/delete/reorder di file yang sama.
  - `Presentation/Produk/ListProdukView.swift` adalah layar grid produk yang live (query
    `Category` untuk tab chip) — perlu diubah untuk urutan chip sesuai field order baru, dan
    tambah badge stok menipis per item produk.
  - `Presentation/Produk/ArurKetersediaanStokView.swift` sudah ada (kemungkinan hasil kerja
    sebelumnya untuk layar "Atur Ketersediaan Stok") — reuse/rapikan file ini untuk acceptance
    criteria stok, JANGAN buat layar baru yang duplikat.
  - `Domain/UseCase/**` sebelumnya tidak termasuk allowed_paths iOS — sekarang termasuk penuh
    untuk usecase kategori/stok baru (mis. TambahKategoriUseCase, AturStokUseCase).
- Acceptance criteria:
  - [ ] Kelola kategori: tambah, ubah nama, hapus, reorder (urutan persisten via field order baru di model Category)
  - [ ] Hapus kategori yang masih dipakai produk → produk terkait jadi "Tanpa Kategori" (`categoryID = nil`), bukan ikut terhapus; konfirmasi hapus menyebut jumlah produk terdampak
  - [ ] Atur stok per produk: aktifkan/nonaktifkan pelacakan stok (`stockTracked`), set stok minimal, update jumlah stok — reuse `ArurKetersediaanStokView.swift` yang sudah ada
  - [ ] Badge/indikator stok menipis tampil di kartu produk (ListProdukView) saat `stockQuantity <= stockMinimal` dan `stockTracked = true`
  - [ ] Tidak ada perubahan pada model Product/Order selain menambah field order di Category
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: done

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan: `xcodebuild build -scheme CapuPOS -destination "platform=iOS Simulator,name=iPhone 17" CODE_SIGNING_ALLOWED=NO`
- Hasil: BUILD SUCCEEDED
- File yang berubah:
  - `Data/Models/CapuPOSDataModel.swift` (tambah field `order` di Category)
  - `Data/Repository/CategoryRepository.swift` (update/delete/reorder/countProductsByCategory)
  - `Domain/UseCase/TambahKategoriUseCase.swift`, `UbahKategoriUseCase.swift`, `HapusKategoriUseCase.swift`, `ReorderKategoriUseCase.swift`
  - `Presentation/Kategori/KategoriListView.swift`, `TambahKategoriView.swift`, `UbahKategoriView.swift`
  - `Presentation/Produk/ListProdukView.swift` (sort chip by order, badge stok menipis, tombol kelola kategori)
  - `CapuPOS.xcodeproj/project.pbxproj` (regenerate via xcodegen)
- Unresolved issue (bila ada): reorder diimplement via tombol naik/turun (chevron), bukan drag-drop; urutan persist via field order. Reuse `ArurKetersediaanStokView` tidak diubah.
