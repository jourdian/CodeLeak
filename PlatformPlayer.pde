class PlatformPlayer extends PlayerBase {
  int tileSize = 48;
  boolean onGround = false;

  float gravity = 0.8;
  float jumpForce = -18;
  float moveSpeed = 4;

  PImage[] walkSpritesRight;
  PImage[] walkSpritesLeft;
  boolean facingRight = true;
  boolean jumpRequested = false;

  
  boolean leftPressed = false;
  boolean rightPressed = false;
  boolean upPressed = false;

  int frame = 0;
  int frameCounter = 0;

  Tile[][] tileMap;

  PlatformPlayer(float x, float y, Tile[][] map) {
    super(x, y);
    this.tileMap = map;
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    loadSprites();
  }

  void loadSprites() {
    walkSpritesRight = spriteMap.get("player_right");
    walkSpritesLeft = spriteMap.get("player_left");

    if (walkSpritesRight == null || walkSpritesLeft == null) {
      println("⚠ Sprites no encontrados para player_right o player_left");
    }
  }

  void update() {
    
    velocity.x = 0;
    if (leftPressed) {
      velocity.x = -moveSpeed;
    }
    if (rightPressed) {
      velocity.x = moveSpeed;
    }

    // Dirección
    if (velocity.x > 0.1) facingRight = true;
    if (velocity.x < -0.1) facingRight = false;

    // Salto 
    if (jumpRequested && onGround) {
      velocity.y = jumpForce;
      onGround = false;
      println("🦘 Saltando en PlatformPlayer!");
      
      
      if (audioManager != null) {
        println("🦘 Reproduciendo sonido de salto desde PlatformPlayer...");
        audioManager.playJump();
      } else {
        println("⚠ AudioManager no disponible en PlatformPlayer");
      }
    }
    jumpRequested = false;  

    // Gravedad
    velocity.y += gravity;
    
    // MOVIMIENTO HORIZONTAL SIMPLIFICADO
    float oldX = position.x;
    float newX = position.x + velocity.x;
    
    // Verificar colisión horizontal simple
    boolean canMoveHorizontally = true;
    if (velocity.x != 0) {
      int checkX = int(newX / tileSize);
      int checkY = int(position.y / tileSize);
      
      if (checkX >= 0 && checkX < tileMap.length && 
          checkY >= 0 && checkY < tileMap[0].length) {
        if (tileMap[checkX][checkY].isWall()) {
          canMoveHorizontally = false;
          println("Colisión horizontal en tile: " + checkX + ", " + checkY);
        }
      } else {
        canMoveHorizontally = false;
        println("Fuera de límites: " + checkX + ", " + checkY);
      }
    }
    
    if (canMoveHorizontally && velocity.x != 0) {
      position.x = newX;
    }
    
    // MOVIMIENTO VERTICAL CON COLISIONES MEJORADAS
    float oldY = position.y;
    position.y += velocity.y;
    
    // Verificar colisión con techo (cuando salta hacia arriba)
    if (velocity.y < 0) { // Moviéndose hacia arriba
      int tx = int(position.x / tileSize);
      int ty = int((position.y - tileSize / 2) / tileSize); // Verificar parte superior del jugador
      
      if (ty >= 0 && ty < tileMap[0].length &&
          tx >= 0 && tx < tileMap.length &&
          tileMap[tx][ty].isWall()) {
        // Colisión con techo
        position.y = (ty + 1) * tileSize + tileSize / 2;
        velocity.y = 0;
        println("Colisión con techo en tile: " + tx + ", " + ty);
      }
    }
    
    // Colisión con suelo (cuando cae hacia abajo)
    onGround = false;
    int tx = int(position.x / tileSize);
    int ty = int((position.y + tileSize / 2) / tileSize); // Verificar parte inferior del jugador

    if (ty >= 0 && ty < tileMap[0].length &&
        tx >= 0 && tx < tileMap.length &&
        tileMap[tx][ty].isWall()) {
      position.y = ty * tileSize - tileSize / 2;
      velocity.y = 0;
      onGround = true;
    }

    baseUpdate();
  }

  void handleInput() {
    
  }

  void keyPressed(char key, int keyCode) {
    if (key == 'a' || key == 'A' || keyCode == LEFT) {
      leftPressed = true;
    }
    if (key == 'd' || key == 'D' || keyCode == RIGHT) {
      rightPressed = true;
    }
    if (key == 'w' || key == 'W' || keyCode == UP) {
      jumpRequested = true;
    }
  }

  void keyReleased(char key, int keyCode) {
    if (key == 'a' || key == 'A' || keyCode == LEFT) {
      leftPressed = false;
    }
    if (key == 'd' || key == 'D' || keyCode == RIGHT) {
      rightPressed = false;
    }
  }

  void display() {
    if (isInvincible() && frameCount % 10 < 5) return;

    PImage[] currentSprites = facingRight ? walkSpritesRight : walkSpritesLeft;
    imageMode(CENTER);
    image(currentSprites[frame], position.x, position.y);
    imageMode(CORNER);

    if (velocity.x != 0) {
      frameCounter++;
      if (frameCounter % 6 == 0) frame = (frame + 1) % currentSprites.length;
    } else {
      frame = 0;
    }
  }
}
