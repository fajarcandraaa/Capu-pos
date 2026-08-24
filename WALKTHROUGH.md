# Contoh Penggunaan End-to-End — Studi Kasus "Cappu POS"

Dokumen ini contoh alur nyata dari scaffold M2S-VSH Lite, dari brief awal
sampai fitur selesai di-merge. Contoh kasus: **Cappu POS**, aplikasi POS
mobile native Android (Kotlin) & iOS (Swift), dokumen pre-development
dihasilkan lewat skill `project-document-builder`.

Anggap fitur yang sedang dikerjakan: **status transaksi Pre-order (PO)**
(menunggu konfirmasi → diproses → siap diambil/dikirim → selesai → dibatalkan).

---

## Catatan Penting: Cara Menjalankan Role (berlaku di semua tahap di bawah)

Anda **tidak perlu** menulis ulang persona role secara manual (mis. mengetik
"kamu adalah project-manager, tugasmu adalah...") di setiap prompt. Persona
itu sudah tertanam di file `.claude/agents/<role>.md` /
`.opencode/agent/<role>.md` (frontmatter + system prompt) yang sudah kita
buat di scaffold ini — begitu file itu ada di repo, tool-nya sudah "kenal"
role tersebut.

Yang perlu Anda lakukan cuma **memanggil role itu secara eksplisit by name**,
bukan menjelaskan ulang siapa dia. Kenapa eksplisit, bukan dibiarkan
auto-routing? Karena workflow ini butuh kepastian role mana yang jalan di
task mana (konsisten dengan prinsip "satu role, satu task, satu path scope")
— auto-delegation berdasarkan deskripsi cocok untuk eksplorasi bebas, tapi
tidak untuk alur berstruktur seperti ini.

**Di Claude Code**, tiga cara (pilih salah satu):

```bash
# 1) Sesi baru langsung sebagai role tsb (paling disarankan untuk worktree per task)
claude --agent backend-engineer

# 2) Di dalam sesi yang sudah jalan, panggil eksplisit
/agent:backend-engineer

# 3) Atau cukup sebut nama role-nya di prompt biasa
"Gunakan subagent backend-engineer untuk mengerjakan TASK-101 sesuai task contract-nya."
```

**Di OpenCode**, dua cara (pilih salah satu):

```bash
# 1) @-mention nama agent di prompt
"@backend-engineer kerjakan TASK-101 sesuai task contract"

# 2) Kalau role tsb di-set mode: primary (biasanya untuk PM),
#    switch ke agent itu dengan tombol Tab di sesi OpenCode
```

Isi prompt yang Anda ketik cukup **konteks tugas** (task ID, dokumen yang
harus dibaca) — bukan penjelasan ulang siapa role itu. Contoh di tahap-tahap
di bawah semuanya memakai pola ini.

---

## Tahap 0 — Brief & Dokumen dari `project-document-builder`

Anda menjalankan skill `project-document-builder` seperti biasa, hasilnya
rangkaian dokumen: Discovery Notes → BRD → SOW → PRD → UI/UX Flow → SRS →
TRD → SDD. Untuk workflow ini, dokumen yang paling relevan untuk PM dan
TL/SA adalah:

- **PRD** — requirement fitur PO status flow, termasuk business rule
  "status PO tidak boleh mandatory/lock, user non-PO tetap bisa transaksi
  normal."
- **SRS/TRD** — kebutuhan data model (field status baru), constraint teknis.
- **SDD** — desain sistem: di mana logic status disimpan (lokal, MVP1),
  bagaimana relasinya dengan fitur "Hapus Transaksi" (soft delete vs hard
  delete berdasarkan status bayar).

**Yang Anda lakukan:** taruh output dokumen tsb di folder referensi, misalnya
`control-repo/docs/cappu-pos/` (BRD.md, PRD.md, SRS.md, TRD.md, SDD.md).
Ini jadi *input*, bukan bagian dari task contract itu sendiri.

---

## Tahap 1 — Project Manager: Breakdown Task

