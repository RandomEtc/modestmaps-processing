
import com.modestmaps.*;

void setup() {
  size(600, 600);
//  runTests();
  noLoop();
}

void draw() {

  MMap m = new MMap(this, new Google.TerrainProvider(), new Point2f(600, 600), new Location(51.5, -0.137), 12);
  PImage img = m.draw(true);

//  img.save("map.png");

  println(img);

  image(img,0,0);  
}
