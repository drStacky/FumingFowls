// Not sure what goes in here exactly

class Material {
  float density, restitution;
  
  Material() {
    density = 0.3;
    restitution = 0.75;
  }
  
  void setDensity(float d) {
    density = d;
  }
  
    void setRestitution(float r) {
    restitution = r;
  }
}