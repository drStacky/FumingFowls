// Object to store pairs of objects during broad phase collision detection
// Called a manifold in first tutorial

class Pair {
  Body A;
  Body B;
  float penetration;
  PVector normal;
 
  Pair() {
    A = null;
    B = null;
    penetration = 0;
    normal = new PVector(1,0);
  }
  
  Pair(Body _A, Body _B) {
    A = _A;
    B = _B;
    penetration = 0;
    normal = new PVector(1,0);
  }
  
  void setPenetration(float p) {
    penetration = p;
  }
  
  float getPenetration() {
    return penetration;
  }
  
  void setNormal(PVector n) {
    normal = n;
  }
  
  PVector getNormal() {
    return normal;
  }
}