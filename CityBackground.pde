
// class city
// berisi render background kota dinamis dengan 4 waktu (pagi/siang/sore/malam)
// termasuk langit gradient, awan animated, bintang, gedung, lampu jalan
class CityBackground {
  // === VARIABEL SKY MODE ===
  int skyMode = 0; // mode waktu: 0=pagi, 1=siang, 2=sore, 3=malam
  
  // init awan
  int numClouds = 8;                      // jumlah awan di langit
  float[] cloudX = new float[numClouds];  // array posisi x setiap awan
  float[] cloudY = new float[numClouds];  // array posisi y setiap awan
  float[] cloudSize = new float[numClouds];  // array ukuran setiap awan
  float[] cloudSpeed = new float[numClouds]; // array kecepatan gerak setiap awan
  
  // init bintant
  int numStars = 150;                        // jumlah bintang (hanya malam)
  float[] starX = new float[numStars];       // array posisi x setiap bintang
  float[] starY = new float[numStars];       // array posisi y setiap bintang
  float[] starBrightness = new float[numStars]; // array kecerahan setiap bintang (efek twinkle)
  

  // PGraphics = buffer untuk pre-render 
  // jendela-jendela gedung di-render sekali saja, tidak setiap frame 
  PGraphics windowOffLayer;  // layer jendela mati (abu-abu gelap)
  PGraphics windowOnLayer;   // layer jendela nyala (kuning terang)

  // === CONSTRUCTOR ===
  CityBackground() {
    // === INISIALISASI AWAN 
    // set posisi dan property acak untuk setiap awan
    for (int i = 0; i < numClouds; i++) {
      cloudX[i] = random(-width, width);  // x acak dari luar kiri sampai luar kanan
      cloudY[i] = random(50, 250);        // y acak di area atas langit
      cloudSize[i] = random(80, 150);     // ukuran acak antara 80-150 pixel
      cloudSpeed[i] = random(0.1, 0.5);   // kecepatan gerak acak (pixel per frame)
    }
    
    // === INISIALISASI BINTANG ===
    // set posisi dan kecerahan acak untuk setiap bintang
    for (int i = 0; i < numStars; i++) {
      starX[i] = random(width);              // x acak di seluruh layar
      starY[i] = random(5, height * 0.7);    // y acak di 70% atas layar
      starBrightness[i] = random(100, 255);  // kecerahan acak (efek twinkle)
    }
    
    // === PRE-RENDER LAYER JENDELA MATI ===
    // createGraphics = buat off-screen buffer dengan renderer P2D (2D cepat)
    windowOffLayer = createGraphics(width, height, P2D);
    windowOffLayer.beginDraw(); // mulai drawing ke buffer
    windowOffLayer.noStroke();
    windowOffLayer.fill(40, 40, 60); // warna jendela mati (abu-abu biru gelap)
    
    // draw 5 gedung dengan jendela mati (false = off)
    drawWindowGrid(windowOffLayer, 375, 125, 100, height-50, false);   // gedung 1
    drawWindowGrid(windowOffLayer, 180, 190, 120, height-120, false);  // gedung 2
    drawWindowGrid(windowOffLayer, 585, 155, 130, height-90, false);   // gedung 3
    drawWindowGrid(windowOffLayer, 70, 310, 100, height-230, false);   // gedung 4
    drawWindowGrid(windowOffLayer, 810, 320, 100, height-230, false);  // gedung 5
    
    windowOffLayer.endDraw(); // selesai drawing
    
    // === PRE-RENDER LAYER JENDELA NYALA ===
    windowOnLayer = createGraphics(width, height, P2D);
    windowOnLayer.beginDraw();
    windowOnLayer.noStroke();
    windowOnLayer.fill(255, 220, 100); // warna jendela nyala (kuning warm)
    
    // draw 5 gedung dengan jendela nyala (true = on)
    drawWindowGrid(windowOnLayer, 375, 125, 100, height-50, true);   // gedung 1
    drawWindowGrid(windowOnLayer, 180, 190, 120, height-120, true);  // gedung 2
    drawWindowGrid(windowOnLayer, 585, 155, 130, height-90, true);   // gedung 3
    drawWindowGrid(windowOnLayer, 70, 310, 100, height-230, true);   // gedung 4
    drawWindowGrid(windowOnLayer, 810, 320, 100, height-230, true);  // gedung 5
    
    windowOnLayer.endDraw();
  }

