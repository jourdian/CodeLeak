// ========== VARIABLES GLOBALES ==========
PImage coverImg;
PImage cutscene01Img;
PImage cutscene02Img;
PImage cutscene03Img;
PImage endImg;

int completionTimer = 0;

// ========== PANTALLA DE INICIO ==========
void drawStartScreen() {
  // Mostrar imagen de cover
  if (coverImg != null) {
    // Escalar la imagen para que ocupe toda la ventana
    image(coverImg, 0, 0, width, height);
  } else {
    // Fallback si no se carga la imagen
    background(0);
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("ERROR: No se pudo cargar cover.png", width/2, height/2);
  }
  
  // Instrucciones parpadeantes superpuestas
  if (frameCount % 60 < 30) {
    fill(255, 255, 255, 200);
    textAlign(CENTER, BOTTOM);
    textFont(pixelFont);
    textSize(14);
    text("PULSA ESPACIO PARA COMENZAR", width / 2, height - 70);
    
    fill(255, 255, 0, 150);
    textSize(12);
    text("PULSA R PARA VER RANKING", width / 2, height - 50);
  }
}

// ========== CUTSCENES CON IMAGENES ==========

void drawCutscene1() {
  if (cutscene01Img != null) {
    image(cutscene01Img, 0, 0, width, height);
  } else {
    background(0);
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("ERROR: No se pudo cargar cutscene01.png", width/2, height/2);
  }
  
  // Instrucciones
  if (frameCount % 60 < 30) {
    fill(255, 255, 255, 200);
    textAlign(CENTER, BOTTOM);
    textFont(pixelFont);
    textSize(12);
    text("PRESIONA ESPACIO PARA CONTINUAR", width / 2, height - 30);
  }
}

void drawCutscene2() {
  if (cutscene02Img != null) {
    image(cutscene02Img, 0, 0, width, height);
  } else {
    background(0);
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("ERROR: No se pudo cargar cutscene02.png", width/2, height/2);
  }
  
  // Instrucciones
  if (frameCount % 60 < 30) {
    fill(255, 255, 255, 200);
    textAlign(CENTER, BOTTOM);
    textFont(pixelFont);
    textSize(12);
    text("PRESIONA ESPACIO PARA CONTINUAR", width / 2, height - 30);
  }
}

void drawCutscene3() {
  if (cutscene03Img != null) {
    image(cutscene03Img, 0, 0, width, height);
  } else {
    background(0);
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("ERROR: No se pudo cargar cutscene03.png", width/2, height/2);
  }
  
  // Instrucciones
  if (frameCount % 60 < 30) {
    fill(255, 255, 255, 200);
    textAlign(CENTER, BOTTOM);
    textFont(pixelFont);
    textSize(12);
    text("PRESIONA ESPACIO PARA CONTINUAR", width / 2, height - 30);
  }
}

void drawEndScreen() {
  if (endImg != null) {
    image(endImg, 0, 0, width, height);
  } else {
    background(0);
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("ERROR: No se pudo cargar end.png", width/2, height/2);
  }
  
  // Mensaje final
  if (frameCount % 120 < 60) {
    fill(255, 255, 255, 150);
    textAlign(CENTER, BOTTOM);
    textFont(pixelFont);
    textSize(12);
    text("GRACIAS POR JUGAR", width / 2, height - 30);
  }
}

// ========== PANTALLAS DE COMPLETACION DE NIVEL ==========

