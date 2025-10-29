// library untuk suara/musik
import processing.sound.*;

// === variabel global ===
VendingMachine vendingMachine; // objek vending machine utama
CityBackground cityBackground; // objek background kota

// === variabel musik ===
SoundFile[] musicTracks = new SoundFile[4]; // array untuk menyimpan 4 track musik
int currentTrack = 0; // tracj yang sedang diputar (0-3)
boolean musicPlaying = false; // status musik sedang play atau pause
// path file musik yang akan diload
String[] musicPaths = {
  "assets/sounds/music.mp3",
  "assets/sounds/music.mp3", 
  "assets/sounds/music.mp3", 
  "assets/sounds/music.mp3"  
};

// === fungsi setup - dipanggil sekali saat program dimulai ===
void setup() {
  // buat window dengan ukuran 800x525, mode P3D untuk render 3d
  // kalau mau ubah ukuran window, ganti angka di sini
  size(800, 525, P3D);
  
  // setup font dan rendering untuk kualitas visual lebih halus
  textAlign(CENTER, CENTER);
  smooth(8); // antialiasing level 8 untuk gambar lebih halus
  
  // buat objek background kota dan vending machine
  cityBackground = new CityBackground(); 
  vendingMachine = new VendingMachine();

  // === load semua file musik ===
  for (int i = 0; i < musicTracks.length; i++) {
    try {
      // load file musik dari path yang sudah ditentukan
      musicTracks[i] = new SoundFile(this, musicPaths[i]); 
      musicTracks[i].amp(0.4); // set volume musik ke 40%
    } catch (Exception e) {
      // tampilkan error di console kalau gagal load musik
      println("Error loading music file: " + musicPaths[i]);
      println(e.getMessage());
    }
  }
}

// === fungsi draw - loop utama yang terus berjalan ===
void draw() {
  // === layer 1: gambar background kota (paling belakang) ===
  cityBackground.update(); // update animasi awan dan bintang
  cityBackground.display(); // render langit, matahari/bulan, gedung, lampu jalan
  
  // === layer 2: gambar vending machine (foreground) ===
  int currentSkyMode = cityBackground.getSkyMode(); // ambil mode waktu (pagi/siang/sore/malam)
  vendingMachine.update(); // update animasi snack jatuh
  vendingMachine.display(currentSkyMode); // render vending machine dengan lighting sesuai waktu

  // === layer 3: gambar ui button dan teks instruksi (paling depan) ===
  hint(DISABLE_DEPTH_TEST); // disable depth test supaya ui selalu di depan
  drawMusicButton(); // gambar tombol play/pause musik
  drawInstructions(); // gambar instruksi kontrol
}


// === event handler - dipanggil otomatis saat mouse diklik ===
void mouseClicked() {
  // cek apakah klik di tombol musik
  float btnX = 60; // posisi x tombol musik
  float btnY = height - 40; // posisi y tombol musik
  float btnW = 100; // lebar tombol
  float btnH = 35; // tinggi tombol
  // deteksi apakah mouse ada di area tombol
  boolean isMusicHover = (mouseX > btnX - btnW/2 && mouseX < btnX + btnW/2 &&
                       mouseY > btnY - btnH/2 && mouseY < btnY + btnH/2);
                       
  if (isMusicHover) {
    // toggle play/pause musik
    if (musicPlaying) {
      if (musicTracks[currentTrack] != null) musicTracks[currentTrack].pause();
      musicPlaying = false;
    } else {
      if (musicTracks[currentTrack] != null) musicTracks[currentTrack].play();
      musicPlaying = true;
    }
  }

  // teruskan klik ke vending machine untuk handle numpad dan pintu pickup
  vendingMachine.handleNumpadClick();
  vendingMachine.handlePickupDoorClick();
  cityBackground.handleMouseClicked(mouseX, mouseY);
}

// === event handler - dipanggil otomatis saat keyboard ditekan ===
void keyPressed() {
  // tekan 'n' untuk ganti ke track musik berikutnya
  if (key == 'n' || key == 'N') {
    if (musicTracks[currentTrack] != null) musicTracks[currentTrack].stop(); // stop track sekarang
    currentTrack = (currentTrack + 1) % musicTracks.length; // pindah ke track berikutnya (loop balik ke 0)
    
    // play track baru
    if (musicTracks[currentTrack] != null) {
      musicTracks[currentTrack].play();
      musicPlaying = true;
    } else {
      musicPlaying = false;
    }
    println("Playing Track: " + (currentTrack + 1));
  }

  // teruskan input keyboard ke vending machine (untuk ketik kode) dan citybackground (untuk ganti waktu)
  vendingMachine.handleKeyPressed(key);
  cityBackground.handleKeyPressed(key); // handle tombol 't' untuk ganti waktu
}

// === fungsi untuk gambar tombol musik ===
void drawMusicButton() {
  // posisi dan ukuran tombol
  float btnX = 60; // kalau mau geser tombol ke kanan/kiri ubah nilai ini
  float btnY = height - 40; // kalau mau geser tombol ke atas/bawah ubah nilai ini
  float btnW = 100; // lebar tombol, ubah untuk resize
  float btnH = 35; // tinggi tombol, ubah untuk resize
  // deteksi apakah mouse hover di tombol
  boolean isHover = (mouseX > btnX - btnW/2 && mouseX < btnX + btnW/2 && 
                     mouseY > btnY - btnH/2 && mouseY < btnY + btnH/2);
  
  // ganti warna tombol kalau dihover
  if (isHover) {
    fill(255, 200, 0); // warna oranye terang saat hover
    cursor(HAND); // ganti cursor jadi tangan
  } else {
    fill(255, 150, 0); // warna oranye normal
    cursor(ARROW); // cursor biasa
  }
  
  // gambar kotak tombol dengan rounded corner
  stroke(200, 100, 0);
  strokeWeight(3);
  rectMode(CENTER);
  rect(btnX, btnY, btnW, btnH, 8); // angka 8 adalah radius sudut rounded
  rectMode(CORNER);
  
  // gambar teks di tombol
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(14);
  
  // tampilkan "play" atau "pause" sesuai status musik
  if (musicPlaying) {
    text("PAUSE", btnX, btnY);
  } else {
    text("PLAY", btnX, btnY);
  }
  
  // tampilkan nomor track saat ini
  textSize(10);
  text("Track " + (currentTrack + 1) + "/" + musicTracks.length, btnX, btnY + 25);
  
  textAlign(LEFT);
  noStroke();
}

// === fungsi untuk gambar teks instruksi kontrol ===
void drawInstructions() {
  fill(255, 255, 255, 200); // warna putih semi transparan
  textSize(12); // ukuran font instruksi, ubah untuk resize teks
  textAlign(LEFT);
  int y_pos = 20; // posisi y awal, ubah untuk geser instruksi ke atas/bawah
  // tampilkan semua instruksi kontrol
  text("Kontrol:", 10, y_pos);
  y_pos += 15;
  text("'T' : Ganti Waktu (Pagi/Siang/Sore/Malam)", 10, y_pos);
  y_pos += 15;
  text("'N' : Ganti Lagu (Next Track)", 10, y_pos);
  y_pos += 15;
  text("Klik 'PLAY' : Toggle Play/Pause", 10, y_pos);
}
