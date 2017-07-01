final static class Collision {
  
  private Collision() { 
  }
  
  static void resolveCollision(Pair p) {
    PVector rv = p.B.velocity.copy().sub( p.A.velocity );
    float velAlongNormal = rv.dot(p.getNormal());
    
    // Do nothing if objects separating
    if (velAlongNormal > 0) return;
    
    // Calculate restitution
    float e = min( p.A.material.restitution, p.B.material.restitution);
   
    // Calculate impulse scalar
    float j = -(1 + e) * velAlongNormal;
    j /= p.A.massData.invMass + p.B.massData.invMass;
   
    // Apply impulse
    PVector impulse = p.getNormal().mult(j);
    p.A.addToVelocity( impulse.copy().mult(-p.A.massData.invMass) );
    p.B.addToVelocity( impulse.copy().mult(p.B.massData.invMass) );
    
    //positionalCorrection(p);
  }
  
  static boolean circleVsCircle(Pair p) {
    Circle A = (Circle) p.A.shape;
    Circle B = (Circle) p.B.shape;
    
    PVector n = B.getPos().sub( A.getPos() );
    float r = A.r + B.r; // Sum of radii
    
    float d = n.mag(); // separation of circle centers
    
    // Circle do not touch
    if(d > r) return false;
    
    // Otherwise circles have collided
    // If circles are not co-centric
    if (d != 0) {
      p.setPenetration(r-d);
      p.setNormal( n.div(d) ); // Make normal unit length
    }
    // Co-centric case
    else {
      p.setPenetration(r);
      // Not sure this is really the direction to set normal
      p.setNormal( new PVector(1,0) ); // Make normal unit length
    }
    
    return true;
  }
  
  static boolean RectVsRect( Pair p ) {
    
    Rectangle A = (Rectangle) p.A.shape;
    Rectangle B = (Rectangle) p.B.shape;
    
    PVector Acenter = A.getPos().add(new PVector(A.w/2,A.h/2));
    PVector Bcenter = B.getPos().add(new PVector(B.w/2,B.h/2));
    
    PVector n = Bcenter.sub(Acenter);
    
    //AABB abox = p.A.getShape().getAABB();
    //AABB bbox = p.B.getShape().getAABB();
    
    // Calculate half extents along x axis for each object
    float a_extent = (A.w) / 2;
    float b_extent = (B.w) / 2;
    
    // Calculate overlap on x axis
    float x_overlap = a_extent + b_extent - abs( n.x );
    
    // SAT test on x axis
    if(x_overlap >= 0) {
      // Calculate half extents along y axis for each object
      a_extent = (A.h) / 2;
      b_extent = (B.h) / 2;
    
      // Calculate overlap on y axis
      float y_overlap = a_extent + b_extent - abs( n.y );
      
      // SAT test on y axis
      if(y_overlap >= 0) {
        // Find out which axis is axis of least penetration
        if(x_overlap < y_overlap) {
          // Point towards B knowing that n points from A to B
          if(n.x < 0) {
            p.setNormal( new PVector(-1,0) );
          } else {
            p.setNormal( new PVector(1,0) );
          }
          p.setPenetration(x_overlap);
        } else {
          // Point toward B knowing that n points from A to B
          if(n.y < 0) {
            p.setNormal( new PVector(0,-1) );
          } else {
            p.setNormal( new PVector(0,1) );
          }
          p.setPenetration( y_overlap );
        }
        return true;
      }
    }

    return false;
  }
  
  //static boolean isSeparate(Pair p) {
  //  Rectangle A = (Rectangle) p.A.shape;
  //  Rectangle B = (Rectangle) p.B.shape;
  //  ArrayList<PVector> aCorners = A.getCorners();
  //  ArrayList<PVector> bCorners = B.getCorners();
    
  //  /*
  //    Separating Axis Theorem (SAT) says that if two polygons (2D or 3D) are not overlapping,
  //  then there's a line whose orthogonal complement separates those polygons. It's sufficient
  //  to check the lines parallel to the normals of the sides.
  //  */
  //  ArrayList<PVector> aNormals = getNormals( aCorners );
  //  ArrayList<PVector> bNormals = getNormals( bCorners );
    
  //  float aMax, aMin, bMax, bMin;
  //  float maxPenetration = 0;
  //  PVector normalPenetration = new PVector();
  //  ArrayList<PVector> normals = new ArrayList();
  //  normals.addAll(aNormals);
  //  normals.addAll(bNormals);
    
  //  for(PVector normal: normals) {
  //    // Reset max and mins
  //    aMax = 0;
  //    aMin = 0;
  //    bMax = 0;
  //    bMin = 0;
      
  //    // Find the maximum and minimum projections* onto normal axis
  //    // *Normal is not unit vector, so technically scalar of projections
  //    for(PVector corner: aCorners) {
  //      aMax = max(aMax, corner.dot(normal));
  //      aMin = min(aMin, corner.dot(normal));
  //    }
  //    for(PVector corner: bCorners) {
  //      bMax = max(bMax, corner.dot(normal));
  //      bMin = min(bMin, corner.dot(normal));
  //    }
  //    // If shapes don't overlap (negative penetration) on this axis, shapes are separate
  //    float penetration = max(aMax - bMin, bMax - aMin);
  //    if( penetration < 0 ) {
  //      return true;
  //    }
  //    maxPenetration = max( maxPenetration, penetration);
  //    // Need normal to determine direction of impulse if colliding
  //    if( penetration == maxPenetration ) {
  //      normalPenetration = normal.copy();
  //    }
  //  }
    
  //  // Overlap from all angles, so not separate
  //  float pen = -maxPenetration / (normalPenetration.x*normalPenetration.x + normalPenetration.y*normalPenetration.y);
    
  //  // !!!!!!!!!!!!!!!!!!!! pen or maxPenetration???
  //  p.setPenetration( -maxPenetration );
  //  p.setNormal(normalPenetration.normalize().mult(-1));
    
  //  return false;
  //}

  static ArrayList<PVector> getNormals( ArrayList<PVector> corners ) {
    ArrayList<PVector> normals = new ArrayList();
    int n = corners.size();
    PVector temp;
    
    // Go around the shape and include 
    for(int i=0; i<n-1; i++) {
      // Temp will be tangent to the side
      temp = corners.get(i+1).copy().sub( corners.get(i) );
      // Reversing the coordinates and making one negative will give a normal vector
      normals.add( new PVector(-temp.y, temp.x) );
    }
    // Last side is a special case
    temp = corners.get(0).copy().sub( corners.get(n-1) );
    normals.add( new PVector(-temp.y, temp.x) );
    
    return normals;
  }

  // Used to prevent objects from sinking into one another
  // Someting isn't working right here
  static void positionalCorrection(Pair p) {
    final float percent = 0.2;
    final float slop = 0.01;
    PVector correction = p.getNormal().mult( percent * max(p.getPenetration()-slop, 0.0) / (p.A.massData.invMass + p.B.massData.invMass) );
    
    p.A.setPos( p.A.getPos().sub( correction.copy().mult(p.A.massData.invMass) ) );
    p.B.setPos( p.B.getPos().add( correction.copy().mult(p.B.massData.invMass) ) );
  }
}