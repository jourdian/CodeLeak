// ========== GESTOR DE MUSICA ==========
// Controla la musica segun el estado del juego

GameState lastMusicState = null; // Inicializar como null para forzar el primer cambio

void updateMusic() {
  // Solo cambiar musica si el estado ha cambiado
  if (gameState != lastMusicState) {
    println("Cambio de musica - Estado anterior: " + lastMusicState);
    println("Cambio de musica - Estado nuevo: " + gameState);
    
    switch (gameState) {
      case START:
        println("Estado START - Reproduciendo musica de intro");
        audioManager.playIntroMusic();
        break;
      case CUTSCENE1:
        println("Estado CUTSCENE1 - Reproduciendo musica de cutscene");
        audioManager.playCutsceneMusic();
        break;
      case CUTSCENE2:
        println("Estado CUTSCENE2 - Reproduciendo musica de cutscene");
        audioManager.playCutsceneMusic();
        break;
      case CUTSCENE3:
        println("Estado CUTSCENE3 - Reproduciendo musica de cutscene");
        audioManager.playCutsceneMusic();
        break;
      case LEVEL1:
        println("Estado LEVEL1 - Reproduciendo musica de nivel 1");
        audioManager.playLevel1Music();
        break;
      case LEVEL1_COMPLETE:
        println("Estado LEVEL1_COMPLETE - Reproduciendo musica de exito");
        audioManager.playLevelSuccessMusic();
        break;
      case LEVEL2:
        println("Estado LEVEL2 - Reproduciendo musica de nivel 2");
        audioManager.playLevel2Music();
        break;
      case LEVEL2_COMPLETE:
        println("Estado LEVEL2_COMPLETE - Reproduciendo musica de exito");
        audioManager.playLevelSuccessMusic();
        break;
      case LEVEL3:
        println("Estado LEVEL3 - Reproduciendo musica de nivel 3");
        audioManager.playLevel3Music();
        break;
      case LEVEL3_COMPLETE:
        println("Estado LEVEL3_COMPLETE - Reproduciendo musica de exito");
        audioManager.playLevelSuccessMusic();
        break;
      case WIN:
        println("Estado WIN - Reproduciendo musica de victoria");
        audioManager.playEndMusic();
        break;
      case END:
        println("Estado END - Reproduciendo musica final");
        audioManager.playEndMusic();
        break;
      case GAMEOVER:
        println("Estado GAMEOVER - Reproduciendo musica de game over");
        audioManager.playGameOverMusic();
        break;
    }
    lastMusicState = gameState;
  }
}