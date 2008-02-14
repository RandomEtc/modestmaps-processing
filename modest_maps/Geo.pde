
void doGeoTest() {

  println();
  println("geo test");
  println();

  Transformation t = new Transformation(1, 0, 0, 0, 1, 0);
  Point p = new Point(1, 1);
  println( p.toString().equals("(1.000, 1.000)") );

  Point p_ = t.transform(p);
  println( p_.toString().equals("(1.000, 1.000)") );
  
  Point p__ = t.untransform(p_);
  println( p__.toString().equals("(1.000, 1.000)") );

  t = new Transformation(0, 1, 0, 1, 0, 0);
  p = new Point(0, 1);
  println( p.toString().equals("(0.000, 1.000)") );
  p_ = t.transform(p);
  println( p_.toString().equals("(1.000, 0.000)") );
  p__ = t.untransform(p_);
  // !!! I will accept -0 here, but clearly something is a bit hairy
  println( p__.toString().equals("(0.000, 1.000)") || p__.toString().equals("(-0.000, 1.000)") );

  t = new Transformation(1, 0, 1, 0, 1, 1);
  p = new Point(0, 0);
  println( p.toString().equals("(0.000, 0.000)") );
  p_ = t.transform(p);
  println( p_.toString().equals("(1.000, 1.000)") );
  p__ = t.untransform(p_);
  // !!! I will accept -0 here, but clearly something is a bit hairy
  println( p__.toString().equals("(0.000, 0.000)") || p__.toString().equals("(0.000, -0.000)") );

  AbstractProjection m = new MercatorProjection(10);
  Coordinate c = m.locationCoordinate(new Location(0, 0));
  // !!! python version has a negative here, but I think this is OK
  println( c.toString().equals("(-0.000, 0.000 @10.000)") || c.toString().equals("(0.000, 0.000 @10.000)") );

  Location l = m.coordinateLocation(new Coordinate(0, 0, 10));
  println( l.toString().equals("(0.000, 0.000)") );

  c = m.locationCoordinate(new Location(37, -122));
  println( c.toString().equals("(0.696, -2.129 @10.000)") );
  
  l = m.coordinateLocation(new Coordinate(0.696, -2.129, 10.000));
  println( l.toString().equals("(37.001, -121.983)") );

}



class Location {

  float lat;
  float lon;

  Location(float lat, float lon) {
    this.lat = lat;
    this.lon = lon;
  }

  String toString() {
    return "(" + nf(lat,1,3) + ", " + nf(lon,1,3) + ")";
  }

}

class Transformation {

  float ax, bx, cx, ay, by, cy;

  Transformation(float ax, float bx, float cx, float ay, float by, float cy) {
    this.ax = ax;
    this.bx = bx;
    this.cx = cx;
    this.ay = ay;
    this.by = by;
    this.cy = cy;
  }

  Point transform(Point point) {
    return new Point(ax*point.x + bx*point.y + cx, ay*point.x + by*point.y + cy);
  }

  Point untransform(Point point) {
    return new Point((point.x*by - point.y*bx - cx*by + cy*bx) / (ax*by - ay*bx), (point.x*ay - point.y*ax - cx*ay + cy*ax) / (bx*ay - by*ax));
  }

}

abstract class AbstractProjection {

  float zoom;
  Transformation transformation;

  AbstractProjection() {
    this(0);
  }

  AbstractProjection(float zoom) {
    this(zoom, new Transformation(1, 0, 0, 0, 1, 0));
  }

  AbstractProjection(float zoom, Transformation transformation) {
    this.zoom = zoom;
    this.transformation = transformation;
  }

  abstract Point rawProject(Point point);

  abstract Point rawUnproject(Point point);

  Point project(Point point) {
    point = this.rawProject(point);
    if(this.transformation != null) {
      point = this.transformation.transform(point);
    }
    return point;
  }

  Point unproject(Point point) {
    if(this.transformation != null) {
      point = this.transformation.untransform(point);
    }
    point = this.rawUnproject(point);
    return point;
  }

  Coordinate locationCoordinate(Location location) {
    Point point = new Point(PI * location.lon / 180.0, PI * location.lat / 180.0);
    point = this.project(point);
    return new Coordinate(point.y, point.x, this.zoom);
  }

  Location coordinateLocation(Coordinate coordinate) {
    coordinate = coordinate.zoomTo(this.zoom);
    Point point = new Point(coordinate.column, coordinate.row);
    point = this.unproject(point);
    return new Location(180.0 * point.y / PI, 180.0 * point.x / PI);
  }

}

class LinearProjection extends AbstractProjection {

  LinearProjection() {
    super(0);
  }

  LinearProjection(float zoom) {
    super(zoom, new Transformation(1, 0, 0, 0, 1, 0));
  }

  LinearProjection(float zoom, Transformation transformation) {
    super(zoom, transformation);
  }  
  
  Point rawProject(Point point) {
    return new Point(point.x, point.y);
  }

  Point rawUnproject(Point point) {
    return new Point(point.x, point.y);
  }

}

class MercatorProjection extends AbstractProjection {

  MercatorProjection() {
    super(0);
  }

  MercatorProjection(float zoom) {
    super(zoom, new Transformation(1, 0, 0, 0, 1, 0));
  }

  MercatorProjection(float zoom, Transformation transformation) {
    super(zoom, transformation);
  }  
  
  Point rawProject(Point point) {
    return new Point(point.x, log(tan(0.25 * PI + 0.5 * point.y)));
  }

  Point rawUnproject(Point point) {
    return new Point(point.x, 2.0 * atan(pow((float)Math.E, point.y)) - 0.5 * PI);
  }

}
