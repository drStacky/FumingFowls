/*
*  A place to implement and play with a physics engine.
*  Tutorial at https://gamedevelopment.tutsplus.com/series/how-to-create-a-custom-physics-engine--gamedev-
*
*  My goal is to eventually implement an "Angry Birds" knock-off.
*
*  author: Matt Stackpole
*  date: 5/3/2017
*/

int fr; // frame rate
float dt; // delta time
int accumulator, frameStart;
ArrayList<Body> myBodies; // Hold all bodies on screen
BroadPhase myBP; // first pass check for collisions
Body body1, body2; // temp bodies for broad phase check
float gravity;


void setup() { //<>//
  size(500,500);
  frameRate(30);
  dt = 1.0/frameRate;
  // Accumulator will hold roundoff error to ensure steady motion regardless of framerate
  accumulator = 0;
  frameStart = 0;
  gravity = 0.0;
  
  myBodies = new ArrayList<Body>();
  // Initial Circle
  //// Note that gravity is in the positive y direction because that is down on the screen
  //for(int i=0; i<10; i++) {
  //  myBodies.add( new Body(new Circle(), gravity, new PVe      qwwetrtyuiop[p]0\ctor(random(-5,5),random(-5)) ) );
  //}
  
  //// Initial rectangles
  //for(int i=0; i<10; i++) {
  //  myBodies.add( new Body(new Rectangle((int) random(20,30), (int) random(20,30)),
  //                         gravity, new PVector(random(-5,5),random(-5)) ) );
  //}
  
  myBodies.add( new Body(new Rectangle(40, 40, 0, height/4),
                         gravity, new PVector(3,0) ) );

  myBodies.add( new Body(new Rectangle(60, 60, width, height/4-10),
                         gravity, new PVector(-2,0) ) );
  
  myBP = new BroadPhase();
}


void draw() { //<>//
  background(255);
  accumulator += millis() - frameStart;
  frameStart = millis();
  
  // In case can't keep up with animation, clamp accumlator to avoid spiral of death
  if( accumulator > 200) accumulator = 200;
  
  // This loop will ensure motion is constant regardless of frame rate
  while (accumulator > dt) {
    resolveImpulses();
  }
  
  render();
}





void resolveImpulses() {
  // Get ready to detect new collisions
  myBP.bpPairs.clear();

  // Move everything one timestep
  for(Body body: myBodies) {
    body.update(dt);
  }

  // Check to see if AABB overlap
  for(int i=0; i<myBodies.size(); i++) {
    body1 = myBodies.get(i);
    for(int j=i+1; j<myBodies.size(); j++) {
      body2 = myBodies.get(j);
      if( !body1.equals(body2) ) {
        if( myBP.AABBtoAABB(body1, body2) ) {
          myBP.bpPairs.add( new Pair(body1, body2) );
        }
      }
    }
  }
  
  // check and resolve collisions
  for(Pair pair: myBP.bpPairs) {
    if( pair.A.shape.isCircle() && pair.B.shape.isCircle()) {
      Collision.circleVsCircle(pair);
    }
    if( pair.A.shape.isRectangle() && pair.B.shape.isRectangle()) {
      Collision.RectVsRect(pair);
    }
    
    Collision.resolveCollision(pair);
  }
  
  // Move forward one time step
  accumulator -= dt;
}



// Tutorial discusses linear interpolation to avoid jitter when accumulator not 0.
// I haven't implemented this yet. Requires having current position and last position saved as shape parameters.
void render() {
  for(Body body: myBodies) {
    body.shape.render();
  }
}


// Add new objects with random velocity at mouse location
void mousePressed() {
  if(mouseButton == LEFT) {
    float r = random(5,15);
    myBodies.add( new Body(new Circle(mouseX, mouseY, int(r)),
                      gravity, new PVector(random(-5,5),random(-5)) ) );
  }
  if(mouseButton == RIGHT) {
    myBodies.add( new Body(new Rectangle(20, 30, mouseX, mouseY),
                      gravity, new PVector(random(-5,5),random(-5)) ) );
  }
}