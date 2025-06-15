// Escena de transición entre niveles
int transitionTimer = 0;

void drawTransition(String message) {
  background(0);
  fill(0, 255, 0);
  textAlign(CENTER, CENTER);
  textSize(24);
  text(message, width / 2, height / 2);

  transitionTimer++;
  if (transitionTimer > 180) { // 3 segundos
    gameState = GameState.END;
    transitionTimer = 0;
  }
}

void drawWinScreen() {
  background(0, 50, 0); // Fondo verde oscuro
  
  // Efecto de partículas de victoria
  for (int i = 0; i < 20; i++) {
    fill(0, 255, 0, random(100, 255));
    float x = random(width);
    float y = random(height);
    ellipse(x, y, random(5, 15), random(5, 15));
  }
  
  fill(0, 255, 0);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("¡SISTEMA REPARADO!", width / 2, height / 2 - 60);
  
  textSize(20);
  text("El último mono ha salvado el código", width / 2, height / 2 - 20);
  text("de la corrupción total.", width / 2, height / 2 + 10);
  
  textSize(16);
  fill(150, 255, 150);
  text("Presiona 'R' para reiniciar", width / 2, height / 2 + 60);
  
  // Código binario cayendo (efecto Matrix)
  fill(0, 255, 0, 100);
  textSize(12);
  for (int i = 0; i < width; i += 20) {
    String binary = "";
    for (int j = 0; j < 10; j++) {
      binary += random(1) > 0.5 ? "1" : "0";
    }
    text(binary, i, (frameCount * 2 + i) % height);
  }
  
  if (key == 'r') {
    loadAllSprites("level01");
    level1 = new Level1Manager();
    gameState = GameState.CUTSCENE1;
  }
}

void drawGameOver() {
  background(50, 0, 0); // Fondo rojo oscuro
  
  // Efecto de glitch
  if (frameCount % 10 < 5) {
    filter(INVERT);
  }
  
  // Líneas de error
  stroke(255, 0, 0);
  for (int i = 0; i < 10; i++) {
    float y = random(height);
    line(0, y, width, y);
  }
  noStroke();
  
  fill(255, 0, 0);
  textAlign(CENTER, CENTER);
  textSize(36);
  text("SYSTEM FAILURE", width / 2, height / 2 - 80);
  
  textSize(24);
  text("ERROR 404: MONO NOT FOUND", width / 2, height / 2 - 40);
  
  textSize(18);
  fill(255, 100, 100);
  text("El código se ha corrompido irreversiblemente.", width / 2, height / 2);
  text("Los glitches han tomado el control.", width / 2, height / 2 + 30);
  
  textSize(16);
  fill(255, 150, 150);
  text("Presiona 'R' para intentar de nuevo", width / 2, height / 2 + 80);
  
  // Texto corrupto
  fill(255, 0, 0, 150);
  textSize(10);
  for (int i = 0; i < 50; i++) {
    text("ERROR", random(width), random(height));
  }
  
  if (key == 'r') {
    loadAllSprites("level01");
    level1 = new Level1Manager();
    gameState = GameState.CUTSCENE1;
  }
}