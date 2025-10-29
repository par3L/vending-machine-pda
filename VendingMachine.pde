// kelas utama vending machine yang manage semua item dan interaksi
class VendingMachine {
  // variabel untuk manage items dan state vending machine
  ArrayList<Item> items; // list semua snack di vending machine
  String inputCode; // kode yang diinput user lewat numpad (2 digit)
  boolean isProcessing; // flag sedang proses animasi jatuh atau tidak
  int processingTimer; // timer untuk tracking durasi animasi
  Item selectedItem; // item yang lagi dipilih untuk dijatuhkan
  ArrayList<Item> itemsToSlide; // list item yang perlu slide ke bawah (tidak terpakai)
  String errorMessage; // pesan error yang ditampilkan di lcd ("ERROR" atau "SOLD")
  int errorTimer; // timer untuk menghitung berapa lama error ditampilkan
  Item collectedItem; // item yang sudah jatuh ke pickup door dan siap diambil
  boolean doorOpen; // flag apakah pintu pickup sedang terbuka (hover)
  
  // constructor - dipanggil saat objek dibuat
  VendingMachine() {
    items = new ArrayList<Item>(); // inisialisasi list kosong
    inputCode = ""; // kode awal kosong
    isProcessing = false;
    itemsToSlide = new ArrayList<Item>();
    errorMessage = "";
    errorTimer = 0;
    collectedItem = null;
    doorOpen = false;
    initializeItems(); // panggil fungsi untuk setup semua snack
  }
  
  // inisialisasi semua snack dalam grid 3 kolom x 4 baris (total 12 item)
  void initializeItems() {
    // warna backup untuk setiap snack kalau gambar tidak load
    color[] colors = {
      color(255, 50, 50), color(255, 150, 0), color(50, 100, 255), 
      color(255, 200, 0), color(150, 50, 200), color(50, 200, 50), 
      color(200, 100, 50), color(255, 100, 150), color(100, 200, 255),
      color(255, 180, 50), color(180, 100, 200), color(255, 80, 100)
    };
    // nama-nama snack yang akan ditampilkan
    String[] names = {
      "Cheetos Hot", "Cheetos", "Doritos", 
      "Lays", "Taro", "Pringles", 
      "Choco", "Pocky", "Cool Mint",
      "Butter", "Grape", "Wafer"
    };
    // path gambar untuk setiap snack (ubah path ini kalau mau ganti gambar)
    String[] imagePaths = {
      "assets/images/cheetos.png", "assets/images/cheetos.png", "assets/images/cheetos.png",
      "assets/images/cheetos.png", "assets/images/cheetos.png", "assets/images/cheetos.png",
      "assets/images/cheetos.png", "assets/images/cheetos.png", "assets/images/cheetos.png",
      "assets/images/cheetos.png", "assets/images/cheetos.png", "assets/images/cheetos.png"
    };
    // loop untuk buat semua item berdasarkan grid
    int index = 0;
    for (int row = 0; row < 4; row++) { // 4 baris, kalau mau tambah baris ubah angka ini
      for (int col = 0; col < 3; col++) { // 3 kolom, kalau mau tambah kolom ubah angka ini
        String code = "" + (row + 1) + (col + 1); // buat kode 2 digit (misal: 11, 12, 13, dst)
        int colorIndex = (row * 3 + col) % colors.length;
        // tambahkan item baru ke list
        items.add(new Item(
          names[colorIndex],
          code,
          colors[colorIndex],
          row,
          col,
          imagePaths[row * 3 + col]
        ));
      }
    }
  }
  
  void display(int skyMode) {
    renderVendingMachine2D(skyMode);
  }
  
