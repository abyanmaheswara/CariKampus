# 📋 Catatan Update Database Android - CariKampus

## Lokasi Database

| Platform | Lokasi File |
|----------|-------------|
| **Windows** | `cari_kampus\.dart_tool\sqflite_common_ffi\databases\kampus_tracking` |
| **Android** | `/data/data/com.example.gempa_tracking/databases/kampus_tracking.db` (internal, tidak bisa diakses langsung) |

> ⚠️ Database Windows dan Android **TERPISAH** dan tidak sinkron otomatis.

---

## Cara Tarik Database dari HP Android ke PC

### Prasyarat
- HP Android terhubung ke PC via **USB**
- **USB Debugging** aktif di HP
- **ADB** sudah terinstall (biasanya sudah ada dari Android SDK/Flutter)
- Aplikasi CariKampus sudah di-install di HP (versi debug)

### Langkah-langkah

#### 1. Cek HP terhubung
```bash
adb devices
```
Pastikan muncul device ID HP-nya.

#### 2. Tarik database ke folder yang sama dengan database Windows
```bash
adb exec-out run-as com.example.gempa_tracking cat databases/kampus_tracking.db > "D:\Politeknik Manufaktur Bandung\SEMESTER 4\P KOMPUTASI BERGERAK\Flutter_Abyan Maheswara\Mini Projects\cari_kampus\.dart_tool\sqflite_common_ffi\databases\kampus_tracking_android.db"
```

#### 3. Atau tarik ke Desktop
```bash
adb exec-out run-as com.example.gempa_tracking cat databases/kampus_tracking.db > C:\Users\user\OneDrive\Desktop\kampus_tracking_android.db
```

#### 4. Atau tarik ke Downloads
```bash
adb exec-out run-as com.example.gempa_tracking cat databases/kampus_tracking.db > C:\Users\user\Downloads\kampus_tracking_android.db
```

#### 5. Buka file hasil tarikan di **DB Browser for SQLite**

---

## Troubleshooting

### Error: "The process cannot access the file because it is being used by another process"
**Solusi:** Tutup DB Browser dulu, atau ganti nama file output-nya (misal tambah `_v2`).

### Error: "run-as: unknown package"
**Solusi:** Pastikan nama package benar: `com.example.gempa_tracking` (BUKAN `com.example.cari_kampus`).

### Database kosong / tidak ada tabel
**Solusi:** Pastikan aplikasi sudah dibuka minimal 1x di HP supaya database ter-create.

---

## Catatan Penting

1. **Setiap kali mau cek data terbaru**, harus tarik ulang database dari HP menggunakan perintah di atas.
2. **Package name Android** tetap `com.example.gempa_tracking` (tidak diubah).
3. **Nama database** yang dipakai: `kampus_tracking.db`
4. **Tabel yang dipakai**: `kampus_catatan`

### Struktur Tabel `kampus_catatan`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | INTEGER | Primary Key, Auto Increment |
| name | TEXT | Nama kampus |
| domain | TEXT | Domain website |
| web_page | TEXT | URL website |
| country | TEXT | Negara |
| catatan | TEXT | Catatan tambahan |

---

## Build APK

```bash
flutter build apk --release
```

Hasil APK ada di:
```
build\app\outputs\flutter-apk\app-release.apk
```

Rename manual ke `CariKampus.apk` jika diperlukan.