  // === FUNGSI UPDATE ===
  // dipanggil setiap frame untuk update animasi (awan, bintang)
  void update() {
    updateClouds(); // geser posisi awan (scrolling)
    
    // update bintang hanya saat mode malam (skyMode == 3)
    if (skyMode == 3) {
      updateStars(); // twinkle effect (ubah kecerahan)
    }
  }

  // === FUNGSI DISPLAY ===
  // dipanggil setiap frame untuk render seluruh background
  void display() {
    // tentukan apakah lampu gedung/jalan nyala
    // lampu nyala di: pagi (0), sore (2), malam (3)
    // lampu mati di: siang (1)
    boolean lightsOn = (skyMode == 0 || skyMode == 2 || skyMode == 3);
    
    // render layer by layer (dari belakang ke depan)
    drawBackgroundAndSky();      // layer 1: gradient langit
    if (skyMode == 3) drawStars(); // layer 2: bintang (hanya malam)
    drawClouds();                // layer 3: awan
    drawBuildings(lightsOn);     // layer 4: gedung + jendela
    drawStreetLights(lightsOn);  // layer 5: lampu jalan
  }


  // === GETTER & SETTER ===
  // getter = fungsi untuk ambil nilai variabel private/protected
  int getSkyMode() {
    return skyMode; // return mode langit sekarang (0-3)
  }
  
  // cycle ke mode berikutnya dengan modulo (loop 0→1→2→3→0)
  void nextSkyMode() {
    skyMode = (skyMode + 1) % 4; // modulo 4 untuk loop
  }


  // === FUNGSI DRAW BACKGROUND DAN SKY ===
  // render gradient langit dan setup lighting berdasarkan sky mode
  void drawBackgroundAndSky() {
    // variabel untuk warna gradient (atas dan bawah)
    color topColor, bottomColor;
    
    // === PILIH WARNA BERDASARKAN SKY MODE ===
    // switch-case = control flow untuk multiple conditions
    switch (skyMode) {
    case 0: // --- PAGI ---
      topColor = color(100, 150, 230);    // biru langit pagi (atas)
      bottomColor = color(255, 220, 180); // orange muda (bawah/horizon)
      break; // keluar dari switch
      
    case 1: // --- SIANG ---
      topColor = color(135, 206, 250);    // sky blue terang (atas)
      bottomColor = color(240, 240, 255); // putih kebiruan (bawah)
      break;
      
    case 2: // --- SORE ---
      topColor = color(255, 140, 0);      // orange terang (atas)
      bottomColor = color(255, 100, 150); // pink sunset (bawah)
      break;
      
    default: // --- MALAM (case 3) ---
      topColor = color(0, 0, 30);         // biru gelap hampir hitam (atas)
      bottomColor = color(20, 0, 60);     // ungu gelap (bawah)
      break;
    }
    
    // render gradient langit dari atas ke bawah
    drawGradient(topColor, bottomColor);
    
    // === SETUP LIGHTING 3D ===
    // lights() = aktifkan default lighting Processing (untuk render 3D)
    lights();
    noStroke(); // matikan stroke untuk render matahari/bulan
    
    // === VARIABEL WARNA CELESTIAL BODY ===
    color sunCol, glowCol, moonCol; // warna matahari, glow, bulan
    
    // === SETUP LIGHTING BERDASARKAN SKY MODE ===
    switch (skyMode) {
    case 0: // --- PAGI ---
      // ambientLight = cahaya ambient (menyinari semua object merata)
      ambientLight(100, 90, 80); // cahaya warm pagi
      
      // directionalLight = cahaya directional (dari arah tertentu)
      // parameter: (r, g, b, vx, vy, vz) - vx/vy/vz adalah vektor arah
      directionalLight(255, 255, 200, -1, -0.5, -1); // cahaya dari kiri atas
      
      sunCol = color(255, 255, 200, 200);  // matahari kuning muda
      glowCol = color(255, 200, 150, 60);  // glow orange muda
      break;
      
    case 1: // --- SIANG ---
      ambientLight(150, 150, 150); // cahaya terang merata
      directionalLight(255, 255, 250, 0, -1, -1); // cahaya dari atas
      sunCol = color(255, 255, 220);      // matahari putih terang
      glowCol = color(255, 255, 255, 50); // glow putih soft
      break;
      
    case 2: // --- SORE ---
      ambientLight(120, 80, 70); // cahaya warm gelap
      directionalLight(255, 150, 0, 1, -0.5, -1); // cahaya orange dari kanan
      sunCol = color(255, 200, 150, 200);  // matahari orange terang
      glowCol = color(255, 140, 100, 60);  // glow merah-orange
      break;
      
    default: // --- MALAM ---
      ambientLight(30, 30, 50); // cahaya sangat gelap dengan tint biru
      directionalLight(100, 100, 150, -1, -0.5, -1); // cahaya bulan dari kiri
      moonCol = color(240, 240, 230); // bulan putih kekuningan
      glowCol = color(200, 220, 255, 40);
      noStroke();
      for (int i = 8; i > 0; i--) {
        fill(red(glowCol), green(glowCol), blue(glowCol), i * 8);
        ellipse(150, 150, 100 + i*8, 100 + i*8);
      }
      fill(moonCol);
      ellipse(150, 150, 100, 100);
      fill(topColor);
      ellipse(160, 145, 5, 20);
      ellipse(130, 170, 2, 15);
      break; // malam
    }
  }

