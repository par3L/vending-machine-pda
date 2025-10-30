
// kelas item snack di mesin
class Item {
  String name; // nama snack
  String code; // kode pembelian
  color snackColor; // warna fallback
  PVector position; // posisi grid
  PVector displayPos; // posisi pixel
  PImage itemImage; // gambar produk
  String imagePath; // path gambar
  int row, col; // posisi grid
  int stock; // stok tersisa
  boolean isEmpty; // stok habis
  boolean isFalling; // sedang jatuh
  boolean isStuck; // tersangkut
  int stuckTimer; // timer stuck
  float fallSpeed; // kecepatan jatuh
  float velocityX; // kecepatan horizontal
  float rotation; // rotasi saat jatuh
  float alpha; // transparansi

  Item(String name, String code, color c, int row, int col, String imgPath) {
    this.name = name; this.code = code; this.snackColor = c; this.row = row; this.col = col; this.imagePath = imgPath;
    this.isFalling = false; this.isEmpty = false; this.fallSpeed = 0; this.position = new PVector(col, row); this.stock = 4; this.isStuck = false; this.stuckTimer = 0; this.alpha = 255; this.velocityX = 0; this.rotation = 0; updateDisplayPosition();
    if (imgPath != null && !imgPath.equals("")) itemImage = loadImage(imgPath); // load gambar
  }

  void updateDisplayPosition() {
    float startX = 245, startY = 88, spacingX = 68, spacingY = 75;
    displayPos = new PVector(startX + position.x * spacingX, startY + position.y * spacingY, 0); // konversi ke pixel
  }

  void display() { /* render di VendingMachine.renderItems2D() */ }

  void startFalling() {
    if (stock > 0) {
      stock--; if (stock == 0) isEmpty = true; // kurangi stok
      isStuck = true; stuckTimer = 0; isFalling = false; velocityX = random(-0.2, 0.2); rotation = 0; alpha = 0; // mulai animasi jatuh
    }
  }

  void updateFalling() {
    if (isStuck) {
      stuckTimer++; // timer stuck
      float startX = 297, startY = 115, spacingX = 68, spacingY = 75;
      float originalX = startX + col * spacingX, originalY = startY + row * spacingY;
      displayPos.x = originalX + sin(stuckTimer * 0.3) * 1.0; // goyang
      displayPos.y = originalY; rotation = sin(stuckTimer * 0.2) * 0.01;
      if (stuckTimer > 120) { isStuck = false; isFalling = true; fallSpeed = 0; velocityX = random(-0.4, 0.4); displayPos.x = originalX; } // lepas stuck
    } else if (isFalling) {
      fallSpeed += 0.021; displayPos.y += fallSpeed; // gravitasi
      displayPos.x += velocityX; velocityX *= 0.95; // friction
      rotation += velocityX * 0.008 + fallSpeed * 0.002; // rotasi
      float startX = 290, spacingX = 68, itemW = 70, centerX = startX + col * spacingX, leftBound = centerX - 3, rightBound = centerX + 3;
      if (displayPos.x < leftBound) { displayPos.x = leftBound; velocityX = abs(velocityX) * 0.5; } // bounce kiri
      if (displayPos.x > rightBound) { displayPos.x = rightBound; velocityX = -abs(velocityX) * 0.5; } // bounce kanan
      if (displayPos.y > height / 2 + 170) { isFalling = false; displayPos.y = height / 2 + 170; rotation = 0; velocityX = 0; fallSpeed = 0; } // mendarat
    }
  }

  void moveTo(int newRow, int newCol) {
    this.row = newRow; this.col = newCol; this.position = new PVector(newCol, newRow); // pindah grid
  }

  void slideToPosition(float speed) {
    float startX = 245, startY = 88, spacingX = 68, spacingY = 75;
    PVector target = new PVector(startX + position.x * spacingX, startY + position.y * spacingY, 0);
    displayPos.x = lerp(displayPos.x, target.x, speed); displayPos.y = lerp(displayPos.y, target.y, speed); displayPos.z = lerp(displayPos.z, target.z, speed); // animasi geser
  }
}