void drawLevel1Complete() {
  if (frameCount % 600 == 0) completionTimer = 0; // Reset cada 10 segundos
  completionTimer++;
  
  // Fondo con efecto de matriz verde (8-bit)
  background(0, 20, 0);
  drawTechnologicalBackground8Bit();
  
  // Título principal
  fill(0, 255, 0);
  textAlign(CENTER, CENTER);
  textFont(pixelFont);
  textSize(28);
  text("NIVEL 1 COMPLETADO", width/2, height/2 - 80);
  
  // Subtítulo con efecto parpadeante
  if (frameCount % 40 < 20) {
    fill(255, 255, 0);
    textSize(16);
    text("SISTEMA 8-BIT REPARADO", width/2, height/2 - 40);
  }
  
  // Estadísticas del nivel
  fill(255, 255, 255);
  textSize(12);
  text("Todas las grietas han sido selladas", width/2, height/2);
  text("El codigo basico esta estabilizado", width/2, height/2 + 20);
  
  // Mensaje de progreso
  fill(0, 255, 255);
  textSize(14);
  text("Preparandose para evolucion a 16-bit...", width/2, height/2 + 60);
  
  // Barra de progreso más lenta
  drawProgressBarCompletion(width/2 - 150, height/2 + 90, 300, 20, completionTimer / 360.0);
  
  // Instrucción - aparece más temprano
  if (completionTimer > 60) {
    if (frameCount % 60 < 30) {
      fill(255, 255, 255);
      textSize(12);
      text("PRESIONA ESPACIO PARA CONTINUAR", width/2, height/2 + 130);
    }
  }
  
  }

void drawLevel2Complete() {
  if (frameCount % 600 == 0) completionTimer = 0; // Reset cada 10 segundos
  completionTimer++;
  
  // Fondo con gradiente 16-bit
  drawGradientRect(0, 0, width, height, color(20, 20, 60), color(60, 20, 60));
  drawTechnologicalBackground16Bit();
  
  // Título con efecto de relieve 16-bit
  fill(150, 150, 255);
  textAlign(CENTER, CENTER);
  textFont(pixelFont);
  textSize(32);
  text("NIVEL 2 COMPLETADO", width/2 + 2, height/2 - 78);
  fill(255, 255, 255);
  text("NIVEL 2 COMPLETADO", width/2, height/2 - 80);
  
  // Subtítulo animado
  if (frameCount % 50 < 25) {
    fill(255, 200, 100);
    textSize(18);
    text("PLATAFORMAS DOMINADAS", width/2, height/2 - 40);
  }
  
  // Estadísticas mejoradas
  fill(200, 255, 200);
  textSize(14);
  text("Sistema de plataformas estabilizado", width/2, height/2 - 5);
  text("Mecanicas de salto perfeccionadas", width/2, height/2 + 15);
  text("Enemigos neutralizados", width/2, height/2 + 35);
  
  // Mensaje de evolución
  fill(255, 150, 150);
  textSize(16);
  text("Iniciando inmersion 3D...", width/2, height/2 + 70);
  
  // Barra de progreso más lenta
  drawProgressBarCompletion(width/2 - 200, height/2 + 100, 400, 25, completionTimer / 400.0);
  
  // Efectos adicionales
  if (completionTimer > 100) {
    // Líneas de energía
    stroke(100, 255, 255, 150);
    strokeWeight(2);
    for (int i = 0; i < 5; i++) {
      float x = width/2 + sin(frameCount * 0.1 + i) * 100;
      line(x, height/2 + 90, x, height/2 + 135);
    }
    noStroke();
  }
  
  // Instrucción - aparece más temprano
  if (completionTimer > 80) {
    if (frameCount % 60 < 30) {
      fill(255, 255, 255);
      textSize(14);
      text("PRESIONA ESPACIO PARA CONTINUAR", width/2, height/2 + 150);
    }
  }
  
  }

