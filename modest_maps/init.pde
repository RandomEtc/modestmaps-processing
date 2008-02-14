
void doMapTest() {
  println();
  println("map test");
  println();  

  Map m = new Map(new RoadProvider(), new Point(600, 600), new Coordinate(3165, 1313, 13), new Point(-144, -94));
  Point p = m.locationPoint(new Location(37.804274, -122.262940));
  println( p.toString().equals("(370.688, 342.438)") );
  // !!! this is what the python version gives (probably floats vs doubles?)
  //println( p.toString().equals("(370.724, 342.549)") );
  Location l = m.pointLocation(p);
  println( l.toString().equals("(37.804, -122.263)") );  
}



class MapCenter {

  Coordinate coordinate;
  Point point; 

  MapCenter(Coordinate coordinate, Point point) {
    this.coordinate = coordinate;
    this.point = point;
  }

}

MapCenter calculateMapCenter(AbstractMapProvider provider, Coordinate centerCoord) {
  // Based on a center coordinate, returns the coordinate
  // of an initial tile and its point placement, relative to
  // the map center.

  // initial tile coordinate
  Coordinate initTileCoord = new Coordinate(floor(centerCoord.row), floor(centerCoord.column), floor(centerCoord.zoom));

  // initial tile position, assuming centered tile well in grid
  float initX = (initTileCoord.column - centerCoord.column) * provider.tileWidth();
  float initY = (initTileCoord.row - centerCoord.row) * provider.tileHeight();
  Point initPoint = new Point(round(initX), round(initY));

  return new MapCenter(initTileCoord, initPoint);
}

MapCenter calculateMapExtent(AbstractMapProvider provider, int width, int height, Location[] locations) {

  float minRow = MAX_FLOAT;
  float maxRow = -MAX_FLOAT;
  float minCol = MAX_FLOAT;
  float maxCol = -MAX_FLOAT;
  float minZoom = MAX_FLOAT;
  float maxZoom = -MAX_FLOAT;

  Coordinate[] coordinates = new Coordinate[locations.length];
  for (int i = 0; i < coordinates.length; i++) {
    coordinates[i] = provider.locationCoordinate(locations[i]);
    minRow = min(minRow, coordinates[i].row);
    maxRow = max(maxRow, coordinates[i].row);
    minCol = min(minCol, coordinates[i].column);
    maxCol = max(maxCol, coordinates[i].column);
    minZoom = min(minZoom, coordinates[i].zoom);
    maxZoom = max(maxZoom, coordinates[i].zoom);
  }

  Coordinate TL = new Coordinate(minRow, minCol, minZoom);

  Coordinate BR = new Coordinate(maxRow, maxCol, maxZoom);

  // multiplication factor between horizontal span and map width
  float hFactor = (BR.column - TL.column) / ((float)width / provider.tileWidth());

  // multiplication factor expressed as base-2 logarithm, for zoom difference
  float hZoomDiff = log(hFactor) / log(2);

  // possible horizontal zoom to fit geographical extent in map width
  float hPossibleZoom = TL.zoom - ceil(hZoomDiff);

  // multiplication factor between vertical span and map height
  float vFactor = (BR.row - TL.row) / ((float)height / provider.tileHeight());

  // multiplication factor expressed as base-2 logarithm, for zoom difference
  float vZoomDiff = log(vFactor) / log(2);

  // possible vertical zoom to fit geographical extent in map height
  float vPossibleZoom = TL.zoom - ceil(vZoomDiff);

  // initial zoom to fit extent vertically and horizontally
  float initZoom = min(hPossibleZoom, vPossibleZoom);

  // additionally, make sure it's not outside the boundaries set by provider limits
  //initZoom = min(initZoom, provider.outerLimits()[1].zoom)
  //initZoom = max(initZoom, provider.outerLimits()[0].zoom)

  // coordinate of extent center
  float centerRow = (TL.row + BR.row) / 2.0;
  float centerColumn = (TL.column + BR.column) / 2.0;
  float centerZoom = (TL.zoom + BR.zoom) / 2.0;
  Coordinate centerCoord = new Coordinate(centerRow, centerColumn, centerZoom).zoomTo(initZoom);

  return calculateMapCenter(provider, centerCoord);
}


class TileRequest {

  // how many times to retry a failing tile
  int MAX_ATTEMPTS = 5;

  boolean done;
  AbstractMapProvider provider;
  Coordinate coord;
  Point  offset;

  PImage imgs[];

  TileRequest(AbstractMapProvider provider, Coordinate coord, Point  offset) {
    this.done = false;
    this.provider = provider;
    this.coord = coord;
    this.offset = offset;
  }