  // render vending machine dalam mode 2d
  void renderVendingMachine2D(int skyMode) {
    pushMatrix();
    camera(); // reset camera ke default
    
    // posisi dan ukuran vending machine
    float vmX = 380; // posisi x tengah vending machine, ubah untuk geser kanan/kiri
    float vmY = height - 240; // posisi y tengah vending machine, ubah untuk geser atas/bawah
    float vmWidth = 360; // lebar vending machine, ubah untuk resize
    float vmHeight = 480; // tinggi vending machine, ubah untuk resize
    
    // === TAMBAHAN: Sisi 3D ===
    float vmSideW = 35; // Lebar sisi "fake 3D"
    float vmLeft = vmX - vmWidth/2; // Koordinat X kiri muka depan
    float vmTop = vmY - vmHeight/2;  // Koordinat Y atas muka depan
    
    // === sistem pencahayaan ===
    color baseBodyColor = color(180, 50, 50); // warna dasar body (merah gelap)
    color basePanelColor = color(200, 65, 65); // warna dasar panel atas (merah agak terang)
    
    // === TAMBAHAN: Warna Sisi 3D ===
    color sideBodyColor = color(red(baseBodyColor) * 0.7, green(baseBodyColor) * 0.7, blue(baseBodyColor) * 0.7);
    color sidePanelColor = color(red(basePanelColor) * 0.7, green(basePanelColor) * 0.7, blue(basePanelColor) * 0.7);

    // [DIHAPUS] Blok switch(skyMode) untuk lerpColor dihapus.
    // Pencahayaan sekarang ditangani oleh ambientLight dan directionalLight dari CityBackground.

    
    // === TAMBAHAN: Gambar Sisi 3D ===
    // Gambar sisi 3D terlebih dahulu agar berada di belakang muka depan
    noStroke();
    
    // Sisi body
    fill(sideBodyColor);
    pushMatrix();
    translate(vmLeft, vmTop); // Pindah ke pojok kiri atas muka depan
    // === DIUBAH ===: -vmSideW (Y) menjadi +vmSideW
    quad(0, 0, -vmSideW, +vmSideW, -vmSideW, vmHeight + vmSideW, 0, vmHeight);
    popMatrix();
    
    // Sisi panel atas
    fill(sidePanelColor);
    pushMatrix();
    translate(vmLeft, vmTop);
    // === DIUBAH ===: -vmSideW (Y) menjadi +vmSideW
    quad(0, 0, -vmSideW, +vmSideW, -vmSideW, 40 + vmSideW, 0, 40);
    popMatrix();
    
    
    // === MODIFIKASI: Gambar Body Utama (Sudut Tajam) ===
    fill(baseBodyColor);
    stroke(30);
    strokeWeight(3);
    // Radius sudut (angka 8) dihilangkan
    rect(vmX - vmWidth/2, vmY - vmHeight/2, vmWidth, vmHeight);
    
    // === MODIFIKASI: Gambar Panel Atas (Sudut Tajam) ===
    fill(basePanelColor);
    noStroke();
    // Radius sudut (8, 8, 0, 0) dihilangkan
    rect(vmX - vmWidth/2, vmY - vmHeight/2, vmWidth, 40);
    
    // gambar plat nama brand di panel atas
    fill(240, 220, 200); // warna cream untuk background plat
    rect(vmX - vmWidth/2 + 10, vmY - vmHeight/2 + 8, vmWidth - 20, 25, 4);
    fill(100, 30, 30); // warna coklat gelap untuk teks
    textAlign(CENTER, CENTER);
    textSize(14); // ukuran font brand name, ubah untuk resize
    text("CHEETOS 4 EVERYONE", vmX, vmY - vmHeight/2 + 20); // teks brand, ubah sesuai keinginan

    renderStickers(vmX, vmY, vmWidth, vmHeight); // gambar stiker dekoratif
    
    // === area kaca display untuk snack ===
    float glassX = vmX - 130; // posisi x kaca
    float glassY = vmY - vmHeight/2 + 60; // posisi y kaca
    float glassW = 220; // lebar kaca, ubah untuk resize area display
    float glassH = 320; // tinggi kaca, ubah untuk resize area display
    
    // gambar frame kaca hitam
    fill(45, 45, 50);
    stroke(25);
    strokeWeight(4);
    rect(glassX, glassY, glassW, glassH, 4);
    
    // gambar efek kaca transparan biru
    fill(150, 180, 200, 40); // warna biru dengan alpha rendah
    noStroke();
    rect(glassX + 5, glassY + 5, glassW - 10, glassH - 10);
    // gambar efek refleksi cahaya di kaca
    fill(255, 255, 255, 50); // putih semi transparan
    pushMatrix();
    translate(glassX + 20, glassY + 30);
    rotate(-0.2); // rotasi sedikit untuk efek dinamis
    rect(0, 0, 40, 150);
    popMatrix();
    
    renderItems2D(glassX + 15, glassY + 18); // render semua snack di dalam kaca
    
    // === area pickup door (pintu pengambilan snack) ===
    float doorX = glassX; // posisi x door sama dengan kaca
    float doorY = vmY + vmHeight/2 - 90; // posisi y door di bawah
    float doorW = glassW; // lebar door sama dengan kaca
    float doorH = 70; // tinggi door, ubah untuk resize
    
    // deteksi hover mouse di area door untuk membuka pintu
    boolean isHovering = mouseX > doorX && mouseX < doorX + doorW && 
                         mouseY > doorY && mouseY < doorY + doorH;
    doorOpen = isHovering; // set status pintu berdasarkan hover
    
    fill(35, 35, 40);
    stroke(25);
    strokeWeight(3);
    rect(doorX, doorY, doorW, doorH, 4);
    
    float openingY = doorY + 12;
    float openingH = doorH - 28;
    if (doorOpen) {
      fill(45, 45, 50);
      noStroke();
      rect(doorX + 20, openingY, doorW - 40, openingH, 3);
      
      if (collectedItem != null) {
        pushMatrix();
        translate(doorX + doorW/2, openingY + openingH/2);
        fill(0, 0, 0, 60);
        noStroke();
        ellipse(0, 10, 50, 10);
        rotate(HALF_PI);
        if (collectedItem.itemImage != null) {
          imageMode(CENTER);
          tint(255, 255);
          image(collectedItem.itemImage, 0, 0, 50, 45);
          noTint();
        } else {
          fill(collectedItem.snackColor);
          stroke(0);
          strokeWeight(1.5);
          rect(-25, -22.5, 50, 45, 3);
        }
        popMatrix();
        imageMode(CORNER);
      }
      
      noFill();
      if (collectedItem != null) {
        stroke(255, 215, 0, 150);
      } else {
        stroke(120, 120, 130, 100);
      }
      strokeWeight(3);
      rect(doorX + 18, openingY - 2, doorW - 36, openingH + 4, 3);
    } else {
      fill(25, 25, 30);
      noStroke();
      rect(doorX + 20, openingY, doorW - 40, openingH, 3);
      
      if (collectedItem != null) {
        noFill();
        stroke(255, 215, 0, 100);
        strokeWeight(2);
        rect(doorX + 18, openingY - 2, doorW - 36, openingH + 4, 3);
      }
    }
    
    fill(120, 120, 130);
    rect(doorX + 5, doorY + doorH/2 - 11, 12, 22, 2);
    
    float numpadX = vmX + 120;
    float numpadY = vmY - 50;
    renderNumpad2D(numpadX, numpadY);
    renderInputDisplay2D(numpadX, numpadY - 78);
    
    fill(50, 50, 55);
    stroke(30);
    strokeWeight(2);
    rect(numpadX - 12, numpadY - 108, 40, 10, 2);
    
    fill(60, 60, 65);
    stroke(30);
    strokeWeight(3);
    rect(vmX - vmWidth/2, vmY + vmHeight/2 - 15, vmWidth, 18, 0, 0, 4, 4);
    
    popMatrix();
  }
  
