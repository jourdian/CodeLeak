// ========== PANTALLA DE ENTRADA DE INICIALES ==========
// Pantalla estilo arcade para introducir iniciales

class InitialsScreen {
  String[] initials = {"A", "A", "A"};
  int currentPosition = 0;
  int finalTime;
  String formattedTime;
  int position;
  boolean isNewRecord;
  
  // Animación
  int blinkTimer = 0;
  boolean showCursor = true;
  
  // Efectos
  ArrayList<Particle> particles;
  
  InitialsScreen(int timeInMilliseconds) {
    this.finalTime = timeInMilliseconds;
    this.formattedTime = formatTime(timeInMilliseconds);
    this.position = rankingSystem.getPosition(timeInMilliseconds);
    this.isNewRecord = rankingSystem.isNewRecord(timeInMilliseconds);
    
    particles = new ArrayList<Particle>();
    
    // Crear partículas de celebración si es nuevo récord
    if (isNewRecord) {
      for (int i = 0; i < 50; i++) {
        particles.add(new Particle(width/2, height/2));
      }
    }
    
    println("🎮 Pantalla de iniciales iniciada - Tiempo: " + formattedTime + " - Posición: " + position);
  }
  
  void update() {
    // Animación del cursor
    blinkTimer++;
    if (blinkTimer > 30) {
      showCursor = !showCursor;
      blinkTimer = 0;
    }
    
    // Actualizar partículas
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
  
  void display() {
    background(0);
    
    // Renderizar partículas de fondo
    for (Particle p : particles) {
      p.display();
    }
    
    // Título principal
    fill(255, 255, 0);
    textAlign(CENTER, TOP);
    textSize(24);
    text("¡JUEGO COMPLETADO!", width/2, 50);
    
    // Mensaje de nuevo récord
    if (isNewRecord) {
      fill(255, 100, 100);
      textSize(18);
      text("🏆 ¡NUEVO RÉCORD! 🏆", width/2, 85);
      
      // Efecto de brillo
      if (frameCount % 20 < 10) {
        fill(255, 255, 255);
        text("🏆 ¡NUEVO RÉCORD! 🏆", width/2, 85);
      }
    }
    
    // Información del tiempo
    fill(255, 255, 255);
    textSize(16);
    text("Tu tiempo:", width/2, 130);
    
    fill(0, 255, 255);
    textSize(20);
    text(formattedTime, width/2, 155);
    
    fill(255, 255, 255);
    textSize(14);
    text("Posición: #" + position, width/2, 185);
    
    // Instrucciones
    fill(255, 255, 0);
    textSize(16);
    text("Introduce tus iniciales:", width/2, 230);
    
    // Caja de iniciales
    drawInitialsBox();
    
    // Controles
    fill(128, 128, 128);
    textSize(12);
    text("↑↓ Cambiar letra  ←→ Mover cursor  ENTER Confirmar", width/2, 350);
    
    // Ranking actual (pequeño)
    drawMiniRanking();
  }
  
  void drawInitialsBox() {
    float boxWidth = 200;
    float boxHeight = 60;
    float boxX = width/2 - boxWidth/2;
    float boxY = 270;
    
    // Fondo de la caja
    fill(50, 50, 50);
    stroke(255, 255, 255);
    strokeWeight(2);
    rect(boxX, boxY, boxWidth, boxHeight);
    noStroke();
    
    // Dibujar cada inicial
    textAlign(CENTER, CENTER);
    textSize(32);
    
    for (int i = 0; i < 3; i++) {
      float letterX = boxX + (i + 0.5) * (boxWidth / 3);
      float letterY = boxY + boxHeight/2;
      
      // Resaltar la posición actual
      if (i == currentPosition) {
        fill(255, 255, 0);
        
        // Cursor parpadeante
        if (showCursor) {
          stroke(255, 255, 0);
          strokeWeight(3);
          line(letterX - 15, letterY + 20, letterX + 15, letterY + 20);
          noStroke();
        }
      } else {
        fill(255, 255, 255);
      }
      
      text(initials[i], letterX, letterY);
    }
  }
  
  void drawMiniRanking() {
    float rankingX = width - 250;
    float rankingY = 100;
    float rankingW = 230;
    float rankingH = 200;
    
    // Fondo semi-transparente
    fill(0, 0, 0, 150);
    rect(rankingX, rankingY, rankingW, rankingH);
    
    // Título
    fill(255, 255, 0);
    textAlign(CENTER, TOP);
    textSize(12);
    text("RANKING ACTUAL", rankingX + rankingW/2, rankingY + 10);
    
    // Mostrar top 5
    textAlign(LEFT, TOP);
    textSize(10);
    
    ArrayList<RankingEntry> rankings = rankingSystem.getRankings();
    for (int i = 0; i < min(rankings.size(), 5); i++) {
      RankingEntry entry = rankings.get(i);
      
      if (i < 3) {
        fill(255, 215, 0); // Oro para top 3
      } else {
        fill(255, 255, 255);
      }
      
      text((i + 1) + ". " + entry.initials, rankingX + 10, rankingY + 35 + i * 15);
      
      textAlign(RIGHT, TOP);
      text(entry.formattedTime, rankingX + rankingW - 10, rankingY + 35 + i * 15);
      textAlign(LEFT, TOP);
    }
  }
  
  void handleInput(char key, int keyCode) {
    if (keyCode == UP) {
      // Cambiar letra hacia arriba
      char currentChar = initials[currentPosition].charAt(0);
      currentChar++;
      if (currentChar > 'Z') currentChar = 'A';
      initials[currentPosition] = String.valueOf(currentChar);
      
    } else if (keyCode == DOWN) {
      // Cambiar letra hacia abajo
      char currentChar = initials[currentPosition].charAt(0);
      currentChar--;
      if (currentChar < 'A') currentChar = 'Z';
      initials[currentPosition] = String.valueOf(currentChar);
      
    } else if (keyCode == LEFT) {
      // Mover cursor a la izquierda
      currentPosition--;
      if (currentPosition < 0) currentPosition = 2;
      
    } else if (keyCode == RIGHT) {
      // Mover cursor a la derecha
      currentPosition++;
      if (currentPosition > 2) currentPosition = 0;
      
    } else if (key == '\n' || key == '\r' || keyCode == ENTER) {
      // Confirmar iniciales
      confirmInitials();
    }
  }
  
  void confirmInitials() {
    String finalInitials = initials[0] + initials[1] + initials[2];
    
    // Añadir al ranking
    rankingSystem.addEntry(finalInitials, finalTime);
    
    println("✅ Iniciales confirmadas: " + finalInitials + " - Tiempo: " + formattedTime);
    
    // Ir a la pantalla de ranking
    gameState = GameState.RANKING;
  }
  
  String formatTime(int milliseconds) {
    int totalSeconds = milliseconds / 1000;
    int minutes = totalSeconds / 60;
    int seconds = totalSeconds % 60;
    int centiseconds = (milliseconds % 1000) / 10;
    
    return String.format("%02d:%02d.%02d", minutes, seconds, centiseconds);
  }
}

// Clase para partículas de celebración
class Particle {
  PVector position;
  PVector velocity;
  color col;
  float life;
  float maxLife;
  
  Particle(float x, float y) {
    position = new PVector(x, y);
    velocity = PVector.random2D();
    velocity.mult(random(2, 8));
    
    // Colores dorados y brillantes
    col = color(random(200, 255), random(150, 255), random(0, 100));
    maxLife = random(60, 120);
    life = maxLife;
  }
  
  void update() {
    position.add(velocity);
    velocity.mult(0.98); // Fricción
    velocity.y += 0.1; // Gravedad
    life--;
  }
  
  void display() {
    float alpha = map(life, 0, maxLife, 0, 255);
    fill(red(col), green(col), blue(col), alpha);
    noStroke();
    ellipse(position.x, position.y, 4, 4);
  }
  
  boolean isDead() {
    return life <= 0;
  }
}

// Variable global para la pantalla de iniciales
InitialsScreen initialsScreen;