
// import library sound untuk efek suara dan musik
import processing.sound.*;

// state management = sistem kontrol state aplikasi (intro atau game)
//int gameState = 0; // 0 = intro, 1 = main game
String currentState = "HOME"; // "HOME", "INTRO", "GAME"
IntroAnimation introAnim; // objek untuk intro 

// objek utama game
VendingMachine vendingMachine; // objek mesin vending (logic + render)
CityBackground cityBackground; // objek background kota (langit, gedung, awan)

// sistem musik dan sound effect
// SoundFile[] = array yang berisi beberapa objek soundfile
SoundFile[] musicTracks = new SoundFile[4]; // array untuk 4 track musik
int currentTrack = 0; // index track yang sedang diputar (0-3)
boolean musicPlaying = false; // status: true = playing, false = pause

// array string berisi path file musik
String[] musicPaths = {
  "assets/sounds/music1.mp3", // track 1
  "assets/sounds/music2.mp3", // track 2
  "assets/sounds/music3.mp3", // track 3
  "assets/sounds/music4.mp3"  // track 4
};

// variable untuk berbagai sound effect (dipanggil saat event tertentu)
SoundFile numpadBeep;    // suara saat klik numpad
SoundFile machineWorks;  // suara mesin bekerja
SoundFile collectItem;   // suara ambil barang
SoundFile coinDrop;      // suara koin masuk slot
SoundFile coinRefund;    // suara refund koin

int userCoins = 1000; // saldo koin user (bisa bertambah/berkurang)

// ArrayList = list dinamis yang bisa bertambah/berkurang ukurannya
// ArrayList<AnimatedCoin> = list yang isinya cuma objek animatedcoin
ArrayList<AnimatedCoin> animatedCoins; // list untuk simpan animasi koin yang terbang

// dipanggil paling awal sebelum setup() untuk set ukuran window
void settings() {
  // size(lebar, tinggi, renderer)
  // P3D = renderer 3d 
  size(1000, 525, P3D); // window 1000x525 pixel dengan mode 3d (mentok disini, os issues)
  smooth(8); // antialiasing lv8 
}

// reminder: setup dipanggil 1 kali di awal program untuk inisialisasi semua objek
void setup() {
  textAlign(CENTER, CENTER); // set text align default ke tengah-tengah
  
  // buat objek-objek utama 
  introAnim = new IntroAnimation(); // buat objek intro animation
  cityBackground = new CityBackground(); // buat objek background kota
  vendingMachine = new VendingMachine(); // buat objek vending machine
  animatedCoins = new ArrayList<AnimatedCoin>(); // buat arraylist kosong untuk koin
  
  // loop untuk load semua track musik
  for (int i = 0; i < musicTracks.length; i++) { // i dari 0 sampai 3
    try { // try-catch untuk handle error kalau file tidak ada
      // load file musik dari path, "this" = reference ke sketch ini
      musicTracks[i] = new SoundFile(this, musicPaths[i]);
      musicTracks[i].amp(0.4); // set volume 40% (0.0 = diam, 1.0 = max)
    } catch (Exception e) { // kalau error (file tidak ketemu)
      println("gagal load musik: " + musicPaths[i]); // print pesan error
      println(e.getMessage()); // debug point
    }
  }
  
  // load sound effect
  try {
    numpadBeep = new SoundFile(this, "assets/sounds/numpadBeep.mp3");
    machineWorks = new SoundFile(this, "assets/sounds/machineWorks.mp3");
    collectItem = new SoundFile(this, "assets/sounds/collectItem.mp3");
    coinDrop = new SoundFile(this, "assets/sounds/coinDrop.mp3");
    coinRefund = new SoundFile(this, "assets/sounds/coinRefund.mp3");
    
    // set volume untuk setiap sound effect (amp = amplitude/volume)
    numpadBeep.amp(0.6);   // 60% volume
    machineWorks.amp(0.8);  // 80% volume
    collectItem.amp(0.7);   // 70% volume
    coinDrop.amp(0.9);      // 90% volume
    coinRefund.amp(0.8);    // 80% volume
  } catch (Exception e) { // catch error no file
    println("debug: " + e.getMessage()); // debug output
  }
  
  // set posisi window di tengah layar
  // displaywidth/height = ukuran layar monitor
  // width/height = ukuran window kita
  surface.setLocation((displayWidth - width)/2, (displayHeight - height)/2);
  
  initHome(); // panggil fungsi dari HomePage.pde
}

