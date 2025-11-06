
// import library sound untuk efek suara dan musik
import processing.sound.*;

// === VARIABLE GLOBAL (bisa diakses di semua fungsi) ===

// state management = sistem kontrol state aplikasi (intro atau game)
int gameState = 0; // 0 = intro, 1 = main game
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

int userCoins = 200; // saldo koin user (bisa bertambah/berkurang)

// ArrayList = list dinamis yang bisa bertambah/berkurang ukurannya (beda dari array biasa)
// ArrayList<AnimatedCoin> = list yang isinya cuma objek animatedcoin
ArrayList<AnimatedCoin> animatedCoins; // list untuk simpan animasi koin yang terbang

// === FUNGSI SETTINGS ===
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
  } catch (Exception e) { // kalau ada file sound tidak ketemu
    println("debug: " + e.getMessage()); // debug
  }
  
  // set posisi window di tengah layar
  // displaywidth/height = ukuran layar monitor
  // width/height = ukuran window kita
  surface.setLocation((displayWidth - width)/2, (displayHeight - height)/2);
}

// === FUNGSI DRAW ===
// dipanggil berulang-ulang (60x per detik) untuk update dan render frame
void draw() {
  // cek state sekarang (intro atau game)
  if (gameState == 0) {
    // === STATE INTRO ===
    introAnim.update();  // update logic animasi intro (gerakan, fase, dll)
    introAnim.display(); // render animasi intro ke layar
  } else {
    // === STATE MAIN GAME ===
    
    // update dan render background kota
    cityBackground.update(); // update animasi awan, bintang, dll
    cityBackground.display(); // gambar langit, gedung, lampu jalan
    
    // ambil mode waktu sekarang untuk lighting
    int currentSkyMode = cityBackground.getSkyMode(); // 0=pagi, 1=siang, 2=sore, 3=malam
    
    // update dan render vending machine
    vendingMachine.update(); // update state mesin (item jatuh, timer, dll)
    vendingMachine.display(currentSkyMode); // gambar mesin dengan lighting sesuai waktu
    
    // update dan render semua animasi koin yang terbang
    // loop mundur (dari belakang ke depan) biar aman saat remove item
    for (int i = animatedCoins.size() - 1; i >= 0; i--) { // size() = jumlah item di arraylist
      AnimatedCoin ac = animatedCoins.get(i); // get(i) = ambil item di index i
      ac.update();  // update posisi koin
      ac.display(); // render koin
      
      // kalau koin sudah mati (lifetime habis)
      if (ac.isDead()) {
        animatedCoins.remove(i); // remove dari arraylist (hemat memori)
      }
    }
    
    // render ui overlay (tampilan di atas semua)
    drawMusicButton();   // tombol play/pause musik
    drawInstructions();  // text instruksi kontrol
    drawCoinUI();        // icon koin dan saldo
  }
}