  boolean loaded() {
    return this.done;
  }

  PImage[] images() {
    return imgs;
  }

  void load(boolean verbose) {
    load(verbose, 1); 
  }

  void load(boolean verbose, int attempt) {
    if (done) {
      return;
    }

    String[] urls = provider.getTileUrls(coord);

    if (verbose) {
      print("Requesting ");
      print(join(urls, ", "));
      println(" - attempt no. " + attempt);// + " in thread', thread.get_ident()
    }

    this.imgs = new PImage[urls.length];

    // this is the time-consuming part
    try {
      for (int i = 0; i < urls.length; i++) {
        String type = urls[i].startsWith("http://mt") ? "png" : urls[i].startsWith("http://kh") ? "jpg" : null;
        if (type != null) { 
          imgs[i] = loadImage(urls[i], type);
        }
        else {
          imgs[i] = loadImage(urls[i]);
        }
      }
    }
    catch (Exception e) {
      /*                
       if verbose:
       print 'Failed', urls, '- attempt no.', attempt, 'in thread', thread.get_ident()
       
       if attempt < TileRequest.MAX_ATTEMPTS:
       time.sleep(1 * attempt)
       return self.load(lock, verbose, attempt+1)
       else:
       imgs = [None for url in urls]
       */
    }

    if (verbose) {
      print("Received ");
      print(join(urls,", "));
      println(" - attempt no. " + attempt);// 'in thread', thread.get_ident()
    }

    /* if lock.acquire():
     self.imgs = imgs
     self.done = True
     lock.release() */
  }

}


class TileQueue extends Vector {
  // List of TileRequest objects, that's sensitive to when they're loaded.
  boolean pending() {
    for (int i = 0; i < size(); i++) {
      if (!((TileRequest)get(i)).loaded()) {
        return true;
      }
    }
    return false; 
  }
}

class Map {

  AbstractMapProvider provider;
  Point dimensions;
  Coordinate coordinate;
  Point offset;

  Map(AbstractMapProvider provider, Point dimensions, Location location, int zoom) {
    MapCenter center = calculateMapCenter(provider, provider.locationCoordinate(location).zoomTo(zoom));
    this.provider = provider;
    this.dimensions = dimensions;
    this.coordinate = center.coordinate;
    this.offset = center.point;
  }

  Map(AbstractMapProvider provider, Point dimensions, Coordinate coordinate, Point offset) {
    // Instance of a map intended for drawing to an image.
    // provider
    //   Instance of IMapProvider         
    // dimensions
    //   Size of output image, instance of Point
    // coordinate
    //   Base tile, instance of Coordinate
    // offset
    //   Position of base tile relative to map center, instance of Point

    this.provider = provider;
    this.dimensions = dimensions;
    this.coordinate = coordinate;
    this.offset = offset;
  }

  String toString() {
    return "Map(" + provider + ", " + dimensions + ", " + coordinate + ", " + offset + ")";
  }

  Point locationPoint(Location location) {
    // Return an x, y point on the map image for a given geographical location.

    Point point = new Point(offset.x, offset.y);
    Coordinate coord = provider.locationCoordinate(location).zoomTo(coordinate.zoom);

    // distance from the known coordinate offset
    point.x += provider.tileWidth() * (coord.column - coordinate.column);
    point.y += provider.tileHeight() * (coord.row - coordinate.row);

    // because of the center/corner business
    point.x += dimensions.x/2.0;
    point.y += dimensions.y/2.0;

    return point;
  }

  Location pointLocation(Point point) {
    // Return a geographical location on the map image for a given x, y point.

    Coordinate hizoomCoord = coordinate.zoomTo(coordinate.MAX_ZOOM);

    // because of the center/corner business
    point = new Point(point.x - dimensions.x/2.0,
    point.y - dimensions.y/2.0);

    // distance in tile widths from reference tile to point
    float xTiles = (point.x - offset.x) / provider.tileWidth();
    float yTiles = (point.y - offset.y) / provider.tileHeight();

    // distance in rows & columns at maximum zoom
    float xDistance = xTiles * pow(2, (coordinate.MAX_ZOOM - coordinate.zoom));
    float yDistance = yTiles * pow(2, (coordinate.MAX_ZOOM - coordinate.zoom));

    // new point coordinate reflecting that distance
    Coordinate coord = new Coordinate(round(hizoomCoord.row + yDistance), round(hizoomCoord.column + xDistance), hizoomCoord.zoom);

    coord = coord.zoomTo(coordinate.zoom);

    Location location = provider.coordinateLocation(coord);

    return location;
  }

