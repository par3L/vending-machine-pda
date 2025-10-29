// kelas untuk background kota dengan sistem waktu dinamis
class CityBackground {

  // === variabel lingkungan ===
  int skyMode = 0; // mode waktu: 0=pagi, 1=siang, 2=sore, 3=malam (ubah default untuk start di waktu berbeda)

  // === variabel animasi awan ===
  int numClouds = 8; // jumlah awan, ubah untuk lebih banyak/sedikit awan
  float[] cloudX = new float[numClouds]; // posisi x setiap awan
  float[] cloudY = new float[numClouds]; // posisi y setiap awan
  float[] cloudSize = new float[numClouds]; // ukuran setiap awan
  float[] cloudSpeed = new float[numClouds]; // kecepatan gerak setiap awan

  // === variabel bintang (untuk malam) ===
  int numStars = 150; // jumlah bintang, ubah untuk langit lebih ramai/sepi
  float[] starX = new float[numStars]; // posisi x setiap bintang
  float[] starY = new float[numStars]; // posisi y setiap bintang
  float[] starBrightness = new float[numStars]; // kecerahan setiap bintang (animasi berkedip)

  // === layer jendela gedung (prerendered untuk performa) ===
  PGraphics windowOffLayer; // layer jendela mati
  PGraphics windowOnLayer; // layer jendela menyala

  // === constructor - setup background saat dibuat ===
  CityBackground() {
    // setup posisi awal awan dengan random
    for (int i = 0; i < numClouds; i++) {
      cloudX[i] = random(-width, width); // spread di sepanjang layar
      cloudY[i] = random(50, 250); // posisi y random di langit
      cloudSize[i] = random(80, 150); // ukuran bervariasi
      cloudSpeed[i] = random(0.1, 0.5); // kecepatan gerak berbeda-beda
    }

    // setup posisi bintang dengan random
    for (int i = 0; i < numStars; i++) {
      starX[i] = random(width);
      starY[i] = random(5, height * 0.7); // bintang di 70% atas layar
      starBrightness[i] = random(100, 255); // kecerahan awal random
    }

    // === prerender jendela gedung untuk performa (tidak perlu render ulang tiap frame) ===
    // layer jendela mati (gelap)
    windowOffLayer = createGraphics(width, height, P2D);
    windowOffLayer.beginDraw();
    windowOffLayer.noStroke();
    windowOffLayer.fill(40, 40, 60); // warna jendela mati
    drawWindowGrid(windowOffLayer, 375, 125, 100, height-50, false); // gedung 1
    drawWindowGrid(windowOffLayer, 180, 190, 120, height-120, false); // gedung 2
    drawWindowGrid(windowOffLayer, 585, 155, 130, height-90, false); // gedung 3
    drawWindowGrid(windowOffLayer, 70,  310, 100, height-230, false);  // gedung 4
    windowOffLayer.endDraw();
    // layer jendela menyala (kuning terang)
    windowOnLayer = createGraphics(width, height, P2D);
    windowOnLayer.beginDraw();
    windowOnLayer.noStroke();
    windowOnLayer.fill(255, 220, 100); // warna jendela menyala
    drawWindowGrid(windowOnLayer, 375, 125, 100, height-50, true); // gedung 1
    drawWindowGrid(windowOnLayer, 180, 190, 120, height-120, true); // gedung 2
    drawWindowGrid(windowOnLayer, 585, 155, 130, height-90, true); // gedung 3
    drawWindowGrid(windowOnLayer, 70,  310, 100, height-230, true);  // gedung 4
    windowOnLayer.endDraw();
  }

  // === update animasi background setiap frame ===
  void update() {
    updateClouds(); // gerakkan awan
    if (skyMode == 3) { // hanya update bintang kalau malam
      updateStars(); // animasi berkedip bintang
    }
  }

  // === render semua elemen background ===
  void display() {
    // lampu menyala di pagi, sore, dan malam (tidak menyala di siang)
    boolean lightsOn = (skyMode == 0 || skyMode == 2 || skyMode == 3);
    
    // PENTING: Panggil setup cahaya 3D SEBELUM menggambar objek 3D
    drawBackgroundAndSky(); // render gradient langit dan setup lighting

    // render bintang hanya kalau malam
    if (skyMode == 3) {
      drawStars();
    }
    drawClouds(); // render awan

    drawBuildings(lightsOn); // render gedung dengan jendela
    drawStreetLights(lightsOn); // render lampu jalan
  }

  // getter untuk skymode (digunakan vending machine untuk lighting)
  int getSkyMode() {
    return skyMode;
  }

  // === event handlers ===
  void handleMouseClicked(float mx, float my) {
    // tidak ada interaksi mouse di background
  }