// === FUNGSI MOUSECLICKED ===
// dipanggil otomatis saat mouse diklik (built-in processing)
void mouseClicked() {
  // kalau lagi di intro, mouse tidak ada fungsi
  if (gameState == 0) {
    return; // keluar dari fungsi (skip semua code di bawah)
  }
  
  // === HANDLE KLIK TOMBOL MUSIK ===
  float btnX = 60, btnY = height - 40; // posisi tengah tombol
  float btnW = 100, btnH = 35; // ukuran tombol
  
  // cek apakah mouse di dalam area tombol (collision detection kotak)
  boolean isMusicHover = (
    mouseX > btnX - btnW/2 && // kiri
    mouseX < btnX + btnW/2 && // kanan
    mouseY > btnY - btnH/2 && // atas
    mouseY < btnY + btnH/2    // bawah
  );
  
  if (isMusicHover) {
    // toggle musik (play <-> pause)
    if (musicPlaying) {
      // kalau lagi playing, pause
      if (musicTracks[currentTrack] != null) { // cek track tidak null
        musicTracks[currentTrack].pause(); // pause musik
      }
      musicPlaying = false; // update state
    } else {
      // kalau lagi pause, play
      if (musicTracks[currentTrack] != null) {
        musicTracks[currentTrack].play(); // play musik
      }
      musicPlaying = true; // update state
    }
    return; // stop cek tombol lain (user sudah klik musik)
  }
  
  // === HANDLE KLIK COIN SLOT ===
  // cek apakah mouse di atas coin slot
  if (vendingMachine.isMouseOverCoinSlot(mouseX, mouseY)) {
    // cek apakah user masih punya koin
    if (userCoins > 0) {
      userCoins--; // kurangi saldo user
      vendingMachine.addCoin(); // tambah koin di mesin
      
      // buat animasi koin terbang
      float[] targetPos = vendingMachine.getCoinSlotPos(); // ambil posisi slot
      // add() = tambah objek baru ke arraylist
      animatedCoins.add(new AnimatedCoin(
        targetPos[0]+40, targetPos[1] - 50, // posisi awal (atas)
        targetPos[0]+40, targetPos[1]-30     // posisi target (slot)
      ));
      
      // play sound effect coin drop
      if (coinDrop != null) coinDrop.play();
    }
    return; // stop cek tombol lain
  }
  
  // === HANDLE KLIK TOMBOL REFUND ===
  if (vendingMachine.isMouseOverRefundButton(mouseX, mouseY)) {
    int refundedAmount = vendingMachine.manualRefund(); // ambil semua koin dari mesin
    userCoins += refundedAmount; // kembalikan ke saldo user
    
    // play sound effect refund kalau ada koin yang dikembalikan
    if (refundedAmount > 0 && coinRefund != null) {
      coinRefund.play();
    }
    return; // stop cek tombol lain
  }
  
  // === HANDLE KLIK NUMPAD ===
  // return: jumlah refund, atau -1 untuk beep, atau 0 untuk diam
  int refundFromNumpad = vendingMachine.handleNumpadClick(machineWorks, coinRefund);
  
  if (refundFromNumpad > 0) {
    userCoins += refundFromNumpad; // ada refund, kembalikan ke user
  } else if (refundFromNumpad == -1) {
    // return -1 = user klik numpad, perlu beep sound
    if (numpadBeep != null) numpadBeep.play();
  }
  // kalau 0 = tidak ada yang diklik
  
  // === HANDLE KLIK PINTU PICKUP ===
  vendingMachine.handlePickupDoorClick(collectItem); // coba ambil item
}

// === FUNGSI KEYPRESSED ===
// dipanggil otomatis saat keyboard ditekan (built-in processing)
// variable global "key" berisi karakter yang ditekan
void keyPressed() {
  // cek state sekarang
  if (gameState == 0) {
    // === KONTROL DI INTRO ===
    
    if (key == ' ') { // spasi ditekan
      gameState = 1; // switch ke state main game
    } else if (key == 'r' || key == 'R') { // r ditekan (case insensitive)
      introAnim.reset(); // reset animasi intro ke awal
    }
    
  } else {
    // === KONTROL DI MAIN GAME ===
    
    // tombol N = ganti track musik
    if (key == 'n' || key == 'N') {
      // stop track sekarang
      if (musicTracks[currentTrack] != null) {
        musicTracks[currentTrack].stop();
      }
      
      // pindah ke track berikutnya dengan modulo (loop balik ke 0)
      // contoh: (3 + 1) % 4 = 0, jadi dari track 4 balik ke track 1
      currentTrack = (currentTrack + 1) % musicTracks.length;
      
      // play track baru
      if (musicTracks[currentTrack] != null) {
        musicTracks[currentTrack].play();
        musicPlaying = true;
      } else {
        musicPlaying = false; // track null (file tidak ada)
      }
      
      println("Playing Track: " + (currentTrack + 1)); // print ke console
    }
    
    // tombol R = refund semua koin
    if (key == 'r' || key == 'R') {
      int refundedAmount = vendingMachine.manualRefund(); // ambil koin dari mesin
      userCoins += refundedAmount; // kembalikan ke saldo user
      
      // play sound kalau ada koin yang dikembalikan
      if (refundedAmount > 0 && coinRefund != null) {
        coinRefund.play();
      }
    }
    
    // handle input keyboard lain (angka, huruf untuk numpad)
    // return: jumlah refund, -1 untuk beep, 0 untuk diam
    int refundFromKey = vendingMachine.handleKeyPressed(key, machineWorks, coinRefund);
    
    if (refundFromKey > 0) {
      userCoins += refundFromKey; // ada refund
    } else if (refundFromKey == -1) {
      // perlu beep sound (user input numpad)
      if (numpadBeep != null) numpadBeep.play();
    }
    
    // tombol T = ganti waktu (pagi/siang/sore/malam)
    if (key == 't' || key == 'T') {
      cityBackground.nextSkyMode(); // cycle ke waktu berikutnya
      println("Sky Mode: " + cityBackground.getSkyMode()); // print mode sekarang
    }
  }
}

