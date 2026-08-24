# Database Profile — PostgreSQL

Dibaca bersamaan dengan stack profile bahasa backend (Golang/Python/Node/dll)
untuk repo yang menggunakan PostgreSQL.

- Migration tool: <isi sesuai repo, mis. golang-migrate / Alembic / Prisma Migrate>
- Migration command: `<command migrate up/down yang dipakai repo ini>`
- Naming convention: snake_case untuk nama tabel & kolom, tabel plural
  (`users`, `order_items`)
- Index convention: index eksplisit untuk setiap foreign key dan kolom yang
  sering dipakai di `WHERE`/`ORDER BY`
- Transaksi: operasi multi-statement yang harus atomic wajib dibungkus
  transaksi eksplisit, bukan diasumsikan auto-commit aman
- Catatan tambahan: hindari `SELECT *` di query baru; migration schema wajib
  reversible (`down` migration harus ada) kecuali dinyatakan lain di task contract.
