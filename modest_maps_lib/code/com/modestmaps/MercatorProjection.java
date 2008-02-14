package com.modestmaps;

import processing.core.*;

public class MercatorProjection extends AbstractProjection {

  public MercatorProjection() {
    super(0);
  }

  public MercatorProjection(float zoom) {
    super(zoom, new Transformation(1, 0, 0, 0, 1, 0));
  }

  public MercatorProjection(float zoom, Transformation transformation) {
    super(zoom, transformation);
  }  
  
  public Point2f rawProject(Point2f point) {
    return new Point2f(point.x, PApplet.log(PApplet.tan(0.25f * PApplet.PI + 0.5f * point.y)));
  }

  public Point2f rawUnproject(Point2f point) {
    return new Point2f(point.x, 2.0f * PApplet.atan(PApplet.pow((float)Math.E, point.y)) - 0.5f * PApplet.PI);
  }

}