void drawLevel3Complete() {
  if (frameCount % 600 == 0) completionTimer = 0; // Reset cada 10 segundos
  completionTimer++;
  
  // Fondo con efecto DOOM
  background(40, 20, 20);
  drawTechnologicalBackground3D();
  
  // Título con efecto metálico DOOM
  fill(100, 100, 100);
  textAlign(CENTER, CENTER);
  textFont(pixelFont);
  textSize(36);
  text("NIVEL 3 COMPLETADO", width/2 + 3, height/2 - 77);
  fill(255, 255, 255);
  text("NIVEL 3 COMPLETADO", width/2, height/2 - 80);
  
  // Subtítulo épico
  if (frameCount % 60 < 30) {
    fill(255, 200, 100);
    textSize(20);
    text("MISION CUMPLIDA", width/2, height/2 - 40);
  }
  
  // Estadísticas finales
  fill(255, 255, 200);
  textSize(14);
  text("Sistema 3D dominado", width/2, height/2 - 5);
  text("Todas las grietas reparadas", width/2, height/2 + 15);
  text("El mundo digital esta a salvo", width/2, height/2 + 35);
  
  // Mensaje épico
  fill(255, 150, 150);
  textSize(16);
  text("Preparandose para el final...", width/2, height/2 + 70);
  
  // Barra de progreso más lenta
  drawProgressBarCompletion(width/2 - 250, height/2 + 100, 500, 30, completionTimer / 440.0);
  
  // Efectos adicionales
  if (completionTimer > 120) {
    // Líneas de energía más intensas
    stroke(255, 200, 100, 200);
    strokeWeight(3);
    for (int i = 0; i < 8; i++) {
      float x = width/2 + sin(frameCount * 0.15 + i) * 150;
      line(x, height/2 + 85, x, height/2 + 145);
    }
    noStroke();
  }
  
  // Instrucción - aparece más temprano
  if (completionTimer > 100) {
    if (frameCount % 60 < 30) {
      fill(255, 255, 255);
      textSize(16);
      text("PRESIONA ESPACIO PARA CONTINUAR", width/2, height/2 + 170);
    }
  }
  
  }

// ========== FUNCIONES AUXILIARES ==========

void drawProgressBarCompletion(float x, float y, float w, float h, float progress) {
  progress = constrain(progress, 0, 1);
  
  // Fondo de la barra
  fill(50, 50, 50);
  rect(x, y, w, h);
  
  // Borde
  stroke(150, 150, 150);
  strokeWeight(2);
  noFill();
  rect(x, y, w, h);
  noStroke();
  
  // Progreso con gradiente
  for (int i = 0; i < w * progress; i++) {
    float ratio = i / (w * progress);
    color startColor = color(0, 255, 0);
    color endColor = color(255, 255, 0);
    color currentColor = lerpColor(startColor, endColor, ratio);
    
    stroke(currentColor);
    line(x + i, y + 2, x + i, y + h - 2);
  }
  noStroke();
  
  // Efecto de brillo
  if (progress > 0.8) {
    fill(255, 255, 255, 100);
    rect(x + 2, y + 2, (w - 4) * progress, h - 4);
  }
  
  // Texto del porcentaje
  fill(255, 255, 255);
  textAlign(CENTER, CENTER);
  textSize(10);
  text(int(progress * 100) + "%", x + w/2, y + h/2);
}

void drawGradientRect(int x, int y, int w, int h, color c1, color c2) {
  for (int i = 0; i < h; i++) {
    float inter = map(i, 0, h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, y + i, x + w, y + i);
  }
  noStroke();
}

float easeInOut(float t) {
  // Funcion de suavizado para animaciones mas naturales
  return t * t * (3.0 - 2.0 * t);
}

// ========== FONDOS TECNOLÓGICOS MEJORADOS ==========