  void handleKeyPressed(char key) {
    // tekan 't' untuk ganti waktu (cycle: pagi -> siang -> sore -> malam -> pagi)
    if (key == 't' || key == 'T') {
      skyMode = (skyMode + 1) % 4; // loop kembali ke 0 setelah 3
      println("Sky Mode: " + skyMode); // debug info di console
    }
  }

  // === fungsi helper untuk render langit dengan gradient ===
  void drawBackgroundAndSky() {
    color topColor, bottomColor; // warna atas dan bawah gradient
    // pilih warna gradient sesuai waktu
    switch (skyMode) {
      case 0: // pagi - biru dengan kuning di bawah
        topColor = color(100, 150, 230);
        bottomColor = color(255, 220, 180); 
        break;
      case 1: // siang - biru cerah terang
        topColor = color(135, 206, 250);
        bottomColor = color(240, 240, 255); 
        break;
      case 2: // sore - oranye ke pink/merah
        topColor = color(255, 140, 0);
        bottomColor = color(255, 100, 150); 
        break;
      default: // malam - biru gelap hampir hitam
        topColor = color(0, 0, 30);
        bottomColor = color(20, 0, 60); 
        break;
    }

    drawGradient(topColor, bottomColor); // render gradient vertikal
    
    // === SETUP PENCAHAYAAN 3D ===
    lights(); 
    noStroke();
    
    // === DEKLARASI VARIABEL ===
    // Deklarasikan variabel di luar switch untuk menghindari error duplikat
    color sunCol;
    color glowCol;
    color moonCol;
    
    // Pilih setup cahaya sesuai waktu
    switch (skyMode) {
      case 0: // pagi - matahari terbit di kiri
        // Cahaya ambient (dasar) yang lembut dan hangat
        ambientLight(100, 90, 80);
        // Cahaya matahari (directional) dari kiri atas, warna kuning cerah
        directionalLight(255, 255, 200, -1, -0.5, -1);
        
        // Render matahari pagi
        sunCol = color(255, 255, 200, 200);
        glowCol = color(255, 200, 150, 60); 
        noStroke(); 
        for (int i = 8; i > 0; i--) { 
          fill(red(glowCol), green(glowCol), blue(glowCol), i * 10);
          ellipse(100, 150, 120 + i*10, 120 + i*10);
        } 
        fill(sunCol);
        ellipse(100, 150, 120, 120);
        break;
        
      case 1: // siang - matahari di tengah atas
        // Cahaya ambient putih terang
        ambientLight(150, 150, 150);
        // Cahaya matahari sangat terang dari atas
        directionalLight(255, 255, 250, 0, -1, -1);
        
        // Render matahari siang
        sunCol = color(255, 255, 220);
        glowCol = color(255, 255, 255, 50); 
        noStroke(); 
        for (int i = 10; i > 0; i--) { 
          fill(red(glowCol), green(glowCol), blue(glowCol), i * 8);
          ellipse(width/2, 120, 150 + i*10, 150 + i*10);
        } 
        fill(sunCol);
        ellipse(width/2, 120, 150, 150);
        break;
        
      case 2: // sore - matahari terbenam di kanan
        // Cahaya ambient oranye/merah
        ambientLight(120, 80, 70);
        // Cahaya matahari oranye dari kanan atas
        directionalLight(255, 150, 0, 1, -0.5, -1);
        
        // Render matahari sore
        sunCol = color(255, 200, 150, 200);
        glowCol = color(255, 140, 100, 60); 
        noStroke(); 
        for (int i = 8; i > 0; i--) { 
          fill(red(glowCol), green(glowCol), blue(glowCol), i * 10);
          ellipse(width - 100, 180, 130 + i*10, 130 + i*10);
        } 
        fill(sunCol);
        ellipse(width - 100, 180, 130, 130);
        break;
        
      default: // malam - bulan
        // Cahaya ambient biru sangat gelap
        ambientLight(30, 30, 50);
        // Cahaya bulan (directional) dari kiri atas, warna biru pucat
        directionalLight(100, 100, 150, -1, -0.5, -1);
        
        // Render bulan
        moonCol = color(240, 240, 230);
        glowCol = color(200, 220, 255, 40); 
        noStroke(); 
        for (int i = 8; i > 0; i--) { 
          fill(red(glowCol), green(glowCol), blue(glowCol), i * 8);
          ellipse(150, 150, 100 + i*8, 100 + i*8); 
        } 
        fill(moonCol); 
        ellipse(150, 150, 100, 100);
        fill(topColor);
        ellipse(160, 145, 20, 20);
        ellipse(130, 170, 15, 15);
        break;
    }
  }
  // fungsi utility untuk render gradient vertikal
  void drawGradient(color c1, color c2) {
    noStroke();
    beginShape(QUADS); 
    fill(c1); // warna atas
    vertex(0, 0); 
    vertex(width, 0); 
    fill(c2); // warna bawah
    vertex(width, height); 
    vertex(0, height); 
    endShape(CLOSE);
  }

