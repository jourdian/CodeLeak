// Clase que representa un objeto recolectable en el mapa
class Collectible {
  PVector position;
  char type; // 'B' = bomba destructora, 'H' = vida, etc.
  boolean collected = false;

  Collectible(float x, float y, char type) {
    position = new PVector(x, y);
    this.type = type;
  }

  void update(PlayerBase player, Level1Manager level) {
    if (!collected && dist(position.x, position.y, player.position.x, player.position.y) < 20) {
      collected = true;
      audioManager.playPowerUp();

      if (type == 'B') {
        if (level.wallBombsRemaining < level.maxWallBombs) {
          level.wallBombsRemaining++;
          println("💣 Has recogido una bomba destructora");
        }
      }

      if (type == 'H') {
        if (level.playerHealth < 3) {
          level.playerHealth++;
          println("❤️ Has recuperado salud");
        }
      }

    }
  }
  
  void update(PlayerBase player, Level2Manager level) {
    if (!collected && dist(position.x, position.y, player.position.x, player.position.y) < 20) {
      collected = true;
      audioManager.playPowerUp();

      if (type == 'B') {
        if (level.wallBombsRemaining < level.maxWallBombs) {
          level.wallBombsRemaining++;
          println("💣 Has recogido una bomba destructora");
        }
      }

      if (type == 'H') {
        if (level.playerHealth < level.maxPlayerHealth) {
          level.playerHealth++;
          println("❤️ Has recuperado salud");
        }
      }

    }
  }
  
  void update(PlayerBase player, Level3Manager level) {
    if (!collected && dist(position.x, position.y, player.position.x, player.position.y) < 30) {
      collected = true;
      audioManager.playPowerUp();

      if (type == 'B') {
        if (level.wallBombsRemaining < 15) { // Límite más alto para nivel 3
          level.wallBombsRemaining++;
          println("💣 Has recogido una bomba destructora");
        }
      }

      if (type == 'H') {
        if (level.playerHealth < 5) {
          level.playerHealth++;
          println("❤️ Has recuperado salud");
        }
      }

    }
  }

  void display() {
    if (collected) return;

    // Efecto de pulsación
    float pulse = sin(frameCount * 0.1) * 0.2 + 1.0;
    
    noStroke();
    if (type == 'B') {
      // Bomba - color verde para nivel 1, amarillo para otros niveles
      if (gameState == GameState.LEVEL1) {
        fill(100, 255, 100, 200);
        ellipse(position.x, position.y, 20 * pulse, 20 * pulse);
        fill(50, 200, 50);
        ellipse(position.x, position.y, 12, 12);
      } else {
        fill(255, 200, 50, 200);
        ellipse(position.x, position.y, 20 * pulse, 20 * pulse);
        fill(255, 150, 0);
        ellipse(position.x, position.y, 12, 12);
      }
    } else if (type == 'H') {
      // Vida - color verde para nivel 1, rojo para otros niveles
      if (gameState == GameState.LEVEL1) {
        fill(150, 255, 150, 200);
        ellipse(position.x, position.y, 20 * pulse, 20 * pulse);
        fill(100, 255, 100);
        ellipse(position.x, position.y, 12, 12);
        // Dibujar cruz de salud en verde
        stroke(0, 150, 0);
        strokeWeight(2);
        line(position.x - 4, position.y, position.x + 4, position.y);
        line(position.x, position.y - 4, position.x, position.y + 4);
        noStroke();
      } else {
        fill(255, 100, 100, 200);
        ellipse(position.x, position.y, 20 * pulse, 20 * pulse);
        fill(255, 50, 50);
        ellipse(position.x, position.y, 12, 12);
        // Dibujar cruz de salud
        stroke(255);
        strokeWeight(2);
        line(position.x - 4, position.y, position.x + 4, position.y);
        line(position.x, position.y - 4, position.x, position.y + 4);
        noStroke();
      }
    }
  }
}
