// class untuk animasi intro 3D dengan 6 fase, bezier curves, dan particle system
// menggambarkan alur vending machine: partikel → mesin → koin → snack → text
class IntroAnimation {
  int phase;           // fase animasi sekarang (0-5, total 6 fase)
  float phaseProgress; // progress dalam fase (0.0-1.0, normalized)
  float totalTime;     // total waktu animasi berjalan (detik)
  
  // arraylist = struktur data dinamis untuk collection object
  ArrayList<Particle3D> particles; // array 50 partikel 3D background
  
  float cameraAngle;    // sudut rotasi kamera (radian)
  float cameraDistance; // jarak kamera dari origin (pixel)
  // PVector = class untuk vektor 3D (x, y, z)
  PVector cameraPos;    // posisi kamera dalam 3D space
  
  ArrayList<Coin3D> coins3D; // array koin 3D yang terbang dengan bezier curve
  float coinAnimProgress;    // progress animasi koin (0.0-1.0)
  
  float machineScale;    // scale mesin (0-1, untuk zoom in effect)
  float machineRotation; // rotasi mesin (radian, untuk spin effect)
  
  float snackFallProgress; // progress animasi snack jatuh (0.0-1.0)
  PVector snackPos;        // posisi snack dalam 3D space (x, y, z)
  
  // PFont = class untuk custom font di Processing
  PFont titleFont, instructionFont; // font untuk judul dan instruksi
  
  // inisialisasi semua variabel dan object saat IntroAnimation dibuat
  IntroAnimation() {
    phase = 0;         // mulai dari fase 0
    phaseProgress = 0; // progress 0% (awal fase)
    totalTime = 0;     // timer mulai dari 0
    
    particles = new ArrayList<Particle3D>(); // buat arraylist kosong
    coins3D = new ArrayList<Coin3D>();       // buat arraylist kosong
    
    cameraAngle = 0;                      // sudut awal 0 (frontal)
    cameraDistance = 600;                 // jarak 600 pixel dari origin
    cameraPos = new PVector(0, 0, 0);    // posisi awal di origin
    
    machineScale = 0;                     // mesin mulai invisible (scale 0)
    machineRotation = 0;                  // rotasi awal 0
    snackFallProgress = 0;                // snack belum jatuh
    snackPos = new PVector(0, -100, 0);  // posisi awal snack (di atas)
    coinAnimProgress = 0;                 // koin belum terbang
    
    // try-catch = error handling (coba load font, jika gagal gunakan fallback)
    try {
      // createFont = buat font dari system font
      titleFont = createFont("Arial Bold", 48);      // font besar untuk judul
      instructionFont = createFont("Arial", 20);     // font kecil untuk instruksi
    } catch (Exception e) {
      // fallback jika Arial Bold tidak ada
      titleFont = createFont("Arial", 48);
      instructionFont = createFont("Arial", 20);
    }
    
    // loop untuk create 50 object Particle3D dengan posisi dan warna random
    for (int i = 0; i < 50; i++) {
      particles.add(new Particle3D(
        random(-500, 500),                // x acak (-500 sampai 500)
        random(-300, 300),                // y acak (-300 sampai 300)
        random(-500, 100),                // z acak (-500 sampai 100)
        color(255, random(100, 255), random(100, 200)) // warna cyan-biru acak
      ));
    }
  }
  
  // reset semua variabel ke nilai awal (dipanggil saat user tekan R)
  void reset() {
    phase = 0;            // kembali ke fase 0
    phaseProgress = 0;    // reset progress
    totalTime = 0;        // reset timer
    machineScale = 0;     // mesin kembali invisible
    machineRotation = 0;  // rotasi ke 0
    snackFallProgress = 0; // snack ke posisi awal
    coinAnimProgress = 0;  // koin ke awal
    coins3D.clear();      // hapus semua koin 3D (clear arraylist)
  }
  