// === FUNGSI DRAW TOMBOL MUSIK ===
// render tombol play/pause musik di kiri bawah layar
void drawMusicButton() {
  float btnX = 60, btnY = height - 40; // posisi tengah tombol
  float btnW = 100, btnH = 35; // ukuran tombol
  
  // deteksi hover mouse (collision detection)
  boolean isHover = (
    mouseX > btnX - btnW/2 && mouseX < btnX + btnW/2 && // cek x
    mouseY > btnY - btnH/2 && mouseY < btnY + btnH/2    // cek y
  );
  
  // ubah warna dan cursor saat hover
  if (isHover) {
    fill(255, 200, 0); // warna kuning terang saat hover
    cursor(HAND); // ubah cursor jadi icon tangan
  } else {
    fill(255, 150, 0); // warna orange normal
  }
  
  // gambar kotak tombol
  stroke(200, 100, 0); // warna border orange gelap
  strokeWeight(3); // tebal border 3 pixel
  rectMode(CENTER); // set mode gambar rect dari tengah (bukan kiri atas)
  rect(btnX, btnY, btnW, btnH, 8); // gambar rect dengan corner radius 8
  rectMode(CORNER); // kembalikan mode ke default (kiri atas)
  
  // gambar text label tombol
  fill(255); // warna putih
  textAlign(CENTER, CENTER); // text di tengah
  textSize(14); // ukuran font
  // operator ternary: (kondisi) ? nilai_true : nilai_false
  text(musicPlaying ? "PAUSE" : "PLAY", btnX, btnY); // text sesuai state
  
  // gambar info track di bawah tombol
  textSize(10); // font lebih kecil
  text("Track " + (currentTrack + 1) + "/" + musicTracks.length, btnX, btnY + 25);
  
  // reset setting
  textAlign(LEFT); // kembalikan align ke kiri
  noStroke(); // matikan stroke untuk render berikutnya
}

// === FUNGSI DRAW INSTRUKSI OVERLAY ===
// tampilkan text instruksi di kiri atas layar
void drawInstructions() {
  // setting text style
  fill(255, 255, 255, 200); // putih semi-transparan (alpha 200)
  textSize(12); // ukuran font kecil
  textAlign(LEFT); // align kiri
  
  // variabel untuk tracking posisi y text
  int y_pos = 20; // mulai dari y=20
  
  // render text instruksi satu per satu
  text("Kontrol:", 10, y_pos); y_pos += 15; // header + increment y
  text("'T' : Ganti Waktu (Pagi/Siang/Sore/Malam)", 10, y_pos); y_pos += 15;
  text("'N' : Ganti Lagu (Next Track)", 10, y_pos); y_pos += 15;
  text("Klik 'PLAY' : Toggle Play/Pause", 10, y_pos); // text terakhir
}

// === FUNGSI DRAW COIN UI ===
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
