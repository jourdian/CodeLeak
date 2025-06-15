class Tile {
  char type;
  int x, y;
  int tileSize = 48;
  boolean hasCrack = false; // Para marcar tiles con grietas
  boolean crackPatched = false; // Para marcar grietas reparadas

  Tile(char type, int x, int y) {
    this.type = type;
    this.x = x;
    this.y = y;
  }
void display() {
  int px = x * tileSize;
  int py = y * tileSize;

  if (type == 'R') {
    // Animación de reconfiguración (4 frames en bucle cada 10 frames)
    PImage[] reconfSprites = spriteMap.get("reconf_tile");
    if (reconfSprites != null && reconfSprites.length > 0) {
      int frame = (frameCount / 10) % reconfSprites.length;
      image(reconfSprites[frame], px, py);
      return;
    } else {
      // Fallback si no hay sprites de reconfiguración
      fill(100, 255, 100);
      rect(px, py, tileSize, tileSize);
      return;
    }
  }

  PImage[] tileImg;

  switch (type) {
    case '.':
      tileImg = spriteMap.get("floor");
      break;
    case 'W':
    case 'B':
      tileImg = spriteMap.get("wall");
      break;
    default:
      tileImg = spriteMap.get("floor");
  }

  if (tileImg != null && tileImg.length > 0 && tileImg[0] != null) {
    image(tileImg[0], px, py);
  } else {
    // Fallback visual si no hay sprites
    switch (type) {
      case '.':
        fill(120, 100, 80); // Marrón para suelo
        break;
      case 'W':
      case 'B':
        fill(100, 100, 100); // Gris para muros
        break;
      default:
        fill(120, 100, 80); // Marrón por defecto
    }
    rect(px, py, tileSize, tileSize);
  }
}




boolean isWall() {
  return type == 'W' || type == 'B'; 
}


boolean isDestructible() {
  return type == 'W';  
}

boolean isIndestructibleWall() {
  return type == 'B';
}


  boolean isReconfigTrigger() {
  return type == 'R';
}
boolean isFloor() {
  return type == '.' || type == 'P' || type == 'G' || type == 'R';
}

boolean isPlatform() {
  return type == 'W';  
}


}

