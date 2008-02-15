
package com.modestmaps;

import processing.core.*;

public class Google {
  
  public static abstract class GoogleProvider extends AbstractMapProvider {
  
    public static final String ROAD_VERSION = "w2.66";
    public static final String AERIAL_VERSION = "24";
    public static final String HYBRID_VERSION = "w2t.66";
    public static final String TERRAIN_VERSION = "w2p.64";
  
    public GoogleProvider() {
      super( new MercatorProjection(26, new Transformation(1.068070779e7f, 0.0f, 3.355443185e7f, 0.0f, -1.068070890e7f, 3.355443057e7f) ) );
    }
  
    abstract String getZoomString(Coordinate coordinate);
  
    public int tileWidth() {
      return 256;
    }
  
    public int tileHeight() {
      return 256;
    }
  
  }
  
  public static class RoadProvider extends GoogleProvider {
    public String[] getTileUrls(Coordinate coordinate) {
      String url = "http://mt" + (int)random(0, 4) + ".google.com/mt?n=404&v=" + ROAD_VERSION + "&" + getZoomString(sourceCoordinate(coordinate));
      return new String[] { url };
    }   
    public String getZoomString(Coordinate coordinate) {
      Coordinate coord = Tiles.toGoogleRoad(coordinate.container());
      return "x=" + (int)coord.column + "&y=" + (int)coord.row + "&zoom=" + (int)coord.zoom;
    }
  }
  
  public static class AerialProvider extends GoogleProvider {
    public String[] getTileUrls(Coordinate coordinate) {
      String url = "http://kh" + (int)random(0, 4) + ".google.com/kh?n=404&v=" + AERIAL_VERSION + "&t=" + getZoomString(sourceCoordinate(coordinate));
      return new String[] { url };
    }
    public String getZoomString(Coordinate coordinate) {
      return Tiles.toGoogleAerial(coordinate.container());
    }
  }
  
  public static class HybridProvider extends GoogleProvider {
    public String[] getTileUrls(Coordinate coordinate) {
      String under = new AerialProvider().getTileUrls(coordinate)[0];
      String over = "http://mt" + (int)random(0, 4) + ".google.com/mt?n=404&v=" + HYBRID_VERSION + "&" + getZoomString(sourceCoordinate(coordinate));
      return new String[] { under, over };
    }
    public String getZoomString(Coordinate coordinate) {
      Coordinate coord = Tiles.toGoogleRoad(coordinate.container());
      return "x=" + (int)coord.column + "&y=" + (int)coord.row + "&zoom=" + (int)coord.zoom;
    }
  }
  
  public static class TerrainProvider extends RoadProvider {
    public String[] getTileUrls(Coordinate coordinate) {
      String url = "http://mt" + (int)random(0, 4) + ".google.com/mt?n=404&v=" + TERRAIN_VERSION + "&" + getZoomString(sourceCoordinate(coordinate));
      return new String[] { url };
    }
  }

}