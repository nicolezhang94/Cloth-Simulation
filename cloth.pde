import java.util.Vector; //<>// //<>// //<>// //<>//

Vector<Vector<Point>> points;
int clothHeight = 35;
int clothWidth = 25;
int heightOffset = 100;
float restingDistance = 15;
int widthOffset = 400;
float k = 25;
float damp = .9;
float maxLen = 4;
float dtFactor = 1.5;
float dt = (float)dtFactor/1000;
float elapsedTime;
float currentTime;
PVector gravity = new PVector(0, 250, 0);
int fireIterations;
float drag = -20;
PVector spherePos = new PVector(675, 200, -200);
float radius = 200;

void keyPressed() {
  if (key == 'r') {
    points.clear();
    makePoints();
    addNeighbors();
  } else
    for (Vector<Point> row : points) {
      for (Point p : row) {
        p.acceleration.add(new PVector(0, 0, -0.5));
      }
    }
}

void keyReleased() {
  for (Vector<Point> row : points) {
    for (Point p : row) {
      p.acceleration.z = 0;
    }
  }
}

void setup() {
  size(1200, 900, P3D);
  surface.setTitle("Cheeky M8");
  points = new Vector<Vector<Point>>(clothHeight + 1);
  makePoints();
  addNeighbors();
  currentTime = millis();
}

/*void mouseClicked() {
 for (Vector<Point> row : points) {
 for (Point p : row) {
 if (Math.abs(mouseX - p.position.x) < 4 && Math.abs(mouseY - p.position.y) < 4) {
 p.burning = true;
 }
 }
 }
 }*/

void mouseDragged() {
  for (Vector<Point> row : points) {
    for (Point p : row) {
      if (Math.abs(mouseX - p.position.x) < 10 && Math.abs(mouseY - p.position.y) < 10) {
        if (mouseButton == LEFT)
          p.velocity.add(new PVector(350*(mouseX - pmouseX), 350*(mouseY-pmouseY), 0));
        else
          p.neighbors.clear();
      }
    }
  }
}

void draw() {
  //fireIterations = (fireIterations + 1) % 30001;
  elapsedTime = millis() - currentTime;
  currentTime = millis();
  int iters = (int)(elapsedTime/dtFactor);

  background(0, 0, 0, 255);
  textSize(32);
  stroke(0, 200, 250, 255);
  fill(0, 200, 250, 255);
  text(frameRate, width - 100, 50);
  text("Left click to pull, right click to rip, r to reset, any key for wind.", 125, height - 32);

  pushMatrix();
  translate(spherePos.x, spherePos.y, spherePos.z);
  sphere(radius);
  popMatrix();

  for (int k = 0; k < iters; k++) {
    doPhysics();
    stroke(255, 255, 255, 255);
    noFill();
    for (Vector<Point> row : points) {
      for (Point p : row) {
        for (Point p1 : p.neighbors) {
          line(p.position.x, p.position.y, p1.position.x, p1.position.y);
        }
      }
    }
  }
}

