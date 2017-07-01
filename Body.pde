// Body object contains all information about some given physics object

class Body {
  Shape shape;
  //Transform tx; // Object to hold position and rotation
  Material material;
  MassData massData;
  PVector velocity;
  PVector force = new PVector(0,1);
  
  Body(Shape s) {
    shape = s;
    material = new Material();
    massData = new MassData( computeMass() );
    velocity = new PVector(0,0);
  }
  
  Body(Shape s, float g) {
    shape = s;
    material = new Material();
    massData = new MassData( computeMass() );
    velocity = new PVector(0,0);
    force = force.mult( massData.mass * g );
  }
  
  Body(Shape s, float g, PVector v) {
    shape = s;
    material = new Material();
    massData = new MassData( computeMass() );
    velocity = v;
    force = force.mult( massData.mass * g );
  }
  
  void update(float dt) {
    checkEdges();
    shape.computeAABB();
    
    // v += a*dt = F/m*dt
    PVector dv = force.copy();
    dv.mult(massData.invMass*dt);
    addToVelocity( dv );
    
    // x += v*dt
    PVector dx = velocity.copy();
    dx.mult(dt);
    shape.setPos( shape.getPos().add( dx ) );
  }
  
  float computeMass() {
    return material.density * shape.getArea();
  }
  
  void checkEdges() {
    float x = shape.getPos().x;
    float y = shape.getPos().y;
    
    // If body crosses edge, move back to edge and reverse velocity component
    if (x <= 0) {
      shape.setPos( new PVector(0,y) );
      velocity.x *= -material.restitution;
    }
    if (x >= width) {
      shape.setPos( new PVector(width,y) );
      velocity.x *= -material.restitution;
    }
    if (y <= 0) {
      shape.setPos( new PVector(x,0) );
      velocity.y *= -material.restitution;
    }
    if (y >= height) {
      shape.setPos( new PVector(x,height) );
      velocity.y *= -material.restitution;
    }
  }
  
  void addToVelocity(PVector v) {
    velocity.add(v);
  }
  
  PVector getPos() {
    return shape.getPos();
  }
  
  void setPos(PVector vec) {
    shape.setPos(vec);
  }
  
  Shape getShape() {
    return shape;
  }
}