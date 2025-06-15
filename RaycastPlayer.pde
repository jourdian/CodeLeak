class RaycastPlayer extends PlayerBase {
  float rotation;
  float rotationSpeed = 0.08;
  float moveSpeed = 8.0;
  float strafeSpeed = 6.0;
  Level3Manager level;
  
  // Variables para movimiento suave
  boolean upPressed = false;
  boolean downPressed = false;
  boolean leftPressed = false;
  boolean rightPressed = false;
  
    
  RaycastPlayer(float x, float y, Level3Manager lvl) {
    super(x, y);
    rotation = 0;
    level = lvl;
  }

  void update() {
    handleInput();
    
    // Movimiento hacia adelante/atrás con deslizamiento suave
    if (upPressed) {
      float newX = position.x + cos(rotation) * moveSpeed;
      float newY = position.y + sin(rotation) * moveSpeed;
      PVector validPos = getValidMovement(position.x, position.y, newX, newY);
      position.x = validPos.x;
      position.y = validPos.y;
    }
    if (downPressed) {
      float newX = position.x - cos(rotation) * moveSpeed;
      float newY = position.y - sin(rotation) * moveSpeed;
      PVector validPos = getValidMovement(position.x, position.y, newX, newY);
      position.x = validPos.x;
      position.y = validPos.y;
    }
    
    // Rotación con flechas
    if (leftPressed) {
      rotation -= rotationSpeed;
    }
    if (rightPressed) {
      rotation += rotationSpeed;
    }
    
    baseUpdate(); // gestiona invulnerabilidad
  }
  
  // Función para movimiento suave con deslizamiento en paredes
  PVector getValidMovement(float currentX, float currentY, float newX, float newY) {
    // Si el movimiento completo es válido, usarlo
    if (level.canMoveTo(newX, newY)) {
      return new PVector(newX, newY);
    }
    
    // Intentar movimiento solo en X (deslizar verticalmente)
    if (level.canMoveTo(newX, currentY)) {
      return new PVector(newX, currentY);
    }
    
    // Intentar movimiento solo en Y (deslizar horizontalmente)
    if (level.canMoveTo(currentX, newY)) {
      return new PVector(currentX, newY);
    }
    
    // Intentar movimiento reducido (para esquinas muy cerradas)
    float reducedSpeed = 0.5;
    float reducedX = currentX + (newX - currentX) * reducedSpeed;
    float reducedY = currentY + (newY - currentY) * reducedSpeed;
    
    if (level.canMoveTo(reducedX, reducedY)) {
      return new PVector(reducedX, reducedY);
    }
    
    // Si nada funciona, quedarse en la posición actual
    return new PVector(currentX, currentY);
  }
  
  
  void handleInput() {
    // El input se maneja con keyPressed/keyReleased para movimiento suave
  }
  
  void display() {
    // En el nivel 3D, el jugador no se dibuja directamente
    // La vista es en primera persona
  }
  
  void keyPressed(char k, int kCode) {
    if (kCode == LEFT) leftPressed = true;
    if (kCode == RIGHT) rightPressed = true;
    if (kCode == UP) upPressed = true;
    if (kCode == DOWN) downPressed = true;
  }
  
  void keyReleased(char k, int kCode) {
    if (kCode == LEFT) leftPressed = false;
    if (kCode == RIGHT) rightPressed = false;
    if (kCode == UP) upPressed = false;
    if (kCode == DOWN) downPressed = false;
  }
}