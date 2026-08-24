# M2S-VSH Lite — Control Repo Scaffold (v0.2.0)

Ini adalah scaffold implementasi dari dokumen `M2S-VSH-Lite-v0.2.0-Draft.md`.
Isi folder ini ditaruh sebagai **control repo** (repo terpisah dari repo aplikasi),
atau di-merge ke repo utama kalau Anda cuma punya satu repo.

## Isi Folder

```text
m2s-vsh-lite/
├── repos.example.yaml        # Repo Registry — daftar semua repo yang dikelola
├── DECISIONS.md              # Governance log — diisi manual oleh TL/SA
├── CLAUDE.md                 # Prinsip simplification + rule precedence (dibaca semua agent)
├── AGENTS.md                 # Sama isinya, untuk engine non-Claude (OpenCode, dll)
├── tasks/
│   └── TASK-TEMPLATE.md      # Template Task Contract
├── stack-profiles/
│   ├── stack-profile-TEMPLATE.md
│   ├── stack-profile-node.md              (backend — Node.js)
│   ├── stack-profile-golang.md            (backend — Golang)
│   ├── stack-profile-python.md            (backend — Python)
│   ├── stack-profile-react.md             (frontend — React)
│   ├── stack-profile-nextjs.md            (frontend — Next.js)
│   ├── stack-profile-nuxtjs.md            (frontend — Nuxt.js)
│   ├── stack-profile-vue.md               (frontend — Vue)
│   ├── stack-profile-kotlin-android.md    (Android — Kotlin native)
│   ├── stack-profile-swift-ios.md         (iOS — Swift native)
│   ├── stack-profile-flutter.md           (Android & iOS — Flutter, satu codebase)
│   └── db/
│       ├── stack-profile-db-postgresql.md
│       ├── stack-profile-db-mysql.md
│       ├── stack-profile-db-sqlserver.md
│       └── stack-profile-db-nosql.md
│       (Database profile dibaca BERSAMAAN dengan stack profile bahasa —
│        bukan repo/role terpisah, karena tidak ada role Database Engineer
│        tersendiri di roster ini)
├── .claude/agents/            # 11 role-agent, format Claude Code
├── .opencode/agent/           # 11 role-agent, format OpenCode
└── scripts/
    ├── new-task.sh            # Bikin task contract baru dari template
    └── new-worktree.sh        # Bikin worktree isolated untuk satu task
```

## Cara Pakai (Setup Awal)

> Untuk contoh alur nyata end-to-end (dari brief/dokumen `project-document-builder`
> sampai fitur selesai di-merge), lihat **`WALKTHROUGH.md`** — studi kasus lengkap
> dengan contoh isi task contract, entry `DECISIONS.md`, dan urutan eksekusi paralel.

1. **Salin folder ini** ke lokasi control repo Anda (atau init repo baru khusus untuk ini).
2. **Copy `repos.example.yaml` → `repos.yaml`**, isi dengan repo nyata Anda:
   ```bash
   cp repos.example.yaml repos.yaml
   ```
3. **Untuk tiap repo aplikasi**, copy stack profile yang sesuai ke root repo tsb sebagai
   `stack-profile.md`, lalu sesuaikan command build/test/lint-nya dengan repo Anda.
   Kalau stack-nya belum ada contohnya, copy `stack-profile-TEMPLATE.md` dan isi manual.
   Kalau repo tsb punya database, copy juga profile dari `stack-profiles/db/` sebagai
   `database-profile.md` di root repo yang sama — Backend/DevOps role membaca
   keduanya (stack profile bahasa + database profile) sebelum bekerja.
4. **Copy `.claude/agents/` dan/atau `.opencode/agent/`** ke tiap repo aplikasi yang
   akan dikerjakan oleh role-agent (atau simpan di control repo kalau engine Anda
   mendukung agent lintas-repo — sesuaikan dengan cara kerja tool yang dipakai).
5. **Jalankan 9Router**, buat composition per role (`role-pm`, `role-backend`, dst —
   lihat daftar lengkap di bagian bawah README ini), lalu arahkan execution engine ke
   endpoint 9Router (lihat bagian 2.4 dokumen arsitektur).
6. **Mulai dengan 1 task nyata** — pakai `scripts/new-task.sh` untuk bikin task contract,
   `scripts/new-worktree.sh` untuk isolasi kerja, lalu jalankan role-agent yang sesuai.

## Daftar Model Alias yang Perlu Dibuat di 9Router

| Alias | Role |
|---|---|
| `role-pm` | Project Manager |
| `role-tlsa` | Technical Lead & System Analyst |
| `role-uiux` | UI/UX Designer |
| `role-backend` | Backend Engineer |
| `role-frontend` | Frontend Engineer |
| `role-android` | Android Developer |
| `role-ios` | iOS Developer |
| `role-qa` | QA Engineer |
| `role-reviewer` | Code Reviewer |
| `role-devops` | DevOps & Release |
| `role-writer` | Technical Writer |

## Catatan

- File-file ini adalah **starting point**, bukan sistem yang otomatis berjalan sendiri.
  PM/TL-SA masih ditulis sebagai role-agent, tapi *siapa yang memicu sesi Claude Code/
  OpenCode dengan role tsb* tetap manual (dijalankan oleh Anda) sampai Anda menemukan
  kebutuhan otomasi nyata — sesuai prinsip rollout minimal di dokumen v0.2.0.
- Jangan tambah mekanisme baru (hook, CI gate, dsb) sebelum benar-benar kepentok
  masalahnya di task nyata.
