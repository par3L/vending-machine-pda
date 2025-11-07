
CityBackground city;

// tombol
Button btnMulai;
Button btnKeluar;
Button btnMusik;

// status halaman
boolean onHome = true;

// inisialisasi di setup utama (panggil dari setup() di file utama)
void initHome() {
  city = new CityBackground();
  
  btnMulai = new Button(width/2 - 100, height/2 - 40, 200, 60, "Mulai");
  btnKeluar = new Button(width/2 - 100, height/2 + 40, 200, 60, "Keluar");
  btnMusik = new Button(40, height - 70, 120, 35, musicPlaying ? "Pause" : "Play");
}

// update dan tampilkan homepage
void drawHome() {
  // update background kota
  city.update();
  city.display();

  // judul besar
  fill(0); // ubah ke hitam agar kontras dengan langit
  textAlign(CENTER, CENTER);
  textFont(createFont("Arial Bold", 48));
  text("VENDING MACHINE SIMULATOR", width/2, height/2 - 200);

  // tombol
  btnMulai.display();
  btnKeluar.display();
  btnMusik.display();
}

// event klik mouse
void mousePressedHome() {
  if (btnMulai.isHovered()) {
    // masuk ke intro animasi
    onHome = false;
    currentState = "INTRO"; // state global
    startIntro();           // mulai animasi intro
  }

  if (btnKeluar.isHovered()) {
    exit(); // keluar aplikasi
  }

  if (btnMusik.isHovered()) {
    toggleMusic();
    btnMusik.label = musicPlaying ? "Pause" : "Play";
  }
}

// fungsi toggle musik
void toggleMusic() {
  if (!musicPlaying) {
    musicTracks[currentTrack].loop();
    musicPlaying = true;
  } else {
    musicTracks[currentTrack].pause();
    musicPlaying = false;
  }
}

class Button {
  float x, y, w, h;
  String label;

  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }

  void display() {
    boolean hover = isHovered();
    
    // efek hover halus + bayangan
    noStroke();
    fill(0, 50);
    rect(x + 4, y + 4, w, h, 15); // bayangan lembut
    
    fill(hover ? color(255, 200, 120) : color(255, 230, 180));
    stroke(0);
    strokeWeight(2);
    rect(x, y, w, h, 15);

    // teks tombol
    fill(0);
    textAlign(CENTER, CENTER);
    textFont(createFont("Arial Bold", 18));
    text(label, x + w/2, y + h/2);
  }

  boolean isHovered() {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
}
