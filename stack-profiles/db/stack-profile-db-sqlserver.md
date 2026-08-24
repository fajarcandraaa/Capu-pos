# Database Profile — SQL Server

Dibaca bersamaan dengan stack profile bahasa backend (Golang/Python/Node/dll)
untuk repo yang menggunakan SQL Server.

- Migration tool: <isi sesuai repo, mis. Entity Framework Migrations / Flyway / DbUp>
- Migration command: `<command migrate up/down yang dipakai repo ini>`
- Naming convention: PascalCase untuk nama tabel & kolom (ikuti konvensi
  T-SQL/.NET yang umum di repo ini — sesuaikan bila repo pakai konvensi lain)
- Index convention: index eksplisit untuk foreign key dan kolom filter yang
  sering dipakai; perhatikan clustered vs non-clustered index saat menambah
- Catatan tambahan: gunakan stored procedure/parameterized query, hindari
  string concatenation untuk SQL (celah SQL injection); migration wajib
  reversible.
