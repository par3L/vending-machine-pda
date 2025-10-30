
// kelas animasi koin terbang dari atas slot
class AnimatedCoin {
  PVector pos;      // posisi koin sekarang
  PVector vel;      // kecepatan koin
  float size;       // ukuran koin
  int lifetime;     // sisa waktu animasi
  float rotation;   // sudut rotasi koin
  float rotSpeed;   // kecepatan rotasi

  AnimatedCoin(float startX, float startY, float targetX, float targetY) {
    pos = new PVector(startX, startY); // set posisi awal
    size = 15; // set ukuran koin
    lifetime = 15; // durasi animasi lebih singkat
    vel = new PVector(targetX - startX, targetY - startY); // arah ke target
    vel.div(lifetime); // bagi biar pas waktunya
    rotation = random(TWO_PI); // rotasi awal acak
    rotSpeed = random(-0.2, 0.2); // kecepatan rotasi acak
  }

  void update() {
    pos.add(vel); // gerak koin
    rotation += rotSpeed; // putar koin
    lifetime--; // kurangi waktu hidup
    vel.y += 0.2; // tambah gravitasi biar jatuh
  }

  void display() {
    pushMatrix(); // simpan transformasi
    translate(pos.x, pos.y); // pindah ke posisi koin
    rotate(rotation); // putar koin
    fill(192, 192, 192); // warna silver
    stroke(150); // garis pinggir abu
    strokeWeight(1); // tebal garis
    ellipse(0, 0, size, size); // gambar lingkaran koin
    fill(160, 160, 160); // warna dalam lebih gelap
    noStroke(); // tanpa garis
    ellipse(0, 0, size * 0.7, size * 0.7); // detail tengah
    popMatrix(); // kembalikan transformasi
  }

  boolean isDead() {
    return lifetime <= 0; // true kalau animasi habis
  }
}
