# Stack Profile — <repo-id> (Python)

- Build: `pip install -r requirements.txt` (atau `poetry install` bila pakai Poetry)
- Test: `pytest`
- Lint: `ruff check .` (atau `flake8` bila project belum migrasi)
- Package manager: pip/Poetry — cek `pyproject.toml` atau `requirements.txt`
  mana yang jadi source of truth di repo ini
- Folder convention: `app/<feature>/{routes,services,models}.py` (FastAPI/Flask)
  atau `<project>/apps/<feature>` (Django)
- Naming convention: snake_case untuk fungsi/variabel/file, PascalCase untuk class
- Database: lihat `stack-profiles/db/stack-profile-db-<engine>.md` sesuai
  database yang dipakai repo ini
- Catatan tambahan: type hint wajib untuk fungsi baru; jangan menambah
  dependency baru bila fungsinya sudah tercover oleh standard library atau
  dependency yang sudah ada di `requirements.txt`/`pyproject.toml`.
