class Crack {
  PVector position;
  boolean isPatched = false;

  // Control de animación del humo binario
  int smokeAnimFrame = 0;
  int smokeAnimSpeed = 5; // Cambia el fotograma cada 5 frames

  Crack(float x, float y) {
    position = new PVector(x, y);
  }

  void update(PlayerBase player) {
    // Aquí podrías añadir lógica si se desea interacción directa con el jugador
  }

void display() {
  imageMode(CENTER);

  // Mostrar sprite de grieta (abierta o parcheada)
  PImage[] crackFrames = spriteMap.get(isPatched ? "crack_patched" : "crack_open");
  if (crackFrames != null && crackFrames.length > 0) {
    image(crackFrames[0], position.x, position.y);
  }

  // Mostrar humo animado si la grieta está activa (ahora encima)
  if (!isPatched) {
    PImage[] smokeFrames = spriteMap.get("crack_binary_smoke");
    if (smokeFrames != null && smokeFrames.length > 0) {
      int frame = (smokeAnimFrame / smokeAnimSpeed) % smokeFrames.length;
      image(smokeFrames[frame], position.x, position.y);
      smokeAnimFrame++;
    }
  }

  imageMode(CORNER);
}


  void patch() {
    isPatched = true;
  }

  void unpatch() {
    isPatched = false;
  }

  boolean isActive() {
    return !isPatched;
  }
}
