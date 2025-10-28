// kelas untuk merepresentasikan item snack di vending machine
class Item {
  String name;          // nama snack
  String code;          // kode untuk beli snack
  color snackColor;     // warna snack (backup jika gambar tidak ada)
  PVector position;     // posisi item di grid vending machine
  PVector displayPos;   // posisi aktual untuk render 3d
  float fallSpeed;      // kecepatan jatuh saat dibeli
  boolean isFalling;    // status apakah sedang jatuh
  boolean isEmpty;      // status apakah slot kosong
  int row, col;         // posisi row dan kolom
  PImage itemImage;     // gambar item
  String imagePath;     // path ke gambar item
  int stock;            // jumlah stok item (default 4)
  boolean isStuck;      // status tersangkut di rail
  int stuckTimer;       // timer untuk animasi tersangkut
  float alpha;          // transparansi untuk fade in effect
  float velocityX;      // kecepatan horizontal untuk physic
  float rotation;       // rotasi item saat jatuh
  
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
    this.position = new PVector(col, row);
    this.stock = 4; // setiap slot memiliki 4 item
    this.isStuck = false;
    this.stuckTimer = 0;
    this.alpha = 255; // fully visible
    this.velocityX = 0;
    this.rotation = 0;
    updateDisplayPosition();
    
    // load gambar jika path tersedia
    if (imgPath != null && !imgPath.equals("")) {
      itemImage = loadImage(imgPath);
    }
  }
  
  // update posisi display berdasarkan grid position (untuk 2d)
  void updateDisplayPosition() {
    float startX = 205;  // posisi x awal dalam screen space
    float startY = 88;   // posisi y awal dalam screen space
    float spacingX = 68;  // spacing lebih lebar untuk 3 kolom
    float spacingY = 75;  // spacing lebih lebar untuk 4 baris
    
    displayPos = new PVector(
      startX + position.x * spacingX,
      startY + position.y * spacingY,
      0
    );
  }
  
  // render tidak digunakan karena item dirender langsung di VendingMachine
  void display() {
    // kosong - rendering dilakukan di VendingMachine.renderItems2D()
  }
  
  // mulai animasi jatuh dengan fase tersangkut
  void startFalling() {
    if (stock > 0) {
      stock--; // kurangi stok
      if (stock == 0) {
        isEmpty = true; // slot kosong jika stok habis
      }
      isStuck = true; // mulai dengan tersangkut di rail
      stuckTimer = 0;
      isFalling = false;
      velocityX = random(-0.2, 0.2); // velocity horizontal minimal
      rotation = 0;
      
      // fade in item baru di belakang
      alpha = 0; // mulai transparan, akan fade in
    }
  }
  
  // update fisika jatuh dengan gravitasi dan fase tersangkut (lebih realistic)
  void updateFalling() {
    // fase 1: tersangkut di rail (goyang-goyang)
    if (isStuck) {
      stuckTimer++;
      // goyang minimal tapi tetap di dalam grid
      float startX = 255;  // posisi awal display
      float startY = 105;   // posisi Y awal display
      float spacingX = 68;
      float spacingY = 75;
      float itemW = 70;
      float originalX = startX + col * spacingX; // posisi X item berdasarkan kolom
      float originalY = startY + row * spacingY; // posisi Y item berdasarkan baris
      
      // goyang sangat kecil agar tetap dalam grid (±2px)
      displayPos.x = originalX + sin(stuckTimer * 0.3) * 2.0;
      displayPos.y = originalY; // set posisi Y sesuai dengan grid row
      rotation = sin(stuckTimer * 0.2) * 0.015; // rotasi minimal
      
      // setelah 35 frame, lepas dari rail
      if (stuckTimer > 35) {
        isStuck = false;
        isFalling = true;
        fallSpeed = 0;
        velocityX = random(-0.4, 0.4); // random horizontal push saat lepas (minimal)
        displayPos.x = originalX; // reset ke posisi center sebelum jatuh
      }
    }
    // fase 2: jatuh dengan gravitasi dan physics - DENGAN BATAS KETAT
    else if (isFalling) {
      // gravitasi
      fallSpeed += 1.2;
      displayPos.y += fallSpeed;
      
      // horizontal movement dengan air resistance
      displayPos.x += velocityX;
      velocityX *= 0.95; // air resistance lebih kuat
      
      // rotasi realistis saat jatuh (minimal)
      rotation += velocityX * 0.008 + fallSpeed * 0.002;
      
      // BATAS KETAT - item tidak boleh keluar dari grid kolomnya
      float startX = 250;
      float spacingX = 68;
      float itemW = 70;
      
      // batas grid per kolom (dengan margin sangat kecil ±3px dari center)
      float centerX = startX + col * spacingX;
      float leftBound = centerX - 3; // hanya 3px ke kiri dari center
      float rightBound = centerX + 3; // hanya 3px ke kanan dari center
      
      // paksa item tetap dalam batas grid
      if (displayPos.x < leftBound) {
        displayPos.x = leftBound;
        velocityX = abs(velocityX) * 0.5; // bounce dengan energy loss
      }
      if (displayPos.x > rightBound) {
        displayPos.x = rightBound;
        velocityX = -abs(velocityX) * 0.5;
      }
      
      // cek kalau sudah sampai bawah (pickup area)
      if (displayPos.y > height / 2 + 170) {
        isFalling = false;
        displayPos.y = height / 2 + 170;
        rotation = 0;
        velocityX = 0;
        fallSpeed = 0;
        // item sudah sampai pickup, siap untuk animasi pop-up
      }
    }
  }
  
  // pindahkan item ke posisi baru (untuk animasi slide)
  void moveTo(int newRow, int newCol) {
    this.row = newRow;
    this.col = newCol;
    this.position = new PVector(newCol, newRow);
  }
  
  // animasi smooth slide ke posisi baru (untuk 2d)
  void slideToPosition(float speed) {
    float startX = 205;
    float startY = 88;
    float spacingX = 68;  // spacing lebih lebar untuk 3 kolom
    float spacingY = 75;  // spacing lebih lebar untuk 4 baris
    
    PVector target = new PVector(
      startX + position.x * spacingX,
      startY + position.y * spacingY,
      0
    );
    
    // interpolasi smooth ke target
    displayPos.x = lerp(displayPos.x, target.x, speed);
    displayPos.y = lerp(displayPos.y, target.y, speed);
    displayPos.z = lerp(displayPos.z, target.z, speed);
  }
}