  // === FUNGSI DRAW GRADIENT ===
  // render gradient vertikal dari warna c1 (atas) ke c2 (bawah)
  // menggunakan vertex color interpolation
  void drawGradient(color c1, color c2) {
    noStroke(); // tanpa border
    
    // beginShape(QUADS) = mulai gambar bentuk dari 4 vertex 
    beginShape(QUADS);
    
    // === VERTEX ATAS (WARNA c1) ===
    fill(c1); // set warna fill untuk 2 vertex atas
    vertex(0, 0);      // kiri atas
    vertex(width, 0);  // kanan atas
    
    // === VERTEX BAWAH (WARNA c2) ===
    fill(c2); // set warna fill untuk 2 vertex bawah
    vertex(width, height); // kanan bawah
    vertex(0, height);     // kiri bawah
    
    // endShape(CLOSE) = tutup shape dan render
    // Processing otomatis interpolate warna antara vertex (gradient smooth)
    endShape(CLOSE);
  }


  void drawBuildings(boolean lightsOn) {
    noStroke();
    float y_base_offset = 50; // offset posisi gedung

    drawSingleBuilding(350, 100 + y_base_offset, 100, height-50, 25, color(40, 45, 60), lightsOn); // gedung 1
    drawSingleBuilding(150, 170 + y_base_offset, 120, height-120, 30, color(50, 50, 55), lightsOn); // gedung 2
    drawSingleBuilding(550, 140 + y_base_offset, 130, height-90, 35, color(45, 50, 50), lightsOn); // gedung 3
    drawSingleBuilding(50, 280 + y_base_offset, 100, height-230, 20, color(60, 60, 70), lightsOn); // gedung 4
    drawSingleBuilding(790, 280 + y_base_offset, 100, height-230, 20, color(60, 60, 70), lightsOn); // gedung 5
    image(windowOffLayer, 0, 0); // layer jendela mati
    if (lightsOn) image(windowOnLayer, 0, 0); // layer jendela nyala
  }


  void drawSingleBuilding(float x, float y, float w, float h, float sideW, color base, boolean lightsOn) {
    color mainFaceColor = base; // warna depan
    color sideFaceColor = color(red(base) * 0.7, green(base) * 0.7, blue(base) * 0.7); // warna sisi
    fill(sideFaceColor);
    pushMatrix();
    translate(x, y);
    quad(0, 0, sideW, -sideW, sideW, h - sideW, 0, h);
    popMatrix(); // sisi kiri
    fill(mainFaceColor);
    rect(x + sideW, y - sideW, w, h); // depan
  }


  void drawWindowGrid(PGraphics pg, float x, float y, float w, float h, boolean drawRandomly) {
    float winSizeW = 8;
    float winSizeH = 12;
    float gapX = 10;
    float gapY = 15;
    for (float wy = y + gapY; wy < y + h - winSizeH; wy += winSizeH + gapY) {
      for (float wx = x + gapX; wx < x + w - winSizeW; wx += winSizeW + gapX) {
        if (!drawRandomly) pg.rect(wx, wy, winSizeW, winSizeH, 1); // semua jendela
        else if (random(1) > 0.3) pg.rect(wx, wy, winSizeW, winSizeH, 1); // random 70% nyala
      }
    }
  }


