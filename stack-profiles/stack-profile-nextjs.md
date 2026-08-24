# Stack Profile — <repo-id> (Next.js)

- Build: `npm run build`
- Test: `npm run test`
- Lint: `npm run lint`
- Package manager: npm/pnpm — cek lockfile yang ada di repo
- Folder convention: `app/<route>/page.tsx` (App Router) atau
  `pages/<route>.tsx` (Pages Router) — cek struktur repo yang sudah ada
  sebelum menambah folder baru
- Naming convention: PascalCase untuk komponen, camelCase untuk hook (`useXxx`)
- Catatan tambahan: ikuti DESIGN.md untuk token visual; perhatikan
  Server Component vs Client Component (`"use client"`) — jangan menambah
  `"use client"` tanpa alasan bila komponen bisa tetap server-side;
  data-fetching ikuti pola yang sudah ada di repo (Server Actions/fetch/SWR).