Jalankan sesi sebagai role **`project-manager`** (lihat "Cara Menjalankan
Role" di atas):

```bash
claude --agent project-manager
```

Lalu kasih instruksi kurang lebih (cukup konteks tugas, bukan penjelasan
ulang siapa PM):

> "Baca `docs/cappu-pos/PRD.md` dan `docs/cappu-pos/SRS.md` bagian PO status
> flow. Pecah jadi task contract untuk repo `cappu-pos-android` dan
> `cappu-pos-ios`, sesuai `tasks/TASK-TEMPLATE.md`."

PM Agent lalu menghasilkan beberapa task. **Siapa yang menjalankan
`scripts/new-task.sh`?** Tergantung mana yang Anda pilih — keduanya valid,
tapi Claude Code **tidak otomatis tahu** untuk memakai script ini kecuali
salah satu dari dua hal berikut terjadi:

- **Opsi A (Anda jalankan manual, lebih deterministik):** Anda sendiri
  menjalankan `./scripts/new-task.sh TASK-101` dkk lewat bash (seperti
  contoh command di bawah), lalu bilang ke PM Agent: *"Isi
  `tasks/TASK-101.md`, `tasks/TASK-102.md`, `tasks/TASK-103.md` sesuai
  breakdown requirement di PRD/SRS."* PM Agent tinggal mengisi konten file
  yang sudah ada — dia tidak perlu tahu soal script sama sekali.
- **Opsi B (PM Agent yang jalankan sendiri):** `project-manager.md` sudah
  punya tool `Bash` di daftar `tools:`, jadi PM Agent BISA menjalankan
  script itu sendiri — **tapi hanya kalau Anda sebut eksplisit di prompt**,
  mis.: *"Gunakan `./scripts/new-task.sh` untuk membuat tiap task baru, lalu
  isi field-nya sesuai breakdown requirement."* Tanpa instruksi eksplisit
  ini, PM Agent tidak otomatis memanggil script tsb — paling banter dia
  menulis file task secara manual (tanpa lewat script), yang hasilnya sama
  saja isinya, cuma tidak lewat template generator.

Scaffold ini tidak "mengetahui" untuk memakai script secara otomatis —
tidak ada hook/trigger yang menyambungkan keduanya. Untuk kasus sesederhana
ini (cuma copy template + isi field), **Opsi A lebih disarankan**: Anda
jalankan manual seperti contoh di bawah, PM Agent fokus di bagian yang
memang butuh reasoning (baca requirement, tentukan allowed_paths, tulis
acceptance criteria) — bukan menjalankan perintah shell yang sepele.

```bash
./scripts/new-task.sh TASK-101   # data model status PO — Android
./scripts/new-task.sh TASK-102   # data model status PO — iOS
./scripts/new-task.sh TASK-103   # UI badge status di List Transaksi
```

Contoh isi `tasks/TASK-101.md` setelah diisi PM:

```markdown
# Task: TASK-101

- Repo: cappu-pos-android
- Role: android-developer
- Base branch: main
- Requirement ref: PRD §4.2 — PO Status Flow
- Allowed paths:
  - app/src/main/java/features/transaction/data/**
  - app/src/main/java/features/transaction/domain/**
- Forbidden paths:
  - app/src/main/java/features/transaction/ui/**
- Dependency: tidak ada
- Acceptance criteria:
  - [ ] Enum status baru: MENUNGGU_KONFIRMASI, DIPROSES, SIAP_DIAMBIL, SELESAI, DIBATALKAN
  - [ ] Status lama (belum bayar/lunas) tetap kompatibel untuk transaksi non-PO
  - [ ] Unit test transisi status lulus (`./gradlew test`)
  - [ ] Tidak ada perubahan di luar allowed paths
- Status: ready
```

PM **tidak** menyentuh source code — hanya menulis task contract ini
berdasarkan dokumen requirement.

---

## Tahap 2 — Tech Lead & System Analyst: API/Data Contract

**Siapa yang menentukan task sequential atau paralel?** Bukan Anda yang
memutuskan manual, dan bukan juga PM — mekanismenya lewat field
`Dependency:` di task contract:

- **PM** saat breakdown awal biasanya mengisi `Dependency:` berdasarkan
  urutan *bisnis/scope* yang dia tahu (mis. "fitur B baru masuk akal setelah
  fitur A ada") — ini baru perkiraan kasar.
- **TL/SA** yang **memvalidasi/memfinalisasi** field ini berdasarkan
  *technical dependency* yang sebenarnya — apakah dua task berbagi data
  contract yang sama, apakah `allowed_paths`-nya tumpang tindih, apakah ada
  migration yang harus jalan lebih dulu. Ini bagian dari kerjaan
  "TL/SA review teknis" di alur kerja (bagian 6 dokumen arsitektur) —
  **terjadi sebelum** task masuk status `ready`.
- Task dengan `Dependency: tidak ada` → boleh dikerjakan paralel.
  Task dengan `Dependency: TASK-XXX` → wajib menunggu TASK-XXX `done`.
- **Anda (manusia)** tetap pemegang keputusan akhir kalau merasa penilaian
  TL/SA kurang tepat (mis. Anda tahu ada keterbatasan sumber daya yang
  TL/SA tidak tahu) — tapi secara default, TL/SA-lah yang menentukan
  berdasarkan analisis teknis, bukan Anda menebak-nebak sendiri, dan bukan
  juga PM yang menentukan (PM fokus ke scope/prioritas bisnis, bukan
  ketergantungan teknis).

Di kasus ini: PM di Tahap 1 sudah menandai TASK-101 dan TASK-102
`Dependency: tidak ada` (asumsi awal keduanya independen karena beda
platform). TL/SA di tahap ini **mengecek ulang** asumsi tsb — dan
menemukan bahwa meski repo-nya beda, keduanya tetap butuh **satu data
contract yang sama** (supaya representasi status PO konsisten). Karena itu
TL/SA menyiapkan contract dulu (di bawah ini), **baru kemudian** kedua task
boleh dieksekusi paralel dengan aman.

Jalankan sesi sebagai role **`tech-lead-system-analyst`**:

```bash
claude --agent tech-lead-system-analyst
```

Lalu:

> "Baca `docs/cappu-pos/TRD.md` dan `docs/cappu-pos/SDD.md`. Tentukan data
> contract untuk status PO (nama field, enum value, aturan transisi) yang
> harus sama persis di Android dan iOS. Catat di `DECISIONS.md`."

Contoh hasil entry baru di `DECISIONS.md`:

```markdown
## [2026-08-22] Data contract — Status Transaksi PO

- Konteks: Android & iOS dikerjakan paralel, butuh 1 sumber kebenaran untuk
  status transaksi PO.
- Keputusan: field `transactionStatus` dengan enum string:
  `MENUNGGU_KONFIRMASI | DIPROSES | SIAP_DIAMBIL | SELESAI | DIBATALKAN`,
  plus status lama `BELUM_BAYAR | LUNAS` tetap ada untuk transaksi non-PO.
  Transisi hanya boleh maju (tidak boleh mundur), kecuali ke `DIBATALKAN`.
- Alasan: enum string lebih mudah dibaca di kedua native codebase
  dibanding integer code; aturan "hanya maju" mencegah state tidak konsisten.
- Dampak: cappu-pos-android (TASK-101), cappu-pos-ios (TASK-102).
```

TL/SA lalu **update** TASK-101 dan TASK-102 dengan referensi ke keputusan
ini (`Dependency: DECISIONS.md — Data contract Status PO`), supaya kedua
role Engineering membaca sumber yang sama sebelum implementasi — ini yang
mencegah Android dan iOS bikin representasi data berbeda meski dikerjakan
paralel.

---

## Tahap 3 — Setup Repo Project

Ini dilakukan **sekali di awal project** (bukan per-task):

1. Di `repos.yaml`, tambahkan:
   ```yaml
   - id: cappu-pos-android
     path: ../cappu-pos-android
     stack: kotlin-android
     stack_profile: stack-profiles/stack-profile-kotlin-android.md

   - id: cappu-pos-ios
     path: ../cappu-pos-ios
     stack: swift-ios
     stack_profile: stack-profiles/stack-profile-swift-ios.md
   ```
2. Copy `stack-profiles/stack-profile-kotlin-android.md` → root repo
   `cappu-pos-android/stack-profile.md`, sesuaikan command Gradle-nya.
   Sama untuk iOS.
3. Copy `.claude/agents/android-developer.md` (dan/atau `.opencode/agent/`)
   ke `cappu-pos-android/`. Copy `ios-developer.md` ke `cappu-pos-ios/`.
4. Kalau belum ada, copy juga `code-reviewer.md` dan `qa-engineer.md` ke
   kedua repo (role read-only/QA perlu akses baca ke repo yang direview).

Setup ini tidak perlu diulang untuk task berikutnya di project yang sama —
hanya saat repo baru pertama kali masuk ke workflow.

---

## Tahap 4 — Implementasi Paralel (Worktree Terisolasi)

Karena TASK-101 (Android) dan TASK-102 (iOS) independen di repo berbeda,
keduanya bisa dikerjakan **benar-benar paralel**:

```bash
./scripts/new-worktree.sh ../cappu-pos-android TASK-101 main
./scripts/new-worktree.sh ../cappu-pos-ios TASK-102 main
```

Di terminal/sesi terpisah:

```bash
cd ../cappu-pos-android-wt-TASK-101
claude --agent android-developer
# lalu: "Kerjakan TASK-101 sesuai task contract-nya."
```

```bash
cd ../cappu-pos-ios-wt-TASK-102
claude --agent ios-developer
# lalu: "Kerjakan TASK-102 sesuai task contract-nya."
```

(Kalau pakai OpenCode: `opencode` lalu `@android-developer kerjakan TASK-101 ...`
di masing-masing folder worktree.)

Masing-masing role membaca `stack-profile.md`, task contract-nya, dan
`DECISIONS.md` (untuk data contract dari Tahap 2) sebelum mulai — sehingga
walau dikerjakan di dua sesi berbeda secara bersamaan, hasilnya tetap
konsisten satu sama lain.

TASK-103 (UI badge status) baru dimulai setelah TASK-101 selesai, karena
task contract-nya menyatakan `Dependency: TASK-101`.

---

## Tahap 5 — Review, QA, PR

Setelah masing-masing role Engineering selesai dan self-check (test lokal)
lulus:

1. Jalankan role **`code-reviewer`** (read-only) di worktree yang sama —
   `claude --agent code-reviewer` lalu "Review TASK-101 terhadap task
   contract dan acceptance criteria-nya."
2. Jalankan role **`qa-engineer`** — `claude --agent qa-engineer` lalu
   "Validasi acceptance criteria TASK-101, tambahkan edge case bila perlu
   (mis. transaksi PO yang dibatalkan setelah `DIPROSES`)."
3. Buka Pull Request seperti biasa dari branch `task/TASK-101` dan
   `task/TASK-102`, jalankan CI.
4. Anda (atau siapa pun reviewer manusia) approve PR sebagai
   **satu-satunya checkpoint manusia di level task** — bukan approval
   berlapis.
5. Merge ke `main`.
6. Hapus worktree:
   ```bash
   git -C ../cappu-pos-android worktree remove ../cappu-pos-android-wt-TASK-101
   git -C ../cappu-pos-ios worktree remove ../cappu-pos-ios-wt-TASK-102
   ```

---

## Tahap 6 — Staging & Human Approval (opsional, bila sudah relevan)

Kalau project sudah butuh staging build (mis. untuk internal testing):

- Role **`devops-release`** menyiapkan/menjalankan script build staging
  (bukan production).
- **Human Workflow Maintainer** (Anda) tetap pemegang approval final untuk
  rilis ke production/store — ini tidak didelegasikan ke agent mana pun.

---

## Tahap 7 — Iterasi Berikutnya

Untuk fitur berikutnya (mis. reminder backup mingguan, export Excel), ulangi
dari **Tahap 1** dengan dokumen PRD/SRS bagian yang relevan. Tahap 3 (setup
repo) tidak perlu diulang karena repo sudah terdaftar di `repos.yaml`.

Kalau selama proses ini ada gesekan nyata (misalnya Android & iOS ternyata
sering bentrok di titik yang sama, atau task contract terasa kurang detail),
catat itu sebagai kandidat perbaikan — baru dipertimbangkan menambah
mekanisme baru, sesuai prinsip rollout minimal di `M2S-VSH-Lite-v0.2.0-Draft.md`.
