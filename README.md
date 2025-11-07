
# Simulator Mesin Penjual Otomatis (Vending Machine)

> Simulasi mesin penjual otomatis interaktif dengan halaman beranda, animasi intro 3D, visual realistis, dan sistem waktu dinamis. Dibuat dengan Processing, fokus pada pengalaman visual, suara, dan interaksi yang mudah dipahami.

## Alur Aplikasi

Aplikasi ini memiliki tiga state utama yang berjalan secara berurutan:

### 1. Halaman Beranda (HOME)
Tampilan awal aplikasi dengan background kota dinamis dan menu utama:
- **Tombol Mulai** - Memulai simulasi dengan animasi intro
- **Tombol Keluar** - Menutup aplikasi
- **Tombol Play/Pause** - Kontrol musik background

### 2. Animasi Intro (INTRO)
Setelah menekan tombol Mulai, animasi intro 3D yang memukau akan diputar dengan 6 fase:
1. Title fade in dengan partikel 3D background
2. Rotasi mesin vending 360 derajat
3. Koin terbang dengan kurva Bezier smooth
4. Snack jatuh dengan animasi rotasi
5. Mesin ke posisi final
6. Tampilan instruksi interaktif

**Kontrol Intro:**
- **SPASI** - Skip intro dan masuk ke simulasi utama
- **R** - Ulangi animasi intro dari awal

**Teknologi Intro:**
- P3D renderer untuk rendering 3D
- Bezier curves untuk pergerakan smooth objek
- Easing functions (easeInOutCubic) untuk animasi natural
- Dynamic camera dengan rotasi dan zoom
- Particle system 3D untuk atmosphere
- 3D lighting dengan ambient, directional, dan point lights

### 3. Simulasi Utama (GAME)
Setelah intro selesai atau di-skip, masuk ke simulasi mesin vending interaktif dengan fitur lengkap:
- Pembayaran koin, saldo user, dan refund otomatis
- 12 produk snack dengan gambar, warna fallback, dan stok
- Animasi jatuh barang dan koin terbang
- Background kota dengan 4 mode waktu yang dapat diganti
- Lighting dinamis sesuai waktu
- Efek suara dan musik background
- Tombol KELUAR untuk kembali ke halaman beranda

## Kontrol

### Halaman Beranda
**Mouse:**
- Klik tombol Mulai untuk memulai
- Klik tombol Setting untuk mengatur koin dan mode langit
- Klik tombol Keluar untuk menutup aplikasi
- Klik tombol Play/Pause untuk kontrol musik

### Animasi Intro
**Keyboard:**
- `SPASI` - Skip intro
- `R` - Ulangi intro

### Simulasi Utama
**Keyboard:**
- `T` - Ganti waktu (pagi/siang/sore/malam)
- `N` - Ganti track musik
- `0-9` - Input kode produk
- `C` - Hapus input
- `Enter` - Konfirmasi pembelian
- `R` - Refund koin

**Mouse:**
- Klik slot koin untuk memasukkan koin
- Klik numpad untuk input kode
- Klik tombol OK untuk konfirmasi pembelian
- Klik tombol R untuk refund
- Klik pintu pengambilan untuk ambil barang
- Klik tombol KELUAR untuk kembali ke beranda

## Struktur Proyek

```
vending-machine-pda/
├── main.pde              // entry point & state management
├── HomePage.pde          // halaman beranda & panel settings
├── IntroAnimation.pde    // animasi intro 3D
├── VendingMachine.pde    // logika mesin & transaksi
├── Item.pde              // class produk & animasi jatuh
├── CityBackground.pde    // background & sistem waktu
├── AnimatedCoin.pde      // animasi koin terbang
├── assets/
│   ├── images/           // gambar produk
│   └── sounds/           // sound efect & musik
└── libraries/
    └── sound/            // Processing Sound library
```

## Penjelasan Tipe & Fungsi Processing

### PVector
PVector adalah tipe bawaan Processing untuk menyimpan dan memproses vektor 2D atau 3D (x, y, z). Di proyek ini:
- Digunakan untuk posisi dan kecepatan koin di AnimatedCoin, posisi item di Item, dan animasi.
- Contoh: `PVector pos;` menyimpan posisi koin, `pos.add(vel);` menambah kecepatan ke posisi.

