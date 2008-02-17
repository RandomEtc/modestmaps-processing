
void setup() {
  size(screen.width, screen.height);
  if (!runTests(false)) {
    println("one or more tests failed");
    exit();
  }
  noLoop();
}

void draw() {

  MMap m = new MMap(this, new Microsoft.AerialProvider(), new Point2f(width*2, height*2), new Location(51.5, -0.137), 12);
  
//  PImage img = m.draw(true);

//  img.save("data/map.png");

  PImage img = loadImage("map.png");

  img = atkinsonDither(img);

  img.save("data/dither.png");
  
  println("done");

//  image(img,0,0);  
}
