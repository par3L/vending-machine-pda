
# Simulator Mesin Penjual Otomatis (Vending Machine)

> Simulasi mesin penjual otomatis interaktif dengan visual 3D, animasi realistis, dan sistem waktu dinamis. Dibuat dengan Processing, fokus pada pengalaman visual, suara, dan interaksi yang mudah dipahami.

## Fitur Utama

- Pembayaran koin, saldo user, dan refund otomatis
- 12 produk snack dengan gambar, warna fallback, dan stok
- Animasi jatuh barang dan koin terbang
- Background kota dengan 4 mode waktu (pagi, siang, sore, malam)
- Lighting dinamis sesuai waktu
- Efek suara dan musik background

## Kontrol

**Keyboard:**
- `T` : Ganti waktu (pagi/siang/sore/malam)
- `N` : Ganti lagu
- `0-9` : Input kode produk
- `C` : Hapus input
- `Enter` : Konfirmasi pembelian

**Mouse:**
- Klik slot koin untuk memasukkan koin
- Klik numpad untuk input kode
- Klik tombol OK untuk beli
- Klik tombol R untuk refund
- Klik pintu pengambilan untuk ambil barang
- Klik tombol PLAY/PAUSE untuk musik

## Struktur Proyek

```
vending-machine-pda/
├── main.pde              // entry point & logika utama
├── VendingMachine.pde    // logika mesin, transaksi, render
├── Item.pde              // class produk & animasi jatuh
├── CityBackground.pde    // background & sistem waktu
├── AnimatedCoin.pde      // animasi koin terbang
├── assets/
│   ├── images/           // gambar produk
│   └── sounds/           // efek suara & musik
└── libraries/
        └── sound/            // Processing Sound library
```

## Penjelasan Tipe & Fungsi Processing

### PVector
`PVector` adalah tipe bawaan Processing untuk menyimpan dan memproses vektor 2D/3D (x, y, z). Di proyek ini:
- Digunakan untuk posisi dan kecepatan koin (`AnimatedCoin`), posisi item (`Item`), dan animasi.
- Contoh: `PVector pos;` menyimpan posisi koin, `pos.add(vel);` menambah kecepatan ke posisi.

### ArrayList
`ArrayList` adalah struktur data dinamis untuk menyimpan list objek. Di proyek ini:
- Menyimpan daftar item snack (`ArrayList<Item> items` di `VendingMachine`), dan daftar animasi koin (`ArrayList<AnimatedCoin>` di `main.pde`).
- Memudahkan menambah/menghapus objek secara dinamis saat animasi berjalan.

### SoundFile
`SoundFile` dari Processing Sound library digunakan untuk memutar efek suara dan musik.
- Contoh: `SoundFile coinDrop;` untuk suara koin masuk.
- Dipanggil dengan `.play()`, `.pause()`, `.amp()` untuk volume.

### Fungsi-fungsi Processing
- `size(w, h, P3D)`: Membuat window 3D.
- `ellipse(x, y, w, h)`: Menggambar lingkaran/oval.
- `rect(x, y, w, h)`: Menggambar persegi panjang.
- `fill(r, g, b, [a])`: Mengatur warna isi.
- `stroke(r, g, b)`: Mengatur warna garis pinggir.
- `pushMatrix()/popMatrix()`: Menyimpan/mengembalikan transformasi.
- `translate(x, y)`, `rotate(a)`: Transformasi objek.
- `random(a, b)`: Mengambil angka acak.
- `lerp(a, b, t)`: Interpolasi nilai (untuk animasi smooth).
- `text(str, x, y)`: Menampilkan teks.
- `image(img, x, y, w, h)`: Menampilkan gambar.
- `ambientLight()`, `directionalLight()`, `pointLight()`: Sistem pencahayaan 3D.

### Bagaimana Diproses di Proyek Ini
- Semua animasi (jatuh barang, koin terbang, awan, bintang) menggunakan perhitungan posisi dengan `PVector` dan update setiap frame di fungsi `draw()`.
- `ArrayList` digunakan agar animasi koin bisa bertambah/berkurang dinamis saat transaksi.
- Efek suara dipicu event (klik, beli, refund) dengan `SoundFile`.
- Fungsi Processing seperti `ellipse`, `rect`, `fill`, `stroke` dipakai untuk menggambar UI, mesin, item, dan background.
- Lighting diatur otomatis sesuai waktu (pagi/siang/sore/malam) untuk menciptakan suasana berbeda.

## Sistem Pembayaran & Animasi

