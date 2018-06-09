import com.modestmaps.*;
import com.modestmaps.core.*;
import com.modestmaps.geo.*;
import com.modestmaps.providers.*;

//
// This is a test of the static Modest Maps library for Processing.
//
// You must have modestmaps in your libraries folder, see INSTALL for details
//
// The tests are useful, and seem to pass.
//
// The Atkinson dithering is fun too, but slow.
//

void setup() {
  size(1280, 720);
  noLoop();
}

void draw() {

  StaticMap m = new StaticMap(this, new Microsoft.RoadProvider(), new Point2f(width, height), new Location(46.086292, 14.478332), 16);
  
  PImage img = m.draw(true);
  image(img,0,0);  

  ellipse(width/2, height/2, 5, 5);

  println("done");
  
}
