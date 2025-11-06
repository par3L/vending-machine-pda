// Kelas untuk animasi intro 3D dengan kurva bezier
class IntroAnimation {
  int phase; // fase animasi (0-5)
  float phaseProgress; // progress dalam fase (0-1)
  float totalTime; // total waktu animasi
  
  // Objek animasi
  ArrayList<Particle3D> particles; // partikel 3D
  float cameraAngle; // sudut kamera
  float cameraDistance; // jarak kamera
  PVector cameraPos; // posisi kamera
  
  // Untuk animasi koin
  ArrayList<Coin3D> coins3D;
  float coinAnimProgress;
  
  // Untuk animasi mesin vending 3D
  float machineScale;
  float machineRotation;
  
  // Untuk animasi snack jatuh
  float snackFallProgress;
  PVector snackPos;
  
  // Font untuk teks
  PFont titleFont, instructionFont;
  
  IntroAnimation() {
    phase = 0;
    phaseProgress = 0;
    totalTime = 0;
    particles = new ArrayList<Particle3D>();
    coins3D = new ArrayList<Coin3D>();
    cameraAngle = 0;
    cameraDistance = 600;
    cameraPos = new PVector(0, 0, 0);
    machineScale = 0;
    machineRotation = 0;
    snackFallProgress = 0;
    snackPos = new PVector(0, -100, 0);
    coinAnimProgress = 0;
    
    // Load atau buat font
    try {
      titleFont = createFont("Arial Bold", 48);
      instructionFont = createFont("Arial", 20);
    } catch (Exception e) {
      titleFont = createFont("Arial", 48);
      instructionFont = createFont("Arial", 20);
    }
    
    // Inisialisasi partikel background
    for (int i = 0; i < 50; i++) {
      particles.add(new Particle3D(
        random(-500, 500),
        random(-300, 300),
        random(-500, 100),
        color(255, random(100, 255), random(100, 200))
      ));
    }
  }
  
  void reset() {
    phase = 0;
    phaseProgress = 0;
    totalTime = 0;
    machineScale = 0;
    machineRotation = 0;
    snackFallProgress = 0;
    coinAnimProgress = 0;
    coins3D.clear();
  }
  
  void update() {
    totalTime += 0.016; // ~60fps
    phaseProgress += 0.008; // kecepatan animasi
    
    // Update particles
    for (Particle3D p : particles) {
      p.update();
    }
    
    // Update camera dengan smooth movement
    float targetAngle = sin(totalTime * 0.5) * 0.3;
    cameraAngle = lerp(cameraAngle, targetAngle, 0.05);
    
    // Phase progression
    if (phaseProgress >= 1.0) {
      phaseProgress = 0;
      phase++;
      if (phase > 5) {
        phase = 5; // stay at last phase
      }
      
      // Trigger events per phase
      if (phase == 2) {
        // Spawn coins
        for (int i = 0; i < 5; i++) {
          coins3D.add(new Coin3D(
            random(-200, 200),
            -300,
            random(-100, 100)
          ));
        }
      }
    }
    
    // Update animations based on phase
    switch (phase) {
      case 0: // Logo fade in + particles
        machineScale = easeInOutCubic(phaseProgress) * 1.0;
        break;
      case 1: // Rotate machine
        machineRotation = easeInOutCubic(phaseProgress) * TWO_PI;
        break;
      case 2: // Coins flying
        coinAnimProgress = easeInOutCubic(phaseProgress);
        for (Coin3D coin : coins3D) {
          coin.update(coinAnimProgress);
        }
        break;
      case 3: // Snack falling
        snackFallProgress = easeInOutCubic(phaseProgress);
        float fallY = bezierPoint(-100, -50, 50, 150, snackFallProgress);
        snackPos.y = fallY;
        break;
      case 4: // Machine final position
        machineRotation = TWO_PI + easeInOutCubic(phaseProgress) * PI;
        break;
      case 5: // Idle with instructions
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
      text("Simulasi Mesin Snack & Minuman", width/2, 130);
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
  
  // Easing function untuk animasi smooth
  float easeInOutCubic(float t) {
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

// Kelas untuk koin 3D yang terbang
class Coin3D {
  PVector startPos;
  PVector endPos;
  PVector currentPos;
  float rotation;
  float rotSpeed;
  
  Coin3D(float x, float y, float z) {
    startPos = new PVector(x, y, z);
    endPos = new PVector(random(-50, 50), random(50, 100), random(40, 60));
    currentPos = startPos.copy();
    rotation = random(TWO_PI);
    rotSpeed = random(0.1, 0.3);
  }
  
  void update(float progress) {
    // Bezier curve untuk path yang smooth
    float bezierProgress = progress;
    PVector control1 = new PVector(
      startPos.x + random(-100, 100),
      startPos.y + 100,
      startPos.z + random(-50, 50)
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
