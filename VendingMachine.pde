// kelas utama vending machine yang manage semua item dan interaksi
class VendingMachine {
  ArrayList<Item> items;
  String inputCode;        // kode yang diinput user
  boolean isProcessing;    // status sedang proses animasi
  int processingTimer;     // timer untuk animasi
  Item selectedItem;       // item yang dipilih untuk dijatuhkan
  ArrayList<Item> itemsToSlide; // item yang perlu slide ke bawah
  String errorMessage;     // pesan error untuk LCD
  int errorTimer;          // timer untuk error message
  Item collectedItem;      // item yang sudah jatuh dan siap diambil
  boolean doorOpen;        // status pintu pickup terbuka
  
  VendingMachine() {
    items = new ArrayList<Item>();
    inputCode = "";
    isProcessing = false;
    itemsToSlide = new ArrayList<Item>();
    errorMessage = "";
    errorTimer = 0;
    collectedItem = null;
    doorOpen = false;
    initializeItems();
  }
  
  // inisialisasi semua snack dalam grid 3 kolom x 4 baris
  void initializeItems() {
    // array warna untuk berbagai jenis snack (backup jika gambar tidak ada)
    color[] colors = {
      color(255, 50, 50),    // merah - cheetos flamin hot
      color(255, 150, 0),    // orange - cheetos original
      color(50, 100, 255),   // biru - doritos cool ranch
      color(255, 200, 0),    // kuning - lays classic
      color(150, 50, 200),   // ungu - taro
      color(50, 200, 50),    // hijau - pringles sour cream
      color(200, 100, 50),   // coklat - choco pie
      color(255, 100, 150),  // pink - strawberry pocky
      color(100, 200, 255),  // cyan - cool mint
      color(255, 180, 50),   // gold - butter cookies
      color(180, 100, 200),  // lavender - grape candy
      color(255, 80, 100),   // coral - strawberry wafer
    };
    
    String[] names = {
      "Cheetos Hot", "Cheetos", "Doritos", 
      "Lays", "Taro", "Pringles", 
      "Choco", "Pocky", "Cool Mint",
      "Butter", "Grape", "Wafer"
    };
    
    // path ke gambar untuk setiap item (bisa diganti sesuai kebutuhan)
    String[] imagePaths = {
      "assets/images/cheetos.png", "assets/images/cheetos.png", "assets/images/cheetos.png",
      "assets/images/cheetos.png", "assets/images/cheetos.png", "assets/images/cheetos.png",
      "assets/images/cheetos.png", "assets/images/cheetos.png", "assets/images/cheetos.png",
      "assets/images/cheetos.png", "assets/images/cheetos.png", "assets/images/cheetos.png"
    };
    
    int index = 0;
    // 3 kolom x 4 baris
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        String code = "" + (row + 1) + (col + 1);
        int colorIndex = (row * 3 + col) % colors.length;
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
  
  // render seluruh vending machine dan komponennya
  void display() {
    // render vending machine dalam 3D dengan sisi kanan terlihatt
    renderVendingMachine2D();
  }
  
  // render vending machine 2d style menghadap user
  void renderVendingMachine2D() {
    pushMatrix();
    
    camera();
    
    float vmX = 380; 
    float vmY = height - 240; // posisi agar menempel di batas bawah (vmHeight/2 = 240)
    float vmWidth = 360; 
    float vmHeight = 480; 
    
    // body utama vending machine (merah soft/brick red)
    fill(180, 50, 50);
    stroke(30);
    strokeWeight(3);
    rect(vmX - vmWidth/2, vmY - vmHeight/2, vmWidth, vmHeight, 8);
    
    // panel atas dengan gradient (merah lebih terang)
    fill(200, 65, 65);
    noStroke();
    rect(vmX - vmWidth/2, vmY - vmHeight/2, vmWidth, 40, 8, 8, 0, 0);
    
    // brand area di atas
    fill(240, 220, 200);
    rect(vmX - vmWidth/2 + 10, vmY - vmHeight/2 + 8, vmWidth - 20, 25, 4);
    fill(100, 30, 30);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("CHEETOS 4 EVERYONE", vmX, vmY - vmHeight/2 + 20);
    
    // render stiker-stiker random di vending machine
    renderStickers(vmX, vmY, vmWidth, vmHeight);
    
    // glass display area (frame hitam) - lebih besar
    float glassX = vmX - 130;
    float glassY = vmY - vmHeight/2 + 60;
    float glassW = 220;
    float glassH = 320;
    
    fill(45, 45, 50);
    stroke(25);
    strokeWeight(4);
    rect(glassX, glassY, glassW, glassH, 4);
    
    // glass transparan
    fill(150, 180, 200, 40);
    noStroke();
    rect(glassX + 5, glassY + 5, glassW - 10, glassH - 10);
    
    // refleksi cahaya di glass
    fill(255, 255, 255, 50);
    pushMatrix();
    translate(glassX + 20, glassY + 30);
    rotate(-0.2);
    rect(0, 0, 40, 150);
    popMatrix();
    
    // render items di dalam glass
    renderItems2D(glassX + 15, glassY + 18);
    
    // pickup door di bawah - interactable
    float doorX = glassX;
    float doorY = vmY + vmHeight/2 - 90;
    float doorW = glassW;
    float doorH = 70;
    
    // cek hover pada pickup door - bisa hover kapan saja
    boolean isHovering = mouseX > doorX && mouseX < doorX + doorW && 
                         mouseY > doorY && mouseY < doorY + doorH;
    doorOpen = isHovering; // pintu terbuka saat hover (dengan atau tanpa item)
    
    // frame pickup door
    fill(35, 35, 40);
    stroke(25);
    strokeWeight(3);
    rect(doorX, doorY, doorW, doorH, 4);
    
    // pintu pickup opening dengan animasi
    float openingY = doorY + 12;
    float openingH = doorH - 28;
    
    if (doorOpen) {
      // pintu terbuka - interior lebih terang
      fill(45, 45, 50);
      noStroke();
      rect(doorX + 20, openingY, doorW - 40, openingH, 3);
      
      // tampilkan item yang jatuh di dalam (kalo ada)
      if (collectedItem != null) {
        pushMatrix();
        translate(doorX + doorW/2, openingY + openingH/2);
        
        // bayangan item
        fill(0, 0, 0, 60);
        noStroke();
        ellipse(0, 10, 50, 10);
        
        // item berbaring (90 derajat)
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
      }
      
      // highlight glow ketika hover dan pintu terbuka (selalu ada)
      noFill();
      if (collectedItem != null) {
        stroke(255, 215, 0, 150); // emas jika ada item
      } else {
        stroke(120, 120, 130, 100); // abu-abu jika kosong
      }
      strokeWeight(3);
      rect(doorX + 18, openingY - 2, doorW - 36, openingH + 4, 3);
    } else {
      // pintu tertutup
      fill(25, 25, 30);
      noStroke();
      rect(doorX + 20, openingY, doorW - 40, openingH, 3);
      
      // glow HANYA jika ada item (bahkan saat pintu tertutup)
      if (collectedItem != null) {
        noFill();
        stroke(255, 215, 0, 100);
        strokeWeight(2);
        rect(doorX + 18, openingY - 2, doorW - 36, openingH + 4, 3);
      }
    }
    
    // handle pintu
    fill(120, 120, 130);
    rect(doorX + 5, doorY + doorH/2 - 11, 12, 22, 2);
    
    // panel numpad di kanan
    float numpadX = vmX + 120;
    float numpadY = vmY - 50;
    
    renderNumpad2D(numpadX, numpadY);
    renderInputDisplay2D(numpadX, numpadY - 78);
    
    // coin/payment slot (lebih kecil)
    fill(50, 50, 55);
    stroke(30);
    strokeWeight(2);
    rect(numpadX - 12, numpadY - 108, 40, 10, 2);
    
    // base/kaki
    fill(60, 60, 65);
    stroke(30);
    strokeWeight(3);
    rect(vmX - vmWidth/2, vmY + vmHeight/2 - 15, vmWidth, 18, 0, 0, 4, 4);
    
    popMatrix();
  }
  
  // render items dalam 2d grid di glass display (3 kolom x 4 baris dengan spacing lebar)
  void renderItems2D(float startX, float startY) {
    float itemW = 70;  // width lebih lebar
    float itemH = 65;
    float spacingX = 68;  // spacing lebih lebar
    float spacingY = 75;  // spacing lebih lebar
    
    // simpan koordinat glass display untuk clipping
    float glassX = 190;
    float glassY = 88;
    float glassW = 220;
    float glassH = 320;
    
    // render support rails/penyangga terlebih dahulu
    renderItemSupports(startX, startY, spacingX, spacingY);
    
    for (Item item : items) {
      if (!item.isEmpty) {
        float x = startX + item.col * spacingX;
        float y = startY + item.row * spacingY;
        
        // cek jika sedang jatuh, gunakan posisi jatuh
        if (item.isFalling || item.isStuck) {
          y = item.displayPos.y;
          x = item.displayPos.x;
          
          // hanya render jika item masih di dalam atau di bawah glass display
          // jika Y item sudah melewati batas bawah glass, item tidak terlihat (di dalam mesin)
          if (y < glassY + glassH) {
            // render item yang jatuh dengan rotasi
            pushMatrix();
            translate(x + itemW/2, y + itemH/2);
            rotate(item.rotation);
            
            // bayangan item
            fill(0, 0, 0, 40);
            noStroke();
            ellipse(0, itemH/2 + 3, itemW * 0.8, 8);
            
            // tampilkan gambar item
            if (item.itemImage != null) {
              imageMode(CENTER);
              tint(255, 255); // no transparency, no blur
              image(item.itemImage, 0, 0, itemW, itemH);
              noTint();
            }
            popMatrix();
          }
        } else {
          // render item normal (tidak jatuh)
          
          // bayangan item
          fill(0, 0, 0, 40);
          noStroke();
          ellipse(x + itemW/2, y + itemH + 3, itemW * 0.8, 8);
          
          // tampilkan gambar item depan dengan fade in effect
          if (item.itemImage != null) {
            imageMode(CORNER);
            tint(255, item.alpha); // gunakan alpha untuk fade in
            image(item.itemImage, x, y, itemW, itemH);
            noTint();
            
            // HANYA tampilkan item di belakang jika stok > 1 (bukan layer transparan blur)
            // render sebagai outline/shadow effect saja
            if (item.stock > 0) {
              // shadow item di belakang (solid, tidak blur)
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
            // fallback: box snack dengan warna jika gambar tidak ada
            fill(item.snackColor);
            stroke(0);
            strokeWeight(1.5);
            rect(x, y, itemW, itemH, 3);
            
            // highlight/cahaya di sisi kiri atas snack
            fill(255, 255, 255, 80);
            noStroke();
            rect(x + 3, y + 3, 8, itemH - 20, 2);
          }
        }
      }
    }
  }
  
  // render stiker-stiker yang menempel di vending machine
  void renderStickers(float vmX, float vmY, float vmWidth, float vmHeight) {
    // Stiker 1: Lingkaran "FRESH!" di kanan atas
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
    
    // Stiker 3: Bintang "SALE!" di kiri bawah
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
    
    // Stiker 4: "24/7" rounded square di kanan bawah
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
    
    // Stiker 5: Badge "QUALITY" di kiri atas dekat glass
    fill(200, 150, 50);
    stroke(150, 100, 20);
    strokeWeight(2);
    rect(vmX - vmWidth/2 + 2, vmY - 100, 40, 20, 10);
    fill(80, 40, 0);
    textSize(8);
    text("QUALITY", vmX - vmWidth/2 + 22.5, vmY - 90);
    
    // Stiker 6: Emoji smiley kecil di pojok kiri bawah
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
    
    // Stiker 7: "NEW!" tag di atas glass
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
  
  // render penyangga/support untuk item di display
  void renderItemSupports(float startX, float startY, float spacingX, float spacingY) {
    float itemW = 62;  // width lebih lebar
    float itemH = 65;
    
    // hitung tinggi maksimal display (4 baris item)
    float maxDisplayHeight = 300;
    
    // render horizontal support bars untuk setiap baris
    for (int row = 0; row < 4; row++) {
      float y = startY + row * spacingY + itemH;
      
      // support bar horizontal (metal rail)
      stroke(80, 80, 90);
      strokeWeight(3);
      fill(100, 100, 110);
      rect(startX, y, spacingX * 3 - 5, 4, 1);
      
      // highlight di atas rail
      stroke(140, 140, 150);
      strokeWeight(1);
      line(startX + 1, y + 1, startX + spacingX * 3 - 6, y + 1);
    }
    
    // render vertical support columns di dalam - di antara kolom
    // kolom pemisah antara kolom 1 dan 2
    float x1 = startX + spacingX - 7;
    stroke(70, 70, 80);
    strokeWeight(3);
    fill(90, 90, 100);
    rect(x1 - 1.5, startY - 5, 4, maxDisplayHeight, 2);
    
    // highlight vertical
    stroke(130, 130, 140);
    strokeWeight(1);
    line(x1, startY - 4, x1, startY + maxDisplayHeight - 6);
    
    // kolom pemisah antara kolom 2 dan 3
    float x2 = startX + spacingX * 2 - 7;
    stroke(70, 70, 80);
    strokeWeight(3);
    fill(90, 90, 100);
    rect(x2 - 1.5, startY - 5, 4, maxDisplayHeight, 2);
    
    // highlight vertical
    stroke(130, 130, 140);
    strokeWeight(1);
    line(x2, startY - 4, x2, startY + maxDisplayHeight - 6);
    
    // render spring/coil mechanism menempel pada horizontal rail
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        float x = startX + col * spacingX;
        float y = startY + row * spacingY + itemH; // posisi di bawah item, menempel rail
        
        // spiral coil menempel pada rail horizontal
        noFill();
        stroke(120, 120, 130, 120);
        strokeWeight(2);
        
        // gambar coil spiral horizontal di sepanjang rail
        for (int i = 0; i < 5; i++) {
          float coilX = x + 8 + i * 9;
          // coil berbentuk spiral kecil menempel pada rail
          arc(coilX, y - 2, 7, 7, 0, PI);
          arc(coilX, y + 2, 7, 7, PI, TWO_PI);
        }
      }
    }
  }
  
  // render numpad 2d
  void renderNumpad2D(float x, float y) {
    // panel background (lebih kecil)
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
      
      // highlight saat hover
      if (isMouseOverButton2D(btnX, btnY, 16, 30)) {
        fill(100, 150, 220);
      } else {
        fill(70, 70, 85);
      }
      
      stroke(40);
      strokeWeight(1);
      rect(btnX, btnY, 16, 30, 3);
      
      // text tombol
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(10);
      text(buttons[i], btnX + 8, btnY + 15);
    }
  }
  
