class Level2Manager extends BaseLevelManager {
  Tile[][] tileMap;
  PlatformPlayer player;
  ArrayList<Crack> cracks = new ArrayList<Crack>();
  ArrayList<PatchBomb> bombs = new ArrayList<PatchBomb>();
  ArrayList<WallBomb> wallBombs = new ArrayList<WallBomb>();
  int tileSize = 48;
  ArrayList<ExplosionParticle> particles = new ArrayList<>();
  ArrayList<ExplosionWave> waves = new ArrayList<>();
  ArrayList<PlatformWalker> enemies = new ArrayList<PlatformWalker>();
  ArrayList<Collectible> collectibles = new ArrayList<Collectible>();
  boolean wallBombShock = false;
  int wallBombShockTimer = 0;
  int playerHealth = 5;
  int maxPlayerHealth = 5;
  int wallBombsRemaining = 8;
  int maxWallBombs = 8;

  String[] level2Map = {
    "....................",
    "....................",
    "....................",
    "......W.....WWWWWW..",
    "......G.............",
    "....WWWWW....W......",
    "..........WWW.......",
    "....................",
    "......W......WWW....",
    "............G.......",
    ".WWW.......WWWW.....",
    ".....WW.......WWWWW.",
    "......G.............",
    "...WWWWWW...........",
    "................E...",
    "......W.......WWW...",
    "....................",
    "..W......WWWWW......",
    "..G.................",
    ".WWWW.........WWWWW.",
    "............G.......",
    "....W......WWWWW....",
    "..........E.........",
    ".....W..............",
    "...WWWW......W......",
    "............G.......",
    ".........WWWWWWW.W..",
    "....................",
    "....W...............",
    "....G.....W.........",
    "...WWW........E.....",
    "...W......LWWWWWWWL.",
    "............G.......",
    "....W.....WWWW..W...",
    "...............E....",
    "......W.............",
    ".............W......",
    ".......W.......W....",
    ".............G......",
    ".....WP....WWWW.....",
    "....................",
    "..............W.....",
    "........E...........",
    ".......E....WWWW....",
    "....LWWWWWWL........",
    "................E...",
    "....................",
    "...LWWWWWL....WW....",
    "....................",
    "WWWWWWWWWWWWWWWWWWWW"
  };