void doPhysics() {
  PVector e;
  float len, v1, v2, f, k1;
  Point p, p0, p1, p2, p3;
  float rest;
  boolean isDiag;
  Vector<Point> toRemove = new Vector<Point>(3);

  for (int i = 0; i <= clothHeight; i++) {
    for (int j = 0; j <= clothWidth; j++) {
      p0 = points.get(i).get(j);
      for (Point pt : p0.neighbors) {
        //isDiag = (abs(p.x - p1.x) + abs(p.y - p1.y) < 2);
        //k1 = isDiag ? k/8 : k;
        //rest = isDiag ? (float)restingDistance : restingDistance * (float)Math.pow(2, .5);
        e = PVector.sub(pt.position, p0.position); 
        len = (float)Math.sqrt(e.dot(e)); 
        e.normalize(); 
        v1 = e.dot(p0.velocity); 
        v2 = e.dot(pt.velocity); 
        f = -k * (restingDistance - len) - damp * (v1-v2); 

        p0.velocity.add(PVector.mult(p0.acceleration, dt));
        pt.velocity.add(PVector.mult(pt.acceleration, dt)); 
        p0.velocity.add(PVector.mult(e, f)); 
        pt.velocity.sub(PVector.mult(e, f));

        if (len > restingDistance * maxLen)
          toRemove.add(pt);
      }



      for (Point rem : toRemove) {
        p0.neighbors.remove(rem);
      }
      toRemove.clear();
    }
  }

  for (int i = 0; i <= clothHeight; i++) {
    points.get(i).get(0).velocity.mult(0);
  }

  PVector n, velAvg, dragF; 
/*
  for (int i = 0; i < clothHeight; i++) {
    for (int j = 0; j < clothWidth; j++) {
      p = points.get(i).get(j);
      p1 = points.get(i).get(j+1);
      p2 = points.get(i+1).get(j+1);
      p3 = points.get(i+1).get(j);
      velAvg = PVector.div(PVector.add(p.velocity, PVector.add(p1.velocity, PVector.add(p2.velocity, p3.velocity))), 4);
      n = PVector.sub(p1.position, p.position).cross(PVector.sub(p2.position, p.position)).normalize();
      dragF = PVector.mult(n, drag * (PVector.dot(velAvg, n) * velAvg.mag()) / (2 * n.mag()));
      dragF.div(4).mult(dt);
      p.acceleration.add(PVector.div(dragF, p.mass)); //<>//
      p1.acceleration.add(PVector.div(dragF, p1.mass));
      p2.acceleration.add(PVector.div(dragF, p2.mass));
      p3.acceleration.add(PVector.div(dragF, p3.mass));
    }
  }
  */

  PVector norm;
  for (int i = 0; i <= clothHeight; i++) {
    for (int j = 0; j <= clothWidth; j++) {

      p = points.get(i).get(j);
      p.position.add(PVector.mult(p.velocity, dt));
      if(PVector.dist(p.position, spherePos) < radius){
        norm = PVector.sub(p.position, spherePos).normalize();
        p.position = PVector.add(spherePos, PVector.mult(norm, radius));
        p.velocity.sub(PVector.mult(norm, p.velocity.dot(norm)));
      }
    }
  }
}

void makePoints() {
  for (int i = 0; i <= clothHeight; i++) {
    Vector<Point> row = new Vector<Point>();
    for (int j = 0; j <= clothWidth; j++) {
      Point p = new Point(new PVector(widthOffset + i*restingDistance, j* restingDistance + heightOffset, 0), new PVector(0, 100, 100), gravity, 1, i, j);
      row.add(p);
    }
    points.add(row);
  }
}

void addNeighbors() {
  Point p;
  Point p2;
  for (int i = 0; i <= clothHeight; i++) {
    for (int j = 0; j <= clothWidth; j++) {
      p = points.get(i).get(j);

      if (i != clothHeight) {
        p2 = points.get(i + 1).get(j);
        p.neighbors.add(p2);
      }

      if (j != clothWidth) {
        p2 = points.get(i).get(j+1);
        p.neighbors.add(p2);
      }
      /*
      if (i != clothHeight && j != clothWidth) {
       p2 = points.get(i+1).get(j+1);
       p.neighbors.add(p2);
       }
       
       if (i != 0 && j != clothWidth) {
       p2 = points.get(i-1).get(j+1);
       p.neighbors.add(p2);
       }*/
    }
  }
}

void burn(Point p) {
  if (p.x < 1 || p.x > clothWidth - 1 || p.y < 1 || p.y > clothHeight - 2) {
    return;
  }
  points.get(p.x - 1).get(p.y).burning = true;
  points.get(p.x + 1).get(p.y).burning = true;
  points.get(p.x).get(p.y - 1).burning = true;
  points.get(p.x).get(p.y + 1).burning = true;
}