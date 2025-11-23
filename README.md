# To-Do List Activity App

> Repository ini berisi proyek Flutter untuk aplikasi To-Do List Activity App yang dikembangkan sebagai tugas/portofolio.

---

## Daftar Tim

- Achmad Varis Abdussalam (2310130001)
- Muhammad Naufal Ammr Dzakwan (2310130010)
- Nabiel Syarof Azzaky (2310130012)
- M. Irfan Janur Gifari (2310130009)

---

## Pembagian Tugas

> _Silakan sesuaikan tugas nyata tiap anggota._

- UI & Desain: Achmad Varis Abdussalam
- Implementasi Login & SharedPreferences: Muhammad Naufal Ammr Dzakwan
- State management (Provider) & Feature Activity: M. Irfan Janur Gifari
- Dokumentasi & README: Nabiel Syarof Azzaky

## Penjelasan Fitur

### 1. Fitur Login

- _Tujuan:_ Mengizinkan pengguna masuk ke aplikasi menggunakan email & password yang sebelumnya didaftarkan.
- _Implementasi saat ini:_

  - Pada halaman Register, aplikasi menyimpan email, password, dan fullName ke SharedPreferences.
  - Pada halaman Login, aplikasi membaca nilai email dan password dari SharedPreferences dan membandingkannya dengan input pengguna.
  - Setelah login sukses, aplikasi menyimpan lastLogin di SharedPreferences dan mengarahkan pengguna ke halaman Activity.

- _Kelemahan/Limitasi:_

  - Autentikasi hanya bersifat lokal (tidak ada server). Data tersimpan plain di SharedPreferences (hindari untuk data sensitif di aplikasi produksi).

### 2. Fitur Light / Dark Mode

- _Tujuan:_ Memungkinkan pengguna beralih antara tema terang dan gelap.
- _Implementasi:_

  - ThemeProvider (ChangeNotifier) menyimpan boolean isDark.
  - Nilai isDark dibaca dari SharedPreferences pada inisialisasi provider (\_load()), sehingga preferensi tema dipertahankan antar sesi.
  - Perubahan tema melalui toggle() akan menyimpan nilai baru ke SharedPreferences dan memanggil notifyListeners().
  - MaterialApp menggunakan themeMode: themeProv.isDark ? ThemeMode.dark : ThemeMode.light sehingga tema berubah secara global.

### 3. Implementasi SharedPreferences

- Paket yang digunakan: shared_preferences.
- Data yang disimpan:

  - email, password, fullName (pada registrasi)
  - lastLogin (pada login sukses)
  - isDark (preference tema)

### 4. Implementasi SQLite

- _Status saat ini:_ BELUM diimplementasikan di kode yang diberikan. Saat ini daftar kegiatan (activities) disimpan dalam memori menggunakan ActivityProvider (list in-memory) sehingga data akan hilang saat aplikasi dimulai ulang.

- _Saran implementasi SQLite (langkah singkat):_

  1. Tambahkan dependency di pubspec.yaml:

     yaml
     dependencies:
     sqflite: ^2.0.0+4
     path: ^1.8.0

  2. Buat helper database (lib/services/db_helper.dart) yang menangani inisialisasi DB dan operasi CRUD.
  3. Buat model Activity (class) dengan field id, text, done.
  4. Modifikasi ActivityProvider agar saat addActivity, deleteActivity, toggleDone, dan clearAll juga melakukan operasi ke database.
  5. Saat provider diinisialisasi, baca daftar dari database dan isi \_activities.

- _Contoh alur singkat implementasi:_

  - DBHelper.openDB() → return instance DB
  - DBHelper.insertActivity(Activity) → insert
  - DBHelper.getAllActivities() → membaca semua activity saat start
  - DBHelper.updateActivity(Activity) → toggle done
  - DBHelper.deleteActivityById(id) → delete

---

## Screenshot

- login_page.jpg — halaman Login
- home_page.jpg — halaman Activity/Home
- add_item_page.jpg — tampilan saat menambah item atau dialog input
- light_mode.jpg — tampilan aplikasi di Light Mode
- dark_mode.jpg — tampilan aplikasi di Dark Mode

## Bagaimana Aplikasi Menyimpan Data

- _SharedPreferences_: digunakan untuk menyimpan preferensi dan data registrasi sederhana (email, fullName, password, isDark, lastLogin). Data ini bertahan antar sesi aplikasi di perangkat.
- _Activities (saat ini)_: Disimpan di memory menggunakan ActivityProvider pada runtime. Jika aplikasi ditutup atau di-restart, daftar akan hilang.
- _Rekomendasi_: Untuk persistensi yang benar, implementasikan SQLite (sqflite) seperti dijelaskan di atas, atau gunakan opsi penyimpanan berbasis file / backend (API) jika ingin sinkronisasi antar perangkat.

6. Kirim link GitHub repository sebagai luaran.
   https://github.com/parisid13/assesment2#

## cucuradabi