  // dipanggil setiap frame untuk update state animasi
  void update() {
    // increment timer (0.016 ≈ 1/60 detik = 1 frame @ 60fps)
    totalTime += 0.016;
    
    // increment phase progress (0.008 = kecepatan animasi)
    // nilai lebih besar = animasi lebih cepat
    phaseProgress += 0.008;
    
    // enhanced for loop untuk iterate collection
    for (Particle3D p : particles) {
      p.update(); // panggil method update() setiap partikel
    }
    
    // hitung target angle dengan sin wave (efek goyang smooth)
    float targetAngle = sin(totalTime * 0.5) * 0.3; // amplitude 0.3 radian
    
    // lerp = linear interpolation (smooth transition dari nilai sekarang ke target)
    // syntax: lerp(start, end, amount) - amount 0.05 = 5% per frame
    cameraAngle = lerp(cameraAngle, targetAngle, 0.05);
    
    // cek apakah phase selesai (progress >= 100%)
    if (phaseProgress >= 1.0) {
      phaseProgress = 0; // reset progress untuk phase berikutnya
      phase++;           // increment ke phase berikutnya
      
      // clamp phase ke maksimal 5 (total 6 phase: 0-5)
      if (phase > 5) {
        phase = 5; // stay di phase terakhir (loop idle)
      }
      
      // spawn object atau setup animasi saat masuk phase tertentu
      if (phase == 2) {
        // --- PHASE 2: SPAWN 5 KOIN 3D ---
        for (int i = 0; i < 5; i++) {
          coins3D.add(new Coin3D(
            random(-200, 200),  // x acak
            -300,               // y di atas (akan terbang turun)
            random(-100, 100)   // z acak (depth)
          ));
        }
      }
    }
  
    // switch-case untuk handle logic setiap fase
    switch (phase) {
      case 0: // --- PHASE 0: MESIN ZOOM IN + PARTIKEL ---
        // scale mesin dari 0 ke 1 (zoom in effect) dengan easing
        machineScale = easeInOutCubic(phaseProgress) * 1.0;
        break;
        
      case 1: // --- PHASE 1: MESIN ROTASI 360° ---
        // rotasi mesin full circle (TWO_PI = 360° = 2π radian)
        machineRotation = easeInOutCubic(phaseProgress) * TWO_PI;
        break;
        
      case 2: // --- PHASE 2: KOIN TERBANG DENGAN BEZIER CURVE ---
        // update progress koin dengan easing
        coinAnimProgress = easeInOutCubic(phaseProgress);
        
        // update semua koin (mereka follow bezier path masing-masing)
        for (Coin3D coin : coins3D) {
          coin.update(coinAnimProgress); // pass progress 0-1
        }
        break;
        
      case 3: // --- PHASE 3: SNACK JATUH DENGAN BEZIER CURVE ---
        // update progress snack dengan easing
        snackFallProgress = easeInOutCubic(phaseProgress);
        
        // bezierPoint = hitung posisi di bezier curve (control points: -100, -50, 50, 150)
        // parameter: (p0, p1, p2, p3, t) - p0-p3 = control points, t = progress (0-1)
        float fallY = bezierPoint(-100, -50, 50, 150, snackFallProgress);
        snackPos.y = fallY; // update posisi y snack
        break;
        
      case 4: // --- PHASE 4: MESIN ROTASI TAMBAHAN 180° ---
        // rotasi dari 360° (TWO_PI) sampai 540° (TWO_PI + PI)
        machineRotation = TWO_PI + easeInOutCubic(phaseProgress) * PI;
        break;
        
      case 5: // --- PHASE 5: IDLE DENGAN INSTRUKSI ---
        machineRotation = TWO_PI + PI;
        break;
    }
  }
  
  void display() {
    // Background gradient
    drawGradientBackground();
    
    // Setup 3D camera
    pushMatrix();
    float camX = sin(cameraAngle) * cameraDistance;
    float camZ = cos(cameraAngle) * cameraDistance;
    camera(camX, -100, camZ, 0, 0, 0, 0, 1, 0);
    
    // Lighting
    lights();
    ambientLight(80, 80, 100);
    directionalLight(200, 200, 220, -1, 1, -1);
    pointLight(255, 200, 150, 0, -200, 200);
    
    // Draw particles
    for (Particle3D p : particles) {
      p.display();
    }
    
    // Draw main vending machine 3D
    if (phase >= 0) {
      // Shadow di bawah mesin
      pushMatrix();
      translate(0, 130, 0);
      rotateX(HALF_PI);
      fill(0, 0, 0, 50 * machineScale);
      noStroke();
      ellipse(0, 0, 220 * machineScale, 120 * machineScale);
      popMatrix();
      
      // Mesin utama
      pushMatrix();
      rotateY(machineRotation);
      scale(machineScale);
      drawVendingMachine3D();
      popMatrix();
    }
    
    // Draw coins
    if (phase >= 2 && phase <= 3) {
      for (Coin3D coin : coins3D) {
        coin.display();
      }
    }
    
    // Draw falling snack
    if (phase == 3) {
      pushMatrix();
      translate(snackPos.x, snackPos.y, snackPos.z);
      rotateZ(snackFallProgress * TWO_PI * 2);
      fill(220, 50, 80);
      stroke(180, 40, 60);
      strokeWeight(2);
      box(40, 60, 30);
      popMatrix();
    }
    
    popMatrix();
    
    // Draw 2D UI elements
    drawUI();
  }
  
