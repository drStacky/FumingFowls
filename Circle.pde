class Circle extends Shape{
  PVector pos;
  float area;
  int r; // Major and minor axis radii
  AABB aabb;
  
  Circle() {
    r = 10;
    pos = new PVector(width/2, height/2);
    area = PI*r*r;
    computeAABB();
  }
  
  Circle(int rad) {
    r = rad;
    pos = new PVector(width/2, height/2);
    area = PI*r*r;
    computeAABB();
  }
  
  Circle( int rad, int x, int y) {
    r = rad;
    pos = new PVector(x, y);
    area = PI*r*r;
    computeAABB();
  }
    
  void computeAABB() {
    PVector upLeft = pos.copy().sub( new PVector(r, r) );
    PVector downRight = pos.copy().add( new PVector(r, r) );
    aabb = new AABB(upLeft, downRight);
  }
  
  AABB getAABB() {
    return aabb.copy();
  }
  
  void render() {
    stroke(0);
    strokeWeight(2);
    fill(255, 0, 0);
    ellipse(pos.x, pos.y, 2*r, 2*r);
  }
  
  PVector getPos() {
    return pos.copy();
  }
  
  void setPos(PVector newPos) {
    pos = newPos;
  }
  
  float getArea() {
    return area;
  }
  
  boolean isCircle() {
    return true;
  }
}