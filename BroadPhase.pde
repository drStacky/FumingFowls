class BroadPhase {
  ArrayList<Pair> bpPairs;
  
  BroadPhase() {
    bpPairs = new ArrayList<Pair>();
  }
 
  // Returns true if AABB overlap
  Boolean AABBtoAABB(Body A, Body B) {
    AABB a = A.shape.getAABB();
    AABB b = B.shape.getAABB();
    
    if (a.max.x < b.min.x || a.min.x > b.max.x) return false;
    if (a.max.y < b.min.y || a.min.y > b.max.y) return false;
    
    return true;
  }
  
  void clearPairs() {
    bpPairs.clear();
  }
}