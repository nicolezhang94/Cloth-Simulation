class Point { //<>//
  public PVector position;
  public PVector velocity;
  public PVector acceleration;
  public Vector<Point> neighbors;
  public float mass;
  public boolean burning;
  int x;
  int y;

  public Point(PVector pos, PVector vel, PVector accel, float m, int xd, int yd) {
    position = pos;
    velocity = vel;
    acceleration = accel;
    mass = m;
    neighbors = new Vector<Point>(2);
    x = xd;
    y = yd;
    burning = false;
  }
}