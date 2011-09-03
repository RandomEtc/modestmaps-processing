package com.modestmaps.providers;

import processing.core.*;
import com.modestmaps.core.*;
import com.modestmaps.geo.*;

public class TemplatedMapProvider extends AbstractMapProvider {

  public String[] subdomains;
  public String template;

  public TemplatedMapProvider(String template, String[] subdomains) {
    super(new MercatorProjection(26, new Transformation(1.068070779e7f, 0.0f, 3.355443185e7f, 0.0f, -1.068070890e7f, 3.355443057e7f)));
    this.template = template;
    this.subdomains = subdomains;
  }

  public TemplatedMapProvider(String template) {
    this(template, null);
  }

  public int tileWidth() {
    return 256;
  }

  public int tileHeight() {
    return 256;
  }

  public String[] getTileUrls(Coordinate coordinate) {
    String url = template.replace("{X}", PApplet.nf((int)coordinate.column,0))
                         .replace("{Y}", PApplet.nf((int)coordinate.row,0))
                         .replace("{Z}", PApplet.nf((int)coordinate.zoom,0));
    if (subdomains != null) {
        String subdomain = subdomains[(int)(Math.random()*subdomains.length)];
        url = url.replace("{S}", subdomain);
    }
    return new String[] { url };
  }

}

