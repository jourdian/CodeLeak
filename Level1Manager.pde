// Clase que gestiona todos los elementos de la Fase 1 del juego
class Level1Manager extends BaseLevelManager {
  ArrayList<Crack> cracks;
  ArrayList<PatchBomb> bombs;
  ArrayList<WallBomb> wallBombs;
  ArrayList<Glitchwalker> enemies;
  ArrayList<ExplosionParticle> particles = new ArrayList<ExplosionParticle>();
  ArrayList<ExplosionWave> waves = new ArrayList<ExplosionWave>();
  ArrayList<Collectible> collectibles = new ArrayList<Collectible>();

  PlayerBase player;
  Tile[][] tileMap;
  int tileSize = 48;

  boolean isGlitching = false;
  int glitchTimer = 0;
  boolean wallBombShock = false;
  int wallBombShockTimer = 0;
  int playerHealth = 5;

  int maxWallBombs = 8;
  int wallBombsRemaining = 10;

  String[] level1Map = {
    "BBBBBBBBBBBBBBBBBBBBB",
    "B.........G.........B",
    "B.W...W.W.W.W...W.W.B",
    "B...................B",
    "B....W.R...P...G.W..B",
    "B...................B",
    "B.W.W.W...W.....W.W.B",
    "B.........G.........B",
    "B...G...............B",
    "B.W.R.W.W.W.W.W...W.B",
    "B...............R...B",
    "B.........G.........B",
    "B.W.....W.W.W...W.W.B",
    "B...G...............B",
    "BBBBBBBBBBBBBBBBBBBBB"
  };

  Level1Manager() {
    player = new TopDownPlayer(0, 0, this);
    cracks = new ArrayList<Crack>();
    bombs = new ArrayList<PatchBomb>();
    wallBombs = new ArrayList<WallBomb>();
    enemies = new ArrayList<Glitchwalker>();
    wallBombsRemaining = maxWallBombs;

    enemies.add(new Glitchwalker(3 * tileSize + tileSize / 2, 3 * tileSize + tileSize / 2));
    enemies.add(new Glitchwalker(16 * tileSize + tileSize / 2, 10 * tileSize + tileSize / 2));

    loadMap();
  }

  boolean isComplete() {
    // El nivel está completo si no quedan grietas activas
    for (Crack c : cracks) {
      if (c.isActive()) {
        return false;
      }
    }
    return true;
  }

