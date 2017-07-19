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
PImage img; // Background image
int fowlX, fowlY, catX, catY;
boolean onFowl = false;
boolean locked = false;
boolean released = false;

void setup() { //<>//
  size(1000,500);
  frameRate(30);
  dt = 1.0/frameRate;
  
  // Accumulator will hold dt error to ensure steady motion regardless of framerate
  accumulator = 0;
  frameStart = 0;
  gravity = 0.03;
  
  img = loadImage("sky.png"); // Load background image
  catX = width/5;
  catY = 3*height/4;
  fowlX = catX;
  fowlY = catY;
  
  rectMode(CENTER); // Processing uses center of rectangles instead of upper left corner  
  
  myBodies = new ArrayList<Body>(); // ArrayList of objects that will be moving on screen
  myBP = new BroadPhase();
}


void draw() { //<>//
  background(255);
  
  image(img, 0, 0, width, height);
  
  drawInstructions();
  drawCatapult();
  
  if(!released) {
    fill(255,0,0);
    stroke(0);
    strokeWeight(1);
    ellipse(fowlX, fowlY, 40, 40);
    strokeWeight(10);
    line(catX, catY, fowlX, fowlY);
  }
  
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


void drawInstructions() {
  fill(0);
  text("'0' = clear", 10, 30);
  text("Click on fowl, hold and pull back", 10, 45); 
  text("'c' = spray of circles", 10, 60); 
  text("'r' = spray of rectangles", 10, 75);
  text("'f' = castle", 10, 90);
}

void drawCatapult() {
  fill(102,51,0); // Brown
  noStroke();
  pushMatrix();
    translate(width/5, 9*height/10);
    rect(0, 0, 20, 100);
    translate(0, -50);
    rotate(11*PI/6);
    rect(0, -20, 20, 50);
    rotate(PI/3);
    rect(0, -20, 20, 50);
  popMatrix();
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


void mousePressed() {
  if( (mouseX-fowlX)*(mouseX-fowlX) + (mouseY-fowlY)*(mouseY-fowlY) <= 160 )
    onFowl = true;
  else
    onFowl = false;
  
  if( (mouseX-catX)*(mouseX-catX) + (mouseY-catY)*(mouseY-catY) <= 160 ) {
    locked = true;
  }
}

void mouseReleased() {
  if(onFowl) {
    Body fowl = new Body(new Circle(20, fowlX, fowlY), gravity, new PVector(0, 0) );
    fowl.addToVelocity( new PVector(mouseX-catX, mouseY-catY).mult(-1.0/20) );
    myBodies.add( fowl );
  }
  
  onFowl = false;
  locked = false;
  released = false;
  fowlX = catX;
  fowlY = catY;
}

void mouseDragged() {
  if(locked) {
    fowlX = mouseX;
    fowlY = mouseY;
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
    myBodies.add( new Body(new Rectangle(20, 40, 9*width / 10 - 20, 9*height/10), gravity, new PVector(0, 0) ) );
    myBodies.add( new Body(new Rectangle(20, 40, 9*width / 10 + 20, 9*height/10), gravity, new PVector(0, 0) ) );
    myBodies.add( new Body(new Rectangle(60, 20, 9*width / 10, 8*height/10), gravity, new PVector(0, 0) ) );
    // Tier 2
    myBodies.add( new Body(new Rectangle(20, 40, 9*width / 10 - 20, 7*height/10), gravity, new PVector(0, 0) ) );
    myBodies.add( new Body(new Rectangle(20, 40, 9*width / 10 + 20, 7*height/10), gravity, new PVector(0, 0) ) );
    myBodies.add( new Body(new Rectangle(60, 20, 9*width / 10, 6*height/10), gravity, new PVector(0, 0) ) );
  }
  
}