  void renderItems2D(float startX, float startY) {
    float itemW = 70;
    float itemH = 65;
    float spacingX = 68;
    float spacingY = 75;
    
    float glassX = 190;
    float glassY = 88;
    float glassW = 220;
    float glassH = 320;
    
    renderItemSupports(startX, startY, spacingX, spacingY);
    for (Item item : items) {
      if (!item.isEmpty) {
        float x = startX + item.col * spacingX;
        float y = startY + item.row * spacingY;
        
        if (item.isFalling || item.isStuck) {
          y = item.displayPos.y;
          x = item.displayPos.x;
          
          if (y < glassY + glassH) {
            pushMatrix();
            translate(x + itemW/2, y + itemH/2);
            rotate(item.rotation);
            
            fill(0, 0, 0, 40);
            noStroke();
            ellipse(0, itemH/2 + 3, itemW * 0.8, 8);
            if (item.itemImage != null) {
              imageMode(CENTER);
              tint(255, 255);
              image(item.itemImage, 0, 0, itemW, itemH);
              noTint();
            }
            popMatrix();
          }
        } else {
          fill(0, 0, 0, 40);
          noStroke();
          ellipse(x + itemW/2, y + itemH + 3, itemW * 0.8, 8);
          if (item.itemImage != null) {
            imageMode(CORNER);
            tint(255, item.alpha);
            image(item.itemImage, x, y, itemW, itemH);
            noTint();
            
            if (item.stock > 0) {
              noStroke();
              fill(0, 0, 0, 60);
              rect(x - 2, y - 2, itemW, itemH);
              if (item.stock > 1) {
                fill(0, 0, 0, 40);
                rect(x - 4, y - 4, itemW, itemH);
              }
              if (item.stock > 2) {
                fill(0, 0, 0, 20);
                rect(x - 6, y - 6, itemW, itemH);
              }
            }
          } else {
            fill(item.snackColor);
            stroke(0);
            strokeWeight(1.5);
            rect(x, y, itemW, itemH, 3);
            
            fill(255, 255, 255, 80);
            noStroke();
            rect(x + 3, y + 3, 8, itemH - 20, 2);
          }
        }
      }
    }
  }
  
