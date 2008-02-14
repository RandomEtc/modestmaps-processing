
void doGoogleTest() {

  println();
  println("google test");
  println();

  AbstractMapProvider p = new GoogleRoadProvider();
  String[] urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println(urls);
  println( urls[0].startsWith("http://mt") && urls[0].endsWith("&x=10507&y=25322&zoom=1") ); //('....google.com/mt?n=404&v=...',)

  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println( urls[0].startsWith("http://mt") && urls[0].endsWith("&x=10482&y=25333&zoom=1") ); //('....google.com/mt?n=404&v=...',)

  p = new GoogleAerialProvider();
  urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println( urls[0].startsWith("http://kh") && urls[0].endsWith("&t=tqtsqrqtrtttqsqsr") ); //google.com/kh?n=404&v=

  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println( urls[0].startsWith("http://kh") && urls[0].endsWith("&t=tqtsqrqtqssssqtrt") ); //google.com/kh?n=404&v=

  p = new GoogleHybridProvider();
  urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println(urls);
  println( urls[0].startsWith("http://kh") && urls[0].endsWith("&t=tqtsqrqtrtttqsqsr") ); //google.com/kh?n=404&v=
  println( urls[1].startsWith("http://mt") && urls[1].endsWith("&x=10507&y=25322&zoom=1") ); //google.com/mt?n=404&v=

  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println(urls);
  println( urls[0].startsWith("http://kh") && urls[0].endsWith("&t=tqtsqrqtqssssqtrt") ); //google.com/kh?n=404&v=
  println( urls[1].startsWith("http://mt") && urls[1].endsWith("&x=10482&y=25333&zoom=1") ); //google.com/mt?n=404&v=
}

abstract class GoogleProvider extends AbstractMapProvider{

  String ROAD_VERSION = "w2.66";
  String AERIAL_VERSION = "24";
  String HYBRID_VERSION = "w2t.66";
  String TERRAIN_VERSION = "w2p.64";

  GoogleProvider() {
    super( new MercatorProjection(26, new Transformation(1.068070779e7, 0, 3.355443185e7, 0, -1.068070890e7, 3.355443057e7) ) );
  }

  abstract String getZoomString(Coordinate coordinate);

  int tileWidth() {
    return 256;
  }

  int tileHeight() {
    return 256;
  }

}

class GoogleRoadProvider extends GoogleProvider {
  String[] getTileUrls(Coordinate coordinate) {
    String url = "http://mt" + (int)random(0, 4) + ".google.com/mt?n=404&v=" + ROAD_VERSION + "&" + getZoomString(sourceCoordinate(coordinate));
    return new String[] { 
      url                     };
  }   
  String getZoomString(Coordinate coordinate) {
    Coordinate coord = toGoogleRoad(coordinate.container());
    return "x=" + (int)coord.column + "&y=" + (int)coord.row + "&zoom=" + (int)coord.zoom;
  }
}

class GoogleAerialProvider extends GoogleProvider {
  String[] getTileUrls(Coordinate coordinate) {
    String url = "http://kh" + (int)random(0, 4) + ".google.com/kh?n=404&v=" + AERIAL_VERSION + "&t=" + getZoomString(sourceCoordinate(coordinate));
    return new String[] { 
      url                 };
  }
  String getZoomString(Coordinate coordinate) {
    return toGoogleAerial(coordinate.container());
  }
}

class GoogleHybridProvider extends GoogleProvider {
  String[] getTileUrls(Coordinate coordinate) {
    String under = new GoogleAerialProvider().getTileUrls(coordinate)[0];
    String over = "http://mt" + (int)random(0, 4) + ".google.com/mt?n=404&v=" + HYBRID_VERSION + "&" + getZoomString(sourceCoordinate(coordinate));
    return new String[] { 
      under, over         };
  }
  String getZoomString(Coordinate coordinate) {
    Coordinate coord = toGoogleRoad(coordinate.container());
    return "x=" + (int)coord.column + "&y=" + (int)coord.row + "&zoom=" + (int)coord.zoom;
  }
}

class GoogleTerrainProvider extends GoogleRoadProvider {
  String[] getTileUrls(Coordinate coordinate) {
    String url = "http://mt" + (int)random(0, 4) + ".google.com/mt?n=404&v=" + TERRAIN_VERSION + "&" + getZoomString(sourceCoordinate(coordinate));
    return new String[] { 
      url     };
  }
}
