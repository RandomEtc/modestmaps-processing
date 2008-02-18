
class InteractiveMap {

  // pan, zoom and (eventually) rotate
  double tx = 0, ty = 0;
  double sc = 1;
  //  float a = 0.0;

  // what kinda maps?
  AbstractMapProvider provider;

  int MAX_PENDING = 4;
  int MAX_IMAGES_TO_KEEP = 256; // 256 would be 64 MB, you may want to lower this quite a bit for your app
  
  Vector recentImages = new Vector();

  InteractiveMap() {
    provider = new Microsoft.HybridProvider();

    // fit to screen
    sc = ceil(min(height/256.0, width/256.0));

    // center the center!
    tx = -128;
    ty = -128;

    addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
      public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
        mouseWheel(evt.getWheelRotation());
      }
    }
    ); 

  }

  void draw() {

    PMatrix m = new PMatrix();

    // translate and scale, from the middle
    pushMatrix();
    translate(width/2, height/2);
    scale((float)sc);
    translate((float)tx, (float)ty);

    //    println("p5: ");
    //    printMatrix();

    m.push();
    m.translate(width/2, height/2);
    m.scale((float)sc);
    m.translate((float)tx,(float)ty);

    //    println("m: ");
    //    m.print();

    // find the world bounds in screen-space:
    float minX = screenX(0,0);
    float minY = screenY(0,0);
    float maxX = screenX(256,256);
    float maxY = screenY(256,256);

    //    println("map p5: " + nf(minX,1,3) + " " + nf(minY,1,3) + " : " + nf(maxX,1,3) + " " + nf(maxY,1,3));

    /*    float[] in1 = { 0, 0, 0 };
     
     float[] out = new float[3];
     m.mult3(in1, out);
     minX = out[0];
     minY = out[1];
     
     float[] in2 = { 256, 256, 0 };
     m.mult3(in2, out);
     maxX = out[0];
     maxY = out[1];
     
     println("map m: " + nf(minX,1,3) + " " + nf(minY,1,3) + " : " + nf(maxX,1,3) + " " + nf(maxY,1,3)); */

    // 0 when scale is 1, 1 when scale is 2, 2 when scale is 4, 3 when scale is 8, etc.
    int zoom = bestZoomForScale((float)sc);

    // how many columns and rows of tiles at this zoom?
    int cols = (int)pow(2,zoom);
    int rows = (int)pow(2,zoom);
    //  println("rows/cols: " + rows + "/" + cols);
    //  println("tileCount: " + (rows * cols));

    // find the biggest box the screen would fit in, aligned with the map:
    float screenMinX = 0;
    float screenMinY = 0;
    float screenMaxX = width;
    float screenMaxY = height;
    //  println("screen: " + nf(screenMinX,1,3) + " " + nf(screenMinY,1,3) + " : " + nf(screenMaxX,1,3) + " " + nf(screenMaxY,1,3));
    // TODO align this box and re-enable rotations!?

    // find start and end columns
    int minCol = (int)floor(cols * (screenMinX-minX) / (maxX-minX));
    int maxCol = (int)ceil(cols * (screenMaxX-minX) / (maxX-minX));
    int minRow = (int)floor(rows * (screenMinY-minY) / (maxY-minY));
    int maxRow = (int)ceil(rows * (screenMaxY-minY) / (maxY-minY));
    //  println("row/col: " + minCol + ", " + minRow + " : " + maxCol + ", " + maxRow);

    // pad a bit, for luck (well, because we might be zooming out between zoom levels)
    minCol -= 1;
    minRow -= 1;
    maxCol += 1;
    maxRow += 1;

    // keep track of what we can see already:
    Vector visibleKeys = new Vector();

    // grab coords for visible tiles
    for (int col = minCol; col <= maxCol; col++) {
      for (int row = minRow; row <= maxRow; row++) {

        // source coordinate wraps around the world:
        Coordinate coord = provider.sourceCoordinate(new Coordinate(row,col,zoom));

        // let's make sure we still have ints:
        coord.row = round(coord.row);
        coord.column = round(coord.column);
        coord.zoom = round(coord.zoom);

        // keep this for later:
        visibleKeys.add(coord);

        if (!images.containsKey(coord)) {
          // fetch it if we don't have it
          grabTile(coord);

          // see if we have  a parent coord for this tile?
          boolean gotParent = false;
          for (int i = (int)coord.zoom; i > 0; i--) {
            Coordinate zoomed = coord.zoomTo(i).container();
            // make sure we still have ints:
            zoomed.row = round(zoomed.row);
            zoomed.column = round(zoomed.column);
            zoomed.zoom = round(zoomed.zoom);
            if (images.containsKey(zoomed)) {
              visibleKeys.add(zoomed);
              gotParent = true;
              break;
            }
          }
          
          // or if we have any of the children
          if (!gotParent) {
            Coordinate zoomed = coord.zoomBy(1).container();
            Coordinate[] kids = new Coordinate[] { zoomed, zoomed.right(), zoomed.down(), zoomed.right().down() }; 
            for (int i = 0; i < kids.length; i++) {
              zoomed = kids[i];
              // make sure we still have ints:
              zoomed.row = round(zoomed.row);
              zoomed.column = round(zoomed.column);
              zoomed.zoom = round(zoomed.zoom);
              if (images.containsKey(zoomed)) {
                visibleKeys.add(zoomed);
              }
            }            
          }
          
        }
        
      } // rows
    } // columns

    // sort by zoom so we draw small zoom levels (big tiles) first:
    Collections.sort(visibleKeys, new Comparator() {
      public int compare(Object o1, Object o2) {
        Coordinate c1 = (Coordinate)o1;
        Coordinate c2 = (Coordinate)o2;
        return c1.zoom < c2.zoom ? -1 : c1.zoom > c2.zoom ? 1 : 0;
      }
    });

    if (visibleKeys.size() > 0) {
      Coordinate previous = (Coordinate)visibleKeys.get(0);
      pushMatrix();
      // correct the scale for this zoom level:
      scale(1.0/pow(2, previous.zoom));
      for (int i = 0; i < visibleKeys.size(); i++) {
        Coordinate coord = (Coordinate)visibleKeys.get(i);

        if (coord.zoom != previous.zoom) {
          popMatrix();
          pushMatrix();
          // correct the scale for this zoom level:
          scale(1.0/pow(2,coord.zoom));
        }
      
        if (images.containsKey(coord)) {
          PImage tile = (PImage)images.get(coord);
          image(tile,coord.column*256,coord.row*256,256,256);
          if (recentImages.contains(tile)) {
            recentImages.remove(tile);
          }
          recentImages.add(tile);
        }
      }
      popMatrix();
    }    

    popMatrix();

    //  println(pending.size() + " pending...");
    //  println(queue.size() + " in queue, pruning...");
    queue.retainAll(visibleKeys); // stop fetching things we can't see
    //  println(queue.size() + " in queue");
    //  println();

    // sort what's left by distance from center:
    Coordinate center = new Coordinate( (minRow + maxRow) / 2.0, (minCol + maxCol) / 2.0, zoom);    
    //    println("center: " + center);
    Collections.sort(queue, new QueueSorter(center));

    // load up to 4 more things:
    processQueue();

    if (recentImages.size() > MAX_IMAGES_TO_KEEP) {
      println(recentImages.size() + " images in memory, removing...");
      recentImages.subList(0, recentImages.size()-MAX_IMAGES_TO_KEEP).clear();
      println(recentImages.size() + " images in memory");
      images.values().retainAll(recentImages);
    }

    if (keyPressed) {
      /*    if (key == CODED) {
       if (keyCode == LEFT) {
       a -= 1;
       }
       else if (keyCode == RIGHT) {
       a += 1;        
       }
       } 
       else */      if (key == '+' || key == '=') {
        sc *= 1.05;
      }
      else if (key == '_' || key == '-' && sc > 0.1) {
        sc *= 1.0/1.05;
      }
      else if (key == 'z' || key == 'Z') {
        sc = pow(2, getZoom());
      }
      else if (key == ' ') {
        sc = 1.0;
        tx = 0;
        ty = 0; 
        //        a = 0;
      }
    }

    /*    println("sc: " + sc + 
     " tx: " + tx + 
     " ty: " + ty); */

  } 

  /** @return zoom level of currently visible tile layer */
  int getZoom() {
    return bestZoomForScale((float)sc);
  }

  void setCenter(Coordinate center) {
    println("setting center to " + center);
    sc = pow(2.0, center.zoom);
    tx = -256.0*center.column/sc;
    ty = -256.0*center.row/sc;
  }

  void setCenter(Location location) {
    setCenter(provider.locationCoordinate(location).zoomTo(getZoom()));
  }
  
  void setCenterZoom(Location location, int zoom) {
    setCenter(provider.locationCoordinate(location).zoomTo(zoom));
  }

  Coordinate getCenter() {
    float row = (float)(ty*sc/-256.0);
    float column = (float)(tx*sc/-256.0);
    float zoom = zoomForScale((float)sc);
    return new Coordinate(row, column, zoom); 
  }

  /** sets scale according to given zoom level, should leave you with pixel perfect tiles */
  void setZoom(int zoom) {
    sc = pow(2.0, zoom-1); 
  }

  void zoomIn() {
    sc = pow(2.0, getZoom()+1); 
  }  

  void zoomOut() {
    sc = pow(2.0, getZoom()-1); 
  }  

  float scaleForZoom(int zoom) {
    return pow(2.0, zoom);
  }

  float zoomForScale(float scale) {
    return log(scale) / log(2);
  }

  int bestZoomForScale(float scale) {
    return (int)min(20, max(1, (int)round(log(scale) / log(2))));
  }

  void mouseDragged() {
    double dx = (double)(mouseX - pmouseX) / sc;
    double dy = (double)(mouseY - pmouseY) / sc;
    //    float angle = radians(-a);
    //    float rx = cos(angle)*dx - sin(angle)*dy;
    //    float ry = sin(angle)*dx + cos(angle)*dy;
    //    tx += rx;
    //    ty += ry;
    tx += dx;
    ty += dy;
  }

  // loading tiles
  Hashtable pending = new Hashtable(); // coord.toString() -> TileLoader
  // loaded tiles
  Hashtable images = new Hashtable();  // coord.toString() -> PImage
  // coords waiting to load
  Vector queue = new Vector(); // coord

  void grabTile(Coordinate coord) {
    if (!pending.containsKey(coord) && !queue.contains(coord) && !images.containsKey(coord)) {
      //    println("adding " + coord.toString() + " to queue");
      queue.add(coord);
    }
  }

  class TileLoader implements Runnable {
    Coordinate coord;
    TileLoader(Coordinate coord) {
      this.coord = coord; 
    }
    public void run() {
      String[] urls = provider.getTileUrls(coord);
      println("loading " + urls[0]);
      PImage img = loadImage(urls[0], "unknown");
      for (int i = 1; i < urls.length; i++) {
        println("loading " + urls[i]);
        img.blend(loadImage(urls[i], "unknown"), 0, 0, img.width, img.height, 0, 0, img.width, img.height, BLEND);
      }
      tileDone(coord, img);
    }
  }

  void tileDone(Coordinate coord, PImage img) {
    images.put(coord, img);
    pending.remove(coord);  
  }

  void processQueue() {
    while (pending.size() < MAX_PENDING && queue.size() > 0) {
      Coordinate coord = (Coordinate)queue.remove(0);
      TileLoader tileLoader = new TileLoader(coord);
      pending.put(coord, tileLoader);
      new Thread(tileLoader).start();
    }  
  }

  void mouseWheel(int delta) {
    if (delta > 0) {
      sc *= 1.05;
    }
    else if (delta < 0) {
      sc *= 1.0/1.05; 
    }
  }

  class QueueSorter implements Comparator {
    Coordinate center;
    QueueSorter(Coordinate center) {
      this.center = center;
    } 
    public int compare(Object o1, Object o2) {
      Coordinate c1 = (Coordinate)o1; 
      Coordinate c2 = (Coordinate)o2;
      if (c1.zoom == center.zoom) {
        if (c2.zoom == center.zoom) {
          float d1 = dist(center.column, center.row, c1.column, c1.row);
          float d2 = dist(center.column, center.row, c2.column, c2.row);
          return d1 < d2 ? -1 : d1 > d2 ? 1 : 0;
        } 
        else {
          return -1;
        }
      }
      else if (c2.zoom == center.zoom) {
        return 1;
      }
      else {
        float d1 = abs(c1.zoom - center.zoom);
        float d2 = abs(c2.zoom - center.zoom);
        return  d1 < d2 ? -1 : d1 > d2 ? 1 : 0;
      }
    }
  }

}
