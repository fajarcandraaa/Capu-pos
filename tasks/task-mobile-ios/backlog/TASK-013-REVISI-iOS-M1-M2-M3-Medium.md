# Task: TASK-013

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: FR-02.2 (Drag & Drop), FR-12.1 (Install Date Reminder), FR-09.3 (Search Laporan)
- Allowed paths:
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Produk/KategoriListView.swift
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/ReminderBackupUseCase.swift
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Laporan/LaporanView.swift
  - apps/capupos-ios/CappuPOS/Sources/App/AppEntry.swift
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/Data/**
- Dependency: TASK-004, TASK-006, TASK-007
- Acceptance criteria:
  - [ ] Kategori: ganti tombol reorder chevron dengan interaksi Drag & Drop (List Move)
  - [ ] Reminder: implementasi tracking `installDate` di UserDefaults (set hanya saat pertama kali app dijalankan); hitung kemunculan reminder pertama 7 hari sejak `installDate`
  - [ ] Laporan: hubungkan `searchText` ke `.searchable` atau `TextField` di UI agar filter pencarian bisa digunakan
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: ready

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
