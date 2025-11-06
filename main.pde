
// import library sound
import processing.sound.*;

// state management
int gameState = 0; // 0 = intro, 1 = main game
IntroAnimation introAnim; // animasi intro

// objek utama
VendingMachine vendingMachine; // mesin utama
CityBackground cityBackground; // background kota

// musik dan sound effect
SoundFile[] musicTracks = new SoundFile[4]; // 4 lagu
int currentTrack = 0; // lagu aktif
boolean musicPlaying = false; // status musik
String[] musicPaths = {
  "assets/sounds/music.mp3",
  "assets/sounds/music.mp3",
  "assets/sounds/music.mp3",
  "assets/sounds/music.mp3"
};
SoundFile numpadBeep, machineWorks, collectItem, coinDrop, coinRefund; // efek suara
int userCoins = 200; // saldo koin user
ArrayList<AnimatedCoin> animatedCoins; // animasi koin

// pengaturan awal window
void settings() {
  size(1000, 525, P3D); // ukuran window
  smooth(8); // antialiasing
}

void setup() {
  textAlign(CENTER, CENTER); // rata tengah
  introAnim = new IntroAnimation(); // buat intro
  cityBackground = new CityBackground(); // buat background
  vendingMachine = new VendingMachine(); // buat mesin
  animatedCoins = new ArrayList<AnimatedCoin>(); // list animasi koin
  for (int i = 0; i < musicTracks.length; i++) {
    try {
      musicTracks[i] = new SoundFile(this, musicPaths[i]);
      musicTracks[i].amp(0.4); // volume 40%
    } catch (Exception e) {
      println("gagal load musik: " + musicPaths[i]);
      println(e.getMessage());
    }
  }
  try {
    numpadBeep = new SoundFile(this, "assets/sounds/numpadBeep.mp3");
    machineWorks = new SoundFile(this, "assets/sounds/machineWorks.mp3");
    collectItem = new SoundFile(this, "assets/sounds/collectItem.mp3");
    coinDrop = new SoundFile(this, "assets/sounds/coinDrop.mp3");
    coinRefund = new SoundFile(this, "assets/sounds/coinRefund.mp3");
    numpadBeep.amp(0.6); machineWorks.amp(0.8); collectItem.amp(0.7); coinDrop.amp(0.9); coinRefund.amp(0.8); // atur volume
  } catch (Exception e) {
    println("debug: " + e.getMessage());
  }
  surface.setLocation((displayWidth - width)/2, (displayHeight - height)/2); // tengah layar
}

void draw() {
  if (gameState == 0) {
    // INTRO STATE
    introAnim.update();
    introAnim.display();
  } else {
    // MAIN GAME STATE
    cityBackground.update(); // update animasi bg
    cityBackground.display(); // gambar bg
    int currentSkyMode = cityBackground.getSkyMode();
    vendingMachine.update(); // update mesin
    vendingMachine.display(currentSkyMode); // gambar mesin
    for (int i = animatedCoins.size() - 1; i >= 0; i--) {
      AnimatedCoin ac = animatedCoins.get(i); ac.update(); ac.display(); if (ac.isDead()) animatedCoins.remove(i); // update koin
    }
    drawMusicButton(); // tombol musik
    drawInstructions(); // instruksi
    drawCoinUI(); // ui koin
  }
}

void mouseClicked() {
  if (gameState == 0) {
    // no mouse interaction in intro
    return;
  }
  
  // MAIN GAME MOUSE INTERACTIONS
  float btnX = 60, btnY = height - 40, btnW = 100, btnH = 35;
  boolean isMusicHover = (mouseX > btnX - btnW/2 && mouseX < btnX + btnW/2 && mouseY > btnY - btnH/2 && mouseY < btnY + btnH/2);
  if (isMusicHover) {
    if (musicPlaying) { if (musicTracks[currentTrack] != null) musicTracks[currentTrack].pause(); musicPlaying = false; }
    else { if (musicTracks[currentTrack] != null) musicTracks[currentTrack].play(); musicPlaying = true; }
    return;
  }
  if (vendingMachine.isMouseOverCoinSlot(mouseX, mouseY)) {
    if (userCoins > 0) {
      userCoins--; vendingMachine.addCoin();
      float[] targetPos = vendingMachine.getCoinSlotPos();
      animatedCoins.add(new AnimatedCoin(targetPos[0]+40, targetPos[1] - 50, targetPos[0]+40, targetPos[1]-30)); // animasi koin
      if (coinDrop != null) coinDrop.play();
    }
    return;
  }
  if (vendingMachine.isMouseOverRefundButton(mouseX, mouseY)) {
    int refundedAmount = vendingMachine.manualRefund(); userCoins += refundedAmount;
    if (refundedAmount > 0 && coinRefund != null) coinRefund.play();
    return;
  }
  int refundFromNumpad = vendingMachine.handleNumpadClick(machineWorks, coinRefund);
  if (refundFromNumpad > 0) userCoins += refundFromNumpad; // refund
  else if (refundFromNumpad == -1) { if (numpadBeep != null) numpadBeep.play(); }
  vendingMachine.handlePickupDoorClick(collectItem); // ambil barang
}

