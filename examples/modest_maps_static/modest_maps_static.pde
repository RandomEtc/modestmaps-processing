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
  if (!runTests(false)) {    
    println("one or more tests failed");    
    exit();    
  }    
   noLoop();
 }
      
 void draw() {
  StaticMap m = new StaticMap(this, new Microsoft.AerialProvider(), new Point2f(width/2, height), new Location(51.5, -0.137), 12);
          
   PImage img = m.draw(true);
   image(img,0,0);
      
  img = atkinsonDither(img);
  image(img,width/2,0);      
      
   println("done");
 }
