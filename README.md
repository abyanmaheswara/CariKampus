# CariKampus 🎓

**CariKampus** adalah aplikasi mobile berbasis Flutter yang dirancang untuk mempermudah calon mahasiswa dalam mengeksplorasi, membandingkan, dan mengelola informasi perguruan tinggi di Indonesia secara real-time.

Aplikasi ini mengintegrasikan data dari **Hipolabs Universities API** dan diselaraskan dengan standar data **PDDikti** untuk menyajikan informasi yang akurat dan terpercaya.

## 🚀 Fitur Utama

- **Smart Search & Filter**: Cari kampus berdasarkan nama, singkatan, atau kategori (Universitas, Politeknik, Institut, dll).
- **Automatic Logo Detection**: Mendeteksi dan menampilkan logo asli kampus secara otomatis menggunakan domain web resmi via Google Favicon Service.
- **Campus Comparison (VS Mode)**: Bandingkan dua kampus pilihan secara side-by-side untuk melihat perbedaan domain, website, tipe, dan lokasi.
- **Catatan Kampus (SQLite CRUD)**: Simpan kampus favorit ke database lokal, tambahkan catatan pribadi, edit informasi, dan kelola daftar simpanan secara offline.
- **Safety Features**: Dilengkapi dengan fitur **UNDO** saat penghapusan data untuk mencegah kehilangan informasi yang tidak sengaja.
- **Interactive Profile**: Halaman profil mahasiswa yang interaktif sesuai dengan rubrik penilaian akademik.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **Database**: [SQLite](https://pub.dev/packages/sqflite) (Versi 5)
- **API Networking**: [HTTP Package](https://pub.dev/packages/http)
- **Fonts**: Google Fonts (Poppins)
- **Icons**: FontAwesome & Material Icons

## 📋 Persyaratan Rubrik (Compliant)

Aplikasi ini telah memenuhi seluruh kriteria penilaian Mini Project:
- [x] Splash Screen responsif dengan branding yang jelas.
- [x] Navigasi lengkap dengan tombol **Back** dan **Home** di setiap sub-halaman.
- [x] Konsumsi REST API secara asinkron dengan penanganan error/retry.
- [x] Implementasi CRUD SQLite yang stabil.
- [x] UI/UX yang estetis dengan tema warna Indigo & Amber.

## 📦 Cara Menjalankan Project

1. **Clone Repository**
   ```bash
   git clone https://github.com/abyanmaheswara/CariKampus.git
   ```
2. **Install Dependencies**
   ```bash
   flutter pub get
   ```
3. **Run Application**
   ```bash
   flutter run
   ```

## 👤 Author

- **Nama**: Abyan Maheswara
- **NIM**: 224443024
- **Institusi**: Politeknik Manufaktur Bandung
- **Jurusan**: Teknik Otomasi Manufaktur dan Mekatronika
- **Prodi**: Teknologi Rekayasa Informatika Industri

---
*Dibuat untuk memenuhi tugas Mini Project mata kuliah Pemrograman Komputasi Bergerak.*