- Harga per item: 5 koin
- User mulai dengan 20 koin
- Koin dimasukkan satu per satu, refund otomatis jika kelebihan
- Animasi jatuh barang: stuck 2 detik, jatuh 3 detik, lalu landing
- Animasi koin: koin terbang dari atas ke slot

## Instalasi

1. Install Processing dari [processing.org](https://processing.org)
2. Clone repo ini
3. Buka `main.pde` di Processing
4. Tekan Run

## Konfigurasi Mudah

- **Ubah harga item:**
    Edit di `VendingMachine.pde`:
    ```java
    final int PRICE = 5;
    ```
- **Ubah stok awal:**
    Edit di `Item.pde`:
    ```java
    this.stock = 4;
    ```
- **Ubah saldo koin user:**
    Edit di `main.pde`:
    ```java
    int userCoins = 20;
    ```

## Catatan Teknis

- Menggunakan renderer P3D untuk efek 3D
- Layer jendela di-prerender untuk performa
- Target 60 FPS, resolusi 800x525 px

## Kredit

Proyek ini dibuat untuk mendemonstrasikan kemampuan Processing dalam membuat aplikasi visual interaktif dengan animasi dan suara realistis.

## Kontrol

### Keyboard
- `T` - Ganti waktu (pagi/siang/sore/malam)
- `N` - Ganti track musik
- `0-9` - Input kode produk
- `C` - Clear input
- `Enter` - Konfirmasi pembelian

### Mouse
- Klik slot koin untuk memasukkan koin
- Klik numpad untuk input kode
- Klik tombol OK untuk membeli
- Klik tombol R untuk refund koin
- Klik pintu pengambilan untuk ambil barang
- Klik tombol PLAY/PAUSE untuk kontrol musik

## Arsitektur

### Struktur Kelas

```
main.pde
├── VendingMachine - Mesin utama
│   ├── Item[] - Array produk
│   ├── Coin system - Sistem pembayaran
│   └── Rendering 2D/3D
├── CityBackground - Background animasi
│   ├── Sky system - Gradient dan lighting
│   ├── Cloud animation - Awan bergerak
│   ├── Star animation - Bintang berkedip
│   └── Buildings - Gedung dengan jendela
└── AnimatedCoin - Animasi koin terbang
```

### File Struktur

```
vending-machine-pda/
├── main.pde              - Entry point dan koordinasi utama
├── VendingMachine.pde    - Logic mesin dan rendering
├── Item.pde              - Class produk dan animasi jatuh
├── CityBackground.pde    - Background dan sistem waktu
├── assets/
│   ├── images/           - Gambar produk snack
│   └── sounds/           - Sound effects dan musik
└── libraries/
    └── sound/            - Processing Sound library
```

## Sistem Pembayaran

- Harga per item: 5 koin
- User memiliki 20 koin di awal
- Koin dapat dimasukkan satu per satu
- Kembalian otomatis jika overpayment
- Tombol refund untuk batalkan transaksi

## Animasi

### Jatuh Barang
1. Fase stuck (2 detik) - Barang goyang di rail
2. Fase jatuh (3 detik) - Gravitasi realistis dengan collision
3. Landing di pickup door

### Koin Terbang
Animasi smooth dari posisi click ke slot koin dengan duration ~0.33 detik

### Awan
8 awan dengan ukuran dan kecepatan berbeda bergerak dari kiri ke kanan

### Bintang
150 bintang dengan animasi berkedip acak (hanya malam)

## Lighting System

Menggunakan Processing 3D lighting:
- Ambient light - Cahaya dasar lingkungan
- Directional light - Cahaya matahari/bulan
- Point light - Cahaya dari lampu jalan

Warna dan intensitas berubah sesuai waktu untuk menciptakan atmosfer yang berbeda.

## Dependencies

- Processing 4.x
- Processing Sound library (included)

## Instalasi

1. Install Processing dari [processing.org](https://processing.org)
2. Clone repository ini
3. Buka `main.pde` di Processing
4. Tekan Run

## Konfigurasi

### Ubah Harga
Edit di `VendingMachine.pde`:
```java
final int PRICE = 5; // ubah angka ini
```

### Ubah Stok Awal
Edit di `Item.pde` constructor:
```java
this.stock = 4; // ubah angka ini
```

### Ubah Koin Awal User
Edit di `main.pde`:
```java
int userCoins = 20; // ubah angka ini
```

## Technical Notes

- Menggunakan P3D renderer untuk efek 3D
- Prerendered window layers untuk optimasi
- Frame rate target: 60 FPS
- Resolution: 800x525 pixels

## Credits

Developed as a demonstration of Processing capabilities in creating interactive visual applications with realistic animations and sound integration.
