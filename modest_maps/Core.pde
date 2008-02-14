
void doCoreTest() {

  println();
  println("core test");
  println();

  Coordinate c = new Coordinate(0, 1, 2);
  println( c.toString().equals("(0.000, 1.000 @2.000)") );
  println( c.row == 0 );
  println( c.column == 1 );
  println( c.zoom == 2 );

  println( c.zoomTo(3).toString().equals("(0.000, 2.000 @3.000)") );

  println( c.zoomTo(1).toString().equals("(0.000, 0.500 @1.000)") );

  println( c.up().toString().equals("(-1.000, 1.000 @2.000)") );

  println( c.right().toString().equals("(0.000, 2.000 @2.000)") );

  println( c.down().toString().equals("(1.000, 1.000 @2.000)") );

  println( c.left().toString().equals("(0.000, 0.000 @2.000)") );

}


class Point {

  float x;
  float y;

  Point(float x, float y) {
    this.x = x;
    this.y = y;
  }

  String toString() {
    return "(" + nf(x,1,3) + ", " + nf(y,1,3) + ")";
  }

}

class Coordinate {

  int MAX_ZOOM = 20;

  float row, column, zoom;

  Coordinate(float row, float column, float zoom) {
    this.row = row;
    this.column = column;
    this.zoom = zoom;
  }

  String toString() {
    return "(" + nf(row,1,3) + ", " + nf(column,1,3) + " @" + nf(zoom,1,3) + ")";
  }

  Coordinate copy() {
    return new Coordinate(row, column, zoom);
  }

  Coordinate container() {
    return new Coordinate(floor(row), floor(column), zoom);
  }

  Coordinate zoomTo(float destination) {
    return new Coordinate(row * pow(2, destination - zoom),
    column * pow(2, destination - zoom),
    destination);
  }

  Coordinate zoomBy(float distance) {
    return new Coordinate(row * pow(2, distance),
    column * pow(2, distance),
    zoom + distance);
  }

  Coordinate up() {
    return up(1);
  }
  Coordinate up(float distance) {
    return new Coordinate(row - distance, column, zoom);
  }

  Coordinate right() {
    return right(1);
  }
  Coordinate right(float distance) {
    return new Coordinate(row, column + distance, zoom);
  }

  Coordinate down() {
    return down(1);
  }
  Coordinate down(float distance) {
    return new Coordinate(row + distance, column, zoom);
  }

  Coordinate left() {
    return left(1);
  }
  Coordinate left(float distance) {
    return new Coordinate(row, column - distance, zoom);
  }

}
