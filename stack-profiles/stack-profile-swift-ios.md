# Stack Profile — mobile-ios (Swift)

- Build: `xcodebuild -scheme <SchemeName> -configuration Debug build`
- Test: `xcodebuild -scheme <SchemeName> test`
- Lint: `swiftlint`
- Package manager: Swift Package Manager (SPM)
- Folder convention: `Sources/Features/<Feature>` (pola MVVM)
- Naming convention: PascalCase untuk type, camelCase untuk fungsi/variabel
- Catatan tambahan: pastikan SwiftUI preview tetap jalan setelah perubahan; jangan
  menambah dependency CocoaPods baru bila SPM cukup.
