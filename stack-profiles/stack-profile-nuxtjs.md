# Stack Profile — <repo-id> (Nuxt.js)

- Build: `npm run build`
- Test: `npm run test`
- Lint: `npm run lint`
- Package manager: npm/pnpm — cek lockfile yang ada di repo
- Folder convention: `pages/<route>.vue`, `components/<Feature>/`,
  `composables/use<Xxx>.ts`
- Naming convention: PascalCase untuk komponen, camelCase untuk composable
- Catatan tambahan: ikuti DESIGN.md untuk token visual; perhatikan mode
  rendering repo ini (SSR/SSG/SPA di `nuxt.config.ts`) sebelum menambah logic
  yang berasumsi salah satu mode.
