
void setup() {
  size(600, 600);
  runTests();
  noLoop();
}

void draw() {

//  Map m = new Map(new GoogleRoadProvider(), new Point(600, 600), new Coordinate(3165, 1313, 13), new Point(-144, -94));
  Map m = new Map(new GoogleTerrainProvider(), new Point(600, 600), new Location(51.5, -0.137), 12);
  PImage img = m.draw(true);

  img.save("map.png");

  println(img);

  image(img,0,0);
}

void runTests() {
  doTilesTest();
  doMicrosoftTest();
  doGoogleTest();
  doGeoTest();
  doCoreTest();
  doMapTest();  
}

