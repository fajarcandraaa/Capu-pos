# Database Profile — NoSQL (Document/Key-Value, mis. MongoDB/DynamoDB/Redis)

Dibaca bersamaan dengan stack profile bahasa backend (Golang/Python/Node/dll)
untuk repo yang menggunakan database NoSQL.

- Engine yang dipakai: <isi, mis. MongoDB / DynamoDB / Redis>
- Schema/validation: <isi, mis. Mongoose schema / Zod validation di application
  layer — NoSQL tidak enforce schema di level DB, jadi validasi WAJIB di kode>
- Naming convention: camelCase untuk field (mengikuti konvensi JSON), collection
  name plural
- Index convention: index eksplisit untuk field yang sering dipakai query/filter
  (di NoSQL, query tanpa index bisa full-scan dan mahal)
- Catatan tambahan: karena tidak ada foreign key enforcement bawaan, konsistensi
  relasi antar dokumen/collection jadi tanggung jawab application layer — dokumentasikan
  asumsi ini di DECISIONS.md bila ada keputusan desain data yang penting.