  void renderStickers(float vmX, float vmY, float vmWidth, float vmHeight) {
    pushMatrix();
    translate(vmX + vmWidth/2 - 50, vmY - vmHeight/2 + 80);
    fill(255, 200, 50);
    stroke(200, 150, 0);
    strokeWeight(2);
    ellipse(0, 0, 45, 45);
    fill(200, 50, 0);
    textAlign(CENTER, CENTER);
    textSize(11);
    text("FRESH!", 0, 0);
    popMatrix();
    
    pushMatrix();
    translate(vmX - vmWidth/2 + 24, vmY + vmHeight/2 - 160);
    fill(255, 80, 80);
    stroke(200, 40, 40);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < 10; i++) {
      float angle = TWO_PI / 10 * i;
      float r = (i % 2 == 0) ? 22 : 12;
      float x = cos(angle - PI/2) * r;
      float y = sin(angle - PI/2) * r;
      vertex(x, y);
    }
    endShape(CLOSE);
    fill(255);
    textSize(10);
    text("SALE!", 0, 0);
    popMatrix();
    
    fill(50, 200, 100);
    stroke(30, 150, 70);
    strokeWeight(2);
    rect(vmX + vmWidth/2 - 65, vmY + vmHeight/2 - 135, 40, 35, 5);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("24", vmX + vmWidth/2 - 45, vmY + vmHeight/2 - 128);
    textSize(10);
    text("HOURS", vmX + vmWidth/2 - 45, vmY + vmHeight/2 - 112);
    
    fill(200, 150, 50);
    stroke(150, 100, 20);
    strokeWeight(2);
    rect(vmX - vmWidth/2 + 2, vmY - 100, 40, 20, 10);
    fill(80, 40, 0);
    textSize(8);
    text("QUALITY", vmX - vmWidth/2 + 22.5, vmY - 90);
    
    fill(255, 220, 50);
    stroke(200, 180, 30);
    strokeWeight(2);
    ellipse(vmX - vmWidth/2 + 30, vmY + 140, 28, 28);
    fill(0);
    noStroke();
    ellipse(vmX - vmWidth/2 + 24, vmY + 135, 4, 5);
    ellipse(vmX - vmWidth/2 + 36, vmY + 135, 4, 5);
    noFill();
    stroke(0);
    strokeWeight(2);
    arc(vmX - vmWidth/2 + 30, vmY + 138, 12, 12, 0, PI);
    
