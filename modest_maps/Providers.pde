

String[] ids =  { 
  "MICROSOFT_ROAD", "MICROSOFT_AERIAL", "MICROSOFT_HYBRID",
  "GOOGLE_ROAD",    "GOOGLE_AERIAL",    "GOOGLE_HYBRID",
  "YAHOO_ROAD",     "YAHOO_AERIAL",     "YAHOO_HYBRID",
  "BLUE_MARBLE",
  "OPEN_STREET_MAP" };

abstract class AbstractMapProvider {

  AbstractProjection projection;

  AbstractMapProvider(AbstractProjection projection) {
    this.projection = projection; 
  }

  abstract String[] getTileUrls(Coordinate coordinate);

  abstract int tileWidth();

  abstract int tileHeight();

  Coordinate locationCoordinate(Location location) {
    return projection.locationCoordinate(location);
  }

  Location coordinateLocation(Coordinate coordinate) {
    return projection.coordinateLocation(coordinate);
  }

  Coordinate sourceCoordinate(Coordinate coordinate) {
    float wrappedColumn = coordinate.column % pow(2, coordinate.zoom);

    while (wrappedColumn < 0) {
      wrappedColumn += pow(2, coordinate.zoom);
    }

    return new Coordinate(coordinate.row, wrappedColumn, coordinate.zoom);
  }

}
