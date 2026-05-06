# 🎓 CariKampus

Aplikasi pencarian data Perguruan Tinggi Indonesia berbasis Flutter.

## 📱 Tentang Aplikasi

CariKampus adalah aplikasi mobile & desktop yang memungkinkan pengguna mencari, menjelajahi, dan menyimpan data perguruan tinggi di Indonesia. Data diambil secara real-time dari **Hipolabs Universities API**.

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🔍 **Pencarian Real-time** | Cari kampus berdasarkan nama atau domain |
| 🏷️ **Filter Kategori** | Filter berdasarkan jenis: Universitas, Institut, Politeknik, Akademi, Sekolah Tinggi |
| 📊 **Statistik Dashboard** | Tampilan total kampus, hasil pencarian, dan data tersimpan |
| 📋 **Detail Kampus** | Halaman detail dengan informasi domain, website, dan negara |
| 💾 **Simpan ke Catatan** | Simpan kampus favorit ke database lokal (SQLite) |
| ✏️ **CRUD Database** | Create, Read, Update, Delete data kampus tersimpan |
| ↩️ **Undo Delete** | Batalkan penghapusan data dengan tombol UNDO di SnackBar |
| 🔄 **Pull to Refresh** | Tarik layar ke bawah untuk memuat ulang data |
| 👤 **Profil Mahasiswa** | Halaman profil dengan identitas lengkap |

## 🛠️ Teknologi

- **Framework**: Flutter
- **Bahasa**: Dart
- **API**: [Hipolabs Universities API](http://universities.hipolabs.com)
- **Database**: SQLite (`sqflite` + `sqflite_common_ffi`)
- **Font**: Google Fonts (Poppins)
- **Platform**: Android, Windows, Web

## 📂 Struktur Project

```
cari_kampus/
├── lib/
│   ├── main.dart              # Entry point & navigasi utama
│   ├── splash_screen.dart     # Splash screen dengan logo
│   ├── home_screen.dart       # Halaman utama pencarian
│   ├── detail_screen.dart     # Detail informasi kampus
│   ├── database_screen.dart   # CRUD catatan kampus (SQLite)
│   ├── profil_screen.dart     # Profil mahasiswa
│   └── db_helper.dart         # Database helper SQLite
├── assets/
│   └── images/                # Logo & gambar
├── pubspec.yaml
└── README.md
```

## 🎨 Desain UI

- **Primary Color**: Indigo Blue `#283593`
- **Secondary Color**: `#3949AB`
- **Accent Color**: Amber `#FFC107`
- **Background**: `#F5F5F5`
- **Surface**: `#E8EAF6`

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK >= 3.11.0
- Dart SDK
- Android Studio / VS Code

### Instalasi

```bash
# Clone repository
git clone https://github.com/abyanmaheswara/CariKampus.git
cd CariKampus

# Install dependencies
flutter pub get

# Jalankan di Android
flutter run -d android

# Jalankan di Windows
flutter run -d windows

# Build APK
flutter build apk --release
```

## 👨‍💻 Pengembang

| | |
|---|---|
| **Nama** | Abyan Maheswara |
| **NIM** | 224443024 |
| **Jurusan** | Teknik Otomasi Manufaktur dan Mekatronika |
| **Prodi** | Teknologi Rekayasa Informatika Industri |
| **Kampus** | Politeknik Manufaktur Bandung |

## 📄 Sumber Data

- **API**: [Hipolabs Universities API](http://universities.hipolabs.com/search?country=Indonesia)
- **Referensi**: PDDikti Kemendiktisaintek

## 📝 Lisensi

Project ini dibuat untuk keperluan tugas Mini Project mata kuliah **Pemrograman Komputasi Bergerak** - Semester 4.
