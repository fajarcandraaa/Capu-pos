# Prinsip Kerja — M2S-VSH Lite (AGENTS.md — untuk engine non-Claude Code)

Dibaca oleh semua role-agent sebelum bekerja (via CLAUDE.md untuk Claude Code,
via AGENTS.md untuk engine lain — isi sama).

## Simplification Principles (pengganti tool eksternal)

- Pastikan fitur memang perlu sebelum dibangun.
- Reuse dulu, standard library dulu, baru tulis kode baru.
- Jangan tambah dependency tanpa alasan jelas dan terukur.
- Diff seminimal mungkin yang benar-benar diperlukan untuk menyelesaikan task.
- Root-cause fix, bukan symptom patch.
- Prinsip ini TIDAK berlaku untuk security, trust-boundary validation, data-loss
  handling, accessibility, atau requirement eksplisit dari task contract.

## Rule Precedence (urutan bila terjadi konflik instruksi)

1. Human safety, legal, dan production governance.
2. Task Contract: repository, allowed_paths, forbidden_paths.
3. DECISIONS.md (keputusan arsitektur yang sudah dicatat).
4. Instruksi role-agent (system prompt role masing-masing).
5. Prompt/instruksi spesifik untuk task tersebut.

Bila konflik terjadi antar level: **berhenti, jangan memilih sendiri**, tulis
laporan konflik singkat, dan eskalasi ke TL/SA (untuk konflik teknis) atau PM
(untuk konflik scope/prioritas).

## Wajib untuk Semua Role

- Bekerja hanya pada task ID yang diberikan di task contract.
- Baca task contract dan stack-profile.md (bila relevan) sebelum mulai.
- Hanya menulis pada `allowed_paths`; `forbidden_paths` bersifat read-only.
- Tidak memperluas scope sendiri, tidak mengambil task role lain.
- Tidak mengklaim test lulus bila tidak benar-benar dijalankan — sebutkan command
  test yang dijalankan dan hasilnya apa adanya.
- Komunikasi dalam Bahasa Indonesia; identifier/kode/field API tetap sesuai
  source of truth (jangan diterjemahkan).
