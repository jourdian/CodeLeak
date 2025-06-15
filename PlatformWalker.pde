class PlatformWalker {
  PVector position;
  PVector velocity;
  boolean facingRight = true;

  float walkSpeed = 1.2;
  float gravity = 0.5;
  float maxFallSpeed = 4.5;

  Tile[][] tileMap;
  int tileSize;
  int spriteHeight = 48;

  PlatformWalker(float x, float y, Tile[][] map, int tileSize) {
    // La posición representa los pies del enemigo
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    this.tileMap = map;
    this.tileSize = tileSize;
    println("Creando enemigo en: (" + x + ", " + y + ")");
  }

  void update() {
    // Aplicar gravedad
    velocity.y += gravity;
    velocity.y = constrain(velocity.y, -10, maxFallSpeed);

    // Movimiento horizontal provisional
    velocity.x = facingRight ? walkSpeed : -walkSpeed;

    // Próximas posiciones
    float nextX = position.x + velocity.x;
    float nextY = position.y + velocity.y;

    // Coordenadas para detección de colisiones
    float headY = nextY - spriteHeight;
    float edgeOffset = tileSize * 0.4;
float footY = position.y; // no uses nextY aquí
float frontX = position.x + (facingRight ? edgeOffset : -edgeOffset);



    // Cambiar dirección si hay muro delante o se acaba el suelo
int checkX = int((position.x + (facingRight ? tileSize * 0.5 : -tileSize * 0.5)) / tileSize);
int checkY = int((position.y + 1) / tileSize); // justo debajo de los pies

if (isValid(checkX, checkY) && tileMap[checkX][checkY].type == 'L') {
  println("↩️ Enemigo en (" + position.x + ", " + position.y + ") cambia por L en [" + checkX + "," + checkY + "]");
  facingRight = !facingRight;
  velocity.x = facingRight ? walkSpeed : -walkSpeed;
}


    // Colisión con suelo
    int tx = int(position.x / tileSize);
    int ty = int((nextY + tileSize / 2) / tileSize);
    boolean onGround = false;

    if (ty >= 0 && ty < tileMap[0].length &&
        tx >= 0 && tx < tileMap.length &&
        tileMap[tx][ty].isPlatform()) {
      position.y = (ty * tileSize) - 2;
      velocity.y = 0;
      onGround = true;
    }

    // Siempre aplicar movimiento horizontal
    position.x += velocity.x;

    // Solo aplicar movimiento vertical si no está en el suelo
    if (!onGround) {
      position.y += velocity.y;
    }
  }

  void display() {
    String key = facingRight ? "enemy_right" : "enemy_left";
    PImage[] anim = spriteMap.get(key);
    if (anim != null) {
      imageMode(CORNER);
      image(anim[(frameCount / 6) % anim.length], position.x - tileSize / 2, position.y - spriteHeight);
    } else {
      fill(255, 0, 0);
      ellipse(position.x, position.y - spriteHeight / 2, 30, 30);
    }
  }

  boolean isOnFloor(float x, float y) {
  int tx = int(x / tileSize);
  int ty = int(y / tileSize);
  if (!isValid(tx, ty)) {
    println("❌ Suelo fuera de rango en: " + tx + "," + ty);
    return false;
  }
  println("🔍 Probando suelo en: " + tx + "," + ty + " → " + tileMap[tx][ty].type);
  return tileMap[tx][ty].isFloor();
}


  boolean isWall(float x, float y) {
    int tx = int(x / tileSize);
    int ty = int(y / tileSize);
    return isValid(tx, ty) && tileMap[tx][ty].isWall();
  }

  boolean isValid(int tx, int ty) {
    return tx >= 0 && tx < tileMap.length && ty >= 0 && ty < tileMap[0].length;
  }

  boolean collidesWith(PlayerBase player) {
    float w = 24;
    float h = 32;
    return abs(position.x - player.position.x) < w &&
           abs(position.y - player.position.y) < h;
  }
}
