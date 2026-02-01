# SuturaApp 🧵✂️

SuturaApp adalah aplikasi **manajemen usaha jahit / tailor** berbasis **Flutter** yang dirancang untuk membantu pencatatan **pelanggan, pesanan, ukuran pakaian, dan keuangan** dalam satu aplikasi. Aplikasi ini cocok untuk penjahit rumahan hingga usaha kecil yang ingin lebih rapi, cepat, dan minim pencatatan manual.

---

## ✨ Fitur Utama

### 👤 Manajemen Pelanggan

* Menyimpan data pelanggan (nama, nomor telepon)
* Menyimpan **ukuran pelanggan** berdasarkan jenis pakaian
* Mendukung banyak jenis ukuran dalam satu pelanggan

### 📦 Manajemen Pesanan

* Pencatatan pesanan jahit pelanggan
* Status pesanan (proses / selesai)
* Integrasi otomatis ke data keuangan saat pesanan selesai

### 💰 Manajemen Keuangan

* Pencatatan keuangan **manual** (uang masuk & keluar)
* Pencatatan keuangan **otomatis** dari pesanan yang selesai
* Kategori keuangan (Rumah / Usaha)
* Riwayat transaksi keuangan

### 📄 Laporan Keuangan

* Menampilkan ringkasan pemasukan dan pengeluaran
* Cetak / export laporan keuangan ke **PDF**

---

## 🛠️ Teknologi yang Digunakan

* **Flutter** (Frontend & App Logic)
* **Dart**
* **Supabase / Database lokal** (menyesuaikan konfigurasi proyek)
* **PDF & Printing Package** untuk laporan
* **Android SDK & NDK** untuk build APK

---

## 📂 Struktur Proyek (Ringkas)

```
lib/
├── core/            # Tema, style, utilitas
├── data/
│   ├── models/      # Model data (pelanggan, pesanan, keuangan)
│   └── repository/  # Akses database
├── modules/
│   ├── pelanggan/   # Halaman & logic pelanggan
│   ├── pesanan/     # Halaman & logic pesanan
│   └── keuangan/    # Halaman keuangan & laporan
└── main.dart
```

---

## 🚀 Cara Menjalankan Aplikasi

### 1. Clone Repository

```bash
git clone https://github.com/username/suturaapp.git
cd suturaapp
```

### 2. Install Dependency

```bash
flutter pub get
```

### 3. Jalankan di Emulator / Device

```bash
flutter run
```

### 4. Build APK Release

```bash
flutter build apk --release
```

> Pastikan **Android SDK & NDK** sudah terpasang dan versinya sesuai dengan plugin Flutter yang digunakan.

---

## 🎯 Tujuan Aplikasi

* Membantu penjahit mengelola usaha dengan lebih rapi
* Mengurangi pencatatan manual di buku
* Memudahkan rekap keuangan dan pesanan
* Menjadi aplikasi UAS / proyek pembelajaran Flutter

---

## 📌 Catatan

* Aplikasi ini masih dapat dikembangkan lebih lanjut
* Sangat terbuka untuk penambahan fitur seperti:

  * Backup cloud
  * Multi user
  * Grafik keuangan

---

## 👩‍💻 Pengembang

Dikembangkan oleh **Rafti Astia Rahayu**
Sebagai proyek aplikasi Flutter / Mobile Development

---

✨ *SuturaApp – Jahit Lebih Rapi, Usaha Lebih Pasti* ✨
