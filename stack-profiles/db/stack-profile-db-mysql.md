# Database Profile — MySQL

Dibaca bersamaan dengan stack profile bahasa backend (Golang/Python/Node/dll)
untuk repo yang menggunakan MySQL.

- Migration tool: <isi sesuai repo, mis. golang-migrate / Alembic / Flyway>
- Migration command: `<command migrate up/down yang dipakai repo ini>`
- Naming convention: snake_case untuk nama tabel & kolom, tabel plural
- Storage engine: InnoDB (default) — jangan ubah ke MyISAM tanpa alasan eksplisit
- Index convention: index eksplisit untuk setiap foreign key dan kolom yang
  sering dipakai di `WHERE`/`JOIN`
- Catatan tambahan: perhatikan charset/collation (`utf8mb4`) konsisten di semua
  tabel baru; hindari `SELECT *` di query baru; migration wajib reversible.