### ArrayList
ArrayList adalah struktur data dinamis untuk menyimpan list objek. Di proyek ini:
- Menyimpan daftar item snack di VendingMachine dan daftar animasi koin di main.pde.
- Memudahkan menambah atau menghapus objek secara dinamis saat animasi berjalan.

### SoundFile
SoundFile dari Processing Sound library digunakan untuk memutar efek suara dan musik.
- Contoh: `SoundFile coinDrop;` untuk suara koin masuk.
- Dipanggil dengan `.play()`, `.pause()`, `.loop()`, dan `.amp()` untuk volume.

### Fungsi-fungsi Processing
- `size(w, h, P3D)` - Membuat window dengan renderer 3D
- `ellipse(x, y, w, h)` - Menggambar lingkaran atau oval
- `rect(x, y, w, h)` - Menggambar persegi panjang
- `fill(r, g, b, [a])` - Mengatur warna isi
- `stroke(r, g, b)` - Mengatur warna garis pinggir
- `pushMatrix()/popMatrix()` - Menyimpan dan mengembalikan transformasi
- `translate(x, y)`, `rotate(a)` - Transformasi objek
- `random(a, b)` - Mengambil angka acak
- `lerp(a, b, t)` - Interpolasi nilai untuk animasi smooth
- `text(str, x, y)` - Menampilkan teks
- `image(img, x, y, w, h)` - Menampilkan gambar
- `ambientLight()`, `directionalLight()`, `pointLight()` - Sistem pencahayaan 3D

### Bagaimana Diproses di Proyek Ini
- Semua animasi menggunakan perhitungan posisi dengan PVector dan update setiap frame di fungsi draw.
- ArrayList digunakan agar animasi koin bisa bertambah atau berkurang dinamis saat transaksi.
- Efek suara dipicu oleh event seperti klik, beli, atau refund menggunakan SoundFile.
- Fungsi Processing seperti ellipse, rect, fill, dan stroke dipakai untuk menggambar UI, mesin, item, dan background.
- Lighting diatur otomatis sesuai waktu untuk menciptakan suasana berbeda di setiap mode.

## Sistem Pembayaran & Animasi

### Pembayaran
- Harga per item: 5 koin
- Koin dimasukkan satu per satu dengan klik pada slot koin
- Refund otomatis jika pembayaran berlebih
- Tombol refund untuk membatalkan transaksi

### Animasi Jatuh Barang
1. Fase stuck (2 detik) - Barang goyang di rail
2. Fase jatuh (3 detik) - Gravitasi realistis dengan collision
3. Landing di pickup door

### Animasi Koin Terbang
Koin terbang dari posisi click ke slot koin dengan duration sekitar 0.33 detik menggunakan interpolasi smooth.

### Animasi Background
- **Awan**: 8 awan dengan ukuran dan kecepatan berbeda bergerak dari kiri ke kanan
- **Bintang**: 150 bintang dengan animasi berkedip acak (hanya pada mode malam)

## Lighting System

Menggunakan Processing 3D lighting yang berubah sesuai waktu:
- **Ambient light** - Cahaya dasar lingkungan
- **Directional light** - Cahaya matahari atau bulan

Warna dan intensitas berubah sesuai mode waktu (pagi/siang/sore/malam) untuk menciptakan suasana yang berbeda.

## Instalasi

1. Install Processing dari [processing.org](https://processing.org)
2. Clone repository ini
3. Buka `main.pde` di Processing
4. Tekan Run

## Konfigurasi

### Ubah Harga Item
Edit di `VendingMachine.pde`:
```java
final int PRICE = 5; // ubah angka ini
```

### Ubah Stok Awal
Edit di `Item.pde` constructor:
```java
this.stock = 4; // ubah angka ini
```

### Ubah Koin Awal User (Default)
Edit di `main.pde`:
```java
int userCoins = 200; // ubah angka ini
```

Catatan: User tetap bisa mengubah jumlah koin awal melalui panel Settings di halaman beranda.

## Catatan Teknis

- Menggunakan renderer P3D untuk efek 3D
- Layer jendela gedung di-prerender untuk optimasi performa
- Target frame rate: 60 FPS
- Resolusi: 1000x525 pixels
- Smooth antialiasing level 8

## Kredit

Proyek ini dibuat sebagai Proyek Akhir dari praktikum Komputer Grafik. Proyek mendemonstrasikan semua hal yang telah dipelajari selama praktikum berjalan