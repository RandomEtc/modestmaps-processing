package com.modestmaps;

import processing.core.*;

public abstract class AbstractProjection {

  public float zoom;
  public Transformation transformation;

  public AbstractProjection() {
    this(0);
  }

  public AbstractProjection(float zoom) {
    this(zoom, new Transformation(1, 0, 0, 0, 1, 0));
  }

  public AbstractProjection(float zoom, Transformation transformation) {
    this.zoom = zoom;
    this.transformation = transformation;
  }

  public abstract Point2f rawProject(Point2f point);

  public abstract Point2f rawUnproject(Point2f point);

  public Point2f project(Point2f point) {
    point = this.rawProject(point);
    if(this.transformation != null) {
      point = this.transformation.transform(point);
    }
    return point;
  }

  public Point2f unproject(Point2f point) {
    if(this.transformation != null) {
      point = this.transformation.untransform(point);
    }
    point = this.rawUnproject(point);
    return point;
  }

  public Coordinate locationCoordinate(Location location) {
    Point2f point = new Point2f(PApplet.PI * location.lon / 180.0f, PApplet.PI * location.lat / 180.0f);
    point = this.project(point);
    return new Coordinate(point.y, point.x, this.zoom);
  }

  public Location coordinateLocation(Coordinate coordinate) {
    coordinate = coordinate.zoomTo(this.zoom);
    Point2f point = new Point2f(coordinate.column, coordinate.row);
    point = this.unproject(point);
    return new Location(180.0f * point.y / PApplet.PI, 180.0f * point.x / PApplet.PI);
  }

}

