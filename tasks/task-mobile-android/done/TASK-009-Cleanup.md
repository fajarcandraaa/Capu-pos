# Task: TASK-009-Cleanup

- Repo: mobile-android
- Role: android-developer
- Base branch: main
- Requirement ref: REVISION-NOTES-Android-2026-09-15.md §8 + Agent A low findings
- Allowed paths:
  - apps/capupos-android/gradlew.new (dihapus)
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/MainActivity.kt
  - apps/capupos-android/app/src/main/res/layout/activity_home.xml
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/presentation/HomeActivity.kt
    <!-- Amend TL/SA 2026-09-16: CTA empty-state (AC #3) butuh click handler di Activity —
         view binding, bukan data binding, android:onClick tetap perlu method Activity.
         Diff: 1 blok setOnClickListener di setupFAB(), reuse intent TambahProdukActivity
         (identik FAB). Detail: DECISIONS.md §[2026-09-16] TASK-009-Cleanup. -->
- Forbidden paths:
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/data/**
  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/domain/**
- Dependency: TASK-009-Git-Commit-Android-Complete
- Acceptance criteria:
  - [x] `gradlew.new` dihapus (isi "404: Not Found")
  - [x] Splash delay sesuai spek: `< 2 detik` (TASK-002.md:15) — 1500ms
  - [x] Empty-state Home (hasil filter kosong) punya CTA jelas (PRD:106) — button ditambah + wired ke `TambahProdukActivity` (amend TL/SA)
  - [x] Tidak ada perubahan di luar allowed paths (amend) — hanya `HomeActivity.kt` tambahan di luar 3 file awal
- Status: done
- Merged: PR #20 (9dee5f7 Merge pull request #20 from fajarcandraaa/feat/TASK-009-Cleanup-android)
<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->

## Catatan Sesi (diisi role-agent yang mengerjakan)

- Command test yang dijalankan: `./gradlew assembleDebug` — gagal karena SDK/JDK tidak ada di env (SDK location not found). XML divalidasi via xmllint (parse OK). Build Kotlin tidak bisa diverifikasi lokal.
- Hasil: 4 file diubah sesuai kontrak (amend TL/SA). Wire CTA selesai — klik `btn_empty_state_cta` → `TambahProdukActivity` (identik FAB).
- File yang berubah:
  - gradlew.new (dihapus)
  - app/src/main/java/com/mindtoscreen/cappupos/presentation/MainActivity.kt (splash 2000 → 1500)
  - app/src/main/res/layout/activity_home.xml (tambah button CTA empty-state, style `Widget.Cappu.Button.Pill`)
  - app/src/main/java/com/mindtoscreen/cappupos/presentation/HomeActivity.kt (+3 baris wire CTA di `setupFAB()`)
- Unresolved issue (bila ada):
  - Build lokal tidak bisa dijalankan (tanpa Android SDK/JDK) — verifikasi fungsional manual di perangkat oleh QA direkomendasikan.
- Review finding (code-reviewer): dedup style manual → `@style/Widget.Cappu.Button.Pill` (sudah di-fix).
- Branch: feat/TASK-009-Cleanup-android → PR #20
