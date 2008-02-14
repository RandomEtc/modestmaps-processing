package com.modestmaps;

public class Transformation {

  public float ax, bx, cx, ay, by, cy;

  public Transformation(float ax, float bx, float cx, float ay, float by, float cy) {
    this.ax = ax;
    this.bx = bx;
    this.cx = cx;
    this.ay = ay;
    this.by = by;
    this.cy = cy;
  }

  public Point2f transform(Point2f point) {
    return new Point2f(ax*point.x + bx*point.y + cx, ay*point.x + by*point.y + cy);
  }

  public Point2f untransform(Point2f point) {
    return new Point2f((point.x*by - point.y*bx - cx*by + cy*bx) / (ax*by - ay*bx), (point.x*ay - point.y*ax - cx*ay + cy*ax) / (bx*ay - by*ax));
  }

}
