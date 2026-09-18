# Task: TASK-010-Audit-Sinkronisasi-Task-Tracking

- Repo: task-tracking (Capu-pos root, bukan kode aplikasi)
- Role: tech-lead-system-analyst
- Base branch: main
- Requirement ref: Temuan investigasi TL/SA 2026-09-17/18 — direktori `tasks/task-mobile-android/`
  dan `tasks/task-mobile-ios/` di `main` tidak sinkron dengan progres kerja nyata. Root cause:
  branch stray `feat/amend-TASK-007-post-hoc-approval-2026-09-15` (commit `84b7dcc`) adalah
  snapshot task-board ter-update per 2026-09-16, tidak pernah di-merge ke `main`, dan sebagian
  file yang hanya tracked di branch itu hilang dari working tree `main` saat checkout balik
  (bukan data loss — recoverable via `git show 84b7dcc:<path>`). Restore parsial sudah dilakukan
  (PR #6 — TASK-009-Add-Item-Name-Snapshot.md + 3 file eskalasi), tapi cakupan masalah lebih besar.
- Allowed paths:
  - tasks/task-mobile-android/**
  - tasks/task-mobile-ios/**
  - DECISIONS.md
- Forbidden paths:
  - apps/capupos-android/** (tidak ada perubahan kode)
  - apps/capupos-ios/** (tidak ada perubahan kode)
- Dependency: tidak ada (independen dari task kode lain, bisa dikerjakan kapan saja)
- Acceptance criteria:
  - [x] Setiap file task Android (`TASK-001` s/d `TASK-009-*` dan turunannya) dibandingkan:
        versi di `84b7dcc` vs versi di `main` saat ini vs bukti merge nyata (riwayat PR/commit
        di `DECISIONS.md` dan `git log --merges`) — status akhir per file ditentukan berdasar
        bukti merge, bukan asal ambil salah satu sumber
  - [x] Setiap file task iOS (`TASK-001` s/d `TASK-011-*` dan turunannya) diperlakukan sama —
        dibandingkan `84b7dcc` vs `main` vs bukti merge nyata
  - [x] File yang terbukti sudah selesai/merged tapi masih nyangkut di `backlog/ready/in-progress`
        dipindah ke `done/` (lokasi final, bukan sekadar disalin ganda)
  - [x] File yang di `main` sudah lebih baru dari `84b7dcc` (misal `TASK-009-Cleanup.md`,
        `TASK-009-Data-Layer-Decisions.md` — di `84b7dcc` masih backlog/draft, di `main` sekarang
        sudah done) TIDAK ditimpa mundur — versi `main` yang lebih baru dipertahankan
  - [x] Tidak ada file task yang berakhir duplikat di dua lifecycle directory berbeda
        (mis. sama-sama ada di `backlog/` dan `done/`) setelah audit selesai
  - [x] Ringkasan audit (tabel: nama file, status lama, status baru, sumber keputusan) dicatat
        sebagai entry baru di `DECISIONS.md`
  - [x] Tidak ada perubahan di luar allowed paths — khususnya tidak menyentuh `apps/capupos-android/**`
        atau `apps/capupos-ios/**`
- Status: done
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan: `git log --oneline --merges --all`, `git ls-tree -r 84b7dcc/HEAD -- tasks/...`,
  `git log --format='%H %ai %s' -1 <ref> -- <file>` per-file untuk evidence commit date & lifecycle history.
- Hasil: 13 file Android + 14 file iOS direkonsiliasi (10 move antar lifecycle dir, 10 restore dari
  84b7dcc yang hilang total dari HEAD). 2 file (TASK-009-Data-Layer-Decisions Android,
  TASK-010-REVISI-iOS-H3 iOS) dipertahankan versi HEAD karena lebih baru/progress lanjut.
  Tidak ada duplikat file di dua lifecycle dir. Detail lengkap di `DECISIONS.md`.
- File yang berubah: lihat tabel keputusan di `DECISIONS.md` — seluruh perubahan di
  `tasks/task-mobile-android/**`, `tasks/task-mobile-ios/**`, `DECISIONS.md` (baru dibuat).
  Task file TASK-010 ini sendiri dipindah backlog/ → done/.
- Unresolved issue (bila ada): TASK-009-Cleanup.md dan ESKALASI-TASK-009-Cleanup-CTA-Scope.md
  sempat ada sebagai untracked file di checkout `main` (hasil sesi investigasi sebelumnya, belum
  pernah commit) — tidak masuk scope audit git-evidence based ini karena tidak ada di riwayat
  commit manapun untuk dibandingkan. Perlu dikonfirmasi terpisah oleh PM/TL apakah file tersebut
  final dan siap commit, sebelum digabung ke branch task ini.
