class Projectile {
  PVector position;
  PVector velocity;
  float speed = 300; // Píxeles por segundo
  float lifespan = 180; // Frames de vida (3 segundos a 60fps)
  float damage = 1;
  boolean active = true;
  
  Projectile(float x, float y, float angle) {
    position = new PVector(x, y);
    velocity = new PVector(cos(angle) * speed, sin(angle) * speed);
  }
  
  void update() {
    if (!active) return;
    
    // Mover proyectil
    position.add(PVector.mult(velocity, 1.0/60.0)); // Asumir 60fps
    
    // Reducir vida
    lifespan--;
    if (lifespan <= 0) {
      active = false;
    }
    
    // Verificar colisión con paredes
    int tileX = int(position.x / 64); // tileSize del Level3Manager
    int tileY = int(position.y / 64);
    
    // Verificar límites y paredes (necesitamos acceso al tilemap)
    // Esto se manejará desde Level3Manager
  }
  
  void display() {
    // Esta función se llama desde Level3Manager para renderizado 3D
  }
  
  boolean isDead() {
    return !active;
  }
  
  // Verificar colisión con enemigo
  boolean collidesWith(WallEnemy enemy) {
    if (!active) return false;
    return dist(position.x, position.y, enemy.position.x, enemy.position.y) < 25;
  }
}