  // render semua gedung dengan jendela
  void drawBuildings(boolean lightsOn) {
    noStroke();
    float y_base_offset = 50; // offset untuk posisi gedung, ubah untuk geser gedung
    // render 4 gedung dengan posisi, ukuran, dan warna berbeda
    // parameter: (x, y, lebar, tinggi, lebar_sisi_3d, warna_base, lampu_nyala)
    drawSingleBuilding(350, 100 + y_base_offset, 100, height-50, 25, color(40, 45, 60), lightsOn);
    drawSingleBuilding(150, 170 + y_base_offset, 120, height-120, 30, color(50, 50, 55), lightsOn);
    drawSingleBuilding(550, 140 + y_base_offset, 130, height-90, 35, color(45, 50, 50), lightsOn);
    drawSingleBuilding(50, 280 + y_base_offset, 100, height-230, 20, color(60, 60, 70), lightsOn);
    // render layer jendela (prerendered untuk performa)
    image(windowOffLayer, 0, 0); // jendela gelap
    if (lightsOn) { 
      image(windowOnLayer, 0, 0); // overlay jendela terang kalau lampu nyala
    }
  }

  // render satu gedung dengan efek 3d sederhana dan lighting dinamis
  void drawSingleBuilding(float x, float y, float w, float h, float sideW, color base, boolean lightsOn) {
    // hitung warna dasar dan sisi 3d
    color mainFaceColor = base; // warna depan gedung
    color sideFaceColor = color(red(base) * 0.7, green(base) * 0.7, blue(base) * 0.7); // sisi lebih gelap
    
    // [DIHAPUS] Blok switch(skyMode) untuk lerpColor dihapus.
    // Pencahayaan sekarang ditangani oleh ambientLight dan directionalLight.
    
    // render sisi kiri gedung (efek 3d)
    fill(sideFaceColor);
    pushMatrix(); 
    translate(x, y); 
    quad(0, 0, sideW, -sideW, sideW, h - sideW, 0, h); // bentuk trapesium
    popMatrix();
    // render depan gedung
    fill(mainFaceColor); 
    rect(x + sideW, y - sideW, w, h);
  }

  // render grid jendela di gedung (dipanggil di constructor untuk prerender)
  void drawWindowGrid(PGraphics pg, float x, float y, float w, float h, boolean drawRandomly) {
    float winSizeW = 8; // lebar jendela, ubah untuk resize
    float winSizeH = 12; // tinggi jendela, ubah untuk resize
    float gapX = 10; // jarak horizontal antar jendela, ubah untuk spacing
    float gapY = 15; // jarak vertikal antar jendela, ubah untuk spacing
    // loop untuk gambar jendela dalam grid
    for (float wy = y + gapY; wy < y + h - winSizeH; wy += winSizeH + gapY) {
      for (float wx = x + gapX; wx < x + w - winSizeW; wx += winSizeW + gapX) {
        if (!drawRandomly) { 
          pg.rect(wx, wy, winSizeW, winSizeH, 1); // gambar semua jendela
        }
        else { 
          // gambar jendela random (70% kemungkinan menyala)
          if (random(1) > 0.3) { 
            pg.rect(wx, wy, winSizeW, winSizeH, 1);
          } 
        }
      }
    }
  }

  // render lampu jalan di kiri dan kanan layar
  void drawStreetLights(boolean lightsOn) {
    drawSingleStreetLight(100, height, lightsOn); // lampu kiri
    drawSingleStreetLight(width - 100, height, lightsOn); // lampu kanan
  }

