/*
*  Axis Aligned Bounding Box
*  Basically just a rectangle to surround a shape.
*  Used for broad phase of collision detection.
*/

class AABB{
  PVector min, max;
  
  AABB(PVector v1, PVector v2) {
    min = v1;
    max = v2;
  }
  
  AABB copy(){
    return new AABB(min.copy(), max.copy());
  }
}