// dipanggil berulang-ulang, update dan render frame
void draw() {
  if (currentState.equals("HOME")) {
    // tampilkan halaman beranda
    drawHome();
  } 
  else if (currentState.equals("INTRO")) {
    // tampilkan animasi intro
    introAnim.update();
    introAnim.display();
  } 
  else if (currentState.equals("GAME")) {
    // tampilkan gameplay utama
    cityBackground.update();
    cityBackground.display();

    int currentSkyMode = cityBackground.getSkyMode();
    vendingMachine.update();
    vendingMachine.display(currentSkyMode);

    for (int i = animatedCoins.size() - 1; i >= 0; i--) {
      AnimatedCoin ac = animatedCoins.get(i);
      ac.update();
      ac.display();
      if (ac.isDead()) animatedCoins.remove(i);
    }

    drawMusicButton();
    drawInstructions();
    drawCoinUI();
  }
}

// dipanggil otomatis saat mouse diklik (built-in processing)
void mouseClicked() {
  // STATE: HOME PAGE 
  if (currentState.equals("HOME")) {
    mousePressedHome(); // panggil handler dari HomePage.pde
    return; // stop, jangan lanjut cek klik game
  }

  // STATE: INTRO ANIMATION 
  if (currentState.equals("INTRO")) {
    // klik di intro tidak melakukan apa pun
    return;
  }

  // STATE: MAIN GAME 
  if (currentState.equals("GAME")) {
    // --- HANDLE KLIK TOMBOL KELUAR ---
    float btnX = 60, btnY = height - 40;
    float btnW = 100, btnH = 35;
    
    boolean isExitHover = (
      mouseX > btnX - btnW/2 &&
      mouseX < btnX + btnW/2 &&
      mouseY > btnY - btnH/2 &&
      mouseY < btnY + btnH/2
    );
    
    if (isExitHover) {
      // tidak menghentikan musik, biarkan terus play
      currentState = "HOME"; 
      return;
    }

    // --- HANDLE KLIK COIN SLOT ---
    if (vendingMachine.isMouseOverCoinSlot(mouseX, mouseY)) {
      if (userCoins > 0) {
        userCoins--;
        vendingMachine.addCoin();

        float[] targetPos = vendingMachine.getCoinSlotPos();
        animatedCoins.add(new AnimatedCoin(
          targetPos[0] + 40, targetPos[1] - 50,
          targetPos[0] + 40, targetPos[1] - 30
        ));

        if (coinDrop != null) coinDrop.play();
      }
      return;
    }

    // --- HANDLE KLIK REFUND ---
    if (vendingMachine.isMouseOverRefundButton(mouseX, mouseY)) {
      int refundedAmount = vendingMachine.manualRefund();
      userCoins += refundedAmount;

      if (refundedAmount > 0 && coinRefund != null) {
        coinRefund.play();
      }
      return;
    }

    // --- HANDLE KLIK NUMPAD ---
    int refundFromNumpad = vendingMachine.handleNumpadClick(machineWorks, coinRefund);

    if (refundFromNumpad > 0) {
      userCoins += refundFromNumpad;
    } else if (refundFromNumpad == -1) {
      if (numpadBeep != null) numpadBeep.play();
    }

    // --- HANDLE KLIK PINTU PICKUP ---
    vendingMachine.handlePickupDoorClick(collectItem);
  }
}

// dipanggil otomatis saat keyboard ditekan (built-in processing)
// variable global "key" berisi karakter yang ditekan
void keyPressed() {
  // STATE: HOME PAGE 
  if (currentState.equals("HOME")) {
    // Di halaman home tidak ada kontrol keyboard
    return;
  }

  // STATE: INTRO ANIMATION 
  if (currentState.equals("INTRO")) {
    if (key == ' ') {
      // lanjut ke main game
      currentState = "GAME";
    } else if (key == 'r' || key == 'R') {
      introAnim.reset(); // reset animasi intro
    }
    return;
  }

  // STATE: MAIN GAME 
  if (currentState.equals("GAME")) {
    // tombol N = ganti musik
    if (key == 'n' || key == 'N') {
      if (musicTracks[currentTrack] != null) {
        musicTracks[currentTrack].stop();
      }
      currentTrack = (currentTrack + 1) % musicTracks.length;
      if (musicTracks[currentTrack] != null) {
        musicTracks[currentTrack].play();
        musicPlaying = true;
      } else {
        musicPlaying = false;
      }
      println("Playing Track: " + (currentTrack + 1));
    }

    // tombol R = refund semua koin
    if (key == 'r' || key == 'R') {
      int refundedAmount = vendingMachine.manualRefund();
      userCoins += refundedAmount;
      if (refundedAmount > 0 && coinRefund != null) {
        coinRefund.play();
      }
    }

    // handle input keyboard numpad
    int refundFromKey = vendingMachine.handleKeyPressed(key, machineWorks, coinRefund);
    if (refundFromKey > 0) {
      userCoins += refundFromKey;
    } else if (refundFromKey == -1) {
      if (numpadBeep != null) numpadBeep.play();
    }

    // tombol T = ganti waktu
    if (key == 't' || key == 'T') {
      cityBackground.nextSkyMode();
      println("Sky Mode: " + cityBackground.getSkyMode());
    }
  }
}

