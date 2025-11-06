
// kelas item snack di mesin
class Item {
  String name; // nama produk (contoh: "cheetos hot")
  String code; // kode untuk beli (contoh: "a1", "b2")
  
  // color = tipe data processing untuk warna (rgb atau rgba)
  color snackColor; // warna cadangan kalau gambar gagal load
  
  // PVector = koordinat posisi (x, y, z)
  PVector position; // posisi dalam grid (kolom, baris) - koordinat logika
  PVector displayPos; // posisi dalam pixel di layar - koordinat visual
  
  // PImage = tipe data processing untuk menyimpan gambar
  PImage itemImage; // objek gambar produk yang sudah di-load
  String imagePath; // lokasi file gambar (contoh: "assets/images/cheetos.png")
  
  int row, col; // posisi grid: row = baris (0-3), col = kolom (0-2)
  int stock; // jumlah stok tersisa (awalnya 4 per item)
  
  boolean isEmpty; // true kalau stok habis, false kalau masih ada
  boolean isFalling; // true kalau lagi jatuh, false kalau diam
  boolean isStuck; // true kalau tersangkut di rail, false kalau sudah lepas
  int stuckTimer; // penghitung frame selama stuck (untuk animasi goyang)
  
  float fallSpeed; // kecepatan jatuh vertikal dalam pixel per frame
  float velocityX; // kecepatan gerak horizontal untuk bounce kiri-kanan
  float rotation; // sudut rotasi item saat jatuh (dalam radian)
  float alpha; // tingkat transparansi (0 = transparan penuh, 255 = solid)

  // constructor untuk buat objek item baru saat mesin diinisialisasi
  // parameter: nama, kode, warna, posisi baris/kolom, path gambar
  Item(String name, String code, color c, int row, int col, String imgPath) {
    // keyword "this" = merujuk ke variabel milik objek ini (bukan parameter)
    this.name = name; // simpan nama produk ke variabel objek
    this.code = code; // simpan kode pembelian
    this.snackColor = c; // simpan warna fallback
    this.row = row; // simpan posisi baris
    this.col = col; // simpan posisi kolom
    this.imagePath = imgPath; // simpan path file gambar
    
    // set state awal item
    this.isFalling = false; // item belum jatuh (masih di rail)
    this.isEmpty = false; // stok masih ada (belum habis)
    this.fallSpeed = 0; // kecepatan jatuh awal = 0 (belum gerak)
    this.position = new PVector(col, row); // bikin pvector untuk posisi grid
    this.stock = 4; // setiap item mulai dengan 4 stok
    this.isStuck = false; // belum stuck (belum ada yang beli)
    this.stuckTimer = 0; // timer stuck mulai dari 0
    this.alpha = 255; // transparansi penuh (tidak transparan)
    this.velocityX = 0; // kecepatan horizontal = 0 (belum gerak)
    this.rotation = 0; // sudut rotasi = 0 (belum diputar)
    
    updateDisplayPosition(); // hitung posisi pixel dari posisi grid
    
    // cek apakah path gambar ada dan tidak kosong
    if (imgPath != null && !imgPath.equals("")) {
      itemImage = loadImage(imgPath); // load gambar dari file ke memori
    }
  }

  // fungsi konversi posisi grid (kolom, baris) ke posisi pixel di layar
  void updateDisplayPosition() {
    float startX = 245, startY = 88; // koordinat pixel kiri atas grid item
    float spacingX = 68, spacingY = 75; // jarak antar item (horizontal dan vertikal)
    
    // rumus: posisi pixel = posisi awal + (posisi grid * jarak)
    // contoh: kolom 1 = 245 + (1 * 68) = 313 pixel dari kiri
    displayPos = new PVector(
      startX + position.x * spacingX, // hitung x dalam pixel
      startY + position.y * spacingY, // hitung y dalam pixel
      0 // z = 0 karena ini 2d
    );
  }

  // fungsi display kosong karena render sebenarnya ada di vendingmachine.renderitems2d()
  // ini cuma placeholder untuk konsistensi struktur kelas
  void display() { /* render di VendingMachine.renderItems2D() */
  }

  // fungsi mulai animasi jatuh saat item dibeli
  void startFalling() {
    // cek apakah masih ada stok
    if (stock > 0) {
      stock--; // kurangi stok 1
      if (stock == 0) isEmpty = true; // kalau stok jadi 0, tandai sebagai habis
      
      // set state awal animasi stuck (fase 1: goyang di rail)
      isStuck = true; // aktifkan mode stuck
      stuckTimer = 0; // reset timer stuck ke 0
      isFalling = false; // belum jatuh (masih stuck dulu)
      velocityX = random(-0.2, 0.2); // kecepatan horizontal acak kecil untuk bounce
      rotation = 0; // reset rotasi ke 0
      alpha = 0; // (tidak dipakai di render sekarang)
    }
  }

