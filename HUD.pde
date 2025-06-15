// ========== HUD NIVEL 1 - ESTILO 8-BIT ==========
void drawHUD(int cracksRemaining, int wallBombsRemaining) {
  drawHUD8Bit(cracksRemaining, wallBombsRemaining, level1.playerHealth);
}

void drawHUD8Bit(int cracksRemaining, int wallBombsRemaining, int playerHealth) {
  // HUD estilo 8-bit clásico
  textFont(pixelFont);
  
  // Marco superior estilo consola 8-bit
  fill(0, 0, 0, 200);
  rect(0, 0, width, 70);
  
  // Borde pixelado
  stroke(0, 255, 0);
  strokeWeight(2);
  // Líneas horizontales
  line(0, 0, width, 0);
  line(0, 68, width, 68);
  // Líneas verticales decorativas
  for (int i = 0; i < width; i += 40) {
    line(i, 0, i, 4);
    line(i, 64, i, 68);
  }
  noStroke();
  
  // Título del sistema
  fill(255, 255, 0);
  textAlign(CENTER, TOP);
  textSize(14);
  text("=== SISTEMA DE INTEGRIDAD ===", width/2, 8);
  
  // Panel izquierdo - Estado de la misión
  fill(0, 255, 0);
  textAlign(LEFT, TOP);
  textSize(10);
  text("GRIETAS:", 20, 30);
  
  // Contador de grietas con efecto parpadeante si quedan pocas
  if (cracksRemaining <= 2 && frameCount % 20 < 10) {
    fill(255, 0, 0);
  } else {
    fill(255, 255, 255);
  }
  textSize(12);
  text(cracksRemaining, 105, 28);
  
  // Bombas disponibles
  fill(0, 255, 0);
  textSize(10);
  text("BOMBAS:", 150, 30);
  fill(255, 255, 255);
  textSize(12);
  text(wallBombsRemaining, 220, 28);
  
  // Panel central - Cronómetro y controles estilo 8-bit
  fill(0, 255, 255);
  textAlign(CENTER, TOP);
  textSize(10);
  text("TIEMPO: " + gameTimer.getFormattedTime(), width/2, 30);
  
  fill(0, 255, 255);
  textSize(8);
  text("CONTROLES", width/2, 45);
  fill(255, 255, 255);
  textSize(8);
  text("Z=PARCHEAR  X=DESTRUIR  FLECHAS=MOVER", width/2, 55);
  
  // Panel derecho - Salud con corazones pixelados
  textAlign(RIGHT, TOP);
  fill(255, 50, 50);
  textSize(10);
  text("VIDA:", width - 120, 30);
  
  // Dibujar corazones pixelados
  int heartX = width - 110;
  int heartY = 28;
  for (int i = 0; i < 5; i++) {
    if (i < playerHealth) {
      drawPixelHeart(heartX + i * 16, heartY, color(255, 0, 0));
    } else {
      drawPixelHeart(heartX + i * 16, heartY, color(100, 0, 0));
    }
  }
  
  // Efecto de escaneo estilo CRT
  if (frameCount % 120 < 60) {
    stroke(0, 255, 0, 50);
    strokeWeight(1);
    for (int i = 0; i < 70; i += 4) {
      line(0, i, width, i);
    }
    noStroke();
  }
}