  // render satu lampu jalan lengkap dengan efek cahaya
  void drawSingleStreetLight(float x, float y, boolean lightsOn) {
    noStroke();
    // alas tiang lampu
    fill(20, 20, 25);
    rect(x - 15, y - 15, 30, 15, 3);
    // tiang lampu vertikal
    float poleTopY = y - 300; // posisi atas tiang, ubah untuk tinggi lampu berbeda
    float poleBottomY = y - 15;
    float poleHeight = poleBottomY - poleTopY;
    fill(30, 30, 35);
    rect(x - 5, poleTopY, 10, poleHeight); // tiang 10px lebar

    // lengan lampu horizontal (mengarah ke kanan)
    fill(45, 45, 50);
    float armWidth = 8; // ketebalan lengan
    float armLength = 55; // panjang lengan, ubah untuk jarak lampu dari tiang
    beginShape();
    vertex(x - 5, poleTopY);
    vertex(x + armLength, poleTopY + 5);
    vertex(x + armLength, poleTopY + 5 + armWidth);
    vertex(x - 5, poleTopY + armWidth * 0.5);
    endShape(CLOSE);

    // posisi bohlam di ujung lengan
    float bulbX = x + armLength;
    float bulbY = poleTopY + 5 + armWidth/2;

    // Rumah Lampu
    fill(50, 50, 60);
    ellipse(bulbX, bulbY, 20, 20);

    // === render lampu dan efek cahaya ===
    if (lightsOn) {
      color glowBaseColor = color(255, 240, 180);
      
      // === TAMBAHAN: Point Light ===
      // Tambahkan sumber cahaya titik (pointLight) di posisi bohlam.
      // Ini akan menyinari objek 3D di dekatnya (gedung, vending machine).
      // Z-posisi 200 berarti cahaya ada di depan scene (yang ada di z=0).
      pointLight(red(glowBaseColor), green(glowBaseColor), blue(glowBaseColor), 
                 bulbX, bulbY, 200);

      // render glow effect 2D (masih dipertahankan untuk efek "bloom")
      for (int i = 12; i > 0; i--) { // loop layers glow dari besar ke kecil
        // transparansi berkurang semakin jauh dari lampu
        float alpha = map(i, 1, 12, 10, 80);
        fill(red(glowBaseColor), green(glowBaseColor), blue(glowBaseColor), alpha);

        // bentuk elips melebar horizontal untuk efek cahaya ke bawah
        float glowWidth = 15 + i * 8; // lebar bertambah per layer
        float glowHeight = 10 + i * 3; // tinggi bertambah per layer
        float glowYOffset = 10 + (12-i)*1.5; // cahaya turun ke bawah

        ellipse(bulbX, bulbY + glowYOffset, glowWidth, glowHeight);
      }

      // render cahaya inti di bohlam
      fill(255, 255, 220, 230); // kuning terang semi transparan
      ellipse(bulbX, bulbY, 14, 14);
      // render bohlam inti
      fill(255, 255, 240); // putih kekuningan sangat terang
      ellipse(bulbX, bulbY, 8, 8); // bohlam kecil di tengah

    } else {
      // lampu mati - warna gelap
      fill(80, 80, 90);
      ellipse(bulbX, bulbY, 12, 12);
    }
  }


  // render satu awan fluffy dengan multiple ellipse
  void drawFluffyCloud(float x, float y, float size) {
    noStroke();
    // layer bayangan awan (lebih transparan dan di bawah)
    fill(220, 220, 225, 70);
    ellipse(x, y + 10, size * 1.2, size * 0.5);
    ellipse(x - size * 0.3, y + 12, size * 0.8, size * 0.4);
    ellipse(x + size * 0.3, y + 12, size * 0.9, size * 0.45);
    // layer utama awan (putih lebih solid)
    fill(255, 255, 255, 160); 
    ellipse(x, y, size, size * 0.6);
    ellipse(x + size * 0.4, y, size * 0.7, size * 0.5);
    ellipse(x - size * 0.3, y - 5, size * 0.8, size * 0.7);
    ellipse(x + size * 0.1, y - 10, size, size * 0.6);
  }

  // render semua awan
  void drawClouds() {
    for (int i = 0; i < numClouds; i++) { 
      drawFluffyCloud(cloudX[i], cloudY[i], cloudSize[i]);
    }
  }

  // render semua bintang (hanya di malam)
  void drawStars() {
    noStroke();
    for (int i = 0; i < numStars; i++) { 
      fill(255, 255, 200, starBrightness[i]); // kuning dengan brightness dinamis
      ellipse(starX[i], starY[i], 2, 2); // bintang kecil 2x2 pixel
    }
  }

  // update posisi awan (bergerak ke kanan, loop kembali dari kiri)
  void updateClouds() {
    for (int i = 0; i < numClouds; i++) { 
      cloudX[i] += cloudSpeed[i]; // gerak ke kanan
      // kalau keluar dari layar kanan, muncul lagi dari kiri dengan posisi y random
      if (cloudX[i] > width + cloudSize[i]) { 
        cloudX[i] = -cloudSize[i] * 1.5;
        cloudY[i] = random(50, 250); 
      } 
    }
  }

  // update kecerahan bintang (animasi berkedip)
  void updateStars() {
    for (int i = 0; i < numStars; i++) { 
      starBrightness[i] += random(-15, 15); // random change brightness
      starBrightness[i] = constrain(starBrightness[i], 100, 255); // batasi range 100-255
    }
  }
}
