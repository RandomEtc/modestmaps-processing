
void setup() {
  size(600, 600);
  if (!runTests(false)) {
    println("one or more tests failed");
    exit();
  }
  noLoop();
}

void draw() {

  MMap m = new MMap(this, new Microsoft.HybridProvider(), new Point2f(600, 600), new Location(51.5, -0.137), 3);
  PImage img = m.draw(true);

  img.save("map.png");

  image(img,0,0);  
}
