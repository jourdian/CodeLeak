abstract class BaseLevelManager {
  
  abstract ArrayList<Crack> getCracks();
  abstract Tile[][] getTileMap();
  abstract int getTileSize();

abstract boolean canMoveTo(float x, float y);


}

