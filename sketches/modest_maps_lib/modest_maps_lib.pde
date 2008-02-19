
//
// This is a test of the static Modest Maps library for Processing
// the modestmaps.jar in the code folder of this sketch might not be 
// entirely up to date - you have been warned!
//
// The tests are useful, and seem to pass.
//
// The Atkinson dithering is fun too, but slow.
//

void setup() {
  size(screen.width/2, screen.height/2);
  if (!runTests(false)) {
    println("one or more tests failed");
    exit();
  }
  noLoop();
}

void draw() {

  StaticMap m = new StaticMap(this, new Microsoft.AerialProvider(), new Point2f(width/2, height/2), new Location(51.5, -0.137), 12);
  
  PImage img = m.draw(true);

//  img.save("data/map.png");

//  PImage img = loadImage("map.png");

//  img = atkinsonDither(img);

//  img.save("data/dither.png");
  
//  println("done");

  image(img,0,0);  
}