// ========== HUD NIVEL 2 - ESTILO 16-BIT ==========
void drawHUD16Bit(int cracksRemaining, int wallBombsRemaining, int playerHealth) {
  textFont(pixelFont);
  
  // Panel superior estilo 16-bit con gradiente
  drawGradientRect(0, 0, width, 80, color(40, 40, 80), color(20, 20, 40));
  
  // Borde metálico
  stroke(150, 150, 200);
  strokeWeight(3);
  line(0, 0, width, 0);
  line(0, 77, width, 77);
  stroke(80, 80, 120);
  strokeWeight(1);
  line(0, 1, width, 1);
  line(0, 78, width, 78);
  noStroke();
  
  // Título con efecto de relieve
  fill(200, 200, 255);
  textAlign(CENTER, TOP);
  textSize(16);
  text("SISTEMA DE REPARACIÓN AVANZADO", width/2 + 1, 9);
  fill(255, 255, 255);
  text("SISTEMA DE REPARACIÓN AVANZADO", width/2, 8);
  
  // Panel izquierdo - Información de misión con iconos
  drawInfoPanel(20, 30, 180, 40, "ESTADO DE MISIÓN");
  
  fill(100, 255, 100);
  textAlign(LEFT, TOP);
  textSize(10);
  text("⚠ GRIETAS:", 30, 45);
  
  // Contador con barra de progreso
  if (cracksRemaining <= 2 && frameCount % 30 < 15) {
    fill(255, 100, 100);
  } else {
    fill(255, 255, 255);
  }
  textSize(14);
  text(cracksRemaining, 100, 43);
  
  // Barra de progreso de grietas
  int totalCracks = 6; // Asumiendo que empezamos con 6 grietas
  float progress = 1.0 - (cracksRemaining / float(totalCracks));
  drawProgressBar(120, 47, 70, 8, progress, color(100, 255, 100));
  
  fill(100, 200, 255);
  textSize(10);
  text("💣 BOMBAS:", 30, 58);
  fill(255, 255, 255);
  textSize(12);
  text(wallBombsRemaining, 100, 56);
  
  // Panel central - Controles mejorados
  drawInfoPanel(220, 30, 280, 40, "CONTROLES");
  fill(255, 255, 200);
  textAlign(LEFT, TOP);
  textSize(9);
  text("Z=REPARAR  X=DESTRUIR  ↑=SALTAR  ←→=MOVER", 230, 50);
  
  // Panel derecho - Salud con barra moderna
  drawInfoPanel(520, 30, 160, 40, "INTEGRIDAD");
  
  fill(255, 100, 100);
  textAlign(LEFT, TOP);
  textSize(10);
  text("❤ SALUD:", 530, 45);
  
  // Barra de salud moderna
  float healthPercent = playerHealth / 5.0;
  drawHealthBar(530, 58, 120, 10, healthPercent);
  
  fill(255, 255, 255);
  textSize(10);
  text(playerHealth + "/5", 655, 56);
  
  // Efectos de partículas flotantes
  drawFloatingParticles();
}

// ========== HUD NIVEL 3 - ESTILO DOOM ==========
void drawHUDDoom(int cracksRemaining, int wallBombsRemaining, int playerHealth) {
  textFont(pixelFont);
  
  // Barra inferior estilo DOOM
  fill(50, 50, 50);
  rect(0, height - 80, width, 80);
  
  // Borde superior de la barra con efecto metálico
  stroke(120, 120, 120);
  strokeWeight(2);
  line(0, height - 80, width, height - 80);
  stroke(80, 80, 80);
  strokeWeight(1);
  line(0, height - 81, width, height - 81);
  noStroke();
  
  // Panel izquierdo - Estado del jugador
  drawDoomPanel(10, height - 70, 200, 60, color(80, 80, 80));
  
  // Salud con barra estilo DOOM
  fill(255, 50, 50);
  textAlign(LEFT, TOP);
  textSize(10);
  text("SALUD", 20, height - 65);
  
  // Barra de salud con efecto 3D
  fill(100, 0, 0);
  rect(20, height - 50, 100, 8);
  fill(150, 0, 0);
  rect(20, height - 50, 100, 2); // Highlight superior
  
  fill(255, 0, 0);
  float healthPercent = playerHealth / 5.0;
  rect(20, height - 50, 100 * healthPercent, 8);
  fill(255, 100, 100);
  rect(20, height - 50, 100 * healthPercent, 2); // Highlight
  
  fill(255, 255, 255);
  textSize(12);
  text(playerHealth + "/5", 130, height - 52);
  
  // Panel central - Objetivos
  drawDoomPanel(220, height - 70, 300, 60, color(80, 80, 80));
  
  fill(255, 255, 0);
  textAlign(CENTER, TOP);
  textSize(10);
  text("ESTADO DE MISION", 370, height - 65);
  
  fill(255, 255, 255);
  textSize(9);
  text("GRIETAS: " + cracksRemaining + " RESTANTES", 370, height - 50);
  text("BOMBAS: " + wallBombsRemaining, 370, height - 35);
  
  // Indicador de peligro si quedan pocas grietas
  if (cracksRemaining <= 2) {
    if (frameCount % 20 < 10) {
      fill(255, 0, 0);
      textSize(8);
      text("CRITICO", 370, height - 22);
    }
  }
  
  // Panel derecho - Controles
  drawDoomPanel(530, height - 70, 200, 60, color(80, 80, 80));
  
  fill(0, 255, 255);
  textAlign(LEFT, TOP);
  textSize(8);
  text("CONTROLES:", 540, height - 65);
  text("FLECHAS MOVER/GIRAR", 540, height - 52);
  text("ESPACIO DISPARAR", 540, height - 42);
  text("Z REPARAR  X BOMBA", 540, height - 32);
  
  // Efectos de escaneo estilo DOOM
  if (frameCount % 60 < 30) {
    stroke(0, 255, 0, 100);
    strokeWeight(1);
    line(0, height - 80, width, height - 80);
    
    // Líneas de escaneo ocasionales
    if (frameCount % 180 < 5) {
      for (int i = 0; i < 3; i++) {
        stroke(0, 255, 0, 50);
        line(0, height - 80 + i * 20, width, height - 80 + i * 20);
      }
    }
    noStroke();
  }
  
}

