// ========== GESTOR DE AUDIO SIMPLIFICADO ==========
// Sistema de audio para CodeLeak: El Último Mono
// Usando librería Minim - Versión simplificada y mejorada

import ddf.minim.*;

class AudioManager {
  // Variables de Minim dentro de la clase
  Minim minim;
  AudioPlayer currentMusicPlayer;
  HashMap<String, AudioPlayer> sfxPlayers;
  
  boolean audioEnabled = true;
  boolean musicLoaded = false;
  float masterVolume = 0.7;
  float musicVolume = 0.5;
  float sfxVolume = 0.8;
  
  String currentMusic = "";
  
  AudioManager() {
    // La inicialización se hará desde setup() del sketch principal
    sfxPlayers = new HashMap<String, AudioPlayer>();
  }
  
  void initializeAudio() {
    println("🔊 AudioManager inicializado - Minim se inicializará desde setup()");
    loadSoundEffects();
  }
  
  void loadSoundEffects() {
    if (minim == null) {
      println("⚠ Minim no inicializado, no se pueden cargar efectos de sonido");
      return;
    }
    
    try {
      // Cargar efectos de sonido con archivos alternativos como fallback
      loadSoundWithFallback("wall_bomb", new String[]{"data/sfx/wall_bomb.mp3", "data/sfx/wall_bomb2.mp3"});
      loadSoundWithFallback("patch_bomb", new String[]{"data/sfx/patch_bomb.mp3", "data/sfx/patch_bomb2.mp3", "data/sfx/patch_bomb - copia.mp3"});
      loadSoundWithFallback("laser_shot", new String[]{"data/sfx/laser_shot.mp3"});
      loadSoundWithFallback("enemy_contact", new String[]{"data/sfx/enemy_contact.mp3", "data/sfx/enemy_contact3.mp3"});
      loadSoundWithFallback("power_up", new String[]{"data/sfx/power_up.mp3"});
      loadSoundWithFallback("jump", new String[]{"data/sfx/jump.mp3"});
      
      println("🔊 Efectos de sonido cargados correctamente");
      println("🔊 Total de efectos cargados: " + sfxPlayers.size());
    } catch (Exception e) {
      println("⚠ Error cargando efectos de sonido: " + e.getMessage());
    }
  }
  
  // Método para cargar sonidos con archivos de fallback
  void loadSoundWithFallback(String soundName, String[] filePaths) {
    AudioPlayer player = null;
    
    for (String path : filePaths) {
      try {
        player = minim.loadFile(path);
        if (player != null) {
          println("✅ Sonido '" + soundName + "' cargado desde: " + path);
          break;
        }
      } catch (Exception e) {
        println("⚠ Error cargando " + path + ": " + e.getMessage());
      }
    }
    
    if (player != null) {
      sfxPlayers.put(soundName, player);
    } else {
      println("❌ No se pudo cargar ningún archivo para: " + soundName);
    }
  }
  
  // ========== MÚSICA ==========
  
  void playMusic(String musicName) {
    currentMusic = musicName;
    
    if (!audioEnabled || minim == null) {
      println("🎵 [SIMULADO] Reproduciendo música: " + musicName);
      return;
    }
    
    stopMusic();
    
    try {
      String filename = "";
      switch (musicName) {
        case "intro":
          filename = "data/music/intro.mp3";
          break;
        case "cutscene":
          filename = "data/music/cutscene.mp3";
          break;
        case "level1":
          filename = "data/music/level01.mp3";
          break;
        case "level2":
          filename = "data/music/level02.mp3";
          break;
        case "level3":
          filename = "data/music/level03.mp3";
          break;
        case "level_success":
          filename = "data/music/level_success.mp3";
          break;
        case "game_over":
          filename = "data/music/game_over.mp3";
          break;
        case "winner":
          filename = "data/music/winner.mp3";
          break;
        default:
          println("🎵 [ERROR] Música no disponible: " + musicName);
          return;
      }
      
      currentMusicPlayer = minim.loadFile(filename);
      if (currentMusicPlayer != null) {
        currentMusicPlayer.setGain(convertVolume(musicVolume * masterVolume));
        currentMusicPlayer.loop();
        println("🎵 Reproduciendo: " + filename);
      } else {
        println("⚠ Error cargando: " + filename);
      }
      
    } catch (Exception e) {
      println("⚠ Error reproduciendo música " + musicName + ": " + e.getMessage());
    }
  }
  
