package com.modestmaps.geo;

import com.modestmaps.core.Point2f;

public class LinearProjection extends AbstractProjection {

  public LinearProjection() {
    super(0);
  }

  public LinearProjection(float zoom) {
    super(zoom, new Transformation(1, 0, 0, 0, 1, 0));
  }

  public LinearProjection(float zoom, Transformation transformation) {
    super(zoom, transformation);
  }  
  
  public Point2f rawProject(Point2f point) {
    return new Point2f(point.x, point.y);
  }

  public Point2f rawUnproject(Point2f point) {
    return new Point2f(point.x, point.y);
  }

}
