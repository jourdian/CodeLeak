class PatchBomb {
  PVector position;
  int timer;
  int duration = 90;
  boolean exploded = false;
  boolean active = true;

  ArrayList<ExplosionWave> waves = new ArrayList<ExplosionWave>();
  ArrayList<ExplosionParticle> particles = new ArrayList<ExplosionParticle>();

  PatchBomb(float x, float y) {
    position = new PVector(x, y);
    timer = duration;
  }

  void update() {
    if (!exploded) {
      timer--;
      if (timer <= 0) {
        explode();
      }
    } else {
      timer--;

      for (ExplosionWave w : waves) w.update();
      for (ExplosionParticle p : particles) p.update();
      particles.removeIf(p -> p.isDead());
    }
  }

  void update(Level2Manager mgr) {
    update(); 
    if (exploded) {
      for (Crack c : mgr.cracks) {
        if (!c.isPatched && isOverCrack(c)) {
          c.patch();
        }
      }
    }
  }
  
  void update(Level3Manager mgr) {
    update(); 
    if (exploded) {
      for (Crack c : mgr.cracks) {
        if (!c.isPatched && isOverCrack(c)) {
          c.patch();
        }
      }
    }
  }

  void explode() {
    exploded = true;
    timer = 0;

    println("🔧 PatchBomb.explode() llamado en posición: " + position.x + ", " + position.y);
    if (audioManager != null) {
      println("🔊 AudioManager disponible, reproduciendo sonido de bomba de reparación...");
      audioManager.playPatchBomb();
      println("🔊 Sonido de bomba de reparación enviado al AudioManager");
    } else {
      println("⚠ AudioManager es null - no se puede reproducir sonido de bomba de reparación");
    }

    // Añadir onda verde
    waves.add(new ExplosionWave(position.x, position.y));

    // Añadir partículas verdes
    for (int i = 0; i < 20; i++) {
      particles.add(new ExplosionParticle(position.x, position.y));
    }
  }

  void display() {
    if (!exploded) {
      PImage[] frames = spriteMap.get("patch_bomb");
      if (frames != null) {
        int frame = int(map(timer, 0, duration, 0, frames.length - 1));
        frame = constrain(frame, 0, frames.length - 1);
        imageMode(CENTER);
        image(frames[frame], position.x, position.y);
        imageMode(CORNER);
      }
    } else {
      for (ExplosionWave w : waves) w.display();
      for (ExplosionParticle p : particles) p.display();
    }
  }

  boolean isDone() {
    return exploded && timer <= -30 && particles.isEmpty() && waves.stream().allMatch(w -> w.isDone());
  }

  boolean isOverCrack(Crack crack) {
    return dist(position.x, position.y, crack.position.x, crack.position.y) < 32;
  }
}
