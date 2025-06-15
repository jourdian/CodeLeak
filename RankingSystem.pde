// ========== SISTEMA DE RANKING ==========
// Sistema de ranking estilo arcade con iniciales y tiempos

class RankingEntry {
  String initials;
  int timeInMilliseconds;
  String formattedTime;
  String date;
  
  RankingEntry(String initials, int timeInMilliseconds) {
    this.initials = initials.toUpperCase();
    this.timeInMilliseconds = timeInMilliseconds;
    this.formattedTime = formatTime(timeInMilliseconds);
    this.date = getCurrentDate();
  }
  
  RankingEntry(String line) {
    // Constructor para cargar desde archivo
    
    String[] parts = line.split(",");
    if (parts.length >= 3) {
      this.initials = parts[0];
      this.timeInMilliseconds = Integer.parseInt(parts[1]);
      this.formattedTime = parts[2];
      this.date = parts.length > 3 ? parts[3] : "Unknown";
    }
  }
  
  String toFileString() {
    return initials + "," + timeInMilliseconds + "," + formattedTime + "," + date;
  }
  
  String formatTime(int milliseconds) {
    int totalSeconds = milliseconds / 1000;
    int minutes = totalSeconds / 60;
    int seconds = totalSeconds % 60;
    int centiseconds = (milliseconds % 1000) / 10;
    
    return String.format("%02d:%02d.%02d", minutes, seconds, centiseconds);
  }
  
  String getCurrentDate() {
    return year() + "-" + String.format("%02d", month()) + "-" + String.format("%02d", day());
  }
}

class RankingSystem {
  ArrayList<RankingEntry> rankings;
  String filename = "data/rankings.txt";
  int maxEntries = 10;
  
  RankingSystem() {
    rankings = new ArrayList<RankingEntry>();
    loadRankings();
  }
  
  void loadRankings() {
    rankings.clear();
    
    try {
      String[] lines = loadStrings(filename);
      if (lines != null) {
        for (String line : lines) {
          if (line.trim().length() > 0) {
            try {
              RankingEntry entry = new RankingEntry(line.trim());
              rankings.add(entry);
            } catch (Exception e) {
              println("⚠️ Error cargando línea del ranking: " + line);
            }
          }
        }
        println("📊 Ranking cargado: " + rankings.size() + " entradas");
      } else {
        println("📊 No se encontró archivo de ranking, creando nuevo");
        createDefaultRankings();
      }
    } catch (Exception e) {
      println("⚠️ Error cargando ranking: " + e.getMessage());
      createDefaultRankings();
    }
    
    sortRankings();
  }
  
  void createDefaultRankings() {
    // Crear algunos rankings por defecto para mostrar el sistema
    rankings.add(new RankingEntry("DEV", 300000)); // 5:00.00
    rankings.add(new RankingEntry("QDO", 420000)); // 7:00.00
    rankings.add(new RankingEntry("TST", 600000)); // 10:00.00
    saveRankings();
  }
  
  void saveRankings() {
    try {
      String[] lines = new String[rankings.size()];
      for (int i = 0; i < rankings.size(); i++) {
        lines[i] = rankings.get(i).toFileString();
      }
      saveStrings(filename, lines);
      println("💾 Ranking guardado: " + rankings.size() + " entradas");
    } catch (Exception e) {
      println("⚠️ Error guardando ranking: " + e.getMessage());
    }
  }
  
  void sortRankings() {
    // Ordenar por tiempo (menor tiempo = mejor posición)
    rankings.sort((a, b) -> Integer.compare(a.timeInMilliseconds, b.timeInMilliseconds));
  }
  
  boolean isNewRecord(int timeInMilliseconds) {
    if (rankings.size() < maxEntries) {
      return true;
    }
    
    // Verificar si el tiempo es mejor que el peor en la lista
    RankingEntry worstEntry = rankings.get(rankings.size() - 1);
    return timeInMilliseconds < worstEntry.timeInMilliseconds;
  }
  
  int getPosition(int timeInMilliseconds) {
    for (int i = 0; i < rankings.size(); i++) {
      if (timeInMilliseconds < rankings.get(i).timeInMilliseconds) {
        return i + 1; // Posición 1-based
      }
    }
    return rankings.size() + 1;
  }
  
  void addEntry(String initials, int timeInMilliseconds) {
    RankingEntry newEntry = new RankingEntry(initials, timeInMilliseconds);
    rankings.add(newEntry);
    sortRankings();
    
    // Mantener solo las mejores entradas
    while (rankings.size() > maxEntries) {
      rankings.remove(rankings.size() - 1);
    }
    
    saveRankings();
    println("🏆 Nueva entrada añadida al ranking: " + initials + " - " + newEntry.formattedTime);
  }
  
  void displayRanking(float x, float y, float w, float h) {
    // Fondo del ranking
    fill(0, 0, 0, 200);
    rect(x, y, w, h);
    
    // Borde
    stroke(255, 255, 0);
    strokeWeight(2);
    noFill();
    rect(x, y, w, h);
    noStroke();
    
    // Título
    fill(255, 255, 0);
    textAlign(CENTER, TOP);
    textSize(16);
    text("🏆 HALL OF FAME 🏆", x + w/2, y + 10);
    
    // Subtítulo
    fill(255, 255, 255);
    textSize(10);
    text("MEJORES TIEMPOS", x + w/2, y + 35);
    
    // Entradas del ranking
    textAlign(LEFT, TOP);
    textSize(12);
    
    float entryY = y + 60;
    float lineHeight = 25;
    
    for (int i = 0; i < min(rankings.size(), 10); i++) {
      RankingEntry entry = rankings.get(i);
      
      // Color según posición
      if (i == 0) {
        fill(255, 215, 0); // Oro
      } else if (i == 1) {
        fill(192, 192, 192); // Plata
      } else if (i == 2) {
        fill(205, 127, 50); // Bronce
      } else {
        fill(255, 255, 255); // Blanco
      }
      
      // Posición
      text((i + 1) + ".", x + 15, entryY);
      
      // Iniciales
      text(entry.initials, x + 40, entryY);
      
      // Tiempo
      textAlign(RIGHT, TOP);
      text(entry.formattedTime, x + w - 15, entryY);
      
      textAlign(LEFT, TOP);
      entryY += lineHeight;
    }
    
    // Mensaje si no hay entradas
    if (rankings.size() == 0) {
      fill(128, 128, 128);
      textAlign(CENTER, CENTER);
      textSize(14);
      text("No hay registros aún", x + w/2, y + h/2);
    }
  }
  
  ArrayList<RankingEntry> getRankings() {
    return rankings;
  }
  
  RankingEntry getBestTime() {
    if (rankings.size() > 0) {
      return rankings.get(0);
    }
    return null;
  }
}

// Instancia global del sistema de ranking
RankingSystem rankingSystem;