  void drawGradientBackground() {
    // Gradient dengan warna mirip background utama
    color topColor = color(100, 150, 230);
    color bottomColor = color(255, 220, 180);
    
    // Manual gradient
    beginShape(QUADS);
    noStroke();
    fill(topColor);
    vertex(0, 0, 0);
    vertex(width, 0, 0);
    fill(bottomColor);
    vertex(width, height, 0);
    vertex(0, height, 0);
    endShape();
  }
  
  void drawVendingMachine3D() {
    // Body utama mesin
    pushMatrix();
    
    // Main body (merah)
    fill(160, 45, 45);
    stroke(100, 30, 30);
    strokeWeight(2);
    box(180, 240, 100);
    
    // Glass panel (depan)
    pushMatrix();
    translate(0, -20, 51);
    fill(150, 180, 200, 100);
    stroke(45, 45, 50);
    strokeWeight(3);
    box(110, 160, 2);
    
    // Glass reflection/shine
    pushMatrix();
    translate(-30, -40, 1);
    fill(255, 255, 255, 80);
    noStroke();
    rotateZ(-0.2);
    box(20, 60, 1);
    popMatrix();
    popMatrix();
    
    // Top sign
    pushMatrix();
    translate(0, -135, 0);
    fill(180, 55, 55);
    stroke(100, 30, 30);
    strokeWeight(2);
    box(180, 30, 100);
    
    // Sign text "SNACKS"
    pushMatrix();
    translate(0, 0, 51);
    fill(240, 220, 200);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(14);
    text("SNACKS", 0, 0);
    popMatrix();
    popMatrix();
    
    // Snack items inside (3x4 grid)
    if (phase >= 1) {
      for (int row = 0; row < 4; row++) {
        for (int col = 0; col < 3; col++) {
          pushMatrix();
          translate(-55 + col * 55, -80 + row * 45, 45);
          fill(220, 50 + row * 30, 80 + col * 30);
          stroke(180, 40, 60);
          strokeWeight(1);
          box(35, 35, 5);
          popMatrix();
        }
      }
    }
    
    // Coin slot (samping kanan)
    pushMatrix();
    translate(95, -50, 0);
    fill(100, 100, 120);
    stroke(60);
    strokeWeight(2);
    box(10, 60, 80);
    // Slot opening
    translate(-5, 0, 0);
    fill(20, 20, 30);
    box(2, 15, 40);
    popMatrix();
    
    // Pickup door (bawah)
    pushMatrix();
    translate(0, 90, 51);
    fill(35, 35, 40);
    stroke(25);
    strokeWeight(2);
    box(110, 40, 2);
    popMatrix();
    
    // Base
    pushMatrix();
    translate(0, 125, 0);
    fill(60, 60, 65);
    stroke(30);
    strokeWeight(2);
    box(190, 10, 110);
    popMatrix();
    
    popMatrix();
  }
  
