
// kelas animasi koin masuk ke slot
class AnimatedCoin {
  // PVector = tipe data bawaan processing untuk menyimpan koordinat 2d/3d (x, y, z)
  // gunanya untuk hitung posisi dan gerakan objek dengan mudah
  PVector pos;      // posisi koin sekarang di layar (x, y)
  PVector vel;      // kecepatan gerak koin per frame (berapa pixel bergerak)
  
  float size;       // ukuran diameter koin dalam pixel
  int lifetime;     // sisa frame sebelum animasi selesai (countdown timer)
  float rotation;   // sudut rotasi koin dalam radian (0 sampai TWO_PI)
  float rotSpeed;   // kecepatan putaran per frame (positif = searah jarum jam)

  // constructor = fungsi yang dipanggil saat objek dibuat dengan keyword "new"
  // parameter: posisi awal (startX, startY) dan posisi tujuan (targetX, targetY)
  AnimatedCoin(float startX, float startY, float targetX, float targetY) {
    pos = new PVector(startX, startY); // buat pvector baru untuk posisi awal koin
    size = 15; // diameter koin 15 pixel
    lifetime = 15; // koin akan hidup selama 15 frame
    
    // hitung vektor arah dari start ke target (selisih koordinat)
    vel = new PVector(targetX - startX, targetY - startY);
    vel.div(lifetime); // bagi dengan lifetime biar sampai tepat waktu (jarak/waktu = kecepatan)
    
    rotation = random(TWO_PI); // sudut awal acak antara 0 sampai 360 derajat (TWO_PI radian)
    rotSpeed = random(-0.2, 0.2); // kecepatan putar acak (negatif = kiri, positif = kanan)
  }

  // fungsi ni dipanggil setiap frame untuk update posisi dan state koin
  void update() {
    pos.add(vel); // tambahkan velocity ke posisi (gerakkan koin sesuai kecepatan)
    rotation += rotSpeed; // tambah sudut rotasi (putar koin pelan-pelan)
    lifetime--; // kurangi 1 dari sisa hidup (countdown setiap frame)
    vel.y += 0.2; // tambah kecepatan y (gravitasi membuat koin jatuh makin cepat)
  }

  // render/gambar koin ke layar
  void display() {
    pushMatrix(); // simpan state transformasi sekarang (posisi/rotasi canvas)
    translate(pos.x, pos.y); // pindah titik origin (0,0) ke posisi koin
    rotate(rotation); // putar canvas sesuai sudut rotasi koin
    
    // gambar koin layer luar (lingkaran silver)
    fill(192, 192, 192); // warna isi abu terang (silver) dalam rgb
    stroke(150); // warna garis pinggir abu gelap
    strokeWeight(1); // tebal garis pinggir 1 pixel
    ellipse(0, 0, size, size); // gambar lingkaran di origin dengan diameter = size
    
    // gambar koin layer dalam (detail tengah lebih gelap)
    fill(160, 160, 160); // warna isi abu lebih gelap dari luar
    noStroke(); // nonaktifkan garis pinggir
    ellipse(0, 0, size * 0.7, size * 0.7); // lingkaran lebih kecil (70% dari ukuran asli)
    
    popMatrix(); // kembalikan transformasi ke state sebelum pushmatrix (reset)
  }

  // fungsi cek apakah koin sudah mati (animasi selesai)
  // return true jika lifetime sudah habis, false jika masih hidup
  boolean isDead() {
    return lifetime <= 0; // true kalau lifetime 0 atau kurang
  }
}