  void drawStreetLights(boolean lightsOn) {
    drawSingleStreetLight(100, height, lightsOn); // lampu kiri
    drawSingleStreetLight(width - 100, height, lightsOn); // lampu kanan
  }


  void drawSingleStreetLight(float x, float y, boolean lightsOn) {
    noStroke();
    fill(20, 20, 25);
    rect(x - 15, y - 15, 30, 15, 3); // alas tiang
    float poleTopY = y - 380;
    float poleBottomY = y - 15;
    float poleHeight = poleBottomY - poleTopY;
    fill(30, 30, 35);
    rect(x - 5, poleTopY, 10, poleHeight); // tiang
    fill(45, 45, 50);
    float armWidth = 8;
    float armLength = 55;
    beginShape();
    vertex(x - 5, poleTopY);
    vertex(x + armLength, poleTopY + 5);
    vertex(x + armLength, poleTopY + 5 + armWidth);
    vertex(x - 5, poleTopY + armWidth * 0.5);
    endShape(CLOSE); // lengan
    float bulbX = x + armLength;
    float bulbY = poleTopY + 5 + armWidth/2;
    fill(50, 50, 60);
    ellipse(bulbX, bulbY, 20, 20); // rumah lampu
    if (lightsOn) {
      color glowBaseColor = color(255, 240, 180);
      pointLight(red(glowBaseColor), green(glowBaseColor), blue(glowBaseColor), bulbX, bulbY, 200); // cahaya 3d
      for (int i = 12; i > 0; i--) {
        float alpha = map(i, 1, 12, 10, 80);
        fill(red(glowBaseColor), green(glowBaseColor), blue(glowBaseColor), alpha);
        float glowWidth = 15 + i * 8;
        float glowHeight = 10 + i * 3;
        float glowYOffset = 10 + (12-i)*1.5;
        ellipse(bulbX, bulbY + glowYOffset, glowWidth, glowHeight);
      } // efek glow
      fill(255, 255, 220, 230);
      ellipse(bulbX, bulbY, 14, 14);
      fill(255, 255, 240);
      ellipse(bulbX, bulbY, 8, 8); // bohlam terang
    } else {
      fill(80, 80, 90);
      ellipse(bulbX, bulbY, 12, 12);
    } // lampu mati
  }



  void drawFluffyCloud(float x, float y, float size) {
    noStroke();
    fill(220, 220, 225, 70);
    ellipse(x, y + 10, size * 1.2, size * 0.5);
    ellipse(x - size * 0.3, y + 12, size * 0.8, size * 0.4);
    ellipse(x + size * 0.3, y + 12, size * 0.9, size * 0.45);
    fill(255, 255, 255, 160);
    ellipse(x, y, size, size * 0.6);
    ellipse(x + size * 0.4, y, size * 0.7, size * 0.5);
    ellipse(x - size * 0.3, y - 5, size * 0.8, size * 0.7);
    ellipse(x + size * 0.1, y - 10, size, size * 0.6); // awan fluffy
  }


  void drawClouds() {
    for (int i = 0; i < numClouds; i++) drawFluffyCloud(cloudX[i], cloudY[i], cloudSize[i]); // gambar semua awan
  }


  void drawStars() {
    noStroke();
    for (int i = 0; i < numStars; i++) {
      fill(255, 255, 200, starBrightness[i]);
      ellipse(starX[i], starY[i], 2, 2);
    } // gambar bintang kecil
  }


  void updateClouds() {
    for (int i = 0; i < numClouds; i++) {
      cloudX[i] += cloudSpeed[i]; // awan ke kanan
      if (cloudX[i] > width + cloudSize[i]) {
        cloudX[i] = -cloudSize[i] * 1.5;
        cloudY[i] = random(50, 250);
      } // reset ke kiri
    }
  }


  void updateStars() {
    for (int i = 0; i < numStars; i++) {
      starBrightness[i] += random(-15, 15); // kedip acak
      starBrightness[i] = constrain(starBrightness[i], 100, 255); // batasi range
    }
  }
}