  PImage draw_bbox(float[] bbox) {
    return draw_bbox(bbox, 16, false);
  }

  PImage draw_bbox(float[] bbox, int zoom) {
    return draw_bbox(bbox, zoom, false);
  }

  // bbox = new float[] { south, west, north, east };
  PImage draw_bbox(float[] bbox, int zoom, boolean verbose) {

    Location sw = new Location(bbox[0], bbox[1]);
    Location ne = new Location(bbox[2], bbox[3]);
    Location nw = new Location(ne.lat, sw.lon);
    Location se = new Location(sw.lat, ne.lon);

    Coordinate TL = provider.locationCoordinate(nw).zoomTo(zoom);

    TileQueue tiles = new TileQueue();

    float cur_lon = sw.lon;
    float cur_lat = ne.lat;       
    float max_lon = ne.lon;
    float max_lat = sw.lat;

    float x_off = 0;
    float y_off = 0;
    float tile_x = 0;
    float tile_y = 0;

    Coordinate tileCoord = TL.copy();

    while (cur_lon < max_lon) {

      y_off = 0;
      tile_y = 0;

      Location loc;
      while (cur_lat > max_lat) {

        tiles.add(new TileRequest(provider, tileCoord, new Point(x_off, y_off)));
        y_off += provider.tileHeight();

        tileCoord = tileCoord.down();
        loc = provider.coordinateLocation(tileCoord);
        cur_lat = loc.lat;

        tile_y += 1;
      }

      x_off += provider.tileWidth();
      cur_lat = ne.lat;

      tile_x += 1;
      tileCoord = TL.copy().right(tile_x);

      loc = provider.coordinateLocation(tileCoord);
      cur_lon = loc.lon;
    }

    int width = (int)floor(provider.tileWidth() * tile_x);
    int height = (int)floor(provider.tileHeight() * tile_y);

    // Quick, look over there!

    MapCenter center = calculateMapExtent(provider, width, height, new Location[] { 
      new Location(bbox[0], bbox[1]), new Location(bbox[2], bbox[3])     } 
    );

    this.offset = center.point;
    this.coordinate = center.coordinate;
    this.dimensions = new Point(width, height);

    return draw();
  }

  PGraphics draw() {
    return draw(false); 
  }

  PGraphics draw(boolean verbose) {
    // Draw map out to a PImage and return it.

    Coordinate coord = coordinate.copy();
    Point corner = new Point(int(offset.x + dimensions.x/2.0), int(offset.y + dimensions.y/2.0));

    while (corner.x > 0) {
      corner.x -= provider.tileWidth();
      coord = coord.left();
    }

    while (corner.y > 0) {
      corner.y -= provider.tileHeight();
      coord = coord.up();
    }

    TileQueue tiles = new TileQueue();

    Coordinate rowCoord = coord.copy();
    for (float y = corner.y; y < dimensions.y; y += provider.tileHeight()) {
      Coordinate tileCoord = rowCoord.copy();
      for (float x = corner.x; x < dimensions.x; x += provider.tileWidth()) {
        tiles.add(new TileRequest(provider, tileCoord, new Point(x, y)));
        tileCoord = tileCoord.right();
      }
      rowCoord = rowCoord.down();
    }

    return render_tiles(tiles, (int)dimensions.x, (int)dimensions.y, verbose);

  }

  PGraphics render_tiles(TileQueue tiles, int img_width, int img_height) {
    return render_tiles(tiles, img_width, img_height, false);
  }

  PGraphics render_tiles(TileQueue tiles, int img_width, int img_height, boolean verbose) {

    // lock = thread.allocate_lock()

    for (int i = 0; i < tiles.size(); i++) {
      TileRequest tile = (TileRequest)tiles.get(i);
      // request all needed images
      // thread.start_new_thread(tile.load, (lock, verbose))
      tile.load(verbose);
    }

    // if it takes any longer than 20 sec overhead + 10 sec per tile, give up
    // due = time.time() + 20 + len(tiles) * 10

    //while time.time() < due and tiles.pending():
    //    # hang around until they are loaded or we run out of time...
    //    time.sleep(1)

    PGraphics mapImg = createGraphics(img_width, img_height, JAVA2D);
    mapImg.beginDraw();

    for (int i = 0; i < tiles.size(); i++) {
      TileRequest tile = (TileRequest)tiles.get(i);
      for (int j = 0; j < tile.images().length; j++) {
        PImage img = tile.images()[j];
        mapImg.image(img, tile.offset.x, tile.offset.y);
      }
    }

    mapImg.endDraw();

    return mapImg;
  }

}
