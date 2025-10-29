// kelas untuk merepresentasikan item snack di vending machine
class Item {
  // properti dasar item
  String name;
  String code; // kode 2 digit untuk beli (misal: "11", "23")
  color snackColor; // warna backup kalau gambar tidak load
  PVector position; // posisi logis di grid (col, row)
  PVector displayPos; // posisi aktual pixel untuk rendering
  float fallSpeed; // kecepatan jatuh vertikal (bertambah karena gravitasi)
  boolean isFalling; // flag apakah sedang dalam animasi jatuh
  boolean isEmpty; // flag apakah slot sudah habis stoknya
  int row, col; // koordinat grid (row 0-3, col 0-2)
  PImage itemImage; // gambar snack yang akan dirender
  String imagePath; // path ke file gambar
  int stock; // jumlah stok tersisa (default 4 per slot)
  boolean isStuck; // flag fase tersangkut di rail sebelum jatuh
  int stuckTimer; // counter frame untuk durasi fase tersangkut
  float alpha; // transparansi 0-255 untuk efek fade in
  float velocityX; // kecepatan horizontal (untuk efek goyang saat jatuh)
  float rotation; // sudut rotasi untuk efek berputar saat jatuh
  
  // constructor - dipanggil saat item dibuat
  Item(String name, String code, color c, int row, int col, String imgPath) {
    this.name = name;
    this.code = code;
    this.snackColor = c;
    this.row = row;
    this.col = col;
    this.imagePath = imgPath;
    this.isFalling = false;
    this.isEmpty = false;
    this.fallSpeed = 0;
    this.position = new PVector(col, row); // posisi grid
    this.stock = 4; // stok awal per slot, ubah angka ini untuk stok berbeda
    this.isStuck = false;
    this.stuckTimer = 0;
    this.alpha = 255; // item langsung terlihat penuh
    this.velocityX = 0;
    this.rotation = 0;
    updateDisplayPosition(); // hitung posisi pixel awal
    
    // load gambar kalau path tersedia
    if (imgPath != null && !imgPath.equals("")) {
      itemImage = loadImage(imgPath);
    }
  }
  
  // konversi posisi grid ke posisi pixel untuk rendering
  void updateDisplayPosition() {
    float startX = 205; // posisi x awal grid pertama (col 0), ubah untuk geser grid
    float startY = 88; // posisi y awal grid pertama (row 0), ubah untuk geser grid
    float spacingX = 68; // jarak horizontal antar item, ubah untuk spacing lebih rapat/renggang
    float spacingY = 75; // jarak vertikal antar item, ubah untuk spacing lebih rapat/renggang
    
    // hitung posisi pixel berdasarkan grid position
    displayPos = new PVector(
      startX + position.x * spacingX,
      startY + position.y * spacingY,
      0
    );
  }
  
  void display() {
    // kosong - rendering dilakukan di VendingMachine.renderItems2D()
  }
  
  // trigger animasi jatuh (dipanggil saat item dibeli)
  void startFalling() {
    if (stock > 0) {
      stock--; // kurangi stok
      if (stock == 0) {
        isEmpty = true; // tandai slot kosong kalau stok habis
      }
      // mulai dengan fase tersangkut dulu (realistic)
      isStuck = true;
      stuckTimer = 0;
      isFalling = false;
      velocityX = random(-0.2, 0.2); // random velocity horizontal untuk variasi
      rotation = 0;
      alpha = 0; // mulai transparan, akan fade in saat jatuh
    }
  }
  
  // update fisika jatuh dengan gravitasi dan fase tersangkut (realistic physics)
  void updateFalling() {
    // fase 1: tersangkut di rail (goyang-goyang sebelum jatuh)
    if (isStuck) {
      stuckTimer++;
      float startX = 255; 
      float startY = 105; 
      float spacingX = 68;
      float spacingY = 75;
      float itemW = 70;
      float originalX = startX + col * spacingX; 
      float originalY = startY + row * spacingY;
      // efek goyang menggunakan sin wave
      displayPos.x = originalX + sin(stuckTimer * 0.3) * 2.0; // amplitudo 2 pixel
      displayPos.y = originalY;
      rotation = sin(stuckTimer * 0.2) * 0.015; // rotasi kecil saat goyang
      
      // setelah 35 frame, lepas dan mulai jatuh
      if (stuckTimer > 35) { // ubah angka ini untuk durasi stuck lebih lama/cepat
        isStuck = false;
        isFalling = true;
        fallSpeed = 0;
        velocityX = random(-0.4, 0.4); // random arah horizontal
        displayPos.x = originalX;
      }
    }
    // fase 2: jatuh 
    else if (isFalling) {
      // tambah kecepatan jatuh (simulasi gravitasi)
      fallSpeed += 1.2; // const gravitasi, ubah ini buat ngatur kecepatan jatuh 
      displayPos.y += fallSpeed;
      // gerakan horizontal dengan friction
      displayPos.x += velocityX;
      velocityX *= 0.95;
      // rotasi berdasarkan kecepatan
      rotation += velocityX * 0.008 + fallSpeed * 0.002;
      // collision dengan dinding samping kolom
      float startX = 250; 
      float spacingX = 68;
      float itemW = 70;
      
      float centerX = startX + col * spacingX;
      float leftBound = centerX - 3;
      float rightBound = centerX + 3;
      
      // bounce dari dinding kiri
      if (displayPos.x < leftBound) {
        displayPos.x = leftBound;
        velocityX = abs(velocityX) * 0.5; // kehilangan 50% energi
      }
      // bounce dari dinding kanan
      if (displayPos.x > rightBound) {
        displayPos.x = rightBound;
        velocityX = -abs(velocityX) * 0.5;
      }
      
      // landing di pickup door (berhenti jatuh)
      if (displayPos.y > height / 2 + 170) { // posisi y pickup door
        isFalling = false;
        displayPos.y = height / 2 + 170;
        rotation = 0;
        velocityX = 0;
        fallSpeed = 0;
      }
    }
  }
  
  void moveTo(int newRow, int newCol) {
    this.row = newRow;
    this.col = newCol;
    this.position = new PVector(newCol, newRow);
  }
  
  void slideToPosition(float speed) {
    float startX = 205;
    float startY = 88;
    float spacingX = 68;
    float spacingY = 75;
    PVector target = new PVector(
      startX + position.x * spacingX,
      startY + position.y * spacingY,
      0
    );
    displayPos.x = lerp(displayPos.x, target.x, speed);
    displayPos.y = lerp(displayPos.y, target.y, speed);
    displayPos.z = lerp(displayPos.z, target.z, speed);
  }
}
