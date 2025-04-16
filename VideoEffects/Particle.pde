class Particle3D {
  PVector pos, vel;
  float size;
  float hue;
  
  Particle3D() {
    reset();
  }
  
  void reset() {
    pos = PVector.random3D().mult(random(100, 300) * sizeMultiplier);
    vel = PVector.random3D().mult(2);
    size = random(10, 30) * sizeMultiplier;
    hue = random(360);
  }
  
  void update() {
    pos.add(vel);
    hue = (hue + colorSpeed) % 360;
    
    // Add distortion
    pos.add(PVector.random3D().mult(distortAmount));
    
    if (pos.mag() > 400 * sizeMultiplier) {
      reset();
    }
  }
  
  void display(PImage tex) {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateY(-theta * 0.5);
    
    int px = constrain(int(map(pos.x, -300, 300, 0, tex.width-1)), 0, tex.width-1);
    int py = constrain(int(map(pos.y, -300, 300, 0, tex.height-1)), 0, tex.height-1);
    
    tint(hue, 80 * colorIntensity, 100 * brightnessMod);
    imageMode(CENTER);
    image(tex, 0, 0, size, size);
    imageMode(CORNER);
    
    popMatrix();
  }
}

// Initialize particle system
void initializeParticles() {
  particles = new ArrayList<Particle3D>();
  for (int i = 0; i < 100; i++) {
    particles.add(new Particle3D());
  }
}

void drawParticleEffect() {
  pushMatrix();
  rotateY(theta * 0.5);
  
  for (Particle3D p : particles) {
    p.update();
    p.display(currentFrame);
  }
  popMatrix();
} 