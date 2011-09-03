package com.modestmaps.providers;

import processing.core.*;
import com.modestmaps.core.*;
import com.modestmaps.geo.*;

public class OpenStreetMapProvider extends AbstractMapProvider {

  public String[] subdomains = new String[] { "", "a.", "b.", "c." };

  public OpenStreetMapProvider() {
    super(new MercatorProjection(26, new Transformation(1.068070779e7f, 0.0f, 3.355443185e7f, 0.0f, -1.068070890e7f, 3.355443057e7f)));
  }

  public int tileWidth() {
    return 256;
  }

  public int tileHeight() {
    return 256;
  }

  public String[] getTileUrls(Coordinate coordinate) {
    String img = (int)coordinate.zoom + "/" + (int)coordinate.column + "/" + (int)coordinate.row + ".png";
    String url = "http://" + subdomains[(int)random(0, 4)] + "tile.openstreetmap.org/" + img;
    return new String[] { url };
  }

}

