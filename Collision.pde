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
  
  static boolean rectVsRect( Pair p ) {
    
    Rectangle A = (Rectangle) p.A.shape;
    Rectangle B = (Rectangle) p.B.shape;
    
    PVector Acenter = A.getCenter();
    PVector Bcenter = B.getCenter();
    
    PVector n = Bcenter.sub(Acenter);
    
    //AABB abox = p.A.getShape().getAABB();
    //AABB bbox = p.B.getShape().getAABB();
    
    // Calculate half extents along x axis for each object
    float aExtent = (A.w) / 2;
    float bExtent = (B.w) / 2;
    
    // Calculate overlap on x axis
    float xOverlap = aExtent + bExtent - abs( n.x );
    
    // SAT test on x axis
    if(xOverlap >= 0) {
      // Calculate half extents along y axis for each object
      aExtent = (A.h) / 2;
      bExtent = (B.h) / 2;
    
      // Calculate overlap on y axis
      float yOverlap = aExtent + bExtent - abs( n.y );
      
      // SAT test on y axis
      if(yOverlap >= 0) {
        // Find out which axis is axis of least penetration
        if(xOverlap < yOverlap) {
          // Point towards B knowing that n points from A to B
          if(n.x < 0) {
            p.setNormal( new PVector(-1,0) );
          } else {
            p.setNormal( new PVector(1,0) );
          }
          p.setPenetration(xOverlap);
        } else {
          // Point toward B knowing that n points from A to B
          if(n.y < 0) {
            p.setNormal( new PVector(0,-1) );
          } else {
            p.setNormal( new PVector(0,1) );
          }
          p.setPenetration( yOverlap );
        }
        return true;
      }
    }

    return false;
  }

  // Never returns false. Need to check if intersection happens
  // Probably has same issue as I had with rectVsRect: Rect position from upper left, not center
  static boolean circleVsRect( Pair p ) {
    
    Body A, B;
    
    // Make sure our A is rectangle and B is circle
    if (p.A.shape.isCircle()) {
      B = p.A;
      A = p.B;
    } else {
      A = p.A;
      B = p.B; 
    }
 
    // Vector from A to B
    PVector n = B.shape.getCenter().sub( A.shape.getCenter() );
   
    // Closest point on A to center of B
    PVector closest = n.copy();
    
    // Calculate half extents along each axis
    float xExtent = (A.shape.getAABB().max.x - A.shape.getAABB().min.x) / 2;
    float yExtent = (A.shape.getAABB().max.y - A.shape.getAABB().min.y) / 2;
    
    // Clamp point to edges of the AABB
    closest.x = constrain( closest.x, -xExtent, xExtent );
    closest.y = constrain( closest.y, -yExtent, yExtent );
    
    boolean inside = false;
    
    // Circle is inside the AABB, so we need to clamp the circle's center
    // to the closest edge
    if(n.equals(closest) )
    {
      inside = true;
   
      // Find closest axis
      if(abs( n.x ) > abs( n.y ))
      {
        // Clamp to closest extent
        if(closest.x > 0)
          closest.x = xExtent;
        else
          closest.x = -xExtent;
      }
   
      // y axis is shorter
      else
      {
        // Clamp to closest extent
        if(closest.y > 0)
          closest.y = yExtent;
        else
          closest.y = -yExtent;
      }
    }
    
    PVector normal = n.copy().sub(closest);
    float d = normal.magSq( );
    Circle bCirc = (Circle) B.shape;
    float r = bCirc.r;
    
    // Early out of the radius is shorter than distance to closest point and
    // Circle not inside the AABB
    if(d > r * r && !inside)
      return false;
   
    // Avoided sqrt until we needed
    d = sqrt( d );
   
    // Collision normal needs to be flipped to point outside if circle was
    // inside the AABB
    if(inside)
    {
      p.setNormal(n.mult(-1).normalize());
    }
    else
    {
      p.setNormal(n.normalize());
    }
    p.setPenetration(r - d);
    
    return true;
  }


  // Used to prevent objects from sinking into one another due to roundoff error
  // Sinking still occurring, so something is wrong here
  static void positionalCorrection(Pair p) {
    final float percent = 0.2;
    final float slop = 0.01;
    
    float aiMass = p.A.massData.invMass;
    float biMass = p.B.massData.invMass;
    
    float scalar = max(p.getPenetration() - slop, 0.0) * percent / (aiMass + biMass);
    PVector correction = p.getNormal().mult( scalar );
    
    p.A.setPos( p.A.getPos().sub( correction.copy().mult(aiMass) ) );
    p.B.setPos( p.B.getPos().add( correction.copy().mult(biMass) ) );
  }
}