  void drawUI() {
    hint(DISABLE_DEPTH_TEST);
    camera();
    ortho();
    
    // Title text dengan glow effect
    if (phase <= 1) {
      float alpha = phase == 0 ? phaseProgress * 255 : 255;
      
      // Glow layers
      for (int i = 3; i > 0; i--) {
        fill(255, 100, 100, alpha * 0.3);
        textFont(titleFont);
        textAlign(CENTER, CENTER);
        textSize(56 + i * 4);
        text("VENDING MACHINE", width/2, 80);
      }
      
      // Main text
      fill(255, 255, 255, alpha);
      textFont(titleFont);
      textAlign(CENTER, CENTER);
      textSize(56);
      text("VENDING MACHINE", width/2, 80);
      
      // Subtitle
      fill(255, 255, 255, alpha * 0.8);
      textFont(instructionFont);
      textSize(18);
      text("Simulasi Mesin Snack", width/2, 130);
    }
    
    // Phase descriptions dengan icon
    String phaseText = "";
    String phaseIcon = "";
    switch (phase) {
      case 0:
        phaseText = "Memperkenalkan Mesin...";
        phaseIcon = "🏪";
        break;
      case 1:
        phaseText = "Mesin Vending Siap Digunakan";
        phaseIcon = "✨";
        break;
      case 2:
        phaseText = "Masukkan Koin...";
        phaseIcon = "🪙";
        break;
      case 3:
        phaseText = "Pilih Snack Favorit Anda!";
        phaseIcon = "🍿";
        break;
      case 4:
        phaseText = "Ambil Snack dari Pintu Bawah";
        phaseIcon = "📦";
        break;
      case 5:
        phaseText = "Selamat Menikmati!";
        phaseIcon = "🎉";
        break;
    }
    
    // Phase description dengan background box
    if (phase < 5) {
      float boxW = 400;
      float boxH = 50;
      float boxX = (width - boxW) / 2;
      float boxY = height - 145;
      
      // Background box dengan alpha
      fill(0, 0, 0, 120);
      noStroke();
      rect(boxX, boxY, boxW, boxH, 8);
      
      // Border glow
      noFill();
      stroke(255, 200, 100, 150);
      strokeWeight(2);
      rect(boxX, boxY, boxW, boxH, 8);
    }
    
    fill(255, 255, 255, 220);
    textFont(instructionFont);
    textAlign(CENTER, CENTER);
    textSize(22);
    text(phaseText, width/2, height - 120);
    
    // Instructions (always visible)
    if (phase >= 4) {
      // Animated instructions dengan icon
      float pulse = sin(totalTime * 3) * 0.5 + 0.5;
      
      // Draw keyboard icon untuk SPACE
      pushMatrix();
      translate(width/2 - 180, height - 70);
      fill(255, 255, 255, 100 + pulse * 100);
      stroke(255, 255, 100, 150 + pulse * 100);
      strokeWeight(2);
      rect(-15, -12, 30, 24, 3);
      fill(255, 255, 100, 150 + pulse * 100);
      noStroke();
      textSize(10);
      text("SPACE", 0, 0);
      popMatrix();
      
      fill(255, 255, 100, 150 + pulse * 100);
      textSize(24);
      text("Tekan SPASI untuk Mulai", width/2 + 20, height - 70);
      
      // Draw keyboard icon untuk R
      pushMatrix();
      translate(width/2 - 140, height - 40);
      fill(255, 255, 255, 120);
      stroke(255, 255, 255, 180);
      strokeWeight(2);
      rect(-12, -10, 24, 20, 3);
      fill(255, 255, 255, 180);
      noStroke();
      textSize(10);
      text("R", 0, 0);
      popMatrix();
      
      fill(255, 255, 255, 180);
      textSize(16);
      text("Tekan R untuk Ulangi Intro", width/2 + 20, height - 40);
    }
    
    // Progress bar
    if (phase < 5) {
      float barW = 300;
      float barH = 8;
      float barX = (width - barW) / 2;
      float barY = height - 25;
      
      noFill();
      stroke(255, 255, 255, 100);
      strokeWeight(2);
      rect(barX, barY, barW, barH);
      
      float progressTotal = (phase + phaseProgress) / 6.0;
      fill(255, 200, 100, 200);
      noStroke();
      rect(barX, barY, barW * progressTotal, barH);
    }
    
    hint(ENABLE_DEPTH_TEST);
  }
  
  // === FUNGSI EASING (CUBIC EASE-IN-OUT) ===
  // menghasilkan animasi smooth dengan percepatan di awal dan perlambatan di akhir
  // input: t (progress 0-1), output: eased value (0-1)
  // cubic = kurva kubik (pangkat 3) untuk transisi halus
  float easeInOutCubic(float t) {
    // operator ternary: (kondisi) ? nilai_true : nilai_false
    // jika t < 0.5 (paruh pertama):
    //   ease in: 4 * t³ (percepatan lambat ke cepat)
    // jika t >= 0.5 (paruh kedua):
    //   ease out: 1 - (-2t + 2)³ / 2 (perlambatan cepat ke lambat)
    // hasilnya: slow → fast → slow (S-curve)
    return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
  }
}

// Kelas untuk partikel 3D background
class Particle3D {
  PVector pos;
  PVector vel;
  color col;
  float size;
  
