
package com.modestmaps.providers;

import processing.core.*;
import com.modestmaps.core.*;
import com.modestmaps.geo.*;

public class Google {
  
  public static abstract class GoogleProvider extends AbstractMapProvider {
  
    public static final String ROAD_VERSION = "w2.83";
    public static final String AERIAL_VERSION = "32";
    public static final String HYBRID_VERSION = "w2t.83";
    public static final String TERRAIN_VERSION = "app.81";
  
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
      // TODO: http://mt1.google.com/mt?v=w2.83&hl=en&x=10513&s=&y=25304&z=16&s=Gal
      String url = "http://mt" + (int)random(0, 4) + ".google.com/mt?n=404&v=" + ROAD_VERSION + "&" + getZoomString(sourceCoordinate(coordinate));
      return new String[] { url };
    }   
    public String getZoomString(Coordinate coordinate) {
      Coordinate coord = toGoogleRoad(coordinate.container());
      return "x=" + (int)coord.column + "&y=" + (int)coord.row + "&zoom=" + (int)coord.zoom;
    }
  }
  
  public static class AerialProvider extends GoogleProvider {
    public String[] getTileUrls(Coordinate coordinate) {
      // TODO: http://khm1.google.com/kh?v=32&hl=en&x=10513&s=&y=25304&z=16&s=Gal
      String url = "http://kh" + (int)random(0, 4) + ".google.com/kh?n=404&v=" + AERIAL_VERSION + "&t=" + getZoomString(sourceCoordinate(coordinate));
      return new String[] { url };
    }
    public String getZoomString(Coordinate coordinate) {
      return toGoogleAerial(coordinate.container());
    }
  }
  
  public static class HybridProvider extends GoogleProvider {
    public String[] getTileUrls(Coordinate coordinate) {
      // TODO: http://mt0.google.com/mt?v=w2t.83&hl=en&x=10510&s=&y=25303&z=16&s=G
      String under = new AerialProvider().getTileUrls(coordinate)[0];
      String over = "http://mt" + (int)random(0, 4) + ".google.com/mt?n=404&v=" + HYBRID_VERSION + "&" + getZoomString(sourceCoordinate(coordinate));
      return new String[] { under, over };
    }
    public String getZoomString(Coordinate coordinate) {
      Coordinate coord = toGoogleRoad(coordinate.container());
      return "x=" + (int)coord.column + "&y=" + (int)coord.row + "&zoom=" + (int)coord.zoom;
    }
  }
  
  public static class TerrainProvider extends RoadProvider {
    public String[] getTileUrls(Coordinate coordinate) {
      // TODO: http://mt1.google.com/mt?v=app.81&hl=en&x=5255&s=&y=12651&z=15&s=
      String url = "http://mt" + (int)random(0, 4) + ".google.com/mt?n=404&v=" + TERRAIN_VERSION + "&" + getZoomString(sourceCoordinate(coordinate));
      return new String[] { url };
    }
  }
  
  public static Coordinate fromGoogleRoad(Coordinate coord) {
    // Return column, row, zoom for Google Road tile x, y, z.
    return new Coordinate(coord.row, coord.column, 17 - coord.zoom);
  }
  
  public static Coordinate toGoogleRoad(Coordinate coord) {
    // Return x, y, z for Google Road tile column, row, zoom.
    return new Coordinate(coord.row, coord.column, 17 - coord.zoom);
  }
  
  public static Coordinate fromGoogleAerial(String s) {
    // Return column, row, zoom for Google Aerial tile string.
    String rowS = "";
    String colS = "";
    for (int i = 0; i < s.length(); i++) {
      switch (s.charAt(i)) {
      case 't':
        rowS += '0';
        colS += '0';
        break;
      case 's':
        rowS += '0';
        colS += '1';
        break;
      case 'q':
        rowS += '1';
        colS += '0';
        break;
      case 'r':
        rowS += '1';
        colS += '1';
        break;
      }
    }
    int row = PApplet.unbinary(rowS);
    int col = PApplet.unbinary(colS);
    int zoom = s.length() - 1;
    row = (int)PApplet.pow(2, zoom) - row - 1;
    return new Coordinate( row, col, zoom );
  }
  
  public static String toGoogleAerial(Coordinate coord) {
    // Return string for Google Road tile column, row, zoom.
    int x = (int)coord.column;
    int y = (int)PApplet.pow(2, coord.zoom) - (int)coord.row - 1;
    int z = (int)coord.zoom + 1;
    String yb = PApplet.binary(y,z);
    String xb = PApplet.binary(x,z);
    String string = "";
    String googleToCorners = "tsqr";
    for (int c = 0; c < z; c++) {
      string += googleToCorners.charAt(PApplet.unbinary("" + yb.charAt(c) + xb.charAt(c)));
    }
    return string;
  }

  

}