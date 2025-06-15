// Clase que representa a un enemigo tipo Glitchwalker
class Glitchwalker {
  PVector position;    // Posición actual
  PVector velocity;    // Dirección y velocidad actuales
  float speed = 1.4;   // Velocidad de movimiento
  PVector targetOverride = null;  // Objetivo temporal (bomba)

  boolean chasing = false;
  int cooldown = 0;
  int changeDirectionTimer = 0;
  float panicTimer = 0;       // Tiempo restante de movimiento agitado
  float normalSpeed = 1.4;
  float panicSpeed = 3.8;

  int animFrame = 0;
  int animSpeed = 6; // frames por cambio
  String currentDir = "down"; // o left/right/up según movimiento

  void drawPlayer() {
    String key = "player_" + currentDir;
    PImage[] anim = spriteMap.get(key);
    image(anim[animFrame / animSpeed % anim.length], position.x, position.y);
  }

  Glitchwalker(float x, float y) {
    position = new PVector(x, y);
    velocity = PVector.random2D().mult(speed);
    changeDirectionTimer = int(random(30, 90));
  }

  void update(PlayerBase player, BaseLevelManager level) {
    float d = dist(position.x, position.y, player.position.x, player.position.y);

    //  Reducir estado nervioso
    if (panicTimer > 0) {
      panicTimer--;
    }

    // Evaluar modo persecución o patrulla
    if (targetOverride == null && panicTimer == 0) {
      if (d < 160) {
        chasing = true;
        cooldown = 60;
      } else if (cooldown > 0) {
        cooldown--;
      } else {
        chasing = false;
      }
    }

    // Seleccionar comportamiento
    if (targetOverride != null) {
      // 🚨 Modo alerta: perseguir bomba
      PVector dir = PVector.sub(targetOverride, position).normalize();
      velocity = dir.mult(normalSpeed);

      if (dist(position.x, position.y, targetOverride.x, targetOverride.y) < 10) {
        targetOverride = null;
        changeDirectionTimer = 0;
        panicTimer = 90; // 🧠 Entra en modo errático
      }
    } else if (panicTimer > 0) {
      // 😵‍ Modo nervioso: movimiento aleatorio rápido
      velocity = PVector.random2D().mult(panicSpeed);
      changeDirectionTimer = 5;
    } else if (chasing) {
      // 👀 Modo persecución al jugador
      PVector dir = PVector.sub(player.position, position).normalize();
      velocity = dir.mult(normalSpeed);
    } else {
      // 🧍 Patrulla aleatoria
      changeDirectionTimer--;
      if (changeDirectionTimer <= 0) {
        velocity = PVector.random2D().mult(normalSpeed);
        changeDirectionTimer = int(random(30, 90));
      }
    }

    // Movimiento con colisión
    float nextX = position.x + velocity.x;
    float nextY = position.y + velocity.y;

    if (level.canMoveTo(nextX, nextY)) {
      position.x = nextX;
      position.y = nextY;
    } else {
      if (targetOverride != null) {
        targetOverride = null;
        chasing = false;
        panicTimer = 90;
        changeDirectionTimer = 0;
      }
      velocity = PVector.random2D().mult(panicTimer > 0 ? panicSpeed : normalSpeed);
      changeDirectionTimer = int(random(10, 40));
    }
  }



  void display() {
    // Calcular dirección visual
    if (abs(velocity.x) > abs(velocity.y)) {
      currentDir = velocity.x > 0 ? "right" : "left";
    } else if (velocity.mag() > 0.1) {
      currentDir = velocity.y > 0 ? "down" : "up";
    }

    String key = "enemy_" + currentDir;
    PImage[] anim = spriteMap.get(key);

    if (anim != null) {
      imageMode(CENTER);
      image(anim[(frameCount / animSpeed) % anim.length], position.x, position.y);
      imageMode(CORNER);
    } else {
      // Colores según estado, como antes
      if (panicTimer > 0) {
        fill(255, 255, 0);
      } else if (targetOverride != null) {
        fill(255, 0, 0);
      } else if (chasing) {
        fill(255, 0, 200);
      } else {
        fill(200);
      }
      ellipse(position.x, position.y, 28, 28);
    }
  }

  boolean collidesWith(PlayerBase player) {
    return dist(position.x, position.y, player.position.x, player.position.y) < 24;
  }

  void alert(PVector source) {
    targetOverride = source.copy();
    chasing = true;
    cooldown = 90;
    panicTimer = 90; // durante 90 frames se comportará de forma nerviosa
  }
}