void drawTechnologicalBackground8Bit() {
  // Efecto de lluvia de código binario (8-bit)
  fill(0, 255, 0, 80);
  textSize(10);
  textAlign(LEFT, TOP);
  
  // Lluvia de código binario
  for (int i = 0; i < 50; i++) {
    float x = (frameCount * 2 + i * 20) % (width + 50) - 50;
    float y = (frameCount * 3 + i * 15) % (height + 100) - 100;
    
    // Alternar entre 0 y 1
    String bit = (frameCount + i) % 2 == 0 ? "1" : "0";
    text(bit, x, y);
  }
  
  // Líneas de circuito
  stroke(0, 255, 0, 100);
  strokeWeight(1);
  for (int i = 0; i < 8; i++) {
    float y = i * height / 8 + sin(frameCount * 0.02 + i) * 20;
    line(0, y, width, y);
  }
  
  // Puntos de conexión
  fill(0, 255, 0, 150);
  noStroke();
  for (int i = 0; i < 15; i++) {
    float x = (i * width / 15) + sin(frameCount * 0.03 + i) * 10;
    float y = height/2 + cos(frameCount * 0.02 + i) * 50;
    ellipse(x, y, 4, 4);
  }
}

void drawTechnologicalBackground16Bit() {
  // Efecto de datos hexadecimales flotantes (16-bit)
  fill(100, 150, 255, 120);
  textSize(8);
  textAlign(LEFT, TOP);
  
  // Datos hexadecimales
  String[] hexChars = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"};
  for (int i = 0; i < 60; i++) {
    float x = (frameCount + i * 30) % (width + 100) - 100;
    float y = (frameCount * 0.5 + i * 25) % (height + 150) - 150;
    
    String hex = hexChars[(frameCount + i) % hexChars.length];
    text(hex, x, y);
  }
  
  // Grid de píxeles
  stroke(100, 100, 255, 80);
  strokeWeight(1);
  for (int x = 0; x < width; x += 40) {
    for (int y = 0; y < height; y += 40) {
      if ((x + y + frameCount) % 120 < 60) {
        line(x, y, x + 20, y);
        line(x, y, x, y + 20);
      }
    }
  }
  
  // Pulsos de energía
  fill(255, 100, 255, 100);
  noStroke();
  for (int i = 0; i < 8; i++) {
    float x = width/2 + sin(frameCount * 0.05 + i) * 200;
    float y = height/2 + cos(frameCount * 0.03 + i) * 100;
    float size = 6 + sin(frameCount * 0.1 + i) * 3;
    ellipse(x, y, size, size);
  }
}

void drawTechnologicalBackground3D() {
  // Efecto de código de máquina y wireframe (3D/DOOM)
  fill(255, 150, 100, 100);
  textSize(6);
  textAlign(LEFT, TOP);
  
  // Código de máquina
  String[] machineCode = {"MOV", "JMP", "CMP", "ADD", "SUB", "MUL", "DIV", "AND", "OR", "XOR"};
  for (int i = 0; i < 40; i++) {
    float x = (frameCount * 1.5 + i * 40) % (width + 120) - 120;
    float y = (frameCount * 0.8 + i * 30) % (height + 180) - 180;
    
    String code = machineCode[(frameCount + i) % machineCode.length];
    text(code, x, y);
  }
  
  // Wireframe 3D
  stroke(255, 200, 100, 120);
  strokeWeight(1);
  
  // Líneas de perspectiva
  for (int i = 0; i < 12; i++) {
    float angle = i * TWO_PI / 12;
    float x1 = width/2 + cos(angle + frameCount * 0.01) * 100;
    float y1 = height/2 + sin(angle + frameCount * 0.01) * 100;
    float x2 = width/2 + cos(angle + frameCount * 0.01) * 200;
    float y2 = height/2 + sin(angle + frameCount * 0.01) * 200;
    line(x1, y1, x2, y2);
  }
  
  // Partículas de datos
  fill(255, 255, 100, 150);
  noStroke();
  for (int i = 0; i < 20; i++) {
    float x = width/2 + sin(frameCount * 0.02 + i) * 300;
    float y = height/2 + cos(frameCount * 0.015 + i) * 150;
    float size = 3 + sin(frameCount * 0.08 + i) * 2;
    ellipse(x, y, size, size);
  }
  
  // Líneas de escaneo
  stroke(255, 100, 100, 80);
  strokeWeight(2);
  float scanY = (frameCount * 4) % height;
  line(0, scanY, width, scanY);
  line(0, scanY + 2, width, scanY + 2);
}

