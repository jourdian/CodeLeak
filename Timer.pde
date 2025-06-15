// ========== SISTEMA DE CRONÓMETRO ==========
// Cronómetro global para el sistema de ranking

class Timer {
  int startTime;
  int pausedTime;
  boolean isRunning;
  boolean isPaused;
  
  Timer() {
    reset();
  }
  
  void start() {
    if (!isRunning) {
      startTime = millis();
      isRunning = true;
      isPaused = false;
      println("⏱️ Cronómetro iniciado");
    }
  }
  
  void pause() {
    if (isRunning && !isPaused) {
      pausedTime += millis() - startTime;
      isPaused = true;
      println("⏸️ Cronómetro pausado");
    }
  }
  
  void resume() {
    if (isRunning && isPaused) {
      startTime = millis();
      isPaused = false;
      println("▶️ Cronómetro reanudado");
    }
  }
  
  void stop() {
    if (isRunning) {
      if (!isPaused) {
        pausedTime += millis() - startTime;
      }
      isRunning = false;
      isPaused = false;
      println("⏹️ Cronómetro detenido - Tiempo total: " + getFormattedTime());
    }
  }
  
  void reset() {
    startTime = 0;
    pausedTime = 0;
    isRunning = false;
    isPaused = false;
    println("🔄 Cronómetro reiniciado");
  }
  
  int getTotalMilliseconds() {
    if (!isRunning) {
      return pausedTime;
    } else if (isPaused) {
      return pausedTime;
    } else {
      return pausedTime + (millis() - startTime);
    }
  }
  
  int getTotalSeconds() {
    return getTotalMilliseconds() / 1000;
  }
  
  String getFormattedTime() {
    int totalSeconds = getTotalSeconds();
    int minutes = totalSeconds / 60;
    int seconds = totalSeconds % 60;
    int milliseconds = (getTotalMilliseconds() % 1000) / 10; // Centésimas
    
    return String.format("%02d:%02d.%02d", minutes, seconds, milliseconds);
  }
  
  String getShortFormattedTime() {
    int totalSeconds = getTotalSeconds();
    int minutes = totalSeconds / 60;
    int seconds = totalSeconds % 60;
    
    if (minutes > 0) {
      return String.format("%d:%02d", minutes, seconds);
    } else {
      return String.format("%ds", seconds);
    }
  }
}

// Instancia global del cronometro
Timer gameTimer;