void keyPressed() {
  if (gameState == 0) {
    // INTRO CONTROLS
    if (key == ' ') {
      gameState = 1; // masuk ke game
    } else if (key == 'r' || key == 'R') {
      introAnim.reset(); // reset intro
    }
  } else {
    // MAIN GAME CONTROLS
    if (key == 'n' || key == 'N') {
      if (musicTracks[currentTrack] != null) musicTracks[currentTrack].stop();
      currentTrack = (currentTrack + 1) % musicTracks.length;
      if (musicTracks[currentTrack] != null) { musicTracks[currentTrack].play(); musicPlaying = true; }
      else musicPlaying = false;
      println("Playing Track: " + (currentTrack + 1));
    }
    if (key == 'r' || key == 'R') {
      int refundedAmount = vendingMachine.manualRefund(); userCoins += refundedAmount;
      if (refundedAmount > 0 && coinRefund != null) coinRefund.play();
    }
    int refundFromKey = vendingMachine.handleKeyPressed(key, machineWorks, coinRefund);
    if (refundFromKey > 0) userCoins += refundFromKey;
    else if (refundFromKey == -1) { if (numpadBeep != null) numpadBeep.play(); }
    if (key == 't' || key == 'T') { cityBackground.nextSkyMode(); println("Sky Mode: " + cityBackground.getSkyMode()); }
  }
}

void drawMusicButton() {
  float btnX = 60, btnY = height - 40, btnW = 100, btnH = 35;
  boolean isHover = (mouseX > btnX - btnW/2 && mouseX < btnX + btnW/2 && mouseY > btnY - btnH/2 && mouseY < btnY + btnH/2);
  if (isHover) { fill(255, 200, 0); cursor(HAND); }
  else fill(255, 150, 0);
  stroke(200, 100, 0); strokeWeight(3); rectMode(CENTER); rect(btnX, btnY, btnW, btnH, 8); rectMode(CORNER);
  fill(255); textAlign(CENTER, CENTER); textSize(14); text(musicPlaying ? "PAUSE" : "PLAY", btnX, btnY);
  textSize(10); text("Track " + (currentTrack + 1) + "/" + musicTracks.length, btnX, btnY + 25);
  textAlign(LEFT); noStroke();
}

void drawInstructions() {
  fill(255, 255, 255, 200); textSize(12); textAlign(LEFT); int y_pos = 20;
  text("Kontrol:", 10, y_pos); y_pos += 15;
  text("'T' : Ganti Waktu (Pagi/Siang/Sore/Malam)", 10, y_pos); y_pos += 15;
  text("'N' : Ganti Lagu (Next Track)", 10, y_pos); y_pos += 15;
  text("Klik 'PLAY' : Toggle Play/Pause", 10, y_pos);
}

void drawCoinUI() {
  pushMatrix(); hint(DISABLE_DEPTH_TEST); noStroke();
  float uiX = width - 90, uiY = 30, iconSize = 30;
  fill(192, 192, 192); stroke(150, 150, 150); strokeWeight(2); ellipse(uiX, uiY, iconSize, iconSize); // koin
  fill(160, 160, 160); noStroke(); ellipse(uiX, uiY, iconSize * 0.7, iconSize * 0.7); fill(192, 192, 192); textAlign(CENTER, CENTER); textSize(iconSize * 0.5); text("C", uiX, uiY);
  fill(255, 255, 255, 220); textAlign(LEFT, CENTER); textSize(18); text(userCoins, uiX + iconSize/2 + 10, uiY);
  noStroke(); textAlign(LEFT); popMatrix();
}
