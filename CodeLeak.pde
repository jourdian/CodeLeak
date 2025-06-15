/**
GRADO EN TECNICAS DE INTERACCION DIGITAL Y MULTIMEDIA
Programacion creativa - PR
Jordi Hernandez Vinyals

Este proyecto pretende ser un homenaje a la historia de los
videojuegos. Hago un recorrido a traves de tres fases en las
que pasamos por una era especifica. En el primer nivel he
intentado dar el aspecto de un juego de 8 bits, al estilo de
los que jugabamos en aquellos ordenadores MSX o Spectrum. 
En el segundo nivel pasamos a los 16 bits y tenemos un plataformas
sencillo. Y, finalmente, en el tercer nivel tenemos un FPS al
estilo de Doom.
Evidentemente, por el escaso tiempo disponible, los niveles son 
bastante sencillos, pero he intentado que sean divertidos y algo
desafiantes.

Los controles son sencillos:

El personaje se mueve con las flechas de direccion.
Con la tecla X (eXplosion) podemos poner una bomba que explote. 
Con la tecla Z (Zip) ponemos una bomba parche, para reparar las grietas.

Si queremos pasar a otro nivel (para evaluarlo, por ejemplo) podemos
hacerlo pulsando las teclas 1, 2, 3 y 4 (para niveles 1, 2, 3, y 4)

Es un poco dificil describir toda la arquitectura del juego en este parrafo
pero he utilizado diferentes clases para los personajes y los niveles, aprovechando
las caracteristicas propias de la orientacion a objetos como son la herencia. De 
ese modo, tengo una clase base para el personaje y clases especificas para el personaje
de cada nivel(tenemos personaje topdown y personaje plataforma, por ejemplo)
Para le gestion de los niveles se puede ver que tengo varios gestores de niveles, 
que me permiten tratar de forma especifica cada uno.

Por desgracia no puedo decir que el juego esta acabado. Hay numerosos bugs pero el 
tiempo no me ha permitido mas.

Espero que lo disfrute.

Un saludo.
 */
// ========== VARIABLES GLOBALES ==========
PFont pixelFont;
GameState gameState;
HashMap<String, PImage[]> spriteMap;

// Managers de niveles
Level1Manager level1;
Level2Manager level2;
Level3Manager level3;

void setup() {
  size(1008, 720);
  pixelFont = createFont("PressStart2P.ttf", 12);
  textFont(pixelFont);
  
  // Inicializar sistema de audio
  initializeMinim();
  audioManager.initializeAudio();
  
  // Cargar imagenes de pantallas
  coverImg = loadImage("data/img/cover.png");
  cutscene01Img = loadImage("data/img/cutscene01.png");
  cutscene02Img = loadImage("data/img/cutscene02.png");
  cutscene03Img = loadImage("data/img/cutscene03.png");
  endImg = loadImage("data/img/end.png");
  
  // Inicializar sistemas de ranking y cronometro
  println("Inicializando sistema de ranking...");
  rankingSystem = new RankingSystem();
  gameTimer = new Timer();
  
  gameState = GameState.START;
}

void draw() {
  background(0);
  
    
  // Actualizar musica automaticamente segun el estado
  updateMusic();
  
  switch (gameState) {
    case START:
      drawStartScreen();
      break;

    case CUTSCENE1:
      drawCutscene1();
      break;

    case LEVEL1:
      if (level1 != null) {
        level1.update();
        level1.display();
        drawHUD(level1.getRemainingCracks(), level1.getRemainingWallBombs());
        
                
        // Verificar completacion de nivel 1
        if (level1.isComplete()) {
          println("Transicion automatica: LEVEL1 -> LEVEL1_COMPLETE");
          println("Nivel 1 completado - todas las grietas reparadas");
          gameState = GameState.LEVEL1_COMPLETE;
          audioManager.playLevelSuccess();
        }
      }
      break;

    case LEVEL1_COMPLETE:
      drawLevel1Complete();
      break;

    case CUTSCENE2:
      drawCutscene2();
      break;

    case LEVEL2:
      if (level2 != null) {
        level2.update();
        level2.display();
        
                
        // Verificar completacion de nivel 2
        if (level2.isComplete()) {
          println("Transicion automatica: LEVEL2 -> LEVEL2_COMPLETE");
          println("Nivel 2 completado - todas las grietas reparadas");
          gameState = GameState.LEVEL2_COMPLETE;
          audioManager.playLevelSuccess();
        }
      }
      break;

    case LEVEL2_COMPLETE:
      drawLevel2Complete();
      break;

    case CUTSCENE3:
      drawCutscene3();
      break;

    case LEVEL3:
      if (level3 != null) {
        level3.update();
        level3.display();
        
                
        // Verificar completacion de nivel 3
        if (level3.isComplete()) {
          println("Transicion automatica: LEVEL3 -> LEVEL3_COMPLETE");
          println("Nivel 3 completado - todas las grietas reparadas");
          gameState = GameState.LEVEL3_COMPLETE;
          audioManager.playLevelSuccess();
        }
      }
      break;

    case LEVEL3_COMPLETE:
      drawLevel3Complete();
      break;

    case WIN:
      drawWinScreen();
      break;

    case INITIALS_ENTRY:
      if (initialsScreen != null) {
        initialsScreen.update();
        initialsScreen.display();
      }
      break;

    case RANKING:
      drawRankingScreen();
      break;

    case END:
      drawEndScreen();
      break;

    case GAMEOVER:
      drawGameOver();
      break;
  }
}

