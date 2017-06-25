// Save some time defining mass and 1/mass to avoid repeated calculations

class MassData {
  float mass;
  float invMass;
  
  MassData (float m) {
    mass = m;
    if (mass==0) invMass = 0;
    else invMass = 1/m;
  }
  
  //float inertia;
  //float inverse_inertia;
}