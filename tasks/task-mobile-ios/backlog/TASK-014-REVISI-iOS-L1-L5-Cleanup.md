# Task: TASK-014

- Repo: mobile-ios
- Role: ios-developer
- Base branch: main
- Requirement ref: Cleanup teknikal batch (L1-L5, non-fungsional/arsitektur)
- Allowed paths:
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Produk/ArurKetersediaanStokView.swift
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Transaksi/OrderDetailEditView.swift
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/UbahStatusPOUseCase.swift
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Reminder/ReminderBackupView.swift
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/ReminderBackupUseCase.swift
  - apps/capupos-ios/CappuPOS/Sources/App/AppEntry.swift
  - apps/capupos-ios/CappuPOS/Sources/Domain/UseCase/GenerateStrukUseCase.swift
  - apps/capupos-ios/CappuPOS/Sources/Presentation/Export/ExportView.swift
- Forbidden paths:
  - apps/capupos-ios/CappuPOS/Sources/Data/**
- Dependency: TASK-004, TASK-005, TASK-013
- Acceptance criteria:
  - [ ] L1: `ArurKetersediaanStokView` pindahkan mutasi `Product` langsung ke pola UseCase (konsisten fitur lain)
  - [ ] L2: `OrderDetailEditView` panggil `UbahStatusPOUseCase` (bukan repository langsung)
  - [ ] L3: reminder counter/flag diset segera setelah popup muncul (bukan hanya saat tombol ditekan) agar tahan force-quit dalam window 7 hari
  - [ ] L4: perbaiki komentar mislabel nomor FR (FR-10.3 -> FR-12.x di Reminder*, FR-10.2 -> FR-11 di GenerateStrukUseCase)
  - [ ] L5: jalankan `ExportDataUseCase.execute()` di background (Task/async), tampilkan `ProgressView` saat export berjalan, hindari blocking main thread
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: ready

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan:
- Hasil:
- File yang berubah:
- Unresolved issue (bila ada):
