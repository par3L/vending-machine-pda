
import processing.sound.*;

// class utama yang handle semua logic mesin vending
// termasuk render 2D, numpad, pembelian, animasi jatuh, dll
class VendingMachine {
  // arraylist = struktur data dinamis yang bisa bertambah/kurang
  ArrayList<Item> items; // daftar semua snack di mesin (12 item: 4 row x 3 col)
  String inputCode; // kode yang user ketik di numpad (2 digit, contoh: "23")
  boolean isProcessing; // true = mesin sedang proses jatuh item
  int processingTimer; // counter frame untuk timing proses
  Item selectedItem; // referensi ke item yang sedang jatuh
  ArrayList<Item> itemsToSlide; // array untuk animasi slide (fitur tidak dipakai)
  String errorMessage; // text error di LCD (contoh: "NO COINS!", "SOLD", dll)
  int errorTimer; // counter frame untuk auto-hide error message (2 detik)
  Item collectedItem; // item yang sudah jatuh dan siap diambil di pintu
  boolean doorOpen; // true = pintu terbuka (saat mouse hover)
  

  final int PRICE = 5; // harga setiap item (5 koin)
  

  int coinsInserted = 0; // jumlah koin yang sudah masuk ke mesin

  // fungsi yang dipanggil saat object VendingMachine dibuat
  VendingMachine() {
    // inisialisasi semua variabel ke nilai awal
    items = new ArrayList<Item>(); // buat arraylist kosong
    inputCode = ""; // kode masih kosong
    isProcessing = false; // tidak ada proses
    itemsToSlide = new ArrayList<Item>(); // buat arraylist kosong
    errorMessage = ""; // tidak ada error
    errorTimer = 0; // timer mulai dari 0
    collectedItem = null; // tidak ada item di pintu
    doorOpen = false; // pintu tertutup
    initializeItems(); // panggil fungsi untuk setup semua snack
  }

