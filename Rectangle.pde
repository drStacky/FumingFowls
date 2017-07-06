class Rectangle extends Shape {
  PVector pos;
  float area;
  int w, h;
  AABB aabb;
  
  Rectangle() {
    w = 20;
    h = 20;
    pos = new PVector(width/2, height/2);
    area = w*h;
    computeAABB();
  }
  
  Rectangle(int _w, int _h) {
    w = _w;
    h = _h;
    pos = new PVector(width/2, height/2);
    area = w*h;
    computeAABB();
  }
  
  Rectangle(int _w, int _h, int x, int y) {
    w = _w;
    h = _h;
    pos = new PVector(x, y);
    area = w*h;
    computeAABB();
  }
  
  // This assumes axes of ellipse are parallel to screen sides.
  // Needs to modified if rotations introduced.
  void computeAABB() {
    PVector upLeft = pos.copy();
    PVector downRight = pos.copy().add( new PVector(w, h) );
    aabb = new AABB(upLeft, downRight);
  }
  
  AABB getAABB() {
    return aabb.copy();
  }
  
  // Returns a list containing the four corners of the rectangle
  // Assumes axis aligned
  ArrayList<PVector> getCorners() {
    ArrayList<PVector> corners = new ArrayList();
    
    corners.add( getPos() );
    corners.add( getPos().add( new PVector(w, 0) ) );
    corners.add( getPos().add( new PVector(w, h) ) );
    corners.add( getPos().add( new PVector(0, h) ) );
    
    return corners;
  }
  
  void render() {
    stroke(0);
    strokeWeight(2);
    fill(255, 0, 0);
    rect(pos.x, pos.y, w, h);
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
    return false;
  }
  
  PVector getCenter() {
    return pos.copy().add( new PVector(w/2, h/2) );
  }
}