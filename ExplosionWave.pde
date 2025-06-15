class ExplosionWave {
  PVector position;
  float radius = 0;
  float maxRadius = 80;
  float alpha = 255;

  ExplosionWave(float x, float y) {
    position = new PVector(x, y);
  }

  void update() {
    radius += 5;
    alpha -= 10;
  }

  void display() {
    noFill();
    stroke(150, 255, 150, alpha);
    strokeWeight(3);
    ellipse(position.x, position.y, radius * 2, radius * 2);
  }

  boolean isDone() {
    return alpha <= 0;
  }
}