  void stopMusic() {
    if (currentMusicPlayer != null) {
      try {
        if (currentMusicPlayer.isPlaying()) {
          currentMusicPlayer.pause();
        }
        currentMusicPlayer.close();
        currentMusicPlayer = null;
        println("🔇 Música detenida");
      } catch (Exception e) {
        println("⚠ Error deteniendo música: " + e.getMessage());
      }
    }
    currentMusic = "";
  }
  
  // Convertir volumen de 0.0-1.0 a decibelios para Minim
  float convertVolume(float volume) {
    if (volume <= 0) return -80; // Silencio
    return 20 * log(volume) / log(10); // Convertir a dB
  }
  
  // ========== EFECTOS DE SONIDO SIMPLIFICADOS ==========
  
  void playSFX(String soundName) {
    println("🔊 playSFX SIMPLIFICADO llamado con: " + soundName);
    
    if (!audioEnabled || minim == null || sfxPlayers == null) {
      println("🔊 Condiciones no cumplidas, usando feedback para: " + soundName);
      createSoundFeedback(soundName);
      return;
    }
    
    try {
      // ESTRATEGIA SIMPLE: Siempre crear nueva instancia del sonido
      String filePath = "data/sfx/" + soundName + ".mp3";
      AudioPlayer newPlayer = minim.loadFile(filePath);
      
      if (newPlayer != null) {
        newPlayer.setGain(convertVolume(sfxVolume * masterVolume));
        newPlayer.play();
        println("✅ SFX reproducido con nueva instancia: " + soundName);
      } else {
        println("⚠ No se pudo crear nueva instancia, usando fallback");
        createSoundFeedback(soundName);
      }
    } catch (Exception e) {
      println("⚠ Error reproduciendo SFX " + soundName + ": " + e.getMessage());
      createSoundFeedback(soundName);
    }
  }
  
  void createSoundFeedback(String soundName) {
    switch (soundName) {
      case "wall_bomb":
        println("💣 SFX: Bomba de muro");
        break;
      case "patch_bomb":
        println("🔧 SFX: Bomba parche");
        break;
      case "laser_shot":
        println("🔫 SFX: Disparo láser");
        break;
      case "enemy_contact":
        println("😱 SFX: Contacto con enemigo");
        break;
      case "power_up":
        println("⚡ SFX: Power-up obtenido");
        break;
      case "jump":
        println("🦘 SFX: Salto");
        break;
      default:
        println("🔊 SFX: " + soundName);
        break;
    }
  }
  
  // ========== MÉTODOS DE CONVENIENCIA ==========
  
  void playIntroMusic() { playMusic("intro"); }
  void playCutsceneMusic() { playMusic("cutscene"); }
  void playLevel1Music() { playMusic("level1"); }
  void playLevel2Music() { playMusic("level2"); }
  void playLevel3Music() { playMusic("level3"); }
  void playLevelSuccessMusic() { playMusic("level_success"); }
  void playGameOverMusic() { playMusic("game_over"); }
  
  void playCutscene1Music() { playCutsceneMusic(); }
  void playCutscene2Music() { playCutsceneMusic(); }
  void playCutscene3Music() { playCutsceneMusic(); }
  void playEndMusic() { playMusic("winner"); }
  
  // Métodos de conveniencia para efectos de sonido
  void playWallBomb() { 
    println("💥 AudioManager.playWallBomb() llamado");
    playSFX("wall_bomb"); 
  }
  void playPatchBomb() { 
    println("🔧 AudioManager.playPatchBomb() llamado");
    playSFX("patch_bomb");
  }
  void playLaserShot() { 
    println("🔫 AudioManager.playLaserShot() llamado");
    playSFX("laser_shot"); 
  }
  void playEnemyContact() { playSFX("enemy_contact"); }
  void playPowerUp() { playSFX("power_up"); }
  void playJump() { 
    println("🦘 AudioManager.playJump() llamado");
    playSFX("jump");
  }
  
  // Método para reinicializar efectos de sonido si es necesario
  void reinitializeSFX() {
    println("🔄 Reinicializando efectos de sonido...");
    if (minim != null) {
      loadSoundEffects();
    } else {
      println("⚠ No se puede reinicializar SFX: Minim no está disponible");
    }
  }
  
