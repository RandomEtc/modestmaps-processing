package com.modestmaps;

import processing.core.*;

public class Microsoft {

  public static abstract class MicrosoftProvider extends AbstractMapProvider {

    public MicrosoftProvider() {
      super(new MercatorProjection(26, new Transformation(1.068070779e7f, 0.0f, 3.355443185e7f, 0.0f, -1.068070890e7f, 3.355443057e7f)));
    }

    public String getZoomString(Coordinate coordinate) {
      return Tiles.toMicrosoft( (int)coordinate.column, (int)coordinate.row, (int)coordinate.zoom );
    }

    public int tileWidth() {
      return 256;
    }

    public int tileHeight() {
      return 256;
    }

    public abstract String[] getTileUrls(Coordinate coordinate);

  }

  public static class RoadProvider extends MicrosoftProvider {
    public String[] getTileUrls(Coordinate coordinate) {
      String url = "http://r" + (int)random(0, 4) + ".ortho.tiles.virtualearth.net/tiles/r" + getZoomString(sourceCoordinate(coordinate)) + ".png?g=90&shading=hill";
      return new String[] { 
        url       };
    }
  }

  public static class AerialProvider extends MicrosoftProvider {
    public String[] getTileUrls(Coordinate coordinate) {
      String url = "http://a" + (int)random(0, 4) + ".ortho.tiles.virtualearth.net/tiles/a" + getZoomString(sourceCoordinate(coordinate)) + ".jpeg?g=90";
      return new String[] { 
        url       };
    }
  }

  public static class HybridProvider extends MicrosoftProvider {
    public String[] getTileUrls(Coordinate coordinate) {
      String url = "http://h" + (int)random(0, 4) + ".ortho.tiles.virtualearth.net/tiles/h" + getZoomString(sourceCoordinate(coordinate)) + ".jpeg?g=90";
      return new String[] { 
        url       };
    }
  }

}