  Particle3D(float x, float y, float z, color c) {
    pos = new PVector(x, y, z);
    vel = new PVector(random(-0.5, 0.5), random(-0.5, 0.5), random(-0.5, 0.5));
    col = c;
    size = random(5, 15);
  }
  
  void update() {
    pos.add(vel);
    
    // Wrap around
    if (pos.x > 500) pos.x = -500;
    if (pos.x < -500) pos.x = 500;
    if (pos.y > 300) pos.y = -300;
    if (pos.y < -300) pos.y = 300;
    if (pos.z > 100) pos.z = -500;
    if (pos.z < -500) pos.z = 100;
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    noStroke();
    fill(col, 150);
    sphere(size);
    popMatrix();
  }
}

// === KELAS COIN3D ===
// class untuk koin 3D yang terbang mengikuti bezier curve
class Coin3D {
  // === VARIABEL POSISI ===
  PVector startPos;   // posisi awal koin (spawn point)
  PVector endPos;     // posisi akhir koin (target/destination)
  PVector currentPos; // posisi sekarang (animated)
  
  // === VARIABEL ROTASI ===
  float rotation;  // sudut rotasi sekarang (radian)
  float rotSpeed;  // kecepatan rotasi (radian per update)
  
  // === CONSTRUCTOR ===
  Coin3D(float x, float y, float z) {
    // set posisi awal dari parameter
    startPos = new PVector(x, y, z);
    
    // generate posisi akhir random (area tengah bawah)
    endPos = new PVector(
      random(-50, 50),   // x: -50 sampai 50 (tengah)
      random(50, 100),   // y: 50 sampai 100 (bawah)
      random(40, 60)     // z: 40 sampai 60 (depth mid)
    );
    
    // copy() = duplicate PVector (tidak reference yang sama)
    currentPos = startPos.copy();
    
    // random initial rotation
    rotation = random(TWO_PI);
    
    // random rotation speed
    rotSpeed = random(0.1, 0.3);
  }
  
  // === FUNGSI UPDATE ===
  // update posisi koin sepanjang bezier curve berdasarkan progress
  void update(float progress) {
    // progress = 0.0 (start) sampai 1.0 (end)
    float bezierProgress = progress;
    
    // === DEFINE BEZIER CONTROL POINTS ===
    // control points menentukan kelengkungan kurva
    PVector control1 = new PVector(
      startPos.x + random(-100, 100), // x dengan offset random (create variety)
      startPos.y + 100,                // y 100 pixel di bawah start (arc upward)
      startPos.z + random(-50, 50)     // z dengan offset random (3D depth)
    );
    PVector control2 = new PVector(
      endPos.x + random(-50, 50),
      endPos.y - 50,
      endPos.z - 20
    );
    
    currentPos.x = bezierPoint(startPos.x, control1.x, control2.x, endPos.x, bezierProgress);
    currentPos.y = bezierPoint(startPos.y, control1.y, control2.y, endPos.y, bezierProgress);
    currentPos.z = bezierPoint(startPos.z, control1.z, control2.z, endPos.z, bezierProgress);
    
    rotation += rotSpeed;
  }
  
  void display() {
    pushMatrix();
    translate(currentPos.x, currentPos.y, currentPos.z);
    rotateY(rotation);
    
    // Coin shape
    fill(192, 192, 192);
    stroke(150, 150, 150);
    strokeWeight(2);
    
    // Draw coin as cylinder
    pushMatrix();
    rotateX(HALF_PI);
    drawCylinder(15, 3, 20);
    popMatrix();
    
    popMatrix();
  }
  
  void drawCylinder(float r, float h, int detail) {
    float angle = TWO_PI / detail;
    
    // Top
    beginShape();
    for (int i = 0; i < detail; i++) {
      float x = cos(angle * i) * r;
      float y = sin(angle * i) * r;
      vertex(x, y, -h/2);
    }
    endShape(CLOSE);
    
    // Bottom
    beginShape();
    for (int i = 0; i < detail; i++) {
      float x = cos(angle * i) * r;
      float y = sin(angle * i) * r;
      vertex(x, y, h/2);
    }
    endShape(CLOSE);
    
    // Sides
    beginShape(QUAD_STRIP);
    for (int i = 0; i <= detail; i++) {
      float x = cos(angle * i) * r;
      float y = sin(angle * i) * r;
      vertex(x, y, -h/2);
      vertex(x, y, h/2);
    }
    endShape();
  }
}

