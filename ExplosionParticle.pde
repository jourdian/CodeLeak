class ExplosionParticle {
  PVector position;
  PVector velocity;
  float lifespan = 60;

  ExplosionParticle(float x, float y) {
    position = new PVector(x, y);
    velocity = PVector.random2D().mult(random(1, 4));
  }

  void update() {
    position.add(velocity);
    velocity.mult(0.95); // Frenado gradual
    lifespan--;
  }

  void display() {
    noStroke();
    fill(120, 255, 120, lifespan * 4); // Opacidad decrece
    ellipse(position.x, position.y, 6, 6);
  }

  boolean isDead() {
    return lifespan <= 0;
  }
}