  // fungsi update animasi jatuh (dipanggil setiap frame)
  void updateFalling() {
    // fase 1: stuck di rail (goyang-goyang selama ~2 detik)
    if (isStuck) {
      stuckTimer++; // tambah timer setiap frame
      
      // hitung posisi asli item di grid
      float startX = 297, startY = 115; // offset pixel awal
      float spacingX = 68, spacingY = 75; // jarak antar item
      float originalX = startX + col * spacingX; // posisi x asli
      float originalY = startY + row * spacingY; // posisi y asli
      
      // animasi goyang horizontal pakai fungsi sin (gelombang)
      // sin(stucktimer * 0.3) menghasilkan nilai -1 sampai 1, dikali 1.0 pixel
      displayPos.x = originalX + sin(stuckTimer * 0.3) * 1.0;
      displayPos.y = originalY; // y tetap (tidak goyang vertikal)
      
      // rotasi kecil pakai sin dengan frekuensi berbeda
      rotation = sin(stuckTimer * 0.2) * 0.01; // goyang miring sangat kecil
      
      // setelah 120 frame (~2 detik), lepas dari stuck
      if (stuckTimer > 120) {
        isStuck = false; // matikan mode stuck
        isFalling = true; // aktifkan mode jatuh
        fallSpeed = 0; // reset kecepatan jatuh
        velocityX = random(-0.4, 0.4); // set kecepatan horizontal acak
        displayPos.x = originalX; // kembalikan x ke posisi tengah
      }
    } 
    // fase 2: jatuh dengan gravitasi dan bounce
    else if (isFalling) {
      fallSpeed += 0.021; // tambah kecepatan jatuh (simulasi gravitasi)
      displayPos.y += fallSpeed; // gerakkan item ke bawah sesuai kecepatan
      
      displayPos.x += velocityX; // gerakkan horizontal sesuai velocity
      velocityX *= 0.95; // kurangi velocity (friction/hambatan udara)
      
      // rotasi bertambah sesuai gerakan (kecepatan horizontal + vertikal)
      rotation += velocityX * 0.008 + fallSpeed * 0.002;
      
      // sistem bounce: cegah item keluar dari kolom
      float startX = 290, spacingX = 68; // parameter grid
      float centerX = startX + col * spacingX; // posisi tengah kolom ini
      float leftBound = centerX - 3; // batas kiri (3 pixel dari tengah)
      float rightBound = centerX + 3; // batas kanan (3 pixel dari tengah)
      
      // bounce dari dinding kiri
      if (displayPos.x < leftBound) {
        displayPos.x = leftBound; // paksa balik ke dalam batas
        velocityX = abs(velocityX) * 0.5; // balik arah, kurangi kecepatan 50%
      }
      
      // bounce dari dinding kanan
      if (displayPos.x > rightBound) {
        displayPos.x = rightBound; // paksa balik ke dalam batas
        velocityX = -abs(velocityX) * 0.5; // balik arah, kurangi kecepatan 50%
      }
      
      // deteksi landing di pintu bawah
      if (displayPos.y > height / 2 + 170) { // 170 = posisi y pintu pickup
        isFalling = false; // stop animasi jatuh
        displayPos.y = height / 2 + 170; // set posisi tepat di pintu
        rotation = 0; // reset rotasi
        velocityX = 0; // stop gerakan horizontal
        fallSpeed = 0; // reset kecepatan jatuh
      }
    }
  }

  // fungsi pindah item ke posisi grid baru (tidak dipakai di versi sekarang)
  void moveTo(int newRow, int newCol) {
    this.row = newRow; // update baris baru
    this.col = newCol; // update kolom baru
    this.position = new PVector(newCol, newRow); // update pvector posisi grid
  }

  // fungsi animasi slide smooth ke posisi target (tidak dipakai di versi sekarang)
  void slideToPosition(float speed) {
    // hitung posisi target dalam pixel dari posisi grid
    float startX = 245, startY = 88; // offset awal grid
    float spacingX = 68, spacingY = 75; // jarak antar item
    PVector target = new PVector(
      startX + position.x * spacingX, // x target
      startY + position.y * spacingY, // y target
      0 // z target
    );
    
    // lerp = linear interpolation (transisi smooth dari nilai a ke b)
    // lerp(a, b, 0.1) = a + (b - a) * 0.1 → bergerak 10% menuju b setiap frame
    displayPos.x = lerp(displayPos.x, target.x, speed); // gerak x pelan-pelan
    displayPos.y = lerp(displayPos.y, target.y, speed); // gerak y pelan-pelan
    displayPos.z = lerp(displayPos.z, target.z, speed); // gerak z pelan-pelan
  }
}