void loadAllSprites(String level) {
  spriteMap = new HashMap<String, PImage[]>();

  String[] folders = { "monkey", "enemy" };
  String[] directions = { "down", "left", "right", "up" };
  int framesPerAnim = 4;

  // Verificar que el nivel sea valido
  if (level == null || level.isEmpty()) {
    println("Error: Nivel invalido");
    return;
  }

  for (String folder : folders) {
    for (String dir : directions) {
      String key = folder.equals("monkey") ? "player_" + dir : "enemy_" + dir;
      PImage[] frames = new PImage[framesPerAnim];
      for (int i = 0; i < framesPerAnim; i++) {
        String path = "sprites/" + level + "/" + folder + "/" + key + "_" + (i + 1) + ".png";
        frames[i] = loadImage(path);
        if (frames[i] == null) {
          println("Error cargando sprite: " + path);
        }
      }
      spriteMap.put(key, frames);
    }
  }

  // Tiles de suelo y pared
  spriteMap.put("floor", new PImage[] {
    loadImage("sprites/" + level + "/tiles/tile_ground.png")
  });
  spriteMap.put("ground", new PImage[] {
    loadImage("sprites/" + level + "/tiles/tile_ground.png")
  });
  spriteMap.put("wall", new PImage[] {
    loadImage("sprites/" + level + "/tiles/tile_wall.png")
  });

  // Grietas
  spriteMap.put("crack_open", new PImage[] {
    loadImage("sprites/" + level + "/tiles/crack_open.png")
  });
  spriteMap.put("crack_patched", new PImage[] {
    loadImage("sprites/" + level + "/tiles/crack_patched.png")
  });

  // Bombas - animaciones
  try {
    PImage[] patchFrames = new PImage[20];
    for (int i = 0; i < 20; i++) {
      String fname = String.format("sprites/" + level + "/bombs/patch_bomb_%02d.png", i + 1);
      patchFrames[i] = loadImage(fname);
    }
    spriteMap.put("patch_bomb", patchFrames);
  } catch (Exception e) {
    println("Bombas no encontradas para " + level);
  }

  try {
    PImage[] wallFrames = new PImage[16];
    for (int i = 0; i < 16; i++) {
      String fname = String.format("sprites/" + level + "/bombs/wall_bomb_%02d.png", i + 1);
      wallFrames[i] = loadImage(fname);
    }
    spriteMap.put("wall_bomb", wallFrames);
  } catch (Exception e) {
    println("Bombas de pared no encontradas para " + level);
  }

  // Efecto de humo glitch
  try {
    PImage[] binarySmoke = new PImage[12];
    for (int i = 0; i < 12; i++) {
      String fname = String.format("sprites/" + level + "/tiles/binary_smoke_%02d.png", i + 1);
      binarySmoke[i] = loadImage(fname);
    }
    spriteMap.put("crack_binary_smoke", binarySmoke);
  } catch (Exception e) {
    println("Humo no encontrado para " + level);
  }

  // Solo en level01: tile de reconfiguracion
  if (level.equals("level01")) {
    PImage[] reconfTileFrames = new PImage[4];
    for (int i = 0; i < 4; i++) {
      String fname = String.format("sprites/level01/tiles/reconf_tile_%d.png", i + 1);
      reconfTileFrames[i] = loadImage(fname);
    }
    spriteMap.put("reconf_tile", reconfTileFrames);
  }
  
  // Para level03: informacion sobre texturas escaladas
  if (level.equals("level03")) {
    println("Cargando texturas para nivel 3D...");
    if (spriteMap.get("wall") != null && spriteMap.get("wall")[0] != null) {
      PImage wallTexture = spriteMap.get("wall")[0];
      println("Textura de pared: " + wallTexture.width + "x" + wallTexture.height);
    }
    if (spriteMap.get("floor") != null && spriteMap.get("floor")[0] != null) {
      PImage floorTexture = spriteMap.get("floor")[0];
      println("Textura de suelo: " + floorTexture.width + "x" + floorTexture.height);
    }
  }
}


