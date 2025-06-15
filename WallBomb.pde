class WallBomb {
  PVector position;
  int timer;
  int duration = 90;
  boolean exploded = false;

  ArrayList<ExplosionWave> waves = new ArrayList<ExplosionWave>();
ArrayList<ExplosionParticle> particles = new ArrayList<ExplosionParticle>();

  WallBomb(float x, float y) {
    position = new PVector(x, y);
    timer = duration;
  }

  // Para Level1Manager (sin destrucción de muros)
void update(BaseLevelManager mgr) {
  if (!exploded) {
    timer--;
    if (timer <= 0) {
      explode();

      // Delegamos la llamada a cada manager concreto
      if (mgr instanceof Level1Manager) {
        ((Level1Manager) mgr).handleWallBombExplosion(this);
      } else if (mgr instanceof Level2Manager) {
        ((Level2Manager) mgr).handleWallBombExplosion(this);
      } else if (mgr instanceof Level3Manager) {
        ((Level3Manager) mgr).handleWallBombExplosion(this);
      }
    }
  } else {
    timer--;
  }

  for (ExplosionWave w : waves) w.update();
  for (ExplosionParticle p : particles) p.update();
particles.removeIf(p -> p.isDead());
}


  void updateCommon() {
    if (!exploded) {
      timer--;
      if (timer <= 0) {
        explode();
      }
    } else {
      timer--;
    }
  }

void explode() {
  exploded = true;
  timer = 0;
  waves.add(new ExplosionWave(position.x, position.y)); 
  
  println("💥 WallBomb.explode() llamado en posición: " + position.x + ", " + position.y);
  if (audioManager != null) {
    println("🔊 AudioManager disponible, reproduciendo sonido de bomba destructora...");
    audioManager.playWallBomb();
    println("🔊 Sonido de bomba destructora enviado al AudioManager");
  } else {
    println("⚠ AudioManager es null - no se puede reproducir sonido de bomba destructora");
  }
  
for (int i = 0; i < 25; i++) {
  particles.add(new ExplosionParticle(position.x, position.y));
}
}


  void display() {
    PImage[] frames = spriteMap.get("wall_bomb");

    if (!exploded && frames != null) {
      int frame = int(map(timer, 0, duration, 0, frames.length - 1));
      frame = constrain(frame, 0, frames.length - 1);
      imageMode(CENTER);
      image(frames[frame], position.x, position.y);
      imageMode(CORNER);
    } else {
      for (ExplosionWave w : waves) w.display();
      for (ExplosionParticle p : particles) p.display();
    }
  }

  boolean isDone() {
return exploded && timer <= -30 && particles.isEmpty() && waves.stream().allMatch(w -> w.isDone());
  }
}