  Level2Manager() {
    println("🎮 Inicializando Level2Manager...");
    if (audioManager != null) {
      println("🔊 AudioManager disponible en Level2");
      audioManager.printStatus();
      
      audioManager.verifyAndRepairSounds();
    } else {
      println("⚠ AudioManager es null en Level2Manager");
    }
    
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
    int rows = level2Map.length;
    int cols = level2Map[0].length();
    tileMap = new Tile[cols][rows];

    // Primera pasada: crear tiles
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        char c = level2Map[y].charAt(x);
        tileMap[x][y] = new Tile(c, x, y);
      }
    }

    // Segunda pasada: procesar entidades
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        char c = level2Map[y].charAt(x);

        if (c == 'P') {
          player = new PlatformPlayer(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2, tileMap);
        } else if (c == 'G') {
          cracks.add(new Crack(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2));
        } else if (c == 'E') {
          int enemyX = x * tileSize + tileSize / 2;
          int enemyY = y * tileSize + tileSize / 2;

          // Buscar el primer suelo debajo del enemigo
          for (int dy = y + 1; dy < level2Map.length; dy++) {
            char below = level2Map[dy].charAt(x);

            if (below == 'W') {
              enemyY = dy * tileSize - tileSize / 2;
              break;
            }
          }

          enemies.add(new PlatformWalker(enemyX, enemyY, tileMap, tileSize));
        }
      }
    }
  }


  void update() {
    player.update();
    // Actualizar enemigos y detectar colisiones con jugador
    for (PlatformWalker e : enemies) {
      e.update();

      if (e.collidesWith(player)) {
        if (!player.isInvincible()) {
          damagePlayer();
          player.setInvincible(60);
        }
      }
    }


    for (int i = bombs.size() - 1; i >= 0; i--) {
      PatchBomb b = bombs.get(i);
      b.update();
      
      // Si la bomba explotó, manejar la reparación de grietas manualmente
      if (b.exploded) {
        for (Crack c : cracks) {
          if (!c.isPatched && b.isOverCrack(c)) {
            c.patch();
            println("🔧 Grieta reparada en Level2");
          }
        }
      }
      
      if (b.isDone()) {
        bombs.remove(i);
      }
    }

    for (WallBomb b : wallBombs) b.update(this);
    wallBombs.removeIf(b -> b.isDone());

    for (Crack c : cracks) c.update(player);

        if (wallBombShock) {
      wallBombShockTimer--;
      if (wallBombShockTimer <= 0) wallBombShock = false;
    }
  }

  void display() {
    boolean shaking = wallBombShock;

    if (shaking) {
      pushMatrix();
      translate(random(-5, 5), random(-5, 5));
    }

    float offsetY = height / 2 - player.position.y;
    pushMatrix();
    translate(0, offsetY);

    for (int y = 0; y < tileMap[0].length; y++) {
      for (int x = 0; x < tileMap.length; x++) {
        tileMap[x][y].display();
      }
    }

    for (Crack c : cracks) c.display();
    for (PatchBomb b : bombs) b.display();
    for (WallBomb b : wallBombs) b.display();
    player.display();
    for (PlatformWalker e : enemies) e.display();

    popMatrix(); 

    if (shaking) {
      popMatrix(); 
    }

    // 🟥 Mensaje de alerta
    if (wallBombShock) {
      fill(255, 0, 0);
      textAlign(CENTER, CENTER);
      textSize(24);
      text("¡Has alertado a los enemigos!", width / 2, height - 40);
    }

    // HUD completo para Level 2
    drawHUD2D();
  }



  void handleInput(char key, int keyCode) {
    if (key == 'a' || key == 'A' || keyCode == LEFT) {
      player.leftPressed = true;
    }
    if (key == 'd' || key == 'D' || keyCode == RIGHT) {
      player.rightPressed = true;
    }
    
    player.keyPressed(key, keyCode);
    
    if (key == 'z') {
      bombs.add(new PatchBomb(player.position.x, player.position.y));
      println("💣 Bomba de reparación colocada en Level2");
      
            if (audioManager != null) {
        println("🔊 AudioManager disponible para bomba de reparación en Level2");
      } else {
        println("⚠ AudioManager no disponible al colocar bomba en Level2");
      }
    }
    if (key == 'x' && wallBombsRemaining > 0) {
      wallBombs.add(new WallBomb(player.position.x, player.position.y));
      wallBombsRemaining--;
      println("💥 Bomba destructora colocada en Level2");
      
            if (audioManager != null) {
        println("🔊 AudioManager disponible para bomba destructora en Level2");
      } else {
        println("⚠ AudioManager no disponible al colocar bomba destructora en Level2");
      }
    }
    if (key == 'w' || keyCode == UP) {
      player.jumpRequested = true;
      println("🦘 Solicitud de salto enviada al PlatformPlayer");
    }
    
    if (key == 't') {
      println("🔊 Prueba manual de sonidos en Level2...");
      if (audioManager != null) {
        println("🔊 Probando sonido de bomba de reparación...");
        audioManager.playPatchBomb();
        
        println("🔊 Probando sonido de bomba destructora...");
        audioManager.playWallBomb();
        
        println("🔊 Probando sonido de salto...");
        audioManager.playJump();
        
        println("🔊 Prueba de sonidos completada en Level2");
      } else {
        println("⚠ AudioManager no disponible para prueba de sonidos en Level2");
      }
    }
  }

  void handleKeyReleased(char key, int keyCode) {
    if (key == 'a' || key == 'A' || keyCode == LEFT) {
      player.leftPressed = false;
    }
    if (key == 'd' || key == 'D' || keyCode == RIGHT) {
      player.rightPressed = false;
    }
    
    player.keyReleased(key, keyCode);
  }

  int getRemainingCracks() {
    int count = 0;
    for (Crack c : cracks) {
      if (!c.isPatched) count++;
    }
    return count;
  }


  void handleWallBombExplosion(WallBomb bomb) {
    // 6. Temblor de pantalla
    wallBombShock = true;
    wallBombShockTimer = 30;

    // 1. Partículas de explosión
    for (int i = 0; i < 30; i++) {
      particles.add(new ExplosionParticle(bomb.position.x, bomb.position.y));
    }

    // 2. Onda expansiva
    waves.add(new ExplosionWave(bomb.position.x, bomb.position.y));

    // 3. Destruir muros dentro de un radio (80 px)
    int tileRadius = 1;
    int cx = int(bomb.position.x / tileSize);
    int cy = int(bomb.position.y / tileSize);

    for (int dx = -tileRadius; dx <= tileRadius; dx++) {
      for (int dy = -tileRadius; dy <= tileRadius; dy++) {
        int tx = cx + dx;
        int ty = cy + dy;
        if (tx >= 0 && tx < tileMap.length && ty >= 0 && ty < tileMap[0].length) {
          Tile t = tileMap[tx][ty];
          float distTile = dist(bomb.position.x, bomb.position.y, tx * tileSize + tileSize / 2, ty * tileSize + tileSize / 2);
          if (distTile <= 80 && t.isDestructible()) {
            t.type = '.';  // Convertir muro en suelo
          }
        }
      }
    }

    // 4. Matar enemigos en radio 100 px
    ArrayList<PlatformWalker> toRemove = new ArrayList<>();
    for (PlatformWalker g : enemies) {
      if (dist(bomb.position.x, bomb.position.y, g.position.x, g.position.y) < 100) {
        toRemove.add(g);
        for (int i = 0; i < 6; i++) {
          particles.add(new ExplosionParticle(g.position.x, g.position.y));
        }
      }
    }
    enemies.removeAll(toRemove);


    // 5. Dañar jugador en radio 100 px
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


  ArrayList<Crack> getCracks() {
    return cracks;
  }

  Tile[][] getTileMap() {
    return tileMap;
  }

  int getTileSize() {
    return tileSize;
  }

  int getRemainingWallBombs() {
    return wallBombsRemaining;
  }

  boolean canMoveTo(float x, float y) {
    int r = 15;
    float[][] points = {
      {x - r, y}, {x + r, y}, {x, y - r}, {x, y + r}
    };

    for (float[] p : points) {
      int tx = int(p[0] / tileSize);
      int ty = int(p[1] / tileSize);
      if (tx < 0 || tx >= tileMap.length || ty < 0 || ty >= tileMap[0].length) return false;
      if (tileMap[tx][ty].isWall()) return false; // ← usa método válido
    }
    return true;
  }
  
  void drawHUD2D() {
    // Panel principal del HUD
    fill(0, 0, 0, 180);
    rect(0, 0, width, 80);
    
    // Borde del panel
    stroke(100, 100, 100);
    strokeWeight(2);
    line(0, 80, width, 80);
    noStroke();
    
    // === SALUD DEL JUGADOR ===
    fill(255, 255, 255);
    textAlign(LEFT, TOP);
    textSize(10);
    text("SALUD", 20, 15);
    
    // Barra de salud
    int healthBarWidth = 150;
    int healthBarHeight = 12;
    int healthX = 20;
    int healthY = 30;
    
    // Fondo de la barra
    fill(100, 0, 0);
    rect(healthX, healthY, healthBarWidth, healthBarHeight);
    
    // Barra de salud actual
    float healthRatio = float(playerHealth) / float(maxPlayerHealth);
    if (playerHealth == 1 && frameCount % 30 < 15) {
      fill(255, 100, 100); // Parpadeo cuando salud crítica
    } else if (playerHealth <= 2) {
      fill(255, 200, 0); // Amarillo cuando salud baja
    } else {
      fill(0, 255, 0); // Verde cuando salud buena
    }
    rect(healthX, healthY, healthBarWidth * healthRatio, healthBarHeight);
    
    // Texto de salud
    fill(255, 255, 255);
    textSize(10);
    text(playerHealth + "/" + maxPlayerHealth, healthX + healthBarWidth + 10, healthY + 2);
    
    // === OBJETIVOS ===
    fill(255, 255, 0);
    textAlign(CENTER, TOP);
    textSize(12);
    text("NIVEL 2: PLATAFORMAS", width/2, 10);
    
    fill(255, 255, 255);
    textSize(9);
    int remainingCracks = getRemainingCracks();
    text("GRIETAS RESTANTES: " + remainingCracks, width/2, 25);
    text("BOMBAS DESTRUCTORAS: " + wallBombsRemaining, width/2, 40);
    
    // === CONTROLES ===
    fill(0, 255, 255);
    textAlign(RIGHT, TOP);
    textSize(8);
    text("CONTROLES:", width - 20, 15);
    text("A/D MOVER  W SALTAR", width - 20, 25);
    text("Z PARCHE  X BOMBA", width - 20, 35);
    text("T PROBAR SONIDOS", width - 20, 45);
    
    // === INDICADORES DE ESTADO ===
    // Indicador de suelo
    if (player != null && player instanceof PlatformPlayer) {
      PlatformPlayer pPlayer = (PlatformPlayer) player;
      if (pPlayer.onGround) {
        fill(0, 255, 0);
        text("EN SUELO", width - 20, 55);
      } else {
        fill(255, 100, 100);
        text("EN AIRE", width - 20, 55);
      }
    }
    
    // Progreso del nivel
    fill(255, 255, 255);
    textAlign(LEFT, TOP);
    textSize(8);
    int totalCracks = cracks.size();
    int cracksPatched = totalCracks - remainingCracks;
    float progress = totalCracks > 0 ? (float(cracksPatched) / float(totalCracks)) * 100 : 0;
    text("PROGRESO: " + int(progress) + "%", 20, 55);
    
    // Barra de progreso
    int progressBarWidth = 100;
    int progressBarHeight = 6;
    int progressX = 20;
    int progressY = 65;
    
    fill(50, 50, 50);
    rect(progressX, progressY, progressBarWidth, progressBarHeight);
    
    fill(0, 200, 255);
    rect(progressX, progressY, progressBarWidth * (progress / 100.0), progressBarHeight);
    
    // === EFECTOS ESPECIALES ===
    // Efecto de temblor en el HUD cuando hay explosión
    if (wallBombShock) {
      fill(255, 0, 0, 100);
      rect(0, 0, width, 80);
      
      fill(255, 255, 255);
      textAlign(CENTER, CENTER);
      textSize(10);
      text("¡EXPLOSIÓN!", width/2, 65);
    }
  }
}