void keyPressed() {
  println("Tecla presionada: '" + key + "' (codigo: " + keyCode + ") en estado: " + gameState);
  
  // Transiciones principales del juego
  if (gameState == GameState.START && key == ' ') {
    println("Transicion: START -> CUTSCENE1");
    gameState = GameState.CUTSCENE1;
    frameCount = 0;
    key = 0; // Reset key
  }

  // Ver ranking desde el menu principal
  if (gameState == GameState.START && (key == 'r' || key == 'R')) {
    println("Transicion: START -> RANKING");
    gameState = GameState.RANKING;
    key = 0;
  }

  // Atajos de evaluacion
  if (true) {
    if (key == '1') {
      println("Atajo 1: -> CUTSCENE1");
      gameState = GameState.CUTSCENE1;
    }
    if (key == '2') {
      println("Atajo 2: -> LEVEL1_COMPLETE (pantalla de nivel 1 superado)");
      gameState = GameState.LEVEL1_COMPLETE;
    }
    if (key == '3') {
      println("Atajo 3: -> LEVEL2_COMPLETE (pantalla de nivel 2 superado)");
      gameState = GameState.LEVEL2_COMPLETE;
    }
    if (key == '4') {
      println("Atajo 4: -> LEVEL3_COMPLETE (pantalla de nivel 3 superado)");
      gameTimer.stop(); // Simular que se completo el juego
      gameState = GameState.LEVEL3_COMPLETE;
      audioManager.playLevelSuccess();
    }
  }
  
  // Transiciones de niveles y cutscenes
  if (gameState == GameState.CUTSCENE1 && key == ' ') {
    println("Transicion: CUTSCENE1 -> LEVEL1");
    gameState = GameState.LEVEL1;
    loadAllSprites("level01");
    level1 = new Level1Manager();
    
    // Iniciar cronometro al comenzar el primer nivel
    gameTimer.start();
    println("Cronometro iniciado al comenzar Level 1");
    
    key = 0;
  }
  
  // Transiciones de nivel 1 completo a cutscene 2
  if (gameState == GameState.LEVEL1_COMPLETE && key == ' ') {
    println("Transicion: LEVEL1_COMPLETE -> CUTSCENE2");
    gameState = GameState.CUTSCENE2;
    key = 0;
  }
  
  // Transicion a nivel 2
  if (gameState == GameState.CUTSCENE2 && key == ' ') {
    println("Transicion: CUTSCENE2 -> LEVEL2");
    gameState = GameState.LEVEL2;
    loadAllSprites("level02");
    level2 = new Level2Manager();
    key = 0;
  }

  // Transiciones de nivel 2 completo a cutscene 3
  if (gameState == GameState.LEVEL2_COMPLETE && key == ' ') {
    println("Transicion: LEVEL2_COMPLETE -> CUTSCENE3");
    gameState = GameState.CUTSCENE3;
    key = 0;
  }
  
  // Transicion a nivel 3
  if (gameState == GameState.CUTSCENE3 && key == ' ') {
    println("Transicion: CUTSCENE3 -> LEVEL3");
    gameState = GameState.LEVEL3;
    loadAllSprites("level03");
    level3 = new Level3Manager();
    key = 0;
  }
  
  // Transicion de nivel 3 completo a pantalla final
  if (gameState == GameState.LEVEL3_COMPLETE && key == ' ') {
    println("Transicion: LEVEL3_COMPLETE -> END");
    
    // Detener cronometro al completar todos los niveles
    gameTimer.stop();
    
    gameState = GameState.END;
    audioManager.playEndMusic();
    key = 0;
  }
  
  // Transicion desde pantalla final (end.png)
  if (gameState == GameState.END && key == ' ') {
    println("Transicion desde END");
    
    int finalTime = gameTimer.getTotalMilliseconds();
    
    // Verificar si es un nuevo record
    if (rankingSystem.isNewRecord(finalTime)) {
      println("Nuevo record! Tiempo: " + gameTimer.getFormattedTime());
      println("Transicion: END -> INITIALS_ENTRY");
      gameState = GameState.INITIALS_ENTRY;
      initialsScreen = new InitialsScreen(finalTime);
    } else {
      println("Juego completado. Tiempo: " + gameTimer.getFormattedTime());
      println("Transicion: END -> RANKING");
      gameState = GameState.RANKING;
    }
    
    key = 0;
  }

  // Input de juego
  if (gameState == GameState.LEVEL1) {
    level1.handleInput(key, keyCode);
  }

  if (gameState == GameState.LEVEL2) {
    level2.handleInput(key, keyCode);
  }
  
  if (gameState == GameState.LEVEL3) {
    level3.handleInput(key, keyCode);
    // Manejar input del jugador 3D
    if (level3.player instanceof RaycastPlayer) {
      ((RaycastPlayer)level3.player).keyPressed(key, keyCode);
    }
  }

  // Reinicio desde Game Over
  if (gameState == GameState.GAMEOVER && key == 'r') {
    level1 = new Level1Manager();
    gameState = GameState.CUTSCENE1;
    gameTimer.reset();
  }
  
  // Input para pantalla de iniciales
  if (gameState == GameState.INITIALS_ENTRY && initialsScreen != null) {
    initialsScreen.handleInput(key, keyCode);
  }
  
  // Input para pantalla de ranking
  if (gameState == GameState.RANKING && key == ' ') {
    gameState = GameState.START;
    gameTimer.reset();
  }
}

void keyReleased() {
  if (gameState == GameState.LEVEL2) {
    level2.handleKeyReleased(key, keyCode);
  }
  
  if (gameState == GameState.LEVEL3) {
    // Manejar input del jugador 3D
    if (level3.player instanceof RaycastPlayer) {
      ((RaycastPlayer)level3.player).keyReleased(key, keyCode);
    }
  }
}