import beads.*;
AudioContext ac;

Flock flock;

void setup() {
  size(1500, 750);
  ac = new AudioContext();
  flock = new Flock();
  ac.start();
}

void draw() {
  background(50);
  flock.run();
}

// Add a new boid into the System
void mousePressed() {
  flock.addBoid(new Boid(this, mouseX, mouseY));
}

// The Flock (a list of Boid objects)
class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }
}

class Boid {
  // Beads
  Reverb reverb;
  Panner pan;
  Glide xPos;
  Gain synthGain;
  SamplePlayer wing;

  int trigger_ms = millis();
  int duration_ms = 4000;

  // Physics
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Boid(PApplet parent, float x, float y) {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    velocity.x *= random(.4)+.8;
    velocity.y *= random(.4)+.8;

    position = new PVector(x, y);
    r = 2.0;
    maxspeed = 2;
    maxforce = 0.03;

    try {
      String sourceFile = sketchPath("") + "wing.wav";
      wing = new SamplePlayer(ac, new Sample(sourceFile));
    }
    catch(Exception e) {
      println("Exception while attempting to load sample!");
      e.printStackTrace();
      exit();
    }
    wing.setKillOnEnd(false);

    reverb = new Reverb(ac, 1);
    reverb.setSize(0.7);
    reverb.setDamping(0.9);
    reverb.setEarlyReflectionsLevel(.1);
    reverb.setLateReverbLevel(.9);
    synthGain = new Gain(ac, 1, .8);
    xPos = new Glide(ac, position.x, 50);
    pan = new Panner(ac, xPos);
    pan.addInput(wing);
    synthGain.addInput(pan);
    reverb.addInput(synthGain);
    ac.out.addInput(reverb);
    ac.out.addInput(synthGain);
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  void articulate() {
    if (millis() > trigger_ms) {
      wing.setToLoopStart();
      wing.start();
      trigger_ms = millis() + ((int)(random(2)*1000)) + 3000;
    }
  }

  // Called in draw().
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
    float amp;
    if (position.x < width/2.0) {
      amp = map(position.x, 0, width/2.0, .2, .95);
    } else {
      amp = map(position.x, width/2.0, width, .95, .2);
    }
    xPos.setValue(-1. + 2.*position.x/width);
    //wave.amp(amp); // Note: Setting the amplitude here messes with articulate() and maybe makes things choppy.
    articulate();
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up

    fill(200, 100);
    stroke(255);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  // What to do at the edges.
  void borders() {
    reflectBorders();
  }

  void reflectBorders() {
    if (position.x+velocity.x < -r || position.x+velocity.x > width+r) velocity.x*=-1;
    if (position.y+velocity.y < -r || position.y+velocity.y > height+r) velocity.y *=-1;
  }

  void wrapBorders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } else {
      return new PVector(0, 0);
    }
  }
}
