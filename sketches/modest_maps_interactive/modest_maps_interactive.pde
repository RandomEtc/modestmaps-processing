InteractiveMap map;

void setup() {
  size(screen.width/2, screen.height/2);
//  smooth(); // REALLY BAD IDEA
  map = new InteractiveMap();
//  map.setCenter(new Coordinate(3165, 1313, 13)); // oakland
  map.setCenterZoom(new Location(37.784393009165576, -122.40649223327637), 18); // san francisco
}

void draw() {
  background(0);
  cursor(CROSS);
  map.draw();
}

void mouseDragged() {
  map.mouseDragged(); 
}