  // setup 12 snack di grid 4x3 (4 row, 3 column)
  void initializeItems() {
    // array warna untuk setiap snack (12 warna unik)
    color[] colors = {
      color(255, 50, 50),   // merah (cheetos)
      color(255, 150, 0),   // orange (bugles)
      color(50, 100, 255),  // biru (chex mix)
      color(255, 200, 0),   // kuning (doritos)
      color(150, 50, 200),  // ungu (ranch doritos)
      color(50, 200, 50),   // hijau (haldirams)
      color(200, 100, 50),  // coklat (lays bbq)
      color(255, 100, 150), // pink (lays salt)
      color(100, 200, 255), // cyan (micos)
      color(255, 180, 50),  // gold (oishi)
      color(180, 100, 200), // lavender (pringles)
      color(255, 80, 100)   // salmon (snatts)
    };
    
    // array nama snack (12 snack)
    String[] names = {
      "Cheetos Hot", "Bugles", "Chex Mix", "Doritos",
      "Ranch Doritos", "Haldirams", "Lays BBQ", "Lays Salt",
      "Micos", "Oishi", "Pringles", "Snatts"
    };
    
    // array path gambar snack (12 gambar PNG)
    String[] imagePaths = {
      "assets/images/cheetos.png", "assets/images/bugles.png",
      "assets/images/chexMix.png", "assets/images/doritos.png",
      "assets/images/doritosRanch.png", "assets/images/haldirams.png",
      "assets/images/laysBBQ.png", "assets/images/laysSalt.png",
      "assets/images/micos.png", "assets/images/oishi.png",
      "assets/images/pringles.png", "assets/images/snatts.png"
    };
    
    // loop nested untuk buat grid 4x3
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 3; col++) {
        // buat kode 2 digit (row+1)(col+1), contoh: row=0 col=0 → "11"
        String code = "" + (row + 1) + (col + 1);
        
        // hitung index warna dengan modulo (loop balik jika lebih dari 12)
        int colorIndex = (row * 3 + col) % colors.length;
        
        // buat object Item baru dan tambahkan ke arraylist
        items.add(new Item(
          names[colorIndex],  // nama snack
          code,               // kode numpad
          colors[colorIndex], // warna fallback
          row,                // posisi row
          col,                // posisi col
          imagePaths[row * 3 + col] // path gambar
        ));
      }
    }
  }


  // dipanggil setiap frame dari main.pde untuk render mesin
  void display(int skyMode) {
    // delegate ke fungsi render 2D (skyMode untuk lighting adjustment)
    renderVendingMachine2D(skyMode);
  }


  // render seluruh mesin vending dalam 2D (body, glass, numpad, door, dll)
  void renderVendingMachine2D(int skyMode) {
    // pushMatrix = save state transformasi (isolasi drawing)
    pushMatrix();
    
    // camera() = reset ke default camera 2D (cancel 3D transformations)
    camera();
    
    // dimensi vm
    float vmX = 420;          // posisi x tengah mesin
    float vmY = height - 240; // posisi y tengah mesin
    float vmWidth = 360;      // lebar mesin
    float vmHeight = 480;     // tinggi mesin
    float vmSideW = 35;       // lebar sisi 3D (pseudo 3D effect)
    
    // koordinat kiri atas mesin (untuk helper)
    float vmLeft = vmX - vmWidth/2;
    float vmTop = vmY - vmHeight/2;
    
    // warna base (merah maroon)
    color baseBodyColor = color(160, 45, 45);   // body utama
    color basePanelColor = color(180, 55, 55);  // panel atas
    
    // warna sisi (70% dari base untuk efek 3D shadow)
    color sideBodyColor = color(
      red(baseBodyColor) * 0.7,
      green(baseBodyColor) * 0.7,
      blue(baseBodyColor) * 0.7
    );
    color sidePanelColor = color(
      red(basePanelColor) * 0.7,
      green(basePanelColor) * 0.7,
      blue(basePanelColor) * 0.7
    );
    
    noStroke(); // matikan border untuk render
    
    // sisi kiri mesin (rill tp fake 3D)
    fill(sideBodyColor); // warna gelap untuk sisi
    pushMatrix();
    translate(vmLeft, vmTop); // pindah ke pojok kiri atas
    // quad = gambar quadrilateral (4 titik bebas)
    // membuat trapesium untuk efek kedalaman 3D
    quad(
      0, 0,                           // pojok kiri atas depan
      -vmSideW, +vmSideW,             // pojok kiri atas belakang
      -vmSideW, vmHeight + vmSideW,   // pojok kiri bawah belakang
      0, vmHeight                     // pojok kiri bawah depan
    );
    popMatrix();
    
    // sisi kiri atas mesin (sama)
    fill(sidePanelColor); // warna panel sisi
    pushMatrix();
    translate(vmLeft, vmTop);
    quad(
      0, 0,                      // pojok kiri atas depan
      -vmSideW, +vmSideW,        // pojok kiri atas belakang
      -vmSideW, 40 + vmSideW,    // pojok kiri bawah belakang (tinggi 40)
      0, 40                      // pojok kiri bawah depan
    );
    popMatrix();
    
    // body utama
    fill(baseBodyColor); // warna merah maroon
    noStroke();
    rect(vmX - vmWidth/2, vmY - vmHeight/2, vmWidth, vmHeight);
    
    // panel atas
    fill(basePanelColor); // warna merah lebih terang
    noStroke();
    rect(vmX - vmWidth/2, vmY - vmHeight/2, vmWidth, 40); // tinggi 40 pixel
    
    // plat vm
    fill(240, 220, 200); // warna cream terang
    rect(vmX - vmWidth/2 + 10, vmY - vmHeight/2 + 8, vmWidth - 20, 25, 4); // rounded rect
    
    // text di plat
    fill(100, 30, 30); // warna coklat gelap
    textAlign(CENTER, CENTER);
    textSize(14);
    text("SNACKS 4 FIVE COINS", vmX, vmY - vmHeight/2 + 20);
    
    // render stiker dekorasi (sale, quality, smiley, new)
    renderStickers(vmX, vmY, vmWidth, vmHeight);
    
    // display glass 
    float glassX = vmX - 130;           // posisi x glass (kiri dari tengah)
    float glassY = vmY - vmHeight/2 + 60; // posisi y glass (60 px dari atas mesin)
    float glassW = 220;                 // lebar glass
    float glassH = 320;                 // tinggi glass
    
    // frame glass (border hitam tebal)
    fill(45, 45, 50); // warna abu gelap (frame metal)
    stroke(25);       // border hitam
    strokeWeight(4);
    rect(glassX, glassY, glassW, glassH, 4); // corner radius 4
    
    // glass transparan (overlay biru muda)
    fill(150, 180, 200, 40); // biru muda dengan alpha 40 (sangat transparan)
    noStroke();
    rect(glassX + 5, glassY + 5, glassW - 10, glassH - 10); // padding 5 pixel
    
    // efek highlight glass (reflection/glare)
    fill(255, 255, 255, 50); // putih semi-transparan
    pushMatrix();
    translate(glassX + 20, glassY + 30); // posisi highlight
    rotate(-0.2); // rotasi -0.2 radian untuk diagonal
    rect(0, 0, 40, 150); // highlight bar vertikal
    popMatrix();
    
    // render semua snack di dalam glass
    renderItems2D(glassX + 15, glassY + 18);
    
    // pickup door
    float doorX = glassX;              // x sama dengan glass
    float doorY = vmY + vmHeight/2 - 90; // 90 pixel dari bawah mesin
    float doorW = glassW;              // lebar sama dengan glass
    float doorH = 70;                  // tinggi pintu 70 pixel
    
    // deteksi hover mouse di area door
    boolean isHovering = (
      mouseX > doorX && mouseX < doorX + doorW &&
      mouseY > doorY && mouseY < doorY + doorH
    );
    doorOpen = isHovering; // update state door
    
    // ubah cursor jadi tangan jika ada item dan mouse hover
    if (isHovering && collectedItem != null) {
      cursor(HAND);
    }
    
    // frame door (border luar)
    fill(35, 35, 40); // abu gelap (metal)
    stroke(25);       // border hitam
    strokeWeight(3);
    rect(doorX, doorY, doorW, doorH, 4); // corner radius 4
    
    // opening area (lubang di tengah door)
    float openingY = doorY + 12;       // 12 pixel dari atas door
    float openingH = doorH - 28;       // tinggi opening (padding atas bawah)
    
    // logic close/open pickup door (ngambil snack)
    if (doorOpen) {
      // --- DOOR TERBUKA ---
      // background opening (abu lebih terang)
      fill(45, 45, 50);
      noStroke();
      rect(doorX + 20, openingY, doorW - 40, openingH, 3); // padding 20 pixel
      
      // jika ada item collected, render item di dalam door
      if (collectedItem != null) {
        pushMatrix();
        // pindah ke tengah opening
        translate(doorX + doorW/2, openingY + openingH/2);
        
        // shadow item (ellipse bawah)
        fill(0, 0, 0, 60); // hitam semi-transparan
        noStroke();
        ellipse(0, 10, 50, 10); // shadow pipih
        
        // rotate item 90 derajat (horizontal)
        rotate(HALF_PI); // HALF_PI = 90 derajat = PI/2
        
        // render image atau fallback rect
        if (collectedItem.itemImage != null) {
          imageMode(CENTER); // draw dari center
          tint(255, 255);    // no tint effect
          image(collectedItem.itemImage, 0, 0, 50, 45); // ukuran 50x45
          noTint();          // reset tint
        } else {
          // fallback jika image tidak ada
          fill(collectedItem.snackColor);
          stroke(0);
          strokeWeight(1.5);
          rect(-25, -22.5, 50, 45, 3); // centered rect
        }
        
        popMatrix();
        imageMode(CORNER); // reset ke default mode
      }
      
      // border dalam opening (highlight jika ada item)
      noFill();
      if (collectedItem != null) {
        stroke(255, 215, 0, 150); // kuning emas (item ready)
      } else {
        stroke(120, 120, 130, 100); // abu-abu (empty)
      }
      strokeWeight(3);
      rect(doorX + 18, openingY - 2, doorW - 36, openingH + 4, 3);
      
    } else {
      // --- DOOR TERTUTUP ---
      // background opening gelap (pintu tertutup)
      fill(25, 25, 30); // hitam gelap
      noStroke();
      rect(doorX + 20, openingY, doorW - 40, openingH, 3);
      
      // jika ada item, tampilkan glow hint
      if (collectedItem != null) {
        noFill();
        stroke(255, 215, 0, 100); // kuning emas semi-transparan (hint)
        strokeWeight(2);
        rect(doorX + 18, openingY - 2, doorW - 36, openingH + 4, 3);
      }
    }
    
    // handle door (pegangan kecil di sisi kiri)
    fill(120, 120, 130); // abu-abu metal
    rect(doorX + 5, doorY + doorH/2 - 11, 12, 22, 2); // handle vertikal
    
    // render numpad
    // base koordinat numpad (semua komponen relatif ke ini)
    float numpadX = vmX + 120; // 120 pixel ke kanan dari center
    float numpadY = vmY - 50;  // 50 pixel ke atas dari center
    
    // render semua komponen UI (dari atas ke bawah)
    renderNumpad2D(numpadX, numpadY);                 // numpad 3x4
    renderInputDisplay2D(numpadX, numpadY - 78);     // LCD display (78px di atas numpad)
    renderCoinSlot(numpadX, numpadY - 93);           // coin slot (93px di atas numpad)
    renderRefundButton(numpadX, numpadY + 147);      // refund button (147px di bawah numpad)
    
    // panel bawah
    fill(60, 60, 65); // abu gelap
    stroke(30);       // border hitam
    strokeWeight(3);
    // kaki mesin di bawah (rounded bottom corners saja)
    rect(vmX - vmWidth/2, vmY + vmHeight/2 - 15, vmWidth, 18, 0, 0, 4, 4);
    
    // popMatrix = restore transformasi (pasangan pushMatrix di awal)
    popMatrix();
  }

  // render snack
  // render semua snack di grid 4x3 dalam glass window
  // handle 3 state: normal, falling, stuck
  void renderItems2D(float startX, float startY) {
    // konstanta ukuran dan jarak item
    float itemW = 70;      // lebar item
    float itemH = 65;      // tinggi item
    float spacingX = 68;   // jarak horizontal antar item
    float spacingY = 75;   // jarak vertikal antar item
    
    // koordinat glass (untuk clipping falling items)
    float glassX = 190;
    float glassY = 88;
    float glassW = 220;
    float glassH = 320;
    
    // render support rails dulu (background layers)
    renderItemSupports(startX, startY, spacingX, spacingY);
    
    // loop semua item dengan enhanced for loop (for-each)
    // syntax: for (Type var : collection)
    for (Item item : items) {
      // skip jika item sudah empty (habis dibeli)
      if (!item.isEmpty) {
        // hitung posisi default berdasarkan row/col
        float x = startX + item.col * spacingX;
        float y = startY + item.row * spacingY;
        
        // === RENDER FALLING/STUCK ITEM ===
        if (item.isFalling || item.isStuck) {
          // gunakan displayPos dari item (animated position)
          y = item.displayPos.y;
          x = item.displayPos.x;
          
          // cek apakah item masih di dalam glass (untuk clipping)
          if (y < glassY + glassH) {
            pushMatrix();
            // translate ke center item
            translate(x + itemW/2, y + itemH/2);
            rotate(item.rotation); // rotasi item saat jatuh
            
            // shadow item
            fill(0, 0, 0, 40); // hitam semi-transparan
            noStroke();
            ellipse(0, itemH/2 + 3, itemW * 0.8, 8); // shadow pipih
            
            // render image item
            if (item.itemImage != null) {
              imageMode(CENTER); // draw dari center (karena sudah translate)
              tint(255, 255);    // no tint (full opacity)
              image(item.itemImage, 0, 0, itemW, itemH);
              noTint();          // reset tint
            }
            
            popMatrix();
          }
        } else {
          // shadow item
          fill(0, 0, 0, 40);
          noStroke();
          ellipse(x + itemW/2, y + itemH + 3, itemW * 0.8, 8);
          
          // render image atau fallback rect
          if (item.itemImage != null) {
            // --- RENDER IMAGE ---
            imageMode(CORNER); // draw dari kiri atas
            tint(255, item.alpha); // apply fade in effect dengan alpha
            image(item.itemImage, x, y, itemW, itemH);
            noTint(); // reset tint
            
            // render layer tambahan untuk efek depth (stock > 1)
            // semakin banyak stock, semakin banyak layer shadow
            if (item.stock > 0) {
              // layer 1 (paling depan)
              noStroke();
              fill(0, 0, 0, 60); // hitam 60% transparan
              rect(x - 2, y - 2, itemW, itemH);
              
              if (item.stock > 1) {
                // layer 2 (tengah)
                fill(0, 0, 0, 40); // hitam 40% transparan
                rect(x - 4, y - 4, itemW, itemH);
              }
              
              if (item.stock > 2) {
                // layer 3 (paling belakang)
                fill(0, 0, 0, 20); // hitam 20% transparan
                rect(x - 6, y - 6, itemW, itemH);
              }
            }
          } else {
            // --- FALLBACK JIKA IMAGE TIDAK ADA ---
            // render rect berwarna dengan highlight
            fill(item.snackColor);
            stroke(0);
            strokeWeight(1.5);
            rect(x, y, itemW, itemH, 3); // rounded corner 3
            
            // highlight bar (efek glossy)
            fill(255, 255, 255, 80); // putih semi-transparan
            noStroke();
            rect(x + 3, y + 3, 8, itemH - 20, 2); // bar vertikal
          }
        }
      }
    }
  }

  void renderStickers(float vmX, float vmY, float vmWidth, float vmHeight) { // yep stiker
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

  // pemisah antar item di dalam display
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

  void renderCoinSlot(float x, float y) {
    // x dan y adalah *base* numpadX dan numpadY
    // posisi y slot: numpadY - 93
    // posisi x slot: numpadX - 12
    float slotX = x - 12;
    float slotY = y;

    // Logika Hover
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
        cursor(HAND); //
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

  boolean isMouseOverRefundButton(float mx, float my) {
    float numpadX = 420 + 120;
    float numpadY = height - 240 - 50;
    // koordinat sama dengan di renderRefundButton
    float btnX = numpadX + 5;
    float btnY = numpadY + 147;
    float btnSize = 15;
    return (mx > btnX && mx < btnX + btnSize && my > btnY && my < btnY + btnSize);
  }

  void addCoin() {
    coinsInserted++;
    errorMessage = ""; // hapus error message saat user masukkan koin
    errorTimer = 0;
  }

  int manualRefund() {
    int amountToRefund = coinsInserted;
    coinsInserted = 0; // kosongkan koin di mesin
    errorMessage = ""; // hapus error
    errorTimer = 0;
    return amountToRefund; // kembalikan jumlah koin
  }

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
      if (collectSound != null) {
        collectSound.play();
      }
    }
  }

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

  // dipanggil setiap frame untuk update state mesin
  // handle error timer, animasi jatuh, dan proses pembelian
  void update() {
    // === UPDATE ERROR MESSAGE TIMER ===
    // auto-hide error message setelah 2 detik (120 frame @ 60fps)
    if (errorMessage.length() > 0) {
      errorTimer++; // increment timer setiap frame
      
      // cek apakah sudah lebih dari 120 frame (2 detik)
      if (errorTimer > 120) {
        errorMessage = ""; // hapus error message
        errorTimer = 0;    // reset timer
      }
    }

    // update animasi item
    // loop semua item untuk update state masing-masing
    for (Item item : items) {
      if (item.isFalling || item.isStuck) {
        // update fisika jatuh (gravity, bounce, rotation)
        item.updateFalling();
      } else if (item.alpha < 255) {
        // fade in item baru (setelah item lama diambil)
        item.alpha += 8; // increment alpha 8 per frame (fade in speed)
        if (item.alpha > 255) item.alpha = 255; // clamp ke 255 (max opacity)
      }
    }

    // proses item di pickup door
    // tunggu animasi jatuh selesai sebelum pindahkan ke pickup door
    if (isProcessing) {
      processingTimer++; // increment timer proses
      
      // cek kondisi: item sudah landing dan timer > 60 frame (1 detik jeda)
      // conditional boolean chain dengan operator && (AND logic)
      if (selectedItem != null &&           // item ada
          !selectedItem.isFalling &&        // tidak lagi jatuh
          !selectedItem.isStuck &&          // tidak stuck
          processingTimer > 60) {           // jeda 1 detik (60 frame)
        
        // pindahkan item ke pickup door
        collectedItem = selectedItem;
        selectedItem.updateDisplayPosition(); // update posisi final
        
        // reset state proses
        isProcessing = false;
        selectedItem = null;
      }
    }
  }
}
