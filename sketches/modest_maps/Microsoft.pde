
void doMicrosoftTest() {
  println();
  println("microsoft test");
  println();
  
  AbstractMapProvider p = new RoadProvider();
  String[] urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println( urls[0].startsWith("http://r") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/r0230102122203031.png?g=90&shading=hill") );
  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println( urls[0].startsWith("http://r") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/r0230102033330212.png?g=90&shading=hill") );

  p = new AerialProvider();
  urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println( urls[0].startsWith("http://a") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/a0230102122203031.jpeg?g=90") );
  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println( urls[0].startsWith("http://a") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/a0230102033330212.jpeg?g=90") );

  p = new HybridProvider();
  urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println( urls[0].startsWith("http://h") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/h0230102122203031.jpeg?g=90") );
  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println( urls[0].startsWith("http://h") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/h0230102033330212.jpeg?g=90") );

}



abstract class MicrosoftProvider extends AbstractMapProvider {

  MicrosoftProvider() {
    super(new MercatorProjection(26, new Transformation(1.068070779e7, 0, 3.355443185e7, 0, -1.068070890e7, 3.355443057e7)));
  }

  String getZoomString(Coordinate coordinate) {
    return toMicrosoft( (int)coordinate.column, (int)coordinate.row, (int)coordinate.zoom );
  }

  int tileWidth() {
    return 256;
  }

  int tileHeight() {
    return 256;
  }

  abstract String[] getTileUrls(Coordinate coordinate);

}

class RoadProvider extends MicrosoftProvider {
  String[] getTileUrls(Coordinate coordinate) {
    String url = "http://r" + (int)random(0, 4) + ".ortho.tiles.virtualearth.net/tiles/r" + getZoomString(sourceCoordinate(coordinate)) + ".png?g=90&shading=hill";
    return new String[] { url };
  }
}

class AerialProvider extends MicrosoftProvider {
  String[] getTileUrls(Coordinate coordinate) {
    String url = "http://a" + (int)random(0, 4) + ".ortho.tiles.virtualearth.net/tiles/a" + getZoomString(sourceCoordinate(coordinate)) + ".jpeg?g=90";
    return new String[] { url };
  }
}

class HybridProvider extends MicrosoftProvider {
  String[] getTileUrls(Coordinate coordinate) {
    String url = "http://h" + (int)random(0, 4) + ".ortho.tiles.virtualearth.net/tiles/h" + getZoomString(sourceCoordinate(coordinate)) + ".jpeg?g=90";
    return new String[] { url };
  }
}
