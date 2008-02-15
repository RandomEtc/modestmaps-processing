package com.modestmaps;

import processing.core.*;

public class Point2f {

  public float x;
  public float y;

  public Point2f(float x, float y) {
    this.x = x;
    this.y = y;
  }

  public String toString() {
    return "(" + PApplet.nf(x,1,3) + ", " + PApplet.nf(y,1,3) + ")";
  }

}