  // render lcd display 2d
  void renderInputDisplay2D(float x, float y) {
    // lcd screen (lebih kecil)
    fill(30, 60, 40);
    stroke(25);
    strokeWeight(2);
    rect(x - 20, y, 55, 26, 3);
    
    // text display
    String displayText = inputCode.length() == 0 ? "- -" : inputCode;
    
    // tampilkan error message jika ada
    if (errorMessage.length() > 0) {
      fill(255, 50, 50); // merah untuk error
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
  
  // cek hover untuk tombol 2d
  boolean isMouseOverButton2D(float x, float y, float w, float h) {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
  
  // handle klik pada numpad
  void handleNumpadClick() {
    if (isProcessing) return; // jangan terima input saat processing
    
    float numpadX = 380 + 120; // posisi X dasar vending machine + offset panel
    float numpadY = height/2 + 10 - 50; // posisi Y dasar vending machine + offset
    
    String[] buttons = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "0", "OK"};
    
    for (int i = 0; i < 12; i++) {
      int row = i / 3;
      int col = i % 3;
      float btnX = numpadX - 14 + col * 18;
      float btnY = numpadY + row * 33;
      
      if (isMouseOverButton2D(btnX, btnY, 16, 30)) {
        String btn = buttons[i];
        
        if (btn.equals("C")) {
          // clear input
          inputCode = "";
        } else if (btn.equals("OK")) {
          // process purchase
          processPurchase();
        } else {
          // tambah angka ke input (max 2 digit)
          if (inputCode.length() < 2) {
            inputCode += btn;
          }
        }
        break;
      }
    }
  }
  
  // handle klik pada pickup door untuk mengambil item
  void handlePickupDoorClick() {
    float vmX = 380;
    float vmY = height - 240;
    float vmHeight = 480;
    float glassX = vmX - 130;
    float doorX = glassX;
    float doorY = vmY + vmHeight/2 - 90;
    float doorW = 220;
    float doorH = 70;
    
    // cek jika klik pada pickup door dan ada item
    if (mouseX > doorX && mouseX < doorX + doorW && 
        mouseY > doorY && mouseY < doorY + doorH && 
        collectedItem != null) {
      // hapus collected item setelah diambil
      collectedItem = null;
      doorOpen = false;
    }
  }
  
  // proses pembelian berdasarkan kode
  void processPurchase() {
    if (inputCode.length() != 2) {
      inputCode = "";
      return;
    }
    
    // cari item dengan kode yang match DAN masih ada stok
    for (Item item : items) {
      if (item.code.equals(inputCode)) {
        if (item.stock > 0) {
          // item tersedia
          selectedItem = item;
          selectedItem.startFalling();
          isProcessing = true;
          processingTimer = 0;
          inputCode = "";
          errorMessage = ""; // clear error
          return;
        } else {
          // item habis - tampilkan SOLD di LCD
          errorMessage = "SOLD";
          errorTimer = 0;
          inputCode = "";
          return;
        }
      }
    }
    
    // kode tidak valid - tampilkan ERROR di LCD
    errorMessage = "ERROR";
    errorTimer = 0;
    inputCode = "";
  }
  
  // cari items yang perlu slide turun setelah item diambil
  void findItemsToSlide(int removedRow, int removedCol) {
    itemsToSlide.clear();
    
    // TIDAK ADA ITEM YANG SLIDE - sistem baru menggunakan stok
    // setiap slot independen dengan stoknya sendiri
  }
  
  // update animasi dan logic
  void update() {
    // update error message timer - hilangkan setelah 2 detik (120 frames)
    if (errorMessage.length() > 0) {
      errorTimer++;
      if (errorTimer > 120) {
        errorMessage = "";
        errorTimer = 0;
      }
    }
    
    // update item yang jatuh atau tersangkut
    for (Item item : items) {
      if (item.isFalling || item.isStuck) {
        item.updateFalling();
      }
      // update fade in untuk item yang tidak jatuh
      else if (item.alpha < 255) {
        item.alpha += 8;
        if (item.alpha > 255) item.alpha = 255;
      }
    }
    
    // kalau sedang processing animasi
    if (isProcessing) {
      processingTimer++;
      
      // tunggu item selesai jatuh
      if (selectedItem != null && !selectedItem.isFalling && !selectedItem.isStuck && processingTimer > 30) {
        // item selesai jatuh, simpan ke collected item
        collectedItem = selectedItem;
        
        // reset posisi item ke slot semula (untuk item berikutnya di belakang)
        selectedItem.updateDisplayPosition();
        
        // selesai processing
        isProcessing = false;
        selectedItem = null;
      }
    }
  }
}
