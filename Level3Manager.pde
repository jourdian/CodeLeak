// Level3Manager con jugabilidad corregida
class Level3Manager extends BaseLevelManager {
  RaycastPlayer player;
  ArrayList<Crack> cracks;
  ArrayList<PatchBomb> bombs;
  ArrayList<WallBomb> wallBombs;
  ArrayList<ExplosionParticle> particles;
  ArrayList<ExplosionWave> waves;
  ArrayList<WallEnemy> enemies;
  ArrayList<Projectile> projectiles;
  ArrayList<Collectible> collectibles;
  int tileSize = 64;
  Tile[][] tileMap;
  float fov = PI / 3;
  int renderStep = 3;
  boolean wallBombShock = false;
  int wallBombShockTimer = 0;
  int playerHealth = 5;
  int wallBombsRemaining = 8;
  
  // Mapa más pequeño y compacto
  String[] level3Map = {
    "WWWWWWWWWWWWWWWWWWWW",
    "W..................W",
    "W.WWWW.WWWWW.WWWW..W",
    "W.W..W.W...W.W..W..W",
    "W.W..W.WGWW.W..W...W", // Grieta en pared
    "W....W.....W.......W",
    "W.WWWWWWWWWWWWWW.E.W", // Enemigo en espacio abierto
    "W.W..........W.....W",
    "W.W.WWGWWWWW.W.WWW.W", // Grieta en pared
    "W.W.W......W.W...W.W",
    "W...W..E...W.....W.W", // Enemigo en espacio abierto
    "W.WWW.WWWWWWWWWW.W.W",
    "W.................GW", // Grieta en pared exterior
    "W.WWWWWWWWWWWWWWWW.W",
    "W.E................W", // Enemigo en espacio abierto
    "W.WWWW.WWGWW.WWWWW.W", // Grieta en pared
    "W.W..W.W...W.W...W.W",
    "W.W..W.....W.....W.W",
    "W..................W",
    "WWWWWWWWWWWWWWWWWWWW"
  };