    fill(255, 100, 255);
    stroke(200, 50, 200);
    strokeWeight(2);
    triangle(vmX - 100, vmY - vmHeight/2 + 40, 
             vmX - 70, vmY - vmHeight/2 + 30,
             vmX - 80, vmY - vmHeight/2 + 53);
    fill(255);
    textSize(8);
    rotate(-0.3);
    text("NEW!", vmX - 155, vmY - vmHeight/2 + 130);
    rotate(0.3);
  }
  
  void renderItemSupports(float startX, float startY, float spacingX, float spacingY) {
    float itemW = 62;
    float itemH = 65;
    float maxDisplayHeight = 300;
    
    for (int row = 0; row < 4; row++) {
      float y = startY + row * spacingY + itemH;
      stroke(80, 80, 90);
      strokeWeight(3);
      fill(100, 100, 110);
      rect(startX, y, spacingX * 3 - 5, 4, 1);
      
      stroke(140, 140, 150);
      strokeWeight(1);
      line(startX + 1, y + 1, startX + spacingX * 3 - 6, y + 1);
    }
    
    float x1 = startX + spacingX - 7;
    stroke(70, 70, 80);
    strokeWeight(3);
    fill(90, 90, 100);
    rect(x1 - 1.5, startY - 5, 4, maxDisplayHeight, 2);
    stroke(130, 130, 140);
    strokeWeight(1);
    line(x1, startY - 4, x1, startY + maxDisplayHeight - 6);
    
    float x2 = startX + spacingX * 2 - 7;
    stroke(70, 70, 80);
    strokeWeight(3);
    fill(90, 90, 100);
    rect(x2 - 1.5, startY - 5, 4, maxDisplayHeight, 2);
    stroke(130, 130, 140);
    strokeWeight(1);
    line(x2, startY - 4, x2, startY + maxDisplayHeight - 6);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        float x = startX + col * spacingX;
        float y = startY + row * spacingY + itemH;
        
        noFill();
        stroke(120, 120, 130, 120);
        strokeWeight(2);
        for (int i = 0; i < 5; i++) {
          float coilX = x + 8 + i * 9;
          arc(coilX, y - 2, 7, 7, 0, PI);
          arc(coilX, y + 2, 7, 7, PI, TWO_PI);
        }
      }
    }
  }
  
  void renderNumpad2D(float x, float y) {
    fill(50, 50, 55);
    stroke(30);
    strokeWeight(2);
    rect(x - 20, y - 8, 65, 150, 4);
    String[] buttons = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "0", "OK"};
    for (int i = 0; i < 12; i++) {
      int row = i / 3;
      int col = i % 3;
      float btnX = x - 14 + col * 18;
      float btnY = y + row * 33;
      
      if (isMouseOverButton2D(btnX, btnY, 16, 30)) {
        fill(100, 150, 220);
      } else {
        fill(70, 70, 85);
      }
      
      stroke(40);
      strokeWeight(1);
      rect(btnX, btnY, 16, 30, 3);
      
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(10);
      text(buttons[i], btnX + 8, btnY + 15);
    }
  }
  
  void renderInputDisplay2D(float x, float y) {
    fill(30, 60, 40);
    stroke(25);
    strokeWeight(2);
    rect(x - 20, y, 55, 26, 3);
    
    String displayText = inputCode.length() == 0 ?
                         "- -" : inputCode;
    if (errorMessage.length() > 0) {
      fill(255, 50, 50);
      textAlign(CENTER, CENTER);
      textSize(10);
      text(errorMessage, x + 7.5, y + 13);
    } else {
      fill(0, 255, 100);
      textAlign(CENTER, CENTER);
      textSize(14);
      text(displayText, x + 7.5, y + 13);
    }
  }
  
  boolean isMouseOverButton2D(float x, float y, float w, float h) {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
  
  void handleNumpadClick() {
    if (isProcessing) return;
    
    float numpadX = 380 + 120;
    float numpadY = height - 240 - 50; // Posisi Y dihitung dari vmY
    
    String[] buttons = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "0", "OK"};
    for (int i = 0; i < 12; i++) {
      int row = i / 3;
      int col = i % 3;
      float btnX = numpadX - 14 + col * 18;
      float btnY = numpadY + row * 33;
      
      if (isMouseOverButton2D(btnX, btnY, 16, 30)) {
        String btn = buttons[i];
        if (btn.equals("C")) {
          inputCode = "";
        } else if (btn.equals("OK")) {
          processPurchase();
        } else {
          if (inputCode.length() < 2) {
            inputCode += btn;
          }
        }
        break;
      }
    }
  }
  
  void handlePickupDoorClick() {
    float vmX = 380;
    float vmY = height - 240;
    float vmHeight = 480;
    float glassX = vmX - 130;
    float doorX = glassX;
    float doorY = vmY + vmHeight/2 - 90;
    float doorW = 220;
    float doorH = 70;
    if (mouseX > doorX && mouseX < doorX + doorW && 
        mouseY > doorY && mouseY < doorY + doorH && 
        collectedItem != null) {
      collectedItem = null;
      doorOpen = false;
    }
  }

  void handleKeyPressed(char key) {
    if (key >= '0' && key <= '9') {
      if (inputCode.length() < 2) {
        inputCode += key;
      }
    } else if (key == '\n' || key == '\r') {
      processPurchase();
    } else if (key == 'c' || key == 'C') {
      inputCode = "";
    }
  }
  
  // proses pembelian saat user tekan "ok" atau enter
  void processPurchase() {
    // validasi kode harus 2 digit
    if (inputCode.length() != 2) {
      inputCode = "";
      return;
    }
    
    // cari item yang sesuai dengan kode input
    for (Item item : items) {
      if (item.code.equals(inputCode)) {
        // cek apakah masih ada stok
        if (item.stock > 0) {
          // mulai proses jatuh
          selectedItem = item;
          selectedItem.startFalling(); // trigger animasi jatuh
          isProcessing = true; // set flag processing
          processingTimer = 0;
          inputCode = ""; // reset input
          errorMessage = "";
          return;
        } else {
          // tampilkan pesan sold out kalau stok habis
          errorMessage = "SOLD";
          errorTimer = 0;
          inputCode = "";
          return;
        }
      }
    }
    
    // tampilkan error kalau kode tidak ditemukan
    errorMessage = "ERROR";
    errorTimer = 0;
    inputCode = "";
  }
  
  void findItemsToSlide(int removedRow, int removedCol) {
    itemsToSlide.clear();
  }
  
  // update state vending machine setiap frame
  void update() {
    // update timer error message dan hapus setelah 120 frame (2 detik)
    if (errorMessage.length() > 0) {
      errorTimer++;
      if (errorTimer > 120) { // ubah angka ini untuk durasi error lebih lama/cepat
        errorMessage = "";
        errorTimer = 0;
      }
    }
    
    // update animasi jatuh untuk semua item
    for (Item item : items) {
      if (item.isFalling || item.isStuck) {
        item.updateFalling(); // update fisika jatuh
      }
      else if (item.alpha < 255) {
        // fade in item baru setelah item sebelumnya diambil
        item.alpha += 8; // kecepatan fade in, ubah untuk efek lebih cepat/lambat
        if (item.alpha > 255) item.alpha = 255;
      }
    }
    
    // cek apakah proses jatuh sudah selesai
    if (isProcessing) {
      processingTimer++;
      // tunggu 30 frame setelah animasi jatuh selesai
      if (selectedItem != null && !selectedItem.isFalling && !selectedItem.isStuck && processingTimer > 30) {
        collectedItem = selectedItem; // pindahkan ke pickup door
        selectedItem.updateDisplayPosition();
        isProcessing = false;
        selectedItem = null;
      }
    }
  }
}
