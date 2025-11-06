
// kelas background kota
class CityBackground {
  int skyMode = 0; // mode langit: 0 pagi, 1 siang, 2 sore, 3 malam
  int numClouds = 8; // jumlah awan
  float[] cloudX = new float[numClouds]; // posisi x awan
  float[] cloudY = new float[numClouds]; // posisi y awan
  float[] cloudSize = new float[numClouds]; // ukuran awan
  float[] cloudSpeed = new float[numClouds]; // kecepatan awan
  int numStars = 150; // jumlah bintang
  float[] starX = new float[numStars]; // posisi x bintang
  float[] starY = new float[numStars]; // posisi y bintang
  float[] starBrightness = new float[numStars]; // kecerahan bintang
  PGraphics windowOffLayer;  // layer jendela mati
  PGraphics windowOnLayer;   // layer jendela nyala

  CityBackground() {
    // random posisi awan
    for (int i = 0; i < numClouds; i++) {
      cloudX[i] = random(-width, width); // x acak
      cloudY[i] = random(50, 250); // y acak
      cloudSize[i] = random(80, 150); // ukuran acak
      cloudSpeed[i] = random(0.1, 0.5); // kecepatan acak
    }
    // random posisi bintang
    for (int i = 0; i < numStars; i++) {
      starX[i] = random(width); // x acak
      starY[i] = random(5, height * 0.7); // y acak
      starBrightness[i] = random(100, 255); // kecerahan acak
    }
    // gambar layer jendela mati
    windowOffLayer = createGraphics(width, height, P2D);
    windowOffLayer.beginDraw();
    windowOffLayer.noStroke();
    windowOffLayer.fill(40, 40, 60);
    drawWindowGrid(windowOffLayer, 375, 125, 100, height-50, false);
    drawWindowGrid(windowOffLayer, 180, 190, 120, height-120, false);
    drawWindowGrid(windowOffLayer, 585, 155, 130, height-90, false);
    drawWindowGrid(windowOffLayer, 70, 310, 100, height-230, false);
    drawWindowGrid(windowOffLayer, 810, 320, 100, height-230, false); // gedung 5
    windowOffLayer.endDraw();
    // gambar layer jendela nyala
    windowOnLayer = createGraphics(width, height, P2D);
    windowOnLayer.beginDraw();
    windowOnLayer.noStroke();
    windowOnLayer.fill(255, 220, 100);
    drawWindowGrid(windowOnLayer, 375, 125, 100, height-50, true);
    drawWindowGrid(windowOnLayer, 180, 190, 120, height-120, true);
    drawWindowGrid(windowOnLayer, 585, 155, 130, height-90, true);
    drawWindowGrid(windowOnLayer, 70, 310, 100, height-230, true);
    drawWindowGrid(windowOnLayer, 810, 320, 100, height-230, true); // gedung 5
    windowOnLayer.endDraw();
  }

  void update() {
    updateClouds(); // update posisi awan
    if (skyMode == 3) updateStars(); // update bintang kalau malam
  }

  void display() {
    boolean lightsOn = (skyMode == 0 || skyMode == 2 || skyMode == 3); // lampu nyala pagi/sore/malam
    drawBackgroundAndSky(); // gambar langit
    if (skyMode == 3) drawStars(); // gambar bintang kalau malam
    drawClouds(); // gambar awan
    drawBuildings(lightsOn); // gambar gedung
    drawStreetLights(lightsOn); // gambar lampu jalan
  }


  int getSkyMode() {
    return skyMode;
  } // ambil mode langit sekarang
  void nextSkyMode() {
    skyMode = (skyMode + 1) % 4;
  } // ganti mode langit


  void drawBackgroundAndSky() {
    color topColor, bottomColor;
    switch (skyMode) {
    case 0:
      topColor = color(100, 150, 230);
      bottomColor = color(255, 220, 180);
      break; // pagi
    case 1:
      topColor = color(135, 206, 250);
      bottomColor = color(240, 240, 255);
      break; // siang
    case 2:
      topColor = color(255, 140, 0);
      bottomColor = color(255, 100, 150);
      break; // sore
    default:
      topColor = color(0, 0, 30);
      bottomColor = color(20, 0, 60);
      break; // malam
    }
    drawGradient(topColor, bottomColor); // gradient langit
    lights(); // aktifkan lighting
    noStroke();
    color sunCol, glowCol, moonCol;
    switch (skyMode) {
    case 0:
      ambientLight(100, 90, 80);
      directionalLight(255, 255, 200, -1, -0.5, -1);
      sunCol = color(255, 255, 200, 200);
      glowCol = color(255, 200, 150, 60);
      break; // pagi
    case 1:
      ambientLight(150, 150, 150);
      directionalLight(255, 255, 250, 0, -1, -1);
      sunCol = color(255, 255, 220);
      glowCol = color(255, 255, 255, 50);
      break; // siang
    case 2:
      ambientLight(120, 80, 70);
      directionalLight(255, 150, 0, 1, -0.5, -1);
      sunCol = color(255, 200, 150, 200);
      glowCol = color(255, 140, 100, 60);
      break; // sore
    default:
      ambientLight(30, 30, 50);
      directionalLight(100, 100, 150, -1, -0.5, -1);
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
      ellipse(160, 145, 5, 20);
      ellipse(130, 170, 2, 15);
      break; // malam
    }
  }

  void drawGradient(color c1, color c2) {
    noStroke(); // tanpa garis
    beginShape(QUADS);
    fill(c1);
    vertex(0, 0);
    vertex(width, 0);
    fill(c2);
    vertex(width, height);
    vertex(0, height);
    endShape(CLOSE); // gradient vertikal
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
