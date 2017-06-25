// Generic shape object with common functions defined or required

abstract class Shape {
  PVector pos;
  float area;
  AABB aabb;
  
  private Shape() {
  }
  
  abstract void computeAABB();
  abstract AABB getAABB();
  abstract void render();
  
  // Need getters and setters to modify child class values, not abstract class
  abstract PVector getPos();
  abstract void setPos(PVector p);
  abstract float getArea();
  abstract boolean isCircle();
  abstract boolean isRectangle();
}