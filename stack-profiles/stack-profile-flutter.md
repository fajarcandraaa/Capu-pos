# Stack Profile — <repo-id> (Flutter — Android & iOS)

- Build: `flutter build apk` (Android) / `flutter build ios` (iOS)
- Test: `flutter test`
- Lint: `flutter analyze`
- Package manager: pub (`pubspec.yaml`)
- Folder convention: `lib/features/<feature>/{presentation,domain,data}`
- Naming convention: PascalCase untuk class/widget, camelCase untuk fungsi/variabel,
  nama file snake_case
- Catatan tambahan — PENTING: Flutter adalah satu codebase untuk Android & iOS.
  Task contract untuk repo Flutter sebaiknya di-assign ke SATU role
  (Android Developer **atau** iOS Developer, ditentukan TL/SA per project —
  bukan dipecah per platform), supaya tidak ada dua role menulis file yang
  sama secara paralel. Kalau kedua role tetap dibutuhkan (mis. ada native
  module per platform), pisahkan scope lewat `allowed_paths`: role Android
  hanya menyentuh `android/**`, role iOS hanya menyentuh `ios/**`, dan
  keduanya read-only terhadap `lib/**` kecuali task contract menyatakan lain.