// ========== FUNCIONES AUXILIARES ==========

void drawPixelHeart(int x, int y, color c) {
  fill(c);
  // Corazón pixelado 8x8
  // Fila 1
  rect(x+2, y, 2, 2);
  rect(x+6, y, 2, 2);
  // Fila 2
  rect(x, y+2, 6, 2);
  rect(x+6, y+2, 4, 2);
  // Fila 3
  rect(x, y+4, 10, 2);
  // Fila 4
  rect(x+2, y+6, 6, 2);
  // Fila 5
  rect(x+4, y+8, 2, 2);
}

// drawGradientRect() movida a Screens.pde para evitar duplicacion

void drawInfoPanel(int x, int y, int w, int h, String title) {
  // Panel con borde 3D
  fill(60, 60, 100);
  rect(x, y, w, h);
  
  // Borde superior e izquierdo (claro)
  stroke(120, 120, 160);
  strokeWeight(1);
  line(x, y, x + w, y);
  line(x, y, x, y + h);
  
  // Borde inferior y derecho (oscuro)
  stroke(30, 30, 50);
  line(x, y + h, x + w, y + h);
  line(x + w, y, x + w, y + h);
  noStroke();
  
  // Título del panel
  fill(200, 200, 255);
  textAlign(LEFT, TOP);
  textSize(8);
  text(title, x + 5, y + 3);
}

void drawProgressBar(int x, int y, int w, int h, float progress, color barColor) {
  // Fondo de la barra
  fill(30, 30, 30);
  rect(x, y, w, h);
  
  // Borde
  stroke(100, 100, 100);
  strokeWeight(1);
  noFill();
  rect(x, y, w, h);
  noStroke();
  
  // Progreso
  fill(barColor);
  rect(x + 1, y + 1, (w - 2) * progress, h - 2);
  
  // Highlight en la barra
  fill(red(barColor) + 50, green(barColor) + 50, blue(barColor) + 50);
  rect(x + 1, y + 1, (w - 2) * progress, 2);
}

void drawHealthBar(int x, int y, int w, int h, float healthPercent) {
  // Fondo
  fill(50, 0, 0);
  rect(x, y, w, h);
  
  // Borde
  stroke(100, 100, 100);
  strokeWeight(1);
  noFill();
  rect(x, y, w, h);
  noStroke();
  
  // Salud
  color healthColor;
  if (healthPercent > 0.6) {
    healthColor = color(0, 255, 0);
  } else if (healthPercent > 0.3) {
    healthColor = color(255, 255, 0);
  } else {
    healthColor = color(255, 0, 0);
  }
  
  fill(healthColor);
  rect(x + 1, y + 1, (w - 2) * healthPercent, h - 2);
  
  // Efecto parpadeante si salud crítica
  if (healthPercent <= 0.2 && frameCount % 20 < 10) {
    fill(255, 255, 255, 100);
    rect(x + 1, y + 1, (w - 2) * healthPercent, h - 2);
  }
  
  // Highlight
  fill(red(healthColor) + 50, green(healthColor) + 50, blue(healthColor) + 50);
  rect(x + 1, y + 1, (w - 2) * healthPercent, 2);
}

void drawFloatingParticles() {
  // Partículas flotantes para el HUD 16-bit
  for (int i = 0; i < 8; i++) {
    float x = 50 + i * 120 + sin(frameCount * 0.02 + i) * 10;
    float y = 15 + cos(frameCount * 0.03 + i) * 5;
    float alpha = 100 + sin(frameCount * 0.05 + i) * 50;
    
    fill(100, 200, 255, alpha);
    ellipse(x, y, 3, 3);
  }
}

void drawDoomPanel(int x, int y, int w, int h, color panelColor) {
  // Panel principal
  fill(panelColor);
  rect(x, y, w, h);
  
  // Borde superior (claro)
  stroke(red(panelColor) + 40, green(panelColor) + 40, blue(panelColor) + 40);
  strokeWeight(1);
  line(x, y, x + w, y);
  line(x, y, x, y + h);
  
  // Borde inferior (oscuro)
  stroke(red(panelColor) - 40, green(panelColor) - 40, blue(panelColor) - 40);
  line(x, y + h, x + w, y + h);
  line(x + w, y, x + w, y + h);
  noStroke();
}