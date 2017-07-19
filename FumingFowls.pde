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
  // Accumulator will hold dt error to ensure steady motion regardless of framerate
  accumulator = 0;
  frameStart = 0;
  gravity = 0.03;
  
  rectMode(CENTER); // Processing uses center of rectangles instead of upper left corner  
  
  myBodies = new ArrayList<Body>();
  myBP = new BroadPhase();
}


void draw() { //<>//
  background(255);
  // Instructions
  fill(0);
  text("'0' = clear", 10, 30);
  text("left click = circle", 10, 45); 
  text("right click = rectangle", 10, 60); 
  text("'c' = spray of circles", 10, 75); 
  text("'r' = spray of rectangles", 10, 90);
  text("'f' = castle", 10, 105);
  
  rect(width/2, 19*height/20, width, height/10);
  
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
        // If AABB intersect, add to broadphase array
        if( myBP.AABBtoAABB(body1, body2) ) {
          Pair p = new Pair(body1, body2);
          
          // TODO Make positionalCorrection work properly
          //Collision.positionalCorrection(p);
          myBP.bpPairs.add( p );
        }
      }
    }
  }
  

  // check and resolve collisions
  for(Pair pair: myBP.bpPairs) {
    boolean aCircle = pair.A.shape.isCircle();
    boolean bCircle = pair.B.shape.isCircle();
    
    if( aCircle && bCircle) {
      if(Collision.circleVsCircle(pair)) Collision.resolveCollision(pair);
    }
    else if( !aCircle && !bCircle) {
      if(Collision.rectVsRect(pair)) Collision.resolveCollision(pair);
    }
    else if( (!aCircle && bCircle) || (aCircle && !bCircle) ) {
      if(Collision.circleVsRect(pair)) Collision.resolveCollision(pair);
    }
    
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
    myBodies.add( new Body(new Circle(int(r), mouseX, mouseY),
                      gravity, new PVector(random(-.5,.5),random(-.5)) ) );
  }
  if(mouseButton == RIGHT) {
    myBodies.add( new Body(new Rectangle(20, 30, mouseX, mouseY),
                      gravity, new PVector(random(-.5,.5),random(-.5)) ) );
  }
}

void keyPressed() {
  if(key == '0') {
    // Clear objects from screen
    myBodies.clear();
  }
  else if(key == 'r') {
    // Initial "spray" of rectangles
    for(int i=0; i<10; i++) {
      myBodies.add( new Body(new Rectangle((int) random(20,30), (int) random(20,30)),
                             gravity, new PVector(random(-.5,.5),random(-.5)) ) );
    }
  }
  else if(key == 'c') {
     //Initial "spray" of circles
    for(int i=0; i<10; i++) {
      myBodies.add( new Body(new Circle((int) random(5,15)), gravity, new PVector(random(-.5,.5),random(-.5)) ) );
    }    
  }
  else if(key == '1') {
    // Reset test case 1
    myBodies.add( new Body(new Rectangle(40, 100, width / 2, height), gravity, new PVector(0, -4) ) );
    myBodies.add( new Body(new Circle(30, width / 2 - 20, 0), gravity, new PVector(0, 0) ) );  
  }
  else if(key == '2') {
    // Reset test case 1
    myBodies.add( new Body(new Rectangle(40, 40, width / 2, 0), gravity, new PVector(0, 0) ) );
    myBodies.add( new Body(new Circle(30, width / 2 + 20, 9*height/10), gravity, new PVector(0, -4) ) );  
  }
  else if(key == 'f') {
    // Fuming Fowl Castle
    // Tier 1
    myBodies.add( new Body(new Rectangle(20, 40, width / 2 - 20, 9*height/10), gravity, new PVector(0, 0) ) );
    myBodies.add( new Body(new Rectangle(20, 40, width / 2 + 20, 9*height/10), gravity, new PVector(0, 0) ) );
    myBodies.add( new Body(new Rectangle(60, 20, width / 2, 8*height/10), gravity, new PVector(0, 0) ) );
    // Tier 2
    myBodies.add( new Body(new Rectangle(20, 40, width / 2 - 20, 7*height/10), gravity, new PVector(0, 0) ) );
    myBodies.add( new Body(new Rectangle(20, 40, width / 2 + 20, 7*height/10), gravity, new PVector(0, 0) ) );
    myBodies.add( new Body(new Rectangle(60, 20, width / 2, 6*height/10), gravity, new PVector(0, 0) ) );
  }
  
}