  void loadMap() {
    int cols = level1Map[0].length();
    int rows = level1Map.length;
    tileMap = new Tile[cols][rows];
    cracks.clear();

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        char c = level1Map[y].charAt(x);
        tileMap[x][y] = new Tile(c, x, y);

        if (c == 'P') {
          player.position = new PVector(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2);
        } else if (c == 'G') {
          cracks.add(new Crack(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2));
        }
      }
    }

    for (int i = 0; i < 3; i++) {
      int x, y;
      do {
        x = int(random(tileMap.length));
        y = int(random(tileMap[0].length));
      } while (!tileMap[x][y].isFloor());

      collectibles.add(new Collectible(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2, 'B'));
    }
  }

  void update() {
    player.update();

    int tx = int(player.position.x / tileSize);
    int ty = int(player.position.y / tileSize);
    if (tileMap[tx][ty].isReconfigTrigger()) {
      triggerMapRebuild();
      tileMap[tx][ty] = new Tile('.', tx, ty);
    }

    if (isGlitching) {
      glitchTimer--;
      if (glitchTimer <= 0) isGlitching = false;
    }

    for (Crack c : cracks) c.update(player);

    for (PatchBomb b : bombs) {
      b.update();
      if (b.exploded) {
        for (Crack c : cracks) {
          if (!c.isPatched && b.isOverCrack(c)) {
            c.patch();
            for (Glitchwalker e : enemies) e.panicTimer = 90;
            int x, y;
            do {
              x = int(random(tileMap.length));
              y = int(random(tileMap[0].length));
            } while (!tileMap[x][y].isFloor());
            enemies.add(new Glitchwalker(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2));
            println("🧬 Nuevo Glitchwalker generado por reparación de grieta");

            if (random(1) < 0.5 && wallBombsRemaining < maxWallBombs) {
              wallBombsRemaining++;
              audioManager.playPowerUp();
              println("🔋 Has recuperado una bomba destructora");
            }
          }
        }
      }
    }
    bombs.removeIf(b -> b.isDone());

    for (WallBomb b : wallBombs) b.update(this);
    wallBombs.removeIf(b -> b.isDone());

    for (ExplosionWave w : waves) w.update();
    waves.removeIf(w -> w.isDone());

    ArrayList<Glitchwalker> toRemove = new ArrayList<Glitchwalker>();
    for (Glitchwalker e : enemies) {
      e.update(player, this);

      if (e.collidesWith(player)) {
        if (!player.isInvincible()) {
          damagePlayer();
          player.setInvincible(60);
        }
      }

      for (Crack c : cracks) {
        if (c.isPatched && dist(c.position.x, c.position.y, e.position.x, e.position.y) < 20) {
          c.unpatch();
          println("¡Una grieta ha sido reactivada!");
          float deathChance = constrain(1.0 / enemies.size(), 0.1, 0.5);
          if (random(1) < deathChance) {
            println("💥 Un glitchwalker ha muerto al intentar reabrir la grieta");
            for (int i = 0; i < 6; i++) {
              particles.add(new ExplosionParticle(e.position.x, e.position.y));
            }
            toRemove.add(e);
            break;
          }
        }
      }
    }
    enemies.removeAll(toRemove);

    
    if (wallBombShock) {
      wallBombShockTimer--;
      if (wallBombShockTimer <= 0) wallBombShock = false;
    }

    for (ExplosionParticle p : particles) p.update();
    particles.removeIf(p -> p.isDead());

    for (Collectible c : collectibles) c.update(player, this);
  }

  void display() {
    boolean shaking = isGlitching || wallBombShock;
    if (shaking) {
      pushMatrix();
      translate(random(-5, 5), random(-5, 5));
      if (isGlitching) filter(INVERT);
    }

    // 1. Suelo
    for (int y = 0; y < tileMap[0].length; y++) {
      for (int x = 0; x < tileMap.length; x++) {
        if (tileMap[x][y].isFloor()) {
          tileMap[x][y].display();
        }
      }
    }

    // 2. Grietas (abiertas y parcheadas)
    for (Crack c : cracks) c.display();

    // 3. Personaje, enemigos y elementos móviles
    player.display();
    for (Glitchwalker e : enemies) e.display();
    for (PatchBomb b : bombs) b.display();
    for (WallBomb b : wallBombs) b.display();
    for (ExplosionParticle p : particles) p.display();
    for (ExplosionWave w : waves) w.display();
    for (Collectible c : collectibles) c.display();

    // 4. Paredes (encima de todo)
    for (int y = 0; y < tileMap[0].length; y++) {
      for (int x = 0; x < tileMap.length; x++) {
        if (tileMap[x][y].isWall()) {
          tileMap[x][y].display();
        }
      }
    }

    if (shaking) popMatrix();

    // 5. UI (barra de salud y aviso)
    if (wallBombShock) {
      fill(255, 0, 0);
      textAlign(CENTER, CENTER);
      textSize(24);
      text("¡Has alertado a los enemigos!", width / 2, height - 40);
    }

    int barWidth = 200;
    int barHeight = 20;
    int x = 20;
    int y = 20;

    fill(50);
    rect(x, y, barWidth, barHeight);

    float ratio = float(playerHealth) / 5.0;
    if (playerHealth == 1 && frameCount % 30 < 15) {
      fill(255, 0, 0);
    } else if (playerHealth == 1) {
      fill(100, 0, 0);
    } else if (playerHealth <= 2) {
      fill(255, 200, 0);
    } else {
      fill(0, 255, 0);
    }

  }


  int getRemainingCracks() {
    int count = 0;
    for (Crack c : cracks) if (c.isActive()) count++;
    return count;
  }

  void handleInput(char key, int keyCode) {
    if (key == 'z') {
      bombs.add(new PatchBomb(player.position.x, player.position.y));
      println("💣 Bomba de reparación colocada");
    }
    if (key == 'x' && wallBombsRemaining > 0) {
      wallBombs.add(new WallBomb(player.position.x, player.position.y));
      wallBombsRemaining--;
      println("💥 Bomba destructora colocada");
    }
  }

boolean canMoveTo(float x, float y) {
  // Radio del jugador (aproximadamente la mitad del sprite)
  int playerRadius = 20;
  
  // Verificar las 4 esquinas del rectángulo de colisión del jugador
  float[][] corners = {
    {x - playerRadius, y - playerRadius}, // Esquina superior izquierda
    {x + playerRadius, y - playerRadius}, // Esquina superior derecha
    {x - playerRadius, y + playerRadius}, // Esquina inferior izquierda
    {x + playerRadius, y + playerRadius}  // Esquina inferior derecha
  };

  // Verificar cada esquina
  for (float[] corner : corners) {
    int tx = int(corner[0] / tileSize);
    int ty = int(corner[1] / tileSize);
    
    // Verificar límites del mapa
    if (tx < 0 || tx >= tileMap.length || ty < 0 || ty >= tileMap[0].length) {
      return false;
    }
    
    // Verificar si hay una pared
    if (tileMap[tx][ty].isWall()) {
      return false;
    }
  }
  
  return true;
}