  Level3Manager() {
    cracks = new ArrayList<Crack>();
    bombs = new ArrayList<PatchBomb>();
    wallBombs = new ArrayList<WallBomb>();
    particles = new ArrayList<ExplosionParticle>();
    waves = new ArrayList<ExplosionWave>();
    enemies = new ArrayList<WallEnemy>();
    projectiles = new ArrayList<Projectile>();
    collectibles = new ArrayList<Collectible>();
    wallBombsRemaining = 8;
    
    println("🎮 Inicializando Level3Manager...");
    if (audioManager != null) {
      println("🔊 AudioManager disponible en Level3");
      audioManager.printStatus();
      
      // Reinicializar efectos de sonido para asegurar que funcionen en Level3
      println("🔄 Reinicializando efectos de sonido para Level3...");
      audioManager.reinitializeSFX();
      
      audioManager.verifyAndRepairSounds();
    } else {
      println("⚠ AudioManager es null en Level3Manager");
    }
    
    loadMap();
    player = new RaycastPlayer(1.5 * tileSize, 1.5 * tileSize, this);
    
    // Agregar collectibles manualmente en ubicaciones estratégicas
    collectibles.add(new Collectible(3 * tileSize, 3 * tileSize, 'B'));
    collectibles.add(new Collectible(7 * tileSize, 5 * tileSize, 'B'));
    collectibles.add(new Collectible(12 * tileSize, 8 * tileSize, 'B'));
    collectibles.add(new Collectible(15 * tileSize, 12 * tileSize, 'B'));
    collectibles.add(new Collectible(5 * tileSize, 14 * tileSize, 'H')); // Vida
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
    int cols = level3Map[0].length();
    int rows = level3Map.length;
    tileMap = new Tile[cols][rows];
    cracks.clear();
    enemies.clear();

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        char c = level3Map[y].charAt(x);
        
        // Las grietas 'G' representan tiles especiales de suelo con grietas
        if (c == 'G') {
          // Crear tile de suelo transitable con grieta
          tileMap[x][y] = new Tile('.', x, y);
          // Marcar este tile como grieta
          tileMap[x][y].hasCrack = true;
          // Crear la grieta para el sistema de juego
          cracks.add(new Crack(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2));
          println("✓ Grieta creada en suelo en posición: (" + x + ", " + y + ") - Mundo: (" + (x * tileSize + tileSize / 2) + ", " + (y * tileSize + tileSize / 2) + ")");
        } else if (c == 'E') {
          // Enemigo en espacio abierto
          tileMap[x][y] = new Tile('.', x, y);
          enemies.add(new WallEnemy(x * tileSize + tileSize / 2, y * tileSize + tileSize / 2, this));
        } else {
          tileMap[x][y] = new Tile(c, x, y);
        }
      }
    }
    
    println("✓ Mapa cargado. Grietas totales: " + cracks.size());
  }

  void update() {
    if (player != null) {
      player.update();
    }
    
    // Actualizar enemigos
    for (int i = enemies.size() - 1; i >= 0; i--) {
      WallEnemy e = enemies.get(i);
      if (player != null) {
        e.update(player);
        
        if (e.collidesWith(player)) {
          if (!player.isInvincible()) {
            damagePlayer();
            player.setInvincible(60);
          }
        }
      }
    }
    
    // Actualizar grietas
    if (player != null) {
      for (Crack c : cracks) c.update(player);
    }
    
    // Actualizar collectibles
    for (Collectible col : collectibles) {
      col.update(player, this);
    }
    
    // Actualizar bombas de reparación
    for (int i = bombs.size() - 1; i >= 0; i--) {
      PatchBomb b = bombs.get(i);
      b.update();
      if (b.exploded) {
        // Buscar grietas en el tile donde explotó la bomba
        int bombTileX = int(b.position.x / tileSize);
        int bombTileY = int(b.position.y / tileSize);
        
        for (Crack c : cracks) {
          if (!c.isPatched) {
            int crackTileX = int(c.position.x / tileSize);
            int crackTileY = int(c.position.y / tileSize);
            
            if (abs(crackTileX - bombTileX) <= 1 && abs(crackTileY - bombTileY) <= 1) {
              c.patch();
              println("🔧 Grieta reparada en el nivel 3D en tile (" + crackTileX + ", " + crackTileY + ")");
            }
          }
        }
      }
      if (b.isDone()) bombs.remove(i);
    }
    
    // Actualizar bombas destructoras
    for (int i = wallBombs.size() - 1; i >= 0; i--) {
      WallBomb b = wallBombs.get(i);
      b.update(this);
      if (b.isDone()) wallBombs.remove(i);
    }
    
    // Actualizar proyectiles
    for (int i = projectiles.size() - 1; i >= 0; i--) {
      Projectile proj = projectiles.get(i);
      proj.update();
      
      // Verificar colisión con paredes
      int tileX = int(proj.position.x / tileSize);
      int tileY = int(proj.position.y / tileSize);
      if (tileX < 0 || tileX >= tileMap.length || tileY < 0 || tileY >= tileMap[0].length || 
          tileMap[tileX][tileY].isWall()) {
        proj.active = false;
        // Crear efecto de impacto
        for (int j = 0; j < 3; j++) {
          particles.add(new ExplosionParticle(proj.position.x, proj.position.y));
        }
      }
      
      // Verificar colisión con enemigos
      for (int j = enemies.size() - 1; j >= 0; j--) {
        WallEnemy enemy = enemies.get(j);
        if (proj.collidesWith(enemy)) {
          // Eliminar enemigo
          enemies.remove(j);
          proj.active = false;
          
          // Crear efecto de eliminación
          for (int k = 0; k < 8; k++) {
            particles.add(new ExplosionParticle(enemy.position.x, enemy.position.y));
          }
          println("🎯 Enemigo eliminado con disparo");
          break;
        }
      }
      
      if (proj.isDead()) projectiles.remove(i);
    }
    
    // Actualizar efectos
    for (int i = particles.size() - 1; i >= 0; i--) {
      ExplosionParticle p = particles.get(i);
      p.update();
      if (p.isDead()) particles.remove(i);
    }
    
    for (int i = waves.size() - 1; i >= 0; i--) {
      ExplosionWave w = waves.get(i);
      w.update();
      if (w.isDone()) waves.remove(i);
    }
    
        
    if (wallBombShock) {
      wallBombShockTimer--;
      if (wallBombShockTimer <= 0) wallBombShock = false;
    }
  }

  void display() {
    boolean shaking = wallBombShock;
    if (shaking) {
      pushMatrix();
      translate(random(-2, 2), random(-2, 2));
    }
    
    background(0);
    drawFloorAndCeilingWithTextures();
    renderWallsWithTextures();
    renderCrackShadows(); // Renderizar sombras/marcas en el suelo
    renderCollectibleShadows(); // Renderizar collectibles en el suelo
    renderEnemyShadows(); // Renderizar sombras de enemigos
    renderBombShadows(); // Renderizar sombras de bombas
    renderCrackSmoke(); // Renderizar humo después de las sombras
    renderEnemiesOptimized();
    renderProjectiles3D(); // Renderizar proyectiles
    renderBombs3D(); // Renderizar bombas en 3D
    renderExplosionEffects3D(); // Renderizar efectos de explosión globales
    renderCrosshair(); // Renderizar punto de mira
    
    if (shaking) popMatrix();
    drawHUDDoom(getRemainingCracks(), getRemainingWallBombs(), playerHealth);
    
    // Dibujar minimapa específico para Level 3
    drawMinimapImproved();
  }
  
  void drawFloorAndCeilingWithTextures() {
    if (player == null) return;
    
    // Renderizar suelo como tiles individuales
    renderFloorTiles();
    
    // Renderizar techo simple
    fill(25, 25, 40);
    rect(0, 0, width, height/2);
  }
  
  void renderFloorTiles() {
    if (player == null) return;
    
    PImage[] floorSprites = spriteMap.get("ground");
    if (floorSprites == null) {
      floorSprites = spriteMap.get("floor");
    }
    PImage[] crackSprites = spriteMap.get("crack_open");
    PImage[] patchedSprites = spriteMap.get("crack_patched");
    PImage floorTexture = (floorSprites != null && floorSprites.length > 0) ? floorSprites[0] : null;
    
    int step = 6; // Reducir paso para mejor detalle
    
    for (int y = height/2; y < height; y += step) {
      float distance = height / (2.0 * y - height);
      if (distance > 0 && distance < 400) {
        float weight = distance * 0.3;
        float brightness = map(distance, 0, 300, 1.0, 0.3);
        brightness = constrain(brightness, 0.3, 1.0);
        
        for (int x = 0; x < width; x += step) {
          float rayAngle = player.rotation - fov/2 + (x / float(width)) * fov;
          float floorX = player.position.x + weight * cos(rayAngle);
          float floorY = player.position.y + weight * sin(rayAngle);
          
          // Determinar qué tile del mapa corresponde a esta posición
          int tileX = int(floorX / tileSize);
          int tileY = int(floorY / tileSize);
          
          color finalColor = color(70, 50, 35); // Color por defecto
          
          // Verificar si es un tile válido y no es pared
          if (tileX >= 0 && tileX < tileMap.length && tileY >= 0 && tileY < tileMap[0].length) {
            Tile currentTile = tileMap[tileX][tileY];
            
            // Solo renderizar si no es pared
            if (!currentTile.isWall()) {
              // Verificar si hay una grieta en este tile
              boolean hasCrackHere = false;
              boolean isCrackPatched = false;
              
              for (Crack crack : cracks) {
                int crackTileX = int(crack.position.x / tileSize);
                int crackTileY = int(crack.position.y / tileSize);
                if (crackTileX == tileX && crackTileY == tileY) {
                  hasCrackHere = true;
                  isCrackPatched = crack.isPatched;
                  break;
                }
              }
              
              // Suelo normal - marrón (las grietas se renderizan por separado)
              if (floorTexture != null) {
                int tx = (int)(abs(floorX) / 2) % floorTexture.width;
                int ty = (int)(abs(floorY) / 2) % floorTexture.height;
                finalColor = floorTexture.get(tx, ty);
              } else {
                finalColor = color(120, 100, 80); // Color marrón por defecto
              }
            } else {
              // Es una pared, no renderizar suelo aquí
              continue;
            }
          } else {
            // Fuera del mapa - usar textura por defecto
            if (floorTexture != null) {
              int tx = (int)(abs(floorX) / 2) % floorTexture.width;
              int ty = (int)(abs(floorY) / 2) % floorTexture.height;
              finalColor = floorTexture.get(tx, ty);
            }
          }
          
          // Aplicar brillo y renderizar
          fill(red(finalColor) * brightness, green(finalColor) * brightness, blue(finalColor) * brightness);
          rect(x, y, step, step);
        }
      }
    }
  }
  
  void renderWallsWithTextures() {
    if (player == null) return;
    
    PImage[] wallSprites = spriteMap.get("wall");
    
    for (int x = 0; x < width; x += renderStep) {
      float rayAngle = player.rotation - fov/2 + (x / float(width)) * fov;
      RaycastHit hit = castRayOptimized(rayAngle);
      
      if (hit.distance > 0) {
        float correctedDistance = hit.distance * cos(rayAngle - player.rotation);
        float wallScreenHeight = (height * 50) / correctedDistance;
        wallScreenHeight = constrain(wallScreenHeight, 0, height);
        float wallTop = height/2 - wallScreenHeight/2;
        float wallBottom = height/2 + wallScreenHeight/2;
        
        wallTop = constrain(wallTop, 0, height);
        wallBottom = constrain(wallBottom, 0, height);
        
        float brightness = map(correctedDistance, 0, 400, 220, 80);
        brightness = constrain(brightness, 80, 220);
        
        if (wallSprites != null && wallSprites.length > 0) {
          PImage wallTexture = wallSprites[0];
          float wallOffset = (hit.hitX + hit.hitY) % tileSize;
          int textureX = (int)(wallOffset / tileSize * wallTexture.width);
          textureX = constrain(textureX, 0, wallTexture.width - 1);
          
          for (int y = (int)wallTop; y <= (int)wallBottom; y += 2) {
            if (y >= 0 && y < height) {
              float textureY = ((y - wallTop) / (wallBottom - wallTop)) * wallTexture.height;
              int ty = constrain((int)textureY, 0, wallTexture.height - 1);
              color pixelColor = wallTexture.get(textureX, ty);
              
              float shadeFactor = hit.isNorthSouth ? 0.7 : 1.0;
              shadeFactor *= brightness / 255.0;
              
              fill(red(pixelColor) * shadeFactor, green(pixelColor) * shadeFactor, blue(pixelColor) * shadeFactor);
              rect(x, y, renderStep, 2);
            }
          }
        } else {
          if (hit.isNorthSouth) {
            fill(brightness * 0.7);
          } else {
            fill(brightness);
          }
          rect(x, wallTop, renderStep, wallBottom - wallTop);
        }
      }
    }
  }
  
  void renderEnemiesOptimized() {
    if (player == null) return;
    
    PImage[] enemySprites = spriteMap.get("enemy_down");
    
    for (WallEnemy enemy : enemies) {
      float dx = enemy.position.x - player.position.x;
      float dy = enemy.position.y - player.position.y;
      float distance = sqrt(dx*dx + dy*dy);
      
      if (distance < 400) {
        // Verificar línea de vista (oclusión)
        if (hasLineOfSight(player.position.x, player.position.y, enemy.position.x, enemy.position.y)) {
          float enemyAngle = atan2(dy, dx);
          float angleDiff = enemyAngle - player.rotation;
          
          while (angleDiff > PI) angleDiff -= TWO_PI;
          while (angleDiff < -PI) angleDiff += TWO_PI;
          
          if (abs(angleDiff) < fov/2) {
            float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
            float spriteScale = (height * 0.8) / distance;
            float spriteWidth = 60 * spriteScale;
            float spriteHeight = 60 * spriteScale;
            
            // Posicionar en el suelo
            float groundLevel = height/2 + (height * 25) / distance;
            float spriteY = groundLevel - spriteHeight;
            
            if (enemySprites != null && enemySprites.length > 0) {
              PImage enemySprite = enemySprites[(frameCount / 8) % enemySprites.length];
              
              if (enemy.chasing) {
                tint(255, 150, 150);
              } else {
                tint(255);
              }
              
              imageMode(CENTER);
              image(enemySprite, screenX, spriteY + spriteHeight/2, spriteWidth, spriteHeight);
              imageMode(CORNER);
              noTint();
            } else {
              if (enemy.chasing) {
                fill(255, 100, 100, 180);
              } else {
                fill(150, 150, 255, 180);
              }
              rect(screenX - spriteWidth/2, spriteY, spriteWidth, spriteHeight);
            }
          }
        }
      }
    }
  }
  
    
  void renderCrackShadows() {
    if (player == null) return;
    
    // Renderizar sombras/marcas en el suelo para anclar el humo
    for (Crack crack : cracks) {
      float dx = crack.position.x - player.position.x;
      float dy = crack.position.y - player.position.y;
      float distance = sqrt(dx*dx + dy*dy);
      
      if (distance < 200) { // Solo renderizar sombras cercanas
        float crackAngle = atan2(dy, dx);
        float angleDiff = crackAngle - player.rotation;
        
        // Normalizar el ángulo
        while (angleDiff > PI) angleDiff -= TWO_PI;
        while (angleDiff < -PI) angleDiff += TWO_PI;
        
        if (abs(angleDiff) < fov/2) { // Solo si está en el campo de visión
          float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
          float spriteScale = (height * 0.3) / distance;
          float shadowSize = 25 * spriteScale;
          
          // Posicionar en el suelo
          float groundLevel = height/2 + (height * 20) / distance;
          float shadowY = groundLevel;
          
          if (!crack.isPatched) {
            // Sombra negra para grieta activa
            fill(0, 0, 0, 150); // Sombra negra más intensa
            ellipse(screenX, shadowY, shadowSize, shadowSize * 0.6); // Elipse aplastada
            
            // Centro más oscuro
            fill(0, 0, 0, 200);
            ellipse(screenX, shadowY, shadowSize * 0.5, shadowSize * 0.3);
          } else {
            // Marca verde para grieta reparada
            fill(50, 150, 50, 120);
            ellipse(screenX, shadowY, shadowSize, shadowSize * 0.6);
            
            // Círculo más claro en el centro
            fill(100, 200, 100, 100);
            ellipse(screenX, shadowY, shadowSize * 0.6, shadowSize * 0.4);
          }
        }
      }
    }
  }
  
  void renderCollectibleShadows() {
    if (player == null) return;
    
    // Renderizar collectibles como sprites en el suelo
    for (Collectible col : collectibles) {
      if (col.collected) continue; // No renderizar si ya fue recogido
      
      float dx = col.position.x - player.position.x;
      float dy = col.position.y - player.position.y;
      float distance = sqrt(dx * dx + dy * dy);
      
      if (distance > 400) continue; // No renderizar si está muy lejos
      
      // Calcular ángulo relativo al jugador
      float angle = atan2(dy, dx) - player.rotation;
      
      // Normalizar ángulo
      while (angle > PI) angle -= TWO_PI;
      while (angle < -PI) angle += TWO_PI;
      
      // Solo renderizar si est   en el campo de visión
      if (abs(angle) < fov / 2) {
        // Proyectar en pantalla
        float screenX = width/2 + (angle / (fov/2)) * (width/2);
        float spriteSize = 800 / distance; // Tamaño basado en distancia
        
        // Renderizar collectible
        if (col.type == 'B') {
          fill(100, 255, 100, 200); // Verde para bombas
        } else if (col.type == 'H') {
          fill(255, 100, 100, 200); // Rojo para vida
        }
        
        noStroke();
        ellipse(screenX, height - 100, spriteSize, spriteSize);
        
        // Efecto de brillo
        fill(255, 255, 255, 100);
        ellipse(screenX, height - 100, spriteSize * 0.6, spriteSize * 0.6);
      }
    }
  }

  void renderEnemyShadows() {
    if (player == null) return;
    
    // Renderizar sombras de enemigos en el suelo
    for (WallEnemy enemy : enemies) {
      // Verificar línea de vista (misma lógica que para renderizar enemigos)
      if (hasLineOfSight(player.position.x, player.position.y, enemy.position.x, enemy.position.y)) {
        float dx = enemy.position.x - player.position.x;
        float dy = enemy.position.y - player.position.y;
        float distance = sqrt(dx*dx + dy*dy);
        
        if (distance < 400) {
          float enemyAngle = atan2(dy, dx);
          float angleDiff = enemyAngle - player.rotation;
          
          // Normalizar el ángulo
          while (angleDiff > PI) angleDiff -= TWO_PI;
          while (angleDiff < -PI) angleDiff += TWO_PI;
          
          if (abs(angleDiff) < fov/2) {
            float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
            float spriteScale = (height * 0.4) / distance;
            float shadowSize = 30 * spriteScale; // Tamaño de la sombra
            
            // Posicionar en el suelo
            float groundLevel = height/2 + (height * 25) / distance;
            float shadowY = groundLevel;
            
            // Sombra del enemigo
            if (enemy.chasing) {
              // Sombra más intensa si está persiguiendo
              fill(0, 0, 0, 120);
              ellipse(screenX, shadowY, shadowSize, shadowSize * 0.5);
              fill(50, 0, 0, 80); // Tinte rojizo sutil
              ellipse(screenX, shadowY, shadowSize * 0.7, shadowSize * 0.35);
            } else {
              // Sombra normal
              fill(0, 0, 0, 100);
              ellipse(screenX, shadowY, shadowSize, shadowSize * 0.5);
              fill(20, 20, 20, 60); 
              ellipse(screenX, shadowY, shadowSize * 0.6, shadowSize * 0.3);
            }
          }
        }
      }
    }
  }
  
  void renderBombShadows() {
    if (player == null) return;
    
    // Renderizar sombras de bombas de reparación
    for (PatchBomb bomb : bombs) {
      float dx = bomb.position.x - player.position.x;
      float dy = bomb.position.y - player.position.y;
      float distance = sqrt(dx*dx + dy*dy);
      
      if (distance < 400) {
        float bombAngle = atan2(dy, dx);
        float angleDiff = bombAngle - player.rotation;
        
        while (angleDiff > PI) angleDiff -= TWO_PI;
        while (angleDiff < -PI) angleDiff += TWO_PI;
        
        if (abs(angleDiff) < fov/2) {
          float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
          float spriteScale = (height * 0.3) / distance;
          float shadowSize = 25 * spriteScale;
          
          float groundLevel = height/2 + (height * 25) / distance;
          float shadowY = groundLevel;
          
          // Sombra verde para bomba de reparación
          fill(0, 0, 0, 80);
          ellipse(screenX, shadowY, shadowSize, shadowSize * 0.4);
          fill(0, 30, 0, 50); 
          ellipse(screenX, shadowY, shadowSize * 0.6, shadowSize * 0.24);
        }
      }
    }
    
    // Renderizar sombras de bombas destructoras
    for (WallBomb bomb : wallBombs) {
      float dx = bomb.position.x - player.position.x;
      float dy = bomb.position.y - player.position.y;
      float distance = sqrt(dx*dx + dy*dy);
      
      if (distance < 400) {
        float bombAngle = atan2(dy, dx);
        float angleDiff = bombAngle - player.rotation;
        
        while (angleDiff > PI) angleDiff -= TWO_PI;
        while (angleDiff < -PI) angleDiff += TWO_PI;
        
        if (abs(angleDiff) < fov/2) {
          float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
          float spriteScale = (height * 0.3) / distance;
          float shadowSize = 25 * spriteScale;
          
          float groundLevel = height/2 + (height * 25) / distance;
          float shadowY = groundLevel;
          
          // Sombra naranja para bomba destructora
          fill(0, 0, 0, 80);
          ellipse(screenX, shadowY, shadowSize, shadowSize * 0.4);
          fill(30, 15, 0, 50); 
          ellipse(screenX, shadowY, shadowSize * 0.6, shadowSize * 0.24);
        }
      }
    }
  }
  
  void renderCrackSmoke() {
    if (player == null) return;
    
    // Renderizar humo binario vertical después de las grietas
    for (Crack crack : cracks) {
      if (!crack.isPatched) { // Solo grietas activas tienen humo
        float dx = crack.position.x - player.position.x;
        float dy = crack.position.y - player.position.y;
        float distance = sqrt(dx*dx + dy*dy);
        
        if (distance < 200) { // Reducir distancia para mejor rendimiento
          float crackAngle = atan2(dy, dx);
          float angleDiff = crackAngle - player.rotation;
          
          // Normalizar el ángulo
          while (angleDiff > PI) angleDiff -= TWO_PI;
          while (angleDiff < -PI) angleDiff += TWO_PI;
          
          if (abs(angleDiff) < fov/2) { // Solo si está en el campo de visión
            float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
            float spriteScale = (height * 0.4) / distance; // Volver al tamaño original
            float spriteSize = 40 * spriteScale; // Volver al tamaño original
            
            // Posicionar encima del suelo
            float groundLevel = height/2 + (height * 20) / distance;
            float smokeY = groundLevel - spriteSize * 0.6;
            
            // Humo binario vertical
            PImage[] smokeFrames = spriteMap.get("crack_binary_smoke");
            if (smokeFrames != null && smokeFrames.length > 0) {
              int smokeFrame = (frameCount / 5) % smokeFrames.length;
              imageMode(CENTER);
              tint(255, 150, 150, 180); // Más visible
              image(smokeFrames[smokeFrame], screenX, smokeY, spriteSize * 0.8, spriteSize * 1.5);
              noTint();
              imageMode(CORNER);
            }
          }
        }
      }
    }
  }
  
  void renderProjectiles3D() {
    if (player == null) return;
    
    // Renderizar proyectiles como sprites 3D
    for (Projectile proj : projectiles) {
      if (!proj.active) continue;
      
      float dx = proj.position.x - player.position.x;
      float dy = proj.position.y - player.position.y;
      float distance = sqrt(dx*dx + dy*dy);
      
      if (distance < 400) {
        float projAngle = atan2(dy, dx);
        float angleDiff = projAngle - player.rotation;
        
        // Normalizar el ángulo
        while (angleDiff > PI) angleDiff -= TWO_PI;
        while (angleDiff < -PI) angleDiff += TWO_PI;
        
        if (abs(angleDiff) < fov/2) {
          float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
          float spriteScale = (height * 0.2) / distance;
          float projSize = 15 * spriteScale;
          
          // Posicionar a altura media (como si volara)
          float midLevel = height/2 + (height * 10) / distance;
          float projY = midLevel;
          
          // Proyectil principal - un solo círculo con gradiente
          // Círculo exterior (más grande y translúcido)
          fill(0, 255, 255, 150);
          ellipse(screenX, projY, projSize, projSize);
          
          // Núcleo central (más pequeño y brillante)
          fill(255, 255, 255, 255);
          ellipse(screenX, projY, projSize * 0.4, projSize * 0.4);
          
          // Partículas digitales alrededor (ocasionales)
          if (frameCount % 4 == 0) {
            for (int i = 0; i < 2; i++) {
              fill(0, 255, 255, random(80, 150));
              float particleX = screenX + random(-projSize/3, projSize/3);
              float particleY = projY + random(-projSize/3, projSize/3);
              ellipse(particleX, particleY, 2, 2);
            }
          }
        }
      }
    }
  }
  
  void renderCrosshair() {
    if (player == null) return;
    
    // Calcular posición donde se colocará la bomba (más lejos del jugador)
    float bombDistance = 80; // Distancia más lejana del jugador
    float targetX = player.position.x + cos(player.rotation) * bombDistance;
    float targetY = player.position.y + sin(player.rotation) * bombDistance;
    
    // Verificar si la posición es válida (no en pared)
    if (!canMoveTo(targetX, targetY)) {
      // Si no es válida, reducir distancia hasta encontrar una posición válida
      for (float dist = bombDistance; dist > 30; dist -= 10) {
        targetX = player.position.x + cos(player.rotation) * dist;
        targetY = player.position.y + sin(player.rotation) * dist;
        if (canMoveTo(targetX, targetY)) {
          bombDistance = dist;
          break;
        }
      }
    }
    
    // Calcular posición en pantalla del punto de mira
    float dx = targetX - player.position.x;
    float dy = targetY - player.position.y;
    float distance = sqrt(dx*dx + dy*dy);
    
    if (distance > 5) { // Solo mostrar si está a cierta distancia
      float targetAngle = atan2(dy, dx);
      float angleDiff = targetAngle - player.rotation;
      
      // Normalizar el ángulo
      while (angleDiff > PI) angleDiff -= TWO_PI;
      while (angleDiff < -PI) angleDiff += TWO_PI;
      
      if (abs(angleDiff) < fov/2) { // Solo si está en el campo de visión
        float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
        float spriteScale = (height * 0.3) / distance;
        float crosshairSize = 20 * spriteScale;
        
        // Posicionar en el suelo
        float groundLevel = height/2 + (height * 20) / distance;
        float crosshairY = groundLevel;
        
        // Verificar si hay una grieta cerca para cambiar el color
        boolean nearCrack = false;
        for (Crack crack : cracks) {
          if (!crack.isPatched && dist(targetX, targetY, crack.position.x, crack.position.y) < 40) {
            nearCrack = true;
            break;
          }
        }
        
        // Dibujar punto de mira
        stroke(nearCrack ? color(0, 255, 0) : color(255, 255, 0)); // Verde si está cerca de grieta, amarillo si no
        strokeWeight(2);
        
        // Cruz simple
        line(screenX - crosshairSize/2, crosshairY, screenX + crosshairSize/2, crosshairY);
        line(screenX, crosshairY - crosshairSize/4, screenX, crosshairY + crosshairSize/4);
        
        // Círculo exterior
        noFill();
        ellipse(screenX, crosshairY, crosshairSize, crosshairSize * 0.6);
        
        noStroke();
      }
    }
  }
  
    
  void renderBombs3D() {
    if (player == null) return;
    
    // Renderizar bombas de reparación
    for (PatchBomb bomb : bombs) {
      float dx = bomb.position.x - player.position.x;
      float dy = bomb.position.y - player.position.y;
      float distance = sqrt(dx*dx + dy*dy);
      
      if (distance < 400) {
        float bombAngle = atan2(dy, dx);
        float angleDiff = bombAngle - player.rotation;
        
        while (angleDiff > PI) angleDiff -= TWO_PI;
        while (angleDiff < -PI) angleDiff += TWO_PI;
        
        if (abs(angleDiff) < fov/2) {
          float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
          float spriteScale = (height * 0.6) / distance; // Más grande
          float spriteWidth = 50 * spriteScale; // Más grande
          float spriteHeight = 50 * spriteScale; // Más grande
          
          // Posicionar en el suelo
          float groundLevel = height/2 + (height * 25) / distance;
          float spriteY = groundLevel - spriteHeight/2;
          
          if (!bomb.exploded) {
            PImage[] patchFrames = spriteMap.get("patch_bomb");
            if (patchFrames != null && patchFrames.length > 0) {
              int frame = int(map(bomb.timer, 0, bomb.duration, 0, patchFrames.length - 1));
              frame = constrain(frame, 0, patchFrames.length - 1);
              
              imageMode(CENTER);
              image(patchFrames[frame], screenX, spriteY, spriteWidth, spriteHeight);
              imageMode(CORNER);
            } else {
              fill(0, 255, 0, 200);
              ellipse(screenX, spriteY, spriteWidth, spriteHeight);
            }
          } else {
            // Renderizar efectos de explosión
            for (ExplosionWave w : bomb.waves) {
              if (w != null) {
                float waveScale = (height * 0.8) / distance;
                float waveSize = w.radius * waveScale;
                stroke(0, 255, 0, w.alpha);
                strokeWeight(3);
                noFill();
                ellipse(screenX, spriteY, waveSize, waveSize);
                noStroke();
              }
            }
            
            for (ExplosionParticle p : bomb.particles) {
              if (p != null && !p.isDead()) {
                float particleScale = (height * 0.3) / distance;
                fill(0, 255, 0, p.lifespan * 4);
                ellipse(screenX + random(-20, 20) * particleScale, 
                       spriteY + random(-20, 20) * particleScale, 
                       5 * particleScale, 5 * particleScale);
              }
            }
          }
        }
      }
    }
    
    // Renderizar bombas destructoras
    for (WallBomb bomb : wallBombs) {
      float dx = bomb.position.x - player.position.x;
      float dy = bomb.position.y - player.position.y;
      float distance = sqrt(dx*dx + dy*dy);
      
      if (distance < 400) {
        float bombAngle = atan2(dy, dx);
        float angleDiff = bombAngle - player.rotation;
        
        while (angleDiff > PI) angleDiff -= TWO_PI;
        while (angleDiff < -PI) angleDiff += TWO_PI;
        
        if (abs(angleDiff) < fov/2) {
          float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
          float spriteScale = (height * 0.6) / distance; // Más grande
          float spriteWidth = 50 * spriteScale; // Más grande
          float spriteHeight = 50 * spriteScale; // Más grande
          
          // Posicionar en el suelo
          float groundLevel = height/2 + (height * 25) / distance;
          float spriteY = groundLevel - spriteHeight/2;
          
          if (!bomb.exploded) {
            PImage[] wallFrames = spriteMap.get("wall_bomb");
            if (wallFrames != null && wallFrames.length > 0) {
              int frame = int(map(bomb.timer, 0, bomb.duration, 0, wallFrames.length - 1));
              frame = constrain(frame, 0, wallFrames.length - 1);
              
              imageMode(CENTER);
              image(wallFrames[frame], screenX, spriteY, spriteWidth, spriteHeight);
              imageMode(CORNER);
            } else {
              fill(255, 100, 0, 200);
              ellipse(screenX, spriteY, spriteWidth, spriteHeight);
            }
          } else {
            // Renderizar efectos de explosión
            for (ExplosionWave w : bomb.waves) {
              if (w != null) {
                float waveScale = (height * 1.2) / distance;
                float waveSize = w.radius * waveScale;
                stroke(255, 100, 0, w.alpha);
                strokeWeight(4);
                noFill();
                ellipse(screenX, spriteY, waveSize, waveSize);
                noStroke();
              }
            }
            
            for (ExplosionParticle p : bomb.particles) {
              if (p != null && !p.isDead()) {
                float particleScale = (height * 0.4) / distance;
                fill(255, 100, 0, p.lifespan * 4);
                ellipse(screenX + random(-30, 30) * particleScale, 
                       spriteY + random(-30, 30) * particleScale, 
                       8 * particleScale, 8 * particleScale);
              }
            }
          }
        }
      }
    }
  }
  
  void renderExplosionEffects3D() {
    if (player == null) return;
    
    // Renderizar ondas de explosión globales
    for (ExplosionWave wave : waves) {
      float dx = wave.position.x - player.position.x;
      float dy = wave.position.y - player.position.y;
      float distance = sqrt(dx*dx + dy*dy);
      
      if (distance < 400) {
        float waveAngle = atan2(dy, dx);
        float angleDiff = waveAngle - player.rotation;
        
        while (angleDiff > PI) angleDiff -= TWO_PI;
        while (angleDiff < -PI) angleDiff += TWO_PI;
        
        if (abs(angleDiff) < fov/2) {
          float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
          float groundLevel = height/2 + (height * 25) / distance;
          
          float waveScale = (height * 1.5) / distance;
          float waveSize = wave.radius * waveScale;
          
          stroke(255, 150, 0, wave.alpha);
          strokeWeight(5);
          noFill();
          ellipse(screenX, groundLevel, waveSize, waveSize);
          noStroke();
        }
      }
    }
    
    // Renderizar partículas de explosión globales
    for (ExplosionParticle particle : particles) {
      float dx = particle.position.x - player.position.x;
      float dy = particle.position.y - player.position.y;
      float distance = sqrt(dx*dx + dy*dy);
      
      if (distance < 300) {
        float particleAngle = atan2(dy, dx);
        float angleDiff = particleAngle - player.rotation;
        
        while (angleDiff > PI) angleDiff -= TWO_PI;
        while (angleDiff < -PI) angleDiff += TWO_PI;
        
        if (abs(angleDiff) < fov/2) {
          float screenX = width/2 + (angleDiff / (fov/2)) * (width/2);
          float groundLevel = height/2 + (height * 25) / distance;
          
          float particleScale = (height * 0.5) / distance;
          float particleSize = 10 * particleScale;
          
          fill(255, 100, 0, particle.lifespan * 4);
          ellipse(screenX + random(-10, 10), groundLevel + random(-20, 10), particleSize, particleSize);
        }
      }
    }
  }
  
  RaycastHit castRayOptimized(float angle) {
    if (player == null) return new RaycastHit(0, false, 0, 0, 0, 0);
    
    float rayX = player.position.x;
    float rayY = player.position.y;
    float rayDirX = cos(angle);
    float rayDirY = sin(angle);
    float distance = 0;
    float stepSize = 1.5;
    
    while (distance < 600) {
      rayX += rayDirX * stepSize;
      rayY += rayDirY * stepSize;
      distance += stepSize;
      
      int mapX = int(rayX / tileSize);
      int mapY = int(rayY / tileSize);
      
      if (mapX < 0 || mapX >= tileMap.length || mapY < 0 || mapY >= tileMap[0].length) {
        return new RaycastHit(distance, abs(rayDirX) > abs(rayDirY), rayX, rayY, rayDirX, rayDirY);
      }
      
      if (tileMap[mapX][mapY].isWall()) {
        boolean isNorthSouth = (abs(rayDirX) > abs(rayDirY));
        return new RaycastHit(distance, isNorthSouth, rayX, rayY, rayDirX, rayDirY);
      }
    }
    
    return new RaycastHit(600, false, rayX, rayY, rayDirX, rayDirY);
  }
  
  void drawHUD3D() {
    // HUD estilo DOOM/FPS clásico
    
    // Barra inferior estilo DOOM
    fill(50, 50, 50);
    rect(0, height - 80, width, 80);
    
    // Borde superior de la barra
    stroke(100, 100, 100);
    strokeWeight(2);
    line(0, height - 80, width, height - 80);
    noStroke();
    
    // Panel izquierdo - Estado del jugador
    fill(80, 80, 80);
    rect(10, height - 70, 200, 60);
    
    // Salud con barra
    fill(255, 50, 50);
    textAlign(LEFT, TOP);
    textSize(10);
    text("SALUD", 20, height - 65);
    
    // Barra de salud
    fill(100, 0, 0);
    rect(20, height - 50, 100, 8);
    fill(255, 0, 0);
    float healthPercent = playerHealth / 5.0;
    rect(20, height - 50, 100 * healthPercent, 8);
    
    fill(255, 255, 255);
    textSize(12);
    text(playerHealth + "/5", 130, height - 52);
    
    // Panel central - Objetivos
    fill(80, 80, 80);
    rect(220, height - 70, 300, 60);
    
    fill(255, 255, 0);
    textAlign(CENTER, TOP);
    textSize(10);
    text("ESTADO DE MISION", 370, height - 65);
    
    fill(255, 255, 255);
    textSize(9);
    text("GRIETAS: " + getRemainingCracks() + " RESTANTES", 370, height - 50);
    text("BOMBAS: " + wallBombsRemaining, 370, height - 35);
    
    // Panel derecho - Controles
    fill(80, 80, 80);
    rect(530, height - 70, 200, 60);
    
    fill(0, 255, 255);
    textAlign(LEFT, TOP);
    textSize(8);
    text("CONTROLES:", 540, height - 65);
    text("FLECHAS MOVER/GIRAR", 540, height - 52);
    text("ESPACIO DISPARAR", 540, height - 42);
    text("Z REPARAR  X BOMBA", 540, height - 32);
    
    // Minimapa mejorado estilo radar
    drawRadarMinimap();
    
    // Efectos de escaneo
    if (frameCount % 60 < 30) {
      stroke(0, 255, 0, 100);
      strokeWeight(1);
      line(0, height - 80, width, height - 80);
      noStroke();
    }
  }
  
  void drawRadarMinimap() {
    int radarSize = 120;
    int radarX = width - radarSize - 20;
    int radarY = 20;
    
    // Fondo del radar
    fill(0, 50, 0, 200);
    ellipse(radarX + radarSize/2, radarY + radarSize/2, radarSize, radarSize);
    
    // Círculos concéntricos
    stroke(0, 255, 0, 100);
    strokeWeight(1);
    noFill();
    for (int i = 1; i <= 3; i++) {
      ellipse(radarX + radarSize/2, radarY + radarSize/2, radarSize * i / 3, radarSize * i / 3);
    }
    
    // Líneas de cruz
    line(radarX, radarY + radarSize/2, radarX + radarSize, radarY + radarSize/2);
    line(radarX + radarSize/2, radarY, radarX + radarSize/2, radarY + radarSize);
    noStroke();
    
    float scale = radarSize / float(tileMap.length * tileSize);
    
    // Paredes
    fill(0, 255, 0, 150);
    for (int y = 0; y < tileMap[0].length; y++) {
      for (int x = 0; x < tileMap.length; x++) {
        if (tileMap[x][y].isWall()) {
          rect(radarX + x * tileSize * scale, radarY + y * tileSize * scale, 
               tileSize * scale, tileSize * scale);
        }
      }
    }
    
    // Enemigos (rojos parpadeantes)
    if (frameCount % 20 < 10) {
      fill(255, 0, 0);
      for (WallEnemy enemy : enemies) {
        ellipse(radarX + enemy.position.x * scale, radarY + enemy.position.y * scale, 4, 4);
      }
    }
    
    // Grietas (amarillas parpadeantes)
    if (frameCount % 30 < 15) {
      fill(255, 255, 0);
      for (Crack crack : cracks) {
        if (!crack.isPatched) {
          ellipse(radarX + crack.position.x * scale, radarY + crack.position.y * scale, 3, 3);
        }
      }
    }
    
    // Grietas reparadas (verdes)
    fill(0, 255, 0);
    for (Crack crack : cracks) {
      if (crack.isPatched) {
        ellipse(radarX + crack.position.x * scale, radarY + crack.position.y * scale, 3, 3);
      }
    }
    
    // Jugador (centro con dirección)
    if (player != null) {
      fill(255, 255, 255);
      float playerRadarX = radarX + (player.position.x * scale);
      float playerRadarY = radarY + (player.position.y * scale);
      ellipse(playerRadarX, playerRadarY, 6, 6);
      
      // Línea de dirección
      stroke(255, 255, 255);
      strokeWeight(2);
      float dirX = playerRadarX + cos(player.rotation) * 10;
      float dirY = playerRadarY + sin(player.rotation) * 10;
      line(playerRadarX, playerRadarY, dirX, dirY);
      noStroke();
    }
    
    // Etiqueta del radar
    fill(0, 255, 0);
    textAlign(CENTER, TOP);
    textSize(8);
    text("RADAR", radarX + radarSize/2, radarY + radarSize + 5);
  }
  
  void drawMinimapImproved() {
    int minimapSize = 200; // Aumentado de 120 a 200
    int minimapX = width - minimapSize - 15;
    int minimapY = 15;
    
    fill(0, 0, 0, 220);
    rect(minimapX, minimapY, minimapSize, minimapSize);
    
    float scale = minimapSize / float(tileMap.length * tileSize);
    
    for (int y = 0; y < tileMap[0].length; y++) {
      for (int x = 0; x < tileMap.length; x++) {
        if (tileMap[x][y].isWall()) {
          fill(120);
          rect(minimapX + x * tileSize * scale, minimapY + y * tileSize * scale, 
               tileSize * scale, tileSize * scale);
        }
      }
    }
    
    fill(255, 100, 100);
    for (WallEnemy enemy : enemies) {
      ellipse(minimapX + enemy.position.x * scale, minimapY + enemy.position.y * scale, 6, 6); // Aumentado de 4 a 6
    }
    
    // Grietas activas (amarillo)
    fill(255, 255, 100);
    for (Crack crack : cracks) {
      if (!crack.isPatched) {
        ellipse(minimapX + crack.position.x * scale, minimapY + crack.position.y * scale, 5, 5);
      }
    }
    
    // Grietas reparadas (verde)
    fill(100, 255, 100);
    for (Crack crack : cracks) {
      if (crack.isPatched) {
        ellipse(minimapX + crack.position.x * scale, minimapY + crack.position.y * scale, 5, 5);
      }
    }
    
    if (player != null) {
      fill(0, 255, 0);
      float playerMinimapX = minimapX + (player.position.x * scale);
      float playerMinimapY = minimapY + (player.position.y * scale);
      ellipse(playerMinimapX, playerMinimapY, 8, 8); // Aumentado de 5 a 8
      
      float dirX = playerMinimapX + cos(player.rotation) * 15; // Aumentado de 10 a 15
      float dirY = playerMinimapY + sin(player.rotation) * 15; // Aumentado de 10 a 15
      stroke(0, 255, 0);
      strokeWeight(2); // Añadido grosor de línea
      line(playerMinimapX, playerMinimapY, dirX, dirY);
      noStroke();
    }
  }

  void handleInput(char key, int keyCode) {
    if (player == null) return;
    
    if (key == ' ') {
      // Disparar proyectil
      float shootX = player.position.x + cos(player.rotation) * 20; // Empezar un poco adelante del jugador
      float shootY = player.position.y + sin(player.rotation) * 20;
      projectiles.add(new Projectile(shootX, shootY, player.rotation));
      
            if (audioManager != null) {
        audioManager.playLaserShot();
        println("🔫 Comando de sonido enviado");
      } else {
        println("⚠ AudioManager es null");
      }
      println("🔫 Proyectil disparado");
    }
    
    if (key == 'z') {
      // Colocar bomba de reparación en la posición del punto de mira
      float bombDistance = 80;
      float bombX = player.position.x + cos(player.rotation) * bombDistance;
      float bombY = player.position.y + sin(player.rotation) * bombDistance;
      
      // Verificar si la posición es válida y ajustar si es necesario
      if (!canMoveTo(bombX, bombY)) {
        for (float dist = bombDistance; dist > 30; dist -= 10) {
          bombX = player.position.x + cos(player.rotation) * dist;
          bombY = player.position.y + sin(player.rotation) * dist;
          if (canMoveTo(bombX, bombY)) {
            break;
          }
        }
      }
      
      bombs.add(new PatchBomb(bombX, bombY));
      println("💣 Bomba de reparación colocada en punto de mira en Level3");
      
            if (audioManager != null) {
        println("🔊 AudioManager disponible, probando sonido...");
              } else {
        println("⚠ AudioManager no disponible al colocar bomba en Level3");
      }
    }
    
    if (key == 'x' && wallBombsRemaining > 0) {
      // Colocar bomba destructora en la posición del punto de mira
      float bombDistance = 80;
      float bombX = player.position.x + cos(player.rotation) * bombDistance;
      float bombY = player.position.y + sin(player.rotation) * bombDistance;
      
      // Verificar si la posición es válida y ajustar si es necesario
      if (!canMoveTo(bombX, bombY)) {
        for (float dist = bombDistance; dist > 30; dist -= 10) {
          bombX = player.position.x + cos(player.rotation) * dist;
          bombY = player.position.y + sin(player.rotation) * dist;
          if (canMoveTo(bombX, bombY)) {
            break;
          }
        }
      }
      
      wallBombs.add(new WallBomb(bombX, bombY));
      wallBombsRemaining--;
      println("💥 Bomba destructora colocada en punto de mira en Level3");
      
            if (audioManager != null) {
        println("🔊 AudioManager disponible para bomba destructora");
      } else {
        println("⚠ AudioManager no disponible al colocar bomba destructora en Level3");
      }
    }
    
    // Tecla de prueba de sonido para debug (tecla 't')
    if (key == 't') {
      println("🔊 Prueba manual de sonidos en Level3...");
      if (audioManager != null) {
        println("🔊 Probando sonido de bomba de reparación...");
        audioManager.playPatchBomb();
        
        // Esperar un poco y probar el otro sonido
        println("🔊 Probando sonido de bomba destructora...");
        audioManager.playWallBomb();
        
        println("🔊 Prueba de sonidos completada");
      } else {
        println("⚠ AudioManager no disponible para prueba de sonidos");
      }
    }
  }
  
  void handleWallBombExplosion(WallBomb bomb) {
    for (int i = 0; i < 15; i++) {
      particles.add(new ExplosionParticle(bomb.position.x, bomb.position.y));
    }
    
    int tileRadius = 1;
    int cx = int(bomb.position.x / tileSize);
    int cy = int(bomb.position.y / tileSize);
    
    for (int dx = -tileRadius; dx <= tileRadius; dx++) {
      for (int dy = -tileRadius; dy <= tileRadius; dy++) {
        int tx = cx + dx;
        int ty = cy + dy;
        if (tx >= 0 && tx < tileMap.length && ty >= 0 && ty < tileMap[0].length) {
          if (tileMap[tx][ty].isDestructible()) {
            tileMap[tx][ty].type = '.';
          }
        }
      }
    }
    
    for (int i = enemies.size() - 1; i >= 0; i--) {
      WallEnemy enemy = enemies.get(i);
      if (dist(bomb.position.x, bomb.position.y, enemy.position.x, enemy.position.y) < 100) {
        enemies.remove(i);
        for (int j = 0; j < 5; j++) {
          particles.add(new ExplosionParticle(enemy.position.x, enemy.position.y));
        }
      }
    }
    
    if (dist(bomb.position.x, bomb.position.y, player.position.x, player.position.y) < 100) {
      if (!player.isInvincible()) {
        damagePlayer();
        player.setInvincible(60);
      }
    }
    
    wallBombShock = true;
    wallBombShockTimer = 20;
  }
  
  void damagePlayer() {
    playerHealth--;
    audioManager.playEnemyContact();
    println("¡Daño recibido en nivel 3D! Salud: " + playerHealth);
    if (playerHealth <= 0) {
      gameState = GameState.GAMEOVER;
    }
  }
  
  int getRemainingCracks() {
    int count = 0;
    for (Crack c : cracks) {
      if (!c.isPatched) count++;
    }
    return count;
  }

  int getRemainingWallBombs() {
    return wallBombsRemaining;
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

  boolean canMoveTo(float x, float y) {
    float radius = 18;
    
    int centerX = int(x / tileSize);
    int centerY = int(y / tileSize);
    
    if (centerX < 0 || centerX >= tileMap.length || centerY < 0 || centerY >= tileMap[0].length) {
      return false;
    }
    
    if (tileMap[centerX][centerY].isWall()) {
      return false;
    }
    
    float[][] checkPoints = {
      {x - radius, y},
      {x + radius, y},
      {x, y - radius},
      {x, y + radius},
      {x - radius*0.6, y - radius*0.6},
      {x + radius*0.6, y - radius*0.6},
      {x - radius*0.6, y + radius*0.6},
      {x + radius*0.6, y + radius*0.6}
    };
    
    for (float[] point : checkPoints) {
      int mapX = int(point[0] / tileSize);
      int mapY = int(point[1] / tileSize);
      
      if (mapX < 0 || mapX >= tileMap.length || mapY < 0 || mapY >= tileMap[0].length) {
        return false;
      }
      
      if (tileMap[mapX][mapY].isWall()) {
        return false;
      }
    }
    
    return true;
  }
  
  // Función para verificar línea de vista (oclusión)
  boolean hasLineOfSight(float x1, float y1, float x2, float y2) {
    float dx = x2 - x1;
    float dy = y2 - y1;
    float distance = sqrt(dx*dx + dy*dy);
    
    if (distance < 5) return true; 
    
    int steps = int(distance / 8); 
    if (steps < 1) steps = 1;
    
    float stepX = dx / steps;
    float stepY = dy / steps;
    
    for (int i = 1; i < steps; i++) {
      float checkX = x1 + stepX * i;
      float checkY = y1 + stepY * i;
      
      int mapX = int(checkX / tileSize);
      int mapY = int(checkY / tileSize);
      
      if (mapX < 0 || mapX >= tileMap.length || mapY < 0 || mapY >= tileMap[0].length) {
        return false;
      }
      
      if (tileMap[mapX][mapY].isWall()) {
        return false; 
      }
    }
    
    return true; 
  }
}

class RaycastHit {
  float distance;
  boolean isNorthSouth;
  float hitX, hitY;
  float rayDirX, rayDirY;
  
  RaycastHit(float distance, boolean isNorthSouth, float hitX, float hitY, float rayDirX, float rayDirY) {
    this.distance = distance;
    this.isNorthSouth = isNorthSouth;
    this.hitX = hitX;
    this.hitY = hitY;
    this.rayDirX = rayDirX;
    this.rayDirY = rayDirY;
  }
}
