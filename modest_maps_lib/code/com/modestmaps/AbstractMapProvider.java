package com.modestmaps;

import processing.core.*;

public abstract class AbstractMapProvider {

  public static String[] ids =  { 
  "MICROSOFT_ROAD", "MICROSOFT_AERIAL", "MICROSOFT_HYBRID",
  "GOOGLE_ROAD",    "GOOGLE_AERIAL",    "GOOGLE_HYBRID",
  "YAHOO_ROAD",     "YAHOO_AERIAL",     "YAHOO_HYBRID",
  "BLUE_MARBLE",
  "OPEN_STREET_MAP" };

  
  public AbstractProjection projection;

  public AbstractMapProvider(AbstractProjection projection) {
    this.projection = projection; 
  }

  public abstract String[] getTileUrls(Coordinate coordinate);

  public abstract int tileWidth();

  public abstract int tileHeight();

  public Coordinate locationCoordinate(Location location) {
    return projection.locationCoordinate(location);
  }

  public Location coordinateLocation(Coordinate coordinate) {
    return projection.coordinateLocation(coordinate);
  }

  public Coordinate sourceCoordinate(Coordinate coordinate) {
    float wrappedColumn = coordinate.column % PApplet.pow(2, coordinate.zoom);

    while (wrappedColumn < 0) {
      wrappedColumn += PApplet.pow(2, coordinate.zoom);
    }

    return new Coordinate(coordinate.row, wrappedColumn, coordinate.zoom);
  }

  /** since we're often given four tile servers to pick from */
  public static float random(int lower, int higher) {
    return (float)((double)lower + Math.random() * (double)(higher-lower));
  }
  
}
