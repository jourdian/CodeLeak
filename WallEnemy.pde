class WallEnemy {
  PVector position;
  PVector velocity;
  float rotation;
  float rotationSpeed = 0.03;
  float moveSpeed = 1.5;
  float detectionRange = 250;
  float attackRange = 40;
  Level3Manager level;
  
  // Estados del enemigo
  boolean chasing = false;
  boolean patrolling = true;
  int cooldown = 0;
  int changeDirectionTimer = 0;
  float panicTimer = 0;
  
  // Patrulla
  PVector patrolTarget;
  boolean hasPatrolTarget = false;
  
  WallEnemy(float x, float y, Level3Manager lvl) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    rotation = random(TWO_PI);
    level = lvl;
    changeDirectionTimer = int(random(60, 120));
  }

  void update(PlayerBase player) {
    float dx = player.position.x - position.x;
    float dy = player.position.y - position.y;
    float distance = sqrt(dx*dx + dy*dy);
    
    // Reducir pánico
    if (panicTimer > 0) {
      panicTimer--;
    }
    
    // Determinar comportamiento
    if (panicTimer == 0) {
      if (distance < detectionRange && hasLineOfSight(player)) {
        chasing = true;
        patrolling = false;
        cooldown = 120; // Perseguir por 2 segundos
      } else if (cooldown > 0) {
        cooldown--;
      } else {
        chasing = false;
        patrolling = true;
      }
    }
    
    // Ejecutar comportamiento
    if (panicTimer > 0) {
      // Movimiento errático
      rotation += random(-0.2, 0.2);
      moveForward(moveSpeed * 1.5);
    } else if (chasing) {
      // Perseguir al jugador
      float targetAngle = atan2(dy, dx);
      rotateTowards(targetAngle);
      moveForward(moveSpeed * 1.2);
    } else {
      // Patrullar
      patrol();
    }
    
    // Mantener rotación en rango válido
    while (rotation > TWO_PI) rotation -= TWO_PI;
    while (rotation < 0) rotation += TWO_PI;
  }
  
  void patrol() {
    changeDirectionTimer--;
    
    if (changeDirectionTimer <= 0 || !hasPatrolTarget) {
      // Elegir nueva dirección de patrulla
      rotation += random(-PI/2, PI/2);
      changeDirectionTimer = int(random(60, 180));
      hasPatrolTarget = true;
    }
    
    moveForward(moveSpeed * 0.8);
  }
  
  void rotateTowards(float targetAngle) {
    float angleDiff = targetAngle - rotation;
    
    // Normalizar diferencia de ángulo
    while (angleDiff > PI) angleDiff -= TWO_PI;
    while (angleDiff < -PI) angleDiff += TWO_PI;
    
    if (abs(angleDiff) < rotationSpeed) {
      rotation = targetAngle;
    } else {
      rotation += angleDiff > 0 ? rotationSpeed : -rotationSpeed;
    }
  }
  
  void moveForward(float speed) {
    float newX = position.x + cos(rotation) * speed;
    float newY = position.y + sin(rotation) * speed;
    
    // Actualizar velocity para animación de sprites
    velocity.x = cos(rotation) * speed;
    velocity.y = sin(rotation) * speed;
    
    if (level.canMoveTo(newX, newY)) {
      position.x = newX;
      position.y = newY;
    } else {
      // Si choca con pared, girar
      rotation += random(-PI/2, PI/2);
      changeDirectionTimer = 0;
      hasPatrolTarget = false;
      velocity.mult(0); // Detener movimiento
      
      if (panicTimer == 0) {
        panicTimer = 60; // Entrar en pánico por 1 segundo
      }
    }
  }
  
  boolean hasLineOfSight(PlayerBase player) {
    // Raycasting simple para verificar línea de visión
    float dx = player.position.x - position.x;
    float dy = player.position.y - position.y;
    float distance = sqrt(dx*dx + dy*dy);
    
    if (distance > detectionRange) return false;
    
    // Verificar si hay paredes entre el enemigo y el jugador
    int steps = int(distance / 10); // Verificar cada 10 píxeles
    for (int i = 1; i < steps; i++) {
      float checkX = position.x + (dx / steps) * i;
      float checkY = position.y + (dy / steps) * i;
      
      if (!level.canMoveTo(checkX, checkY)) {
        return false; // Hay una pared en el camino
      }
    }
    
    return true;
  }
  
  boolean collidesWith(PlayerBase player) {
    float distance = dist(position.x, position.y, player.position.x, player.position.y);
    return distance < attackRange;
  }
  
  void alert(PVector source) {
    // Reaccionar a explosiones
    panicTimer = 120;
    chasing = false;
    patrolling = false;
    
    // Girar hacia la fuente del ruido
    float alertAngle = atan2(source.y - position.y, source.x - position.x);
    rotation = alertAngle + random(-PI/4, PI/4); // Añadir algo de imprecisión
  }

  void display() {
    // El enemigo se renderiza en 3D en Level3Manager.renderEnemies()
    }
}
