package com.modestmaps;

import processing.core.*;

/*
def fromYahoo(x, y, z) {
 """ Return column, row, zoom for Yahoo x, y, z.
 """
 zoom = 18 - z
 row = int(math.pow(2, zoom - 1) - y - 1)
 col = x
 return col, row, zoom
 
 def toYahoo(col, row, zoom) {
 """ Return x, y, z for Yahoo tile column, row, zoom.
 """
 x = col
 y = int(math.pow(2, zoom - 1) - row - 1)
 z = 18 - zoom
 return x, y, z
 
 def fromYahooRoad(x, y, z) {
 """ Return column, row, zoom for Yahoo Road tile x, y, z.
 """
 return fromYahoo(x, y, z)
 
 def toYahooRoad(col, row, zoom) {
 """ Return x, y, z for Yahoo Road tile column, row, zoom.
 """
 return toYahoo(col, row, zoom)
 
 def fromYahooAerial(x, y, z) {
 """ Return column, row, zoom for Yahoo Aerial tile x, y, z.
 """
 return fromYahoo(x, y, z)
 
 def toYahooAerial(col, row, zoom) {
 """ Return x, y, z for Yahoo Aerial tile column, row, zoom.
 """
 return toYahoo(col, row, zoom)
 
 */

public class Tiles {

  
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


  public static Coordinate fromMicrosoft(String s) {
    // Return column, row, zoom for Microsoft tile string.
    String rowS = "";
    String colS = "";
    for (int i = 0; i < s.length(); i++) {
      int v = Integer.parseInt("" + s.charAt(i));
      String bv = PApplet.binary(v,2);
      rowS += bv.charAt(0);
      colS += bv.charAt(1);
    }
    return new Coordinate(PApplet.unbinary(colS), PApplet.unbinary(rowS), s.length());
  }


  public static String toMicrosoft(int col, int row, int zoom) {
    // Return string for Microsoft tile column, row, zoom
    String y = PApplet.binary(row, zoom);
    String x = PApplet.binary(col, zoom);
    String out = "";
    for (int i = 0; i < zoom; i++) {
      out += PApplet.unbinary("" + y.charAt(i) + x.charAt(i));
    }
    return out;
  }


  public static Coordinate fromMicrosoftRoad(String s) {
    // Return column, row, zoom for Microsoft Road tile string.
    return fromMicrosoft(s);
  }

  public static String toMicrosoftRoad(int col, int row, int zoom) {
    // Return x, y, z for Microsoft Road tile column, row, zoom.
    return toMicrosoft(col, row, zoom);
  }


  public static Coordinate fromMicrosoftAerial(String s) {
    // Return column, row, zoom for Microsoft Aerial tile string.
    return fromMicrosoft(s);
  } 

  public static String toMicrosoftAerial(int col, int row, int zoom) {
    // Return x, y, z for Microsoft Aerial tile column, row, zoom.
    return toMicrosoft(col, row, zoom);
  }

}