void drawMatrixBackground() {
  drawTechnologicalBackground8Bit();
}

void drawGlitchEffect() {
  // Efecto de glitch ocasional
  if (frameCount % 120 < 5) {
    fill(255, 0, 0, 50);
    rect(random(width), random(height), random(100), random(20));
    
    fill(0, 255, 0, 50);
    rect(random(width), random(height), random(100), random(20));
  }
}

// ========== PANTALLA DE INTRODUCCIÓN ==========
void drawIntro() {
  background(0);
  
  // Efecto de matriz digital
  drawMatrixBackground();
  
  // Texto de introducción con efecto de máquina de escribir
  fill(0, 255, 0);
  textAlign(LEFT, TOP);
  textSize(16);
  
  String[] introText = {
    "INICIANDO SISTEMA...",
    "DETECTANDO ANOMALIAS...",
    "ADVERTENCIA: MULTIPLES GRIETAS DETECTADAS",
    "INICIANDO PROTOCOLO DE REPARACION",
    "ACTIVANDO AL ULTIMO MONO..."
  };
  
  for (int i = 0; i < introText.length; i++) {
    if (frameCount > i * 60) {
      int charCount = min((frameCount - i * 60) / 2, introText[i].length());
      text(introText[i].substring(0, charCount), 50, 50 + i * 40);
    }
  }
  
  // Transición automática después de mostrar todo el texto
  if (frameCount > introText.length * 60 + 120) {
    println("🔄 Transición automática: INTRO → CUTSCENE1");
    gameState = GameState.CUTSCENE1;
    frameCount = 0;
  }
  
  // Instrucción para saltar
  if (frameCount % 60 < 30) {
    fill(255);
    textAlign(CENTER, BOTTOM);
    textSize(12);
    text("PRESIONA ESPACIO PARA SALTAR", width/2, height - 30);
  }
}

void drawRankingScreen() {
  background(0, 0, 50);
  
  // Fondo tecnológico
  drawTechnologicalBackground3D();
  
  // Título principal
  fill(255, 255, 0);
  textAlign(CENTER, TOP);
  textSize(24);
  text("🏆 HALL OF FAME 🏆", width/2, 30);
  
  // Subtítulo
  fill(255, 255, 255);
  textSize(14);
  text("Los mejores tiempos de CodeLeak", width/2, 70);
  
  // Mostrar el ranking principal
  rankingSystem.displayRanking(width/2 - 200, 120, 400, 400);
  
  // Información adicional
  fill(128, 128, 128);
  textAlign(CENTER, BOTTOM);
  textSize(12);
  text("Presiona ESPACIO para volver al menú principal", width/2, height - 30);
  
  // Mostrar tiempo actual si hay uno
  if (gameTimer.getTotalSeconds() > 0) {
    fill(255, 255, 255);
    textAlign(CENTER, TOP);
    textSize(14);
    text("Tu último tiempo: " + gameTimer.getFormattedTime(), width/2, 100);
  }
  
  // Estadísticas adicionales
  RankingEntry bestTime = rankingSystem.getBestTime();
  if (bestTime != null) {
    fill(255, 215, 0);
    textAlign(LEFT, BOTTOM);
    textSize(10);
    text("Récord actual: " + bestTime.initials + " - " + bestTime.formattedTime, 20, height - 20);
  }
  
  // Efectos visuales adicionales
  if (frameCount % 120 < 60) {
    fill(255, 255, 0, 100);
    textAlign(CENTER, TOP);
    textSize(16);
    text("🏆", width/2 - 150, 30);
    text("🏆", width/2 + 150, 30);
  }
}

// Las pantallas drawWinScreen() y drawGameOver() estan implementadas en Transitions.pde