void triggerMapRebuild() {
  println("⚠ RECONFIGURANDO EL SISTEMA...");
  cracks.clear();

  // 1. Crear nuevas grietas
  for (int i = 0; i < 6; i++) {
    int x, y;
    do {
      x = int(random(tileMap.length));
      y = int(random(tileMap[0].length));
    } while (!tileMap[x][y].isFloor());
    cracks.add(new Crack(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2));
  }

  // 2. Reposicionar enemigos
  for (Glitchwalker e : enemies) {
    int x, y;
    do {
      x = int(random(tileMap.length));
      y = int(random(tileMap[0].length));
    } while (!tileMap[x][y].isFloor());
    e.position = new PVector(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2);
  }

  // 3. Añadir 2 nuevos tiles de reconfiguración
// 3. Añadir 2 nuevos tiles de reconfiguración (sin conflicto con jugador ni grietas)
for (int i = 0; i < 2; i++) {
  int x, y;
  boolean conflict;
  do {
    x = int(random(tileMap.length));
    y = int(random(tileMap[0].length));

    conflict = false;

    // No sobre una grieta
    for (Crack c : cracks) {
      int cx = int(c.position.x / tileSize);
      int cy = int(c.position.y / tileSize);
      if (x == cx && y == cy) {
        conflict = true;
        break;
      }
    }

    // No sobre el jugador
    int px = int(player.position.x / tileSize);
    int py = int(player.position.y / tileSize);
    if (x == px && y == py) conflict = true;

    // No sobre otro 'R' existente (opcional)
    if (tileMap[x][y].isReconfigTrigger()) conflict = true;

  } while (!tileMap[x][y].isFloor() || conflict);

  tileMap[x][y] = new Tile('R', x, y);
}


  isGlitching = true;
  glitchTimer = 30;
  println("✔ RECONFIGURACIÓN COMPLETA");
}


  void damagePlayer() {
    playerHealth--;
    audioManager.playEnemyContact();
    println("¡El mono ha recibido daño! Salud restante: " + playerHealth);
    if (playerHealth <= 0) {
      println("🧠 Salud agotada... GAME OVER");
      gameState = GameState.GAMEOVER;
    } else {
      println("💥 Has recibido daño. Salud restante: " + playerHealth);
    }
  }

  int getRemainingWallBombs() {
    return wallBombsRemaining;
  }

void handleWallBombExplosion(WallBomb bomb) {
  // 1. Partículas
  for (int i = 0; i < 30; i++) {
    particles.add(new ExplosionParticle(bomb.position.x, bomb.position.y));
  }

  // 2. Onda expansiva
  waves.add(new ExplosionWave(bomb.position.x, bomb.position.y));

  int tileRadius = 1; // distancia en tiles para destruir muros (1 tile = 48 px)

  // 3. Destruir muros dentro del radio de 80px
  int cx = int(bomb.position.x / tileSize);
  int cy = int(bomb.position.y / tileSize);
  for (int dx = -tileRadius; dx <= tileRadius; dx++) {
    for (int dy = -tileRadius; dy <= tileRadius; dy++) {
      int tx = cx + dx;
      int ty = cy + dy;
      if (tx >= 0 && tx < tileMap.length && ty >= 0 && ty < tileMap[0].length) {
        Tile t = tileMap[tx][ty];
        float distTile = dist(bomb.position.x, bomb.position.y, tx * tileSize + tileSize/2, ty * tileSize + tileSize/2);
        if (distTile <= 80 && t.isDestructible()) {
          t.type = '.'; // convertir en suelo
        }
      }
    }
  }

  // 4. Matar enemigos cercanos con radio 100px
  ArrayList<Glitchwalker> toRemove = new ArrayList<Glitchwalker>();
  for (Glitchwalker g : enemies) {
    if (dist(bomb.position.x, bomb.position.y, g.position.x, g.position.y) < 100) {
      toRemove.add(g);
      for (int i = 0; i < 6; i++) {
        particles.add(new ExplosionParticle(g.position.x, g.position.y));
      }
    }
  }
  enemies.removeAll(toRemove);

  // 5. Dañar jugador si está dentro de 100px
  if (dist(bomb.position.x, bomb.position.y, player.position.x, player.position.y) < 100) {
    if (!player.isInvincible()) {
      damagePlayer();
      player.setInvincible(60);
    }
  }

  // 6. Temblor de pantalla
  wallBombShock = true;
  wallBombShockTimer = 30;
}


ArrayList<Crack> getCracks() {
  return cracks;
}

Tile[][] getTileMap() {
  return tileMap;
}

int getTileSize() {
  return tileSize;
}




}
