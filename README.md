# LunarFlow – Period Tracker App

> Aplikasi mobile pelacak siklus menstruasi berbasis Flutter, dikembangkan oleh Kelompok 6 sebagai proyek mata kuliah Pemrograman Berbasis Mobile (PBM).

---

## Deskripsi Aplikasi

LunarFlow adalah aplikasi Android/iOS untuk membantu pengguna memantau siklus menstruasi mereka secara mandiri. Dengan antarmuka yang bersih dan intuitif, pengguna dapat mencatat tanggal haid, melihat prediksi siklus berikutnya, serta memantau riwayat kesehatan reproduksi mereka.

---

## Tujuan Pengembangan

- Memudahkan pengguna dalam mencatat dan memantau siklus menstruasi secara digital
- Memberikan prediksi siklus berikutnya berdasarkan data historis
- Menyediakan fitur pencatatan gejala dan kondisi kesehatan harian
- Mengembangkan kemampuan tim dalam membangun aplikasi mobile menggunakan Flutter dan backend Supabase

---

## Fitur Aplikasi

- **Autentikasi Pengguna** – Register dan login aman menggunakan Supabase Auth
- **Pelacak Siklus** – Catat tanggal mulai dan selesai menstruasi
- **Prediksi Siklus** – Estimasi otomatis siklus berikutnya berdasarkan riwayat
- **Riwayat Siklus** – Tampilkan data haid bulan-bulan sebelumnya
- **Catatan Harian** – Tambahkan catatan gejala atau kondisi kesehatan
- **Tampilan Kalender** – Visualisasi siklus dalam format kalender
- **Profil Pengguna** – Kelola data diri dan preferensi

---

## Teknologi yang Digunakan

| Kategori | Detail |
|---|---|
| **Framework** | Flutter (Dart SDK ≥ 3.0.0) |
| **Backend & Database** | Supabase (PostgreSQL + Auth + Realtime) |
| **UI Library** | Flutter Material Design |
| **Font** | Google Fonts (`google_fonts: ^6.2.1`) |
| **Internasionalisasi** | `intl: ^0.20.2` |
| **Dev Tools** | `device_preview: ^1.2.0`, `flutter_lints: ^3.0.0` |
| **Platform** | Android, iOS, Web (Flutter multiplatform) |

---

## Struktur Database (Supabase)

### Tabel `users`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid | Primary key (dari Supabase Auth) |
| `email` | text | Email pengguna |
| `nama` | text | Nama lengkap |
| `tanggal_lahir` | date | Tanggal lahir |
| `created_at` | timestamp | Waktu registrasi |

### Tabel `siklus`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid | Primary key |
| `user_id` | uuid | Foreign key ke `users.id` |
| `tanggal_mulai` | date | Tanggal mulai haid |
| `tanggal_selesai` | date | Tanggal selesai haid |
| `catatan` | text | Catatan tambahan |
| `created_at` | timestamp | Waktu pencatatan |

> Struktur database dikelola melalui Supabase Dashboard. Row Level Security (RLS) diterapkan agar setiap pengguna hanya dapat mengakses data miliknya sendiri.

---

## Struktur Proyek

```
LunarFlow_Kelompok6_PBM/
├── lib/                  # Source code utama Dart/Flutter
│   ├── main.dart         # Entry point aplikasi
│   ├── screens/          # Halaman-halaman UI
│   ├── widgets/          # Komponen UI reusable
│   ├── models/           # Model data
│   └── services/         # Koneksi Supabase & logika bisnis
├── assets/
│   └── images/           # Aset gambar aplikasi
├── android/              # Konfigurasi platform Android
├── ios/                  # Konfigurasi platform iOS
├── web/                  # Konfigurasi platform Web
├── pubspec.yaml          # Dependensi dan konfigurasi Flutter
└── README.md
```

---

## Panduan Instalasi & Menjalankan Aplikasi

### Prasyarat

- [Flutter SDK](https://flutter.dev/docs/get-started/install) versi ≥ 3.0.0
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Akun [Supabase](https://supabase.com) (untuk konfigurasi backend)
- Emulator Android/iOS atau perangkat fisik

### Langkah Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/tinsarirauhana/LunarFlow_Kelompok6_PBM.git
   cd LunarFlow_Kelompok6_PBM
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Supabase**

   Buat file `lib/services/supabase_config.dart` dan isi dengan kredensial Supabase project kamu:
   ```dart
   const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
   const String supabaseAnonKey = 'YOUR_ANON_KEY';
   ```
   > URL dan Anon Key bisa ditemukan di **Supabase Dashboard → Project Settings → API**.

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```
   Atau pilih device target secara spesifik:
   ```bash
   flutter run -d android
   flutter run -d ios
   ```

5. **Build APK (opsional)**
   ```bash
   flutter build apk --release
   ```
   File APK akan tersedia di `build/app/outputs/flutter-apk/app-release.apk`.

---

## Screenshot Tampilan Aplikasi

> Tambahkan screenshot di folder `assets/images/screenshots/` lalu referensikan di sini.

| Halaman | Tampilan |
|---|---|
| Splash / Onboarding | ![Splash](assets/images/screenshots/splash.png) |
| Login & Register | ![Login](assets/images/screenshots/login.png) |
| Dashboard Utama | ![Dashboard](assets/images/screenshots/dashboard.png) |
| Kalender Siklus | ![Kalender](assets/images/screenshots/kalender.png) |
| Catat Siklus | ![Catat](assets/images/screenshots/catat.png) |
| Profil | ![Profil](assets/images/screenshots/profil.png) |

---

## Anggota Kelompok 6

| Nama | NIM |
|---|---|
| _Tinsari Rauhana_ | _2308107010038_ |
| _Dian Islami_ | _2308107010048_ |

---
