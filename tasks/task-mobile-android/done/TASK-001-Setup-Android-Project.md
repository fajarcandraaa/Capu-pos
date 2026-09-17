1	# Task: TASK-001
2	
3	- Repo: mobile-android
4	- Role: android-engineer
5	- Base branch: main
6	- Requirement ref: Setup project structure sesuai TRD Clean Architecture
7	- Allowed paths:
8	  - apps/capupos-android/app/src/main/java/com/mindtoscreen/cappupos/**
9	  - apps/capupos-android/app/src/main/resources/**
10	- Forbidden paths:
11	  - apps/capupos-android/build.gradle (hanya untuk konfigurasi build)
12	- Dependency: tidak ada
13	- Acceptance criteria:
14	  - [x] Package structure mengikuti SDD: presentation/, domain/, data/
15	  - [x] Room database dikonfigurasi dengan skema 8 tabel
16	  - [x] Hilt DI sudah terintegrasi
17	  - [x] Produk utama (Splash, Onboarding, Home) dapat dijalankan
18	  - [x] Tidak ada perubahan di luar allowed paths
19	- Status: done
20	<!-- Status: draft -> ready -> in-progress -> done (atau blocked bila terhambat) -->
21	
22	## Catatan Sesi (diisi role-agent yang mengerjakan)
23	
24	- Command test yang dijalankan: ./gradlew assembleDebug
25	- Hasil: Build success. App runs splash → onboarding → home.
26	- File yang berubah: AppApplication.kt, MainActivity.kt, OnboardingActivity.kt, HomeActivity.kt, all data/domain entities
27	- Unresolved issue: ProductRepository unimplemented (next task)