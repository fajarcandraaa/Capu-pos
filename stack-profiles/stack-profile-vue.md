# Stack Profile — <repo-id> (Vue)

- Build: `npm run build`
- Test: `npm run test:unit`
- Lint: `npm run lint`
- Package manager: npm/pnpm — cek lockfile yang ada di repo
- Folder convention: `src/features/<feature>/{components,composables,api}`
- Naming convention: PascalCase untuk komponen (`.vue`), camelCase untuk
  composable (`useXxx.ts`)
- Catatan tambahan: gunakan Composition API (`<script setup>`) bila project
  sudah memakainya; jangan campur Options API baru ke file yang sudah
  Composition API kecuali mengikuti pola file tsb.