  void verifyAndRepairSounds() {
    println("🔧 Verificando sonidos...");
    
    // Verificar específicamente patch_bomb
    AudioPlayer patchBombPlayer = sfxPlayers.get("patch_bomb");
    if (patchBombPlayer == null) {
      println("❌ patch_bomb no está cargado, intentando cargar...");
      loadSoundWithFallback("patch_bomb", new String[]{"data/sfx/patch_bomb2.mp3", "data/sfx/patch_bomb - copia.mp3", "data/sfx/patch_bomb.mp3"});
    } else {
      println("✅ patch_bomb está cargado correctamente");
    }
    
    // Verificar jump
    AudioPlayer jumpPlayer = sfxPlayers.get("jump");
    if (jumpPlayer == null) {
      println("❌ jump no está cargado, intentando cargar...");
      loadSoundWithFallback("jump", new String[]{"data/sfx/jump.mp3"});
    } else {
      println("✅ jump está cargado correctamente");
    }
    
    println("🔧 Verificación completada");
  }
  
  void playLevelSuccess() { playLevelSuccessMusic(); }
  void playWallBombPlace() { playSFX("wall_bomb"); }
  void playWallBombExplode() { playSFX("wall_bomb"); }
  void playPatchBombPlace() { playSFX("patch_bomb"); }
  void playPatchBombExplode() { playSFX("patch_bomb"); }
  void playShoot() { playSFX("laser_shot"); }
  
  // ========== CONFIGURACIÓN ==========
  
  void setMasterVolume(float volume) {
    masterVolume = constrain(volume, 0.0, 1.0);
    if (currentMusicPlayer != null && currentMusicPlayer.isPlaying()) {
      currentMusicPlayer.setGain(convertVolume(musicVolume * masterVolume));
    }
    println("🔊 Volumen maestro: " + int(masterVolume * 100) + "%");
  }
  
  void setMusicVolume(float volume) {
    musicVolume = constrain(volume, 0.0, 1.0);
    if (currentMusicPlayer != null && currentMusicPlayer.isPlaying()) {
      currentMusicPlayer.setGain(convertVolume(musicVolume * masterVolume));
    }
    println("🎵 Volumen música: " + int(musicVolume * 100) + "%");
  }
  
  void setSFXVolume(float volume) {
    sfxVolume = constrain(volume, 0.0, 1.0);
    println("🔊 Volumen efectos: " + int(sfxVolume * 100) + "%");
  }
  
  void toggleAudio() {
    audioEnabled = !audioEnabled;
    if (!audioEnabled) {
      stopMusic();
      println("🔇 Audio desactivado");
    } else {
      playMusic(currentMusic);
      println("🔊 Audio activado");
    }
  }
  
  // ========== INFORMACIÓN ==========
  
  boolean isAudioEnabled() { return audioEnabled; }
  boolean isMusicLoaded() { return musicLoaded; }
  String getCurrentMusic() { return currentMusic; }
  float getMasterVolume() { return masterVolume; }
  float getMusicVolume() { return musicVolume; }
  float getSFXVolume() { return sfxVolume; }
  
  void printStatus() {
    println("🎵 === ESTADO DEL SISTEMA DE AUDIO ===");
    println("Audio habilitado: " + audioEnabled);
    println("Minim inicializado: " + (minim != null));
    println("Música actual: " + (currentMusic.equals("") ? "Ninguna" : currentMusic));
    println("Reproductor activo: " + (currentMusicPlayer != null));
    println("SFX Players cargados: " + (sfxPlayers != null ? sfxPlayers.size() : 0));
    if (sfxPlayers != null) {
      println("Efectos disponibles: " + sfxPlayers.keySet());
      // Verificar específicamente los sonidos de bombas
      println("wall_bomb disponible: " + (sfxPlayers.get("wall_bomb") != null));
      println("patch_bomb disponible: " + (sfxPlayers.get("patch_bomb") != null));
      println("jump disponible: " + (sfxPlayers.get("jump") != null));
    }
    println("=====================================");
  }
}

// Instancia global del gestor de audio
AudioManager audioManager = new AudioManager();

// Función para inicializar Minim desde el sketch principal
void initializeMinim() {
  try {
    audioManager.minim = new Minim(this);
    println("🎵 Minim inicializado correctamente");
    
    // Cargar efectos de sonido después de inicializar Minim
    audioManager.loadSoundEffects();
  } catch (Exception e) {
    println("⚠ Error inicializando Minim: " + e.getMessage());
  }
}

// Función requerida por Minim para limpieza
void stop() {
  if (audioManager.currentMusicPlayer != null) {
    audioManager.currentMusicPlayer.close();
  }
  
  // Cerrar efectos de sonido
  if (audioManager.sfxPlayers != null) {
    for (AudioPlayer sfx : audioManager.sfxPlayers.values()) {
      if (sfx != null) {
        sfx.close();
      }
    }
  }
  
  if (audioManager.minim != null) {
    audioManager.minim.stop();
  }
  super.stop();
}