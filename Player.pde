// Clase base abstracta para cualquier tipo de jugador (Fase 1, 2 o 3)
abstract class PlayerBase {
  PVector position;
  PVector velocity;
  PVector acceleration;

  int invincibleTimer = 0;

  PlayerBase(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  abstract void update();  
  abstract void handleInput();
  abstract void display();  


  boolean isInvincible() {
    return invincibleTimer > 0;
  }

  void setInvincible(int frames) {
    invincibleTimer = frames;
  }

  void baseUpdate() {
    if (invincibleTimer > 0) invincibleTimer--;
  }



}

// Subclase para la Fase 1 – Movimiento top-down con física básica
class TopDownPlayer extends PlayerBase {
  float maxSpeed = 3.0;
  float accelStrength = 1.0;
  float friction = 0.85;
  Level1Manager level;

  // 🟩 Añadir estas variables aquí dentro
  int animFrame = 0;
  int animSpeed = 6;
  String currentDir = "down";

  TopDownPlayer(float x, float y, Level1Manager lvl) {
    super(x, y);
    this.level = lvl;
  }


/*   void drawPlayer() {
    String key = "player_" + currentDir;
    PImage[] anim = spriteMap.get(key);
    image(anim[animFrame / animSpeed % anim.length], position.x, position.y);
  } */

void display() {
  if (isInvincible() && frameCount % 10 < 5) return;

  // Detectar dirección por velocidad
  if (abs(velocity.x) > abs(velocity.y)) {
    currentDir = velocity.x > 0 ? "right" : "left";
  } else if (velocity.mag() > 0.1) {
    currentDir = velocity.y > 0 ? "down" : "up";
  }

  // Obtener animación
  String key = "player_" + currentDir;
  PImage[] anim = spriteMap.get(key);

  if (anim != null) {
    imageMode(CENTER);

    if (velocity.mag() > 0.1) {
      // Si se está moviendo → animar
      image(anim[(frameCount / animSpeed) % anim.length], position.x, position.y);
    } else {
      // Si está quieto → mostrar primer frame estático
      image(anim[0], position.x, position.y);
    }

    imageMode(CORNER);
  } else {
    fill(255, 200, 0);
    ellipse(position.x, position.y, 30, 30);
  }
}


  void update() {
    handleInput();

    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    
    // Movimiento separado en X e Y para evitar enganches
    PVector newPos = position.copy();
    
    // Intentar movimiento horizontal
    newPos.x = position.x + velocity.x;
    if (level.canMoveTo(newPos.x, position.y)) {
      position.x = newPos.x;
    } else {
      velocity.x = 0; // Detener solo el movimiento horizontal
    }
    
    // Intentar movimiento vertical
    newPos.y = position.y + velocity.y;
    if (level.canMoveTo(position.x, newPos.y)) {
      position.y = newPos.y;
    } else {
      velocity.y = 0; // Detener solo el movimiento vertical
    }

    velocity.mult(friction);
    acceleration.mult(0);

    baseUpdate(); // gestiona invulnerabilidad
  }

  void handleInput() {
    if (keyPressed) {
      if (keyCode == LEFT)  acceleration.add(new PVector(-accelStrength, 0));
      if (keyCode == RIGHT) acceleration.add(new PVector(accelStrength, 0));
      if (keyCode == UP)    acceleration.add(new PVector(0, -accelStrength));
      if (keyCode == DOWN)  acceleration.add(new PVector(0, accelStrength));
    }
  }
}