// render tombol play/pause musik di kiri bawah layar
void drawMusicButton() {
  float btnX = 60, btnY = height - 40; // posisi tengah tombol
  float btnW = 100, btnH = 35; // ukuran tombol
  
  // deteksi hover mouse
  boolean isHover = (
    mouseX > btnX - btnW/2 && mouseX < btnX + btnW/2 &&
    mouseY > btnY - btnH/2 && mouseY < btnY + btnH/2
  );
  
  // ubah warna saat hover
  if (isHover) {
    fill(255, 80, 80); // merah terang saat hover
    cursor(HAND);
  } else {
    fill(255, 50, 50); // merah normal
  }

  // gambar kotak tombol
  stroke(180, 30, 30);
  strokeWeight(3);
  rectMode(CENTER);
  rect(btnX, btnY, btnW, btnH, 8);
  rectMode(CORNER);

  // text label tombol
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("KELUAR", btnX, btnY);

  // reset style
  textAlign(LEFT);
  noStroke();
}

// tampilkan text instruksi di kiri atas layar
void drawInstructions() {
  // setting text style
  fill(255, 255, 255, 200); // putih semi-transparan (alpha 200)
  textSize(12); // ukuran font kecil
  textAlign(LEFT); // align kiri
  
  // variabel untuk tracking posisi y text
  int y_pos = 20; // mulai dari y=20
  
  // render text instruksi satu per satu
  int skyMode = cityBackground.getSkyMode();  
  if (skyMode == 3){ // ni malam, teks putih
  fill(255);
  text("Kontrol:", 10, y_pos); y_pos += 15; // header + increment y
  text("'T' : Ganti Waktu (Pagi/Siang/Sore/Malam)", 10, y_pos); y_pos += 15;
  text("'N' : Ganti Lagu (Next Track)", 10, y_pos); y_pos += 15;
  } else { // selebihnya hitam
  fill(0); 
  text("Kontrol:", 10, y_pos); y_pos += 15; // header + increment y
  text("'T' : Ganti Waktu (Pagi/Siang/Sore/Malam)", 10, y_pos); y_pos += 15;
  text("'N' : Ganti Lagu (Next Track)", 10, y_pos); y_pos += 15;
  }
}

// tampilkan jumlah koin user di kanan atas layar
void drawCoinUI() {
  // pushMatrix = save transformasi sekarang (isolasi drawing)
  pushMatrix();
  
  // hint(DISABLE_DEPTH_TEST) = matikan depth test agar UI selalu di atas 3D
  // ini penting untuk 3D rendering agar UI tidak tertimpa object 3D
  hint(DISABLE_DEPTH_TEST);
  noStroke();
  
  // koordinat dan ukuran icon koin
  float uiX = width - 90; // posisi x (90 pixel dari kanan)
  float uiY = 30; // posisi y (30 pixel dari atas)
  float iconSize = 30; // diameter icon koin
  
  // gambar lingkaran luar koin (coin border)
  fill(192, 192, 192); // warna abu-abu terang (silver)
  stroke(150, 150, 150); // border abu-abu gelap
  strokeWeight(2); // tebal border 2 pixel
  ellipse(uiX, uiY, iconSize, iconSize); // gambar lingkaran
  
  // gambar lingkaran dalam koin (inner circle)
  fill(160, 160, 160); // abu-abu lebih gelap
  noStroke(); // tanpa border
  ellipse(uiX, uiY, iconSize * 0.7, iconSize * 0.7); // 70% ukuran luar
  
  // gambar huruf "C" di tengah koin
  fill(192, 192, 192); // silver lagi
  textAlign(CENTER, CENTER); // center text
  textSize(iconSize * 0.5); // ukuran text 50% icon
  text("C", uiX, uiY); // render text "C" untuk "Coin"
  
  // gambar angka jumlah koin
  fill(255, 255, 255, 220); // putih semi-transparan
  textAlign(LEFT, CENTER); // align kiri tengah
  textSize(18); // ukuran font medium
  text(userCoins, uiX + iconSize/2 + 10, uiY); // text di kanan icon + padding 10
  
  // reset setting
  noStroke();
  textAlign(LEFT);
  
  // popMatrix = restore transformasi sebelumnya
  // pasangan dari pushMatrix, balikin state sebelum pushMatrix
  popMatrix();
}

void startIntro() {
  introAnim = new IntroAnimation();
  currentState = "INTRO";
}
