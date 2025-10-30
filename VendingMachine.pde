
import processing.sound.*;

// kelas vending machine
class VendingMachine {
  ArrayList<Item> items; // daftar snack
  String inputCode; // kode input
  boolean isProcessing; // status proses
  int processingTimer; // timer proses
  Item selectedItem; // item diproses
  ArrayList<Item> itemsToSlide; // animasi slide (tidak dipakai)
  String errorMessage; // pesan error
  int errorTimer; // timer error
  Item collectedItem; // item di pintu
  boolean doorOpen; // pintu terbuka
  final int PRICE = 5; // harga item
  int coinsInserted = 0; // koin masuk

  VendingMachine() {
    items = new ArrayList<Item>(); inputCode = ""; isProcessing = false; itemsToSlide = new ArrayList<Item>(); errorMessage = ""; errorTimer = 0; collectedItem = null; doorOpen = false; initializeItems();
  }


  void initializeItems() {
    color[] colors = { color(255, 50, 50), color(255, 150, 0), color(50, 100, 255), color(255, 200, 0), color(150, 50, 200), color(50, 200, 50), color(200, 100, 50), color(255, 100, 150), color(100, 200, 255), color(255, 180, 50), color(180, 100, 200), color(255, 80, 100) };
    String[] names = { "Cheetos Hot", "Bugles", "Chex Mix", "Doritos", "Ranch Doritos", "Haldirams", "Lays BBQ", "Lays Salt", "Micos", "Oishi", "Pringles", "Snatts" };
    String[] imagePaths = { "assets/images/cheetos.png", "assets/images/bugles.png", "assets/images/chexMix.png", "assets/images/doritos.png", "assets/images/doritosRanch.png", "assets/images/haldirams.png", "assets/images/laysBBQ.png", "assets/images/laysSalt.png", "assets/images/micos.png", "assets/images/oishi.png", "assets/images/pringles.png", "assets/images/snatts.png" };
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        String code = "" + (row + 1) + (col + 1);
        int colorIndex = (row * 3 + col) % colors.length;
        items.add(new Item(names[colorIndex], code, colors[colorIndex], row, col, imagePaths[row * 3 + col]));
      }
    }
  }


  void display(int skyMode) { renderVendingMachine2D(skyMode); }


  void renderVendingMachine2D(int skyMode) {
    pushMatrix(); camera();
    float vmX = 420, vmY = height - 240, vmWidth = 360, vmHeight = 480;
    float vmSideW = 35, vmLeft = vmX - vmWidth/2, vmTop = vmY - vmHeight/2;
    color baseBodyColor = color(160, 45, 45), basePanelColor = color(180, 55, 55);
    color sideBodyColor = color(red(baseBodyColor) * 0.7, green(baseBodyColor) * 0.7, blue(baseBodyColor) * 0.7);
    color sidePanelColor = color(red(basePanelColor) * 0.7, green(basePanelColor) * 0.7, blue(basePanelColor) * 0.7);
    noStroke(); fill(sideBodyColor); pushMatrix(); translate(vmLeft, vmTop); quad(0, 0, -vmSideW, +vmSideW, -vmSideW, vmHeight + vmSideW, 0, vmHeight); popMatrix(); fill(sidePanelColor); pushMatrix(); translate(vmLeft, vmTop); quad(0, 0, -vmSideW, +vmSideW, -vmSideW, 40 + vmSideW, 0, 40); popMatrix(); fill(baseBodyColor); noStroke(); rect(vmX - vmWidth/2, vmY - vmHeight/2, vmWidth, vmHeight); fill(basePanelColor); noStroke(); rect(vmX - vmWidth/2, vmY - vmHeight/2, vmWidth, 40); fill(240, 220, 200); rect(vmX - vmWidth/2 + 10, vmY - vmHeight/2 + 8, vmWidth - 20, 25, 4); fill(100, 30, 30); textAlign(CENTER, CENTER); textSize(14); text("SNACKS 4 FIVE COINS", vmX, vmY - vmHeight/2 + 20);
    renderStickers(vmX, vmY, vmWidth, vmHeight); // stiker
    float glassX = vmX - 130, glassY = vmY - vmHeight/2 + 60, glassW = 220, glassH = 320;
    fill(45, 45, 50); stroke(25); strokeWeight(4); rect(glassX, glassY, glassW, glassH, 4); fill(150, 180, 200, 40); noStroke(); rect(glassX + 5, glassY + 5, glassW - 10, glassH - 10); fill(255, 255, 255, 50); pushMatrix(); translate(glassX + 20, glassY + 30); rotate(-0.2); rect(0, 0, 40, 150); popMatrix();
    renderItems2D(glassX + 15, glassY + 18); // snack
    float doorX = glassX, doorY = vmY + vmHeight/2 - 90, doorW = glassW, doorH = 70;
    boolean isHovering = mouseX > doorX && mouseX < doorX + doorW && mouseY > doorY && mouseY < doorY + doorH;
    doorOpen = isHovering; if (isHovering && collectedItem != null) cursor(HAND);
    fill(35, 35, 40); stroke(25); strokeWeight(3); rect(doorX, doorY, doorW, doorH, 4); float openingY = doorY + 12, openingH = doorH - 28;
    if (doorOpen) { fill(45, 45, 50); noStroke(); rect(doorX + 20, openingY, doorW - 40, openingH, 3); if (collectedItem != null) { pushMatrix(); translate(doorX + doorW/2, openingY + openingH/2); fill(0, 0, 0, 60); noStroke(); ellipse(0, 10, 50, 10); rotate(HALF_PI); if (collectedItem.itemImage != null) { imageMode(CENTER); tint(255, 255); image(collectedItem.itemImage, 0, 0, 50, 45); noTint(); } else { fill(collectedItem.snackColor); stroke(0); strokeWeight(1.5); rect(-25, -22.5, 50, 45, 3); } popMatrix(); imageMode(CORNER); } noFill(); if (collectedItem != null) stroke(255, 215, 0, 150); else stroke(120, 120, 130, 100); strokeWeight(3); rect(doorX + 18, openingY - 2, doorW - 36, openingH + 4, 3); } else { fill(25, 25, 30); noStroke(); rect(doorX + 20, openingY, doorW - 40, openingH, 3); if (collectedItem != null) { noFill(); stroke(255, 215, 0, 100); strokeWeight(2); rect(doorX + 18, openingY - 2, doorW - 36, openingH + 4, 3); } } fill(120, 120, 130); rect(doorX + 5, doorY + doorH/2 - 11, 12, 22, 2);
    float numpadX = vmX + 120, numpadY = vmY - 50;
    renderNumpad2D(numpadX, numpadY); renderInputDisplay2D(numpadX, numpadY - 78); renderCoinSlot(numpadX, numpadY - 93); renderRefundButton(numpadX, numpadY + 147);
    fill(60, 60, 65); stroke(30); strokeWeight(3); rect(vmX - vmWidth/2, vmY + vmHeight/2 - 15, vmWidth, 18, 0, 0, 4, 4);
    popMatrix();
  }

  // ...existing code...
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
  
  // === Stiker tidak berubah ===
  void renderStickers(float vmX, float vmY, float vmWidth, float vmHeight) {
    // --- STIKER SALE (TETAP ADA) ---
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

    // --- STIKER QUALITY (TETAP ADA) ---
    fill(200, 150, 50);
    stroke(150, 100, 20);
    strokeWeight(2);
    rect(vmX - vmWidth/2 + 2, vmY - 100, 40, 20, 10);
    fill(80, 40, 0);
    textSize(8);
    text("QUALITY", vmX - vmWidth/2 + 22.5, vmY - 90);

    // --- STIKER SMILEY (TETAP ADA) ---
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

    // --- STIKER NEW (TETAP ADA) ---
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
  
  // ... (renderItemSupports tidak berubah) ...
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

  // === MODIFIKASI: gambar slot koin dengan efek hover ===
  void renderCoinSlot(float x, float y) {
    // x dan y adalah *base* numpadX dan numpadY
    // posisi y slot: numpadY - 93
    // posisi x slot: numpadX - 12
    float slotX = x - 12;
    float slotY = y;
    
    // === BARU: Logika Hover ===
    boolean isHovering = isMouseOverCoinSlot(mouseX, mouseY);
    if (isHovering) {
      cursor(HAND); // Ganti kursor
      fill(120, 120, 100); // Warna dasar glow
      stroke(255, 215, 0); // Warna glow kuning
      strokeWeight(2);
    } else {
      fill(80, 80, 90); // warna abu-abu metal
      stroke(30);
      strokeWeight(2);
    }
    // ==========================
    
    rect(slotX, slotY, 40, 10, 2); // frame
    
    // lubang slot koin
    fill(20, 20, 25); // warna hitam (lubang)
    noStroke();
    rect(slotX + 10, slotY + 2, 20, 6, 1); // lubang
  }
  
  // === BARU: Getter untuk posisi slot koin ===
  // ini dipakai oleh main.pde untuk tahu ke mana koin harus terbang
  float[] getCoinSlotPos() {
    float numpadX = 380 + 120; // x tengah vm + 120
    float numpadY = height - 240 - 50; // y tengah vm - 50
    float slotX = numpadX - 12; // posisi x slot
    float slotY = numpadY - 93; // posisi y slot
    float slotW = 40; // lebar slot
    float slotH = 10; // tinggi slot
    
    // kembalikan posisi tengah (x, y) dari slot
    return new float[] { slotX + slotW / 2, slotY + slotH / 2 };
  }

  // === BARU: gambar tombol refund ===
  void renderRefundButton(float x, float y) {
    // x dan y adalah *base* numpadX dan numpadY
    // posisi y: numpadY + 147
    // posisi x: numpadX + 5
    float btnX = x + 5;
    float btnY = y;
    float btnSize = 15; // ukuran tombol
    
    // deteksi hover
    if (isMouseOverRefundButton(mouseX, mouseY)) {
      fill(255, 60, 60); // warna merah terang saat hover
      cursor(HAND); // Ganti kursor
    } else {
      fill(200, 0, 0); // warna merah standar
    }
    
    stroke(100, 0, 0);
    strokeWeight(2);
    rect(btnX, btnY, btnSize, btnSize, 3); // gambar tombol
    
    // teks 'R' (refund)
    fill(255);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(10);
    text("R", btnX + btnSize/2, btnY + btnSize/2);
  }

  void renderNumpad2D(float x, float y) {
    fill(50, 50, 55); // base numpad
    stroke(30);
    strokeWeight(2);
    rect(x - 20, y - 8, 65, 150, 4); // tinggi 150
    
    String[] buttons = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "0", "OK"};
    for (int i = 0; i < 12; i++) {
      int row = i / 3;
      int col = i % 3;
      float btnX = x - 14 + col * 18;
      float btnY = y + row * 33;

      if (isMouseOverButton2D(btnX, btnY, 16, 30)) {
        fill(100, 150, 220); // warna hover tombol
        cursor(HAND); // === BARU: Ganti kursor ===
      } else {
        fill(70, 70, 85); // warna standar tombol
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

  // === MODIFIKASI: display lcd diupdate untuk sistem koin ===
  void renderInputDisplay2D(float x, float y) {
    // background lcd
    fill(30, 60, 40); // warna hijau gelap background
    stroke(25);
    strokeWeight(2);
    rect(x - 20, y, 55, 26, 3); // background

    if (errorMessage.length() > 0) {
      // jika ada pesan error (no coins, sold, refund)
      fill(255, 50, 50); // warna teks error (merah)
      textAlign(CENTER, CENTER);
      // kecilkan font jika pesannya panjang (cth: "REFUND X COIN")
      if (errorMessage.startsWith("REFUND") || errorMessage.equals("NOT ENOUGH!")) {
        textSize(9);
      } else {
        textSize(10);
      }
      text(errorMessage, x + 7.5, y + 13);
    } else {
      // jika tidak ada error
      fill(0, 255, 100); // warna teks standar (hijau terang)
      textAlign(CENTER, CENTER);
      if (inputCode.length() > 0) {
        // jika user sedang mengetik kode
        textSize(14); // font besar untuk kode
        text(inputCode, x + 7.5, y + 13);
      } else {
        // jika tidak ada kode, tampilkan jumlah koin di mesin
        textSize(10); // font lebih kecil untuk status koin
        text(coinsInserted + " COIN", x + 7.5, y + 13);
      }
    }
  }

  boolean isMouseOverButton2D(float x, float y, float w, float h) {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }

  // === BARU: fungsi cek hover slot koin ===
  boolean isMouseOverCoinSlot(float mx, float my) {
    float numpadX = 420 + 120;
    float numpadY = height - 240 - 50;
    // koordinat sama dengan di renderCoinSlot
    float slotX = numpadX - 12;
    float slotY = numpadY - 93;
    float slotW = 40;
    float slotH = 10;
    return (mx > slotX && mx < slotX + slotW && my > slotY && my < slotY + slotH);
  }
  
  // === BARU: fungsi cek hover tombol refund ===
  boolean isMouseOverRefundButton(float mx, float my) {
    float numpadX = 420 + 120;
    float numpadY = height - 240 - 50;
    // koordinat sama dengan di renderRefundButton
    float btnX = numpadX + 5;
    float btnY = numpadY + 147;
    float btnSize = 15;
    return (mx > btnX && mx < btnX + btnSize && my > btnY && my < btnY + btnSize);
  }

  // === BARU: fungsi untuk menambah koin ke mesin ===
  void addCoin() {
    coinsInserted++;
    errorMessage = ""; // hapus error message saat user masukkan koin
    errorTimer = 0;
  }
  
  // === BARU: fungsi untuk refund manual ===
  int manualRefund() {
    int amountToRefund = coinsInserted;
    coinsInserted = 0; // kosongkan koin di mesin
    errorMessage = ""; // hapus error
    errorTimer = 0;
    return amountToRefund; // kembalikan jumlah koin
  }

  // === MODIFIKASI: handleNumpadClick diubah untuk sistem koin ===
  // sekarang return int (jumlah refund, -1 untuk beep, 0 untuk diam)
  int handleNumpadClick(SoundFile machineWorksSound, SoundFile coinRefundSound) {
    if (isProcessing) return 0; // jangan proses jika mesin sedang bekerja

    float numpadX = 420 + 120;
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
          return -1; // sinyal untuk mainkan beep
        } else if (btn.equals("OK")) {
          // proses pembelian dan dapatkan jumlah refund (jika ada)
          int refundAmount = processPurchase(machineWorksSound, coinRefundSound);
          return refundAmount; // kembalikan jumlah refund
        } else {
          if (inputCode.length() < 2) {
            inputCode += btn;
          }
          return -1; // sinyal untuk mainkan beep
        }
      }
    }
    return 0; // tidak ada tombol numpad yang diklik
  }

  // === MODIFIKASI: Fungsi diubah untuk menerima SoundFile ===
  void handlePickupDoorClick(SoundFile collectSound) {
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
      // === TAMBAHAN: Mainkan sound collect ===
      if (collectSound != null) {
        collectSound.play();
      }
    }
  }

  // === MODIFIKASI: handleKeyPressed diubah untuk sistem koin ===
  // sekarang return int (jumlah refund, -1 untuk beep, 0 untuk diam)
  int handleKeyPressed(char key, SoundFile machineWorksSound, SoundFile coinRefundSound) {
    if (key >= '0' && key <= '9') {
      if (inputCode.length() < 2) {
        inputCode += key;
        return -1; // sinyal beep
      }
    } else if (key == '\n' || key == '\r') { // jika tekan enter
      int refundAmount = processPurchase(machineWorksSound, coinRefundSound);
      return refundAmount; // kembalikan jumlah refund
    } else if (key == 'c' || key == 'C') {
      inputCode = "";
      return -1; // sinyal beep
    }
    return 0; // tidak ada input valid
  }

  // === MODIFIKASI TOTAL: processPurchase dirombak untuk sistem koin ===
  // proses pembelian saat user tekan "ok" atau enter
  // sekarang return int (jumlah refund)
  int processPurchase(SoundFile machineWorksSound, SoundFile coinRefundSound) {
    // 1. validasi kode harus 2 digit
    if (inputCode.length() != 2) {
      inputCode = "";
      return 0; // tidak ada refund
    }

    // 2. validasi koin
    if (coinsInserted == 0) {
      errorMessage = "NO COINS!";
      errorTimer = 0;
      inputCode = "";
      return 0; // tidak ada refund
    }
    
    if (coinsInserted < PRICE) {
      errorMessage = "NOT ENOUGH!";
      errorTimer = 0;
      inputCode = "";
      return 0; // tidak ada refund
    }
    
    // 3. cari item yang sesuai dengan kode input
    for (Item item : items) {
      if (item.code.equals(inputCode)) {
        // 4. cek apakah masih ada stok
        if (item.stock > 0) {
          // --- PEMBELIAN BERHASIL ---
          int overpayment = coinsInserted - PRICE; // hitung kembalian
          coinsInserted = 0; // kosongkan koin di mesin
          
          // mulai proses jatuh
          selectedItem = item;
          selectedItem.startFalling(); // trigger animasi jatuh

          // mainkan sound mesin
          if (machineWorksSound != null) {
            machineWorksSound.play();
          }

          isProcessing = true; // set flag processing
          processingTimer = 0;
          inputCode = "";
          
          // 5. handle kembalian (overpayment)
          if (overpayment > 0) {
            errorMessage = "REFUND " + overpayment + " COIN";
            errorTimer = 0;
            if (coinRefundSound != null) coinRefundSound.play(); // mainkan sound refund
            return overpayment; // kembalikan jumlah refund
          } else {
            errorMessage = ""; // tidak ada error
            return 0; // tidak ada refund
          }
          
        } else {
          // --- STOK HABIS ---
          errorMessage = "SOLD";
          errorTimer = 0;
          inputCode = "";
          // koin *tetap* di dalam mesin!
          return 0; // tidak ada refund
        }
      }
    }

    // --- KODE TIDAK DITEMUKAN ---
    errorMessage = "ERROR";
    errorTimer = 0;
    inputCode = "";
    // koin *tetap* di dalam mesin!
    return 0; // tidak ada refund
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
      } else if (item.alpha < 255) {
        // fade in item baru setelah item sebelumnya diambil
        item.alpha += 8; // kecepatan fade in, ubah untuk efek lebih cepat/lambat
        if (item.alpha > 255) item.alpha = 255;
      }
    }

    // cek apakah proses jatuh sudah selesai
    if (isProcessing) {
      processingTimer++;
      // === MODIFIKASI: Timer jeda diperpanjang (1 detik) ===
      // tunggu 60 frame setelah animasi jatuh selesai
      if (selectedItem != null && !selectedItem.isFalling && !selectedItem.isStuck && processingTimer > 60) {
        collectedItem = selectedItem; // pindahkan ke pickup door
        selectedItem.updateDisplayPosition();
        isProcessing = false;
        selectedItem = null;
      }
    }
  }
}
