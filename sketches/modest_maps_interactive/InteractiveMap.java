
import com.modestmaps.*;
import processing.core.*;
import java.util.*;

public class InteractiveMap implements PConstants {

  // I have made the dumb mistake of getting these wrong before...
  // it's REALLY unlikely you'll want to change them:
  int TILE_WIDTH = 256;
  int TILE_HEIGHT = 256;
  
  // unavoidable right now, for loadImage and float maths
  PApplet p;

  // pan and zoom
  double tx = -TILE_WIDTH/2; // half the world width, at zoom 0
  double ty = -TILE_HEIGHT/2; // half the world height, at zoom 0
  double sc = 1;

  // limit simultaneous calls to loadImage
  int MAX_PENDING = 4;
  
  // limit tiles in memory
  // 256 would be 64 MB, you may want to lower this quite a bit for your app
  int MAX_IMAGES_TO_KEEP = 256;

  // upping this can help appearances when zooming out, but also loads many more tiles
  int GRID_PADDING = 1;

  // what kinda maps?
  AbstractMapProvider provider;

  // how big?
  float width, height;

  // loading tiles
  Hashtable pending = new Hashtable(); // coord -> TileLoader
  // loaded tiles
  Hashtable images = new Hashtable();  // coord -> PImage
  // coords waiting to load
  Vector queue = new Vector();
  // a list of the most recent MAX_IMAGES_TO_KEEP PImages we've seen
  Vector recentImages = new Vector();

  // for sorting coordinates by zoom
  ZoomComparator zoomComparator = new ZoomComparator();

  // for loading tiles from the inside first
  QueueSorter queueSorter = new QueueSorter();

  /** make a new interactive map, using the given provider, of the given width and height */
  InteractiveMap(PApplet p, AbstractMapProvider provider, float width, float height) {

    this.p = p;
    this.provider = provider;
    this.width = width;
    this.height = height;

    // fit to screen
    sc = p.ceil(p.min(height/(float)TILE_WIDTH, width/(float)TILE_HEIGHT));

  }

  void draw() {

    // remember smooth setting so it can be reset 
    boolean smooth = p.g.smooth;

    // !!! VERY IMPORTANT
    // (all the renderers apart from OpenGL will choke if you ask for smooth scaling of image calls)
    p.noSmooth();

    // translate and scale, from the middle
    p.pushMatrix();
    p.translate(width/2, height/2);
    p.scale((float)sc);
    p.translate((float)tx, (float)ty);

    // find the bounds of the ur-tile in screen-space:
    float minX = p.screenX(0,0);
    float minY = p.screenY(0,0);
    float maxX = p.screenX(TILE_WIDTH, TILE_HEIGHT);
    float maxY = p.screenY(TILE_WIDTH, TILE_HEIGHT);
    p.println(minX + " " + minY);
    p.println(maxX + " " + maxY);

    // what power of 2 are we at?
    // 0 when scale is around 1, 1 when scale is around 2, 
    // 2 when scale is around 4, 3 when scale is around 8, etc.
    int zoom = bestZoomForScale((float)sc);

    // how many columns and rows of tiles at this zoom?
    // (this is basically (int)sc, but let's derive from zoom to be sure 
    int cols = (int)p.pow(2,zoom);
    int rows = (int)p.pow(2,zoom);

//    p.println(cols + " " + rows);

    // find the biggest box the screen would fit in:, aligned with the map:
    float screenMinX = 0;
    float screenMinY = 0;
    float screenMaxX = width;
    float screenMaxY = height;
    // TODO: align this, and fix the next bit to work with rotated maps

    // find start and end columns
    int minCol = (int)p.floor(cols * (screenMinX-minX) / (maxX-minX));
    int maxCol = (int)p.ceil(cols * (screenMaxX-minX) / (maxX-minX));
    int minRow = (int)p.floor(rows * (screenMinY-minY) / (maxY-minY));
    int maxRow = (int)p.ceil(rows * (screenMaxY-minY) / (maxY-minY));

    // pad a bit, for luck (well, because we might be zooming out between zoom levels)
    minCol -= GRID_PADDING;
    minRow -= GRID_PADDING;
    maxCol += GRID_PADDING;
    maxRow += GRID_PADDING;

    // we don't wrap around the world yet, so:
    minCol = p.constrain(minCol, 0, cols);
    maxCol = p.constrain(maxCol, 0, cols);
    minRow = p.constrain(minRow, 0, rows);
    maxRow = p.constrain(maxRow, 0, rows);

    // keep track of what we can see already:
    Vector visibleKeys = new Vector();

    // grab coords for visible tiles
    for (int col = minCol; col <= maxCol; col++) {
      for (int row = minRow; row <= maxRow; row++) {

        // source coordinate wraps around the world:
        Coordinate coord = provider.sourceCoordinate(new Coordinate(row,col,zoom));

        // let's make sure we still have ints:
        coord.row = p.round(coord.row);
        coord.column = p.round(coord.column);
        coord.zoom = p.round(coord.zoom);

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
            zoomed.row = p.round(zoomed.row);
            zoomed.column = p.round(zoomed.column);
            zoomed.zoom = p.round(zoomed.zoom);
            if (images.containsKey(zoomed)) {
              visibleKeys.add(zoomed);
              gotParent = true;
              break;
            }
          }

          // or if we have any of the children
          if (!gotParent) {
            Coordinate zoomed = coord.zoomBy(1).container();
            Coordinate[] kids = new Coordinate[] { 
              zoomed, zoomed.right(), zoomed.down(), zoomed.right().down()                         }; 
            for (int i = 0; i < kids.length; i++) {
              zoomed = kids[i];
              // make sure we still have ints:
              zoomed.row = p.round(zoomed.row);
              zoomed.column = p.round(zoomed.column);
              zoomed.zoom = p.round(zoomed.zoom);
              if (images.containsKey(zoomed)) {
                visibleKeys.add(zoomed);
              }
            }            
          }

        }

      } // rows
    } // columns

    // sort by zoom so we draw small zoom levels (big tiles) first:
    Collections.sort(visibleKeys, zoomComparator);

    if (visibleKeys.size() > 0) {
      Coordinate previous = (Coordinate)visibleKeys.get(0);
      p.pushMatrix();
      // correct the scale for this zoom level:
      p.scale(1.0f/p.pow(2, previous.zoom));
      for (int i = 0; i < visibleKeys.size(); i++) {
        Coordinate coord = (Coordinate)visibleKeys.get(i);

        if (coord.zoom != previous.zoom) {
          p.popMatrix();
          p.pushMatrix();
          // correct the scale for this zoom level:
          p.scale(1.0f/p.pow(2,coord.zoom));
        }

        if (images.containsKey(coord)) {
          PImage tile = (PImage)images.get(coord);
          p.image(tile,coord.column*256,coord.row*256,256,256);
//          if (p.frameCount % 100 == 0) {
//            p.println(p.screenX(coord.column*256,coord.row*256) + ", " + p.screenY(coord.column*256,coord.row*256));
//          }
          if (recentImages.contains(tile)) {
            recentImages.remove(tile);
          }
          recentImages.add(tile);
        }
      }
      p.popMatrix();
    }    

    p.popMatrix();

    //  println(pending.size() + " pending...");
    //  println(queue.size() + " in queue, pruning...");
    queue.retainAll(visibleKeys); // stop fetching things we can't see
    //  println(queue.size() + " in queue");
    //  println();

    // sort what's left by distance from center:
    queueSorter.setCenter(new Coordinate( (minRow + maxRow) / 2.0f, (minCol + maxCol) / 2.0f, zoom));
    //    println("center: " + center);
    Collections.sort(queue, queueSorter);

    // load up to 4 more things:
    processQueue();

    if (recentImages.size() > MAX_IMAGES_TO_KEEP) {
      //println(recentImages.size() + " images in memory, removing...");
      recentImages.subList(0, recentImages.size()-MAX_IMAGES_TO_KEEP).clear();
      //println(recentImages.size() + " images in memory");
      images.values().retainAll(recentImages);
    }

    if (smooth) p.smooth();

  } 

  /** @return zoom level of currently visible tile layer */
  int getZoom() {
    return bestZoomForScale((float)sc);
  }

  Location getCenter() {
    return provider.coordinateLocation(getCenterCoordinate());
  }

  Coordinate getCenterCoordinate() {
    float row = (float)(ty*sc/-256.0);
    float column = (float)(tx*sc/-256.0);
    float zoom = zoomForScale((float)sc);
    return new Coordinate(row, column, zoom); 
  }

  void setCenter(Coordinate center) {
    //println("setting center to " + center);
    sc = p.pow(2.0f, center.zoom);
    tx = -256.0*center.column/sc;
    ty = -256.0*center.row/sc;
  }

  void setCenter(Location location) {
    setCenter(provider.locationCoordinate(location).zoomTo(getZoom()));
  }

  void setCenterZoom(Location location, int zoom) {
    setCenter(provider.locationCoordinate(location).zoomTo(zoom));
  }

  /** sets scale according to given zoom level, should leave you with pixel perfect tiles */
  void setZoom(int zoom) {
    sc = p.pow(2.0f, zoom-1); 
  }

  void zoom(int dir) {
    sc = p.pow(2.0f, getZoom()+dir); 
  }

  void zoomIn() {
    sc = p.pow(2.0f, getZoom()+1); 
  }  

  void zoomOut() {
    sc = p.pow(2.0f, getZoom()-1); 
  }

  //	    public function setExtent(extent:MapExtent):void
  //	    public function getExtent():MapExtent

  /*
	    protected function coordinatePosition(centerCoord:Coordinate):MapPosition
   	    public function locationsPosition(locations:Array):MapPosition
   	    protected function extentPosition(extent:MapExtent):MapPosition
   */

  //	    public function getCenterZoom():Array

  AbstractMapProvider getMapProvider() {
    return this.provider;
  }

  void setMapProvider(AbstractMapProvider provider) {
    this.provider = provider;
    images.clear();
    queue.clear();
    pending.clear();
  }

  // TODO: move constructor args to match:
  //float width, float height, boolean draggable, AbstractMapProvider provider, Location[] extent

  Point2f locationPoint(Location location) {
    PMatrix m = new PMatrix();
    m.translate(width/2, height/2);
    m.scale((float)sc);
    m.translate((float)tx, (float)ty);

    Coordinate coord = provider.locationCoordinate(location).zoomTo(0);
    float[] out = new float[3];
    m.mult3(new float[] {
      coord.column*256.0f, coord.row*256.0f, 0    }
    , out);

    return new Point2f(out[0], out[1]);
  }

  Location pointLocation(Point2f point) {

    // TODO: create this matrix once and keep it around for drawing and projecting
    PMatrix m = new PMatrix();
    m.translate(width/2, height/2);
    m.scale((float)sc);
    m.translate((float)tx, (float)ty);

    // find top left and bottom right positions of map in screenspace:
    float tl[] = new float[3];
    m.mult3(new float[] { 
      0,0,0     }
    , tl);
    float br[] = new float[3];    
    m.mult3(new float[] { 
      256,256,0     }
    , br);

    float col = (point.x - tl[0]) / (br[0] - tl[0]);
    float row = (point.y - tl[1]) / (br[1] - tl[1]);
    Coordinate coord = new Coordinate(row, col, 0);

    return provider.coordinateLocation(coord);    
  }

  // TODO: pan by proportion of screen size, not by coordinate grid
  void panUp() {
    setCenter(getCenterCoordinate().up());
  }
  void panDown() {
    setCenter(getCenterCoordinate().down());
  }
  void panLeft() {
    setCenter(getCenterCoordinate().left());
  }
  void panRight() {
    setCenter(getCenterCoordinate().right());
  }

  void panAndZoomIn(Location location) {
    // TODO: animate
    setCenterZoom(location, getZoom() + 1);
  }

  void panTo(Location location) {
    // TODO: animate
    setCenter(location);
  }

  /*
	    public function putMarker(location:Location, marker:DisplayObject=null):void
   		public function getMarker(id:String):DisplayObject
   	    public function removeMarker(id:String):void
   
   	    public function setCopyright(copyright:String):void {
   */

  /*
  	    public function onStartZoom():void
   	    public function onStopZoom():void
   	    public function onZoomed(delta:Number):void
   
   	    public function onStartPan():void
   	    public function onStopPan():void
   	    public function onPanned(delta:Point):void
   
   	    public function onResized():void
   
   	    public function onExtentChanged(extent:MapExtent):void
   */



  ///////////////////////////////////////////////////////////////////////

  float scaleForZoom(int zoom) {
    return p.pow(2.0f, zoom);
  }

  float zoomForScale(float scale) {
    return p.log(scale) / p.log(2);
  }

  int bestZoomForScale(float scale) {
    return (int)p.min(20, p.max(1, (int)p.round(p.log(scale) / p.log(2))));
  }

  //////////////////////////////////////////////////////////////////////////

  void mouseDragged() {
    double dx = (double)(p.mouseX - p.pmouseX) / sc;
    double dy = (double)(p.mouseY - p.pmouseY) / sc;
    //    float angle = radians(-a);
    //    float rx = cos(angle)*dx - sin(angle)*dy;
    //    float ry = sin(angle)*dx + cos(angle)*dy;
    //    tx += rx;
    //    ty += ry;
    tx += dx;
    ty += dy;
  }

  /////////////////////////////////////////////////////////////////

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
      p.println("loading " + coord);
      String[] urls = provider.getTileUrls(coord);
      //      p.println("loading " + urls[0]);
      PImage img = p.loadImage(urls[0], "unknown");
      if (img != null) {
        for (int i = 1; i < urls.length; i++) {
          //          p.println("loading " + urls[i]);
          PImage img2 = p.loadImage(urls[i], "unknown");
          if (img2 != null) {
            img.blend(img2, 0, 0, img.width, img.height, 0, 0, img.width, img.height, BLEND);
          }
        }
      }
      tileDone(coord, img);
    }
  }

  // TODO: there could be issues when this is called from within a thread
  // probably needs synchronizing on images / pending / queue
  void tileDone(Coordinate coord, PImage img) {
    // check if we're still waiting for this (new provider clears pending)
    // also check if we got something
    if (pending.containsKey(coord) && img != null) {
      //      p.println("got " + coord + " image");
      images.put(coord, img);
      pending.remove(coord);  
    }
    else {
      //      p.println("failed to get " + coord + " image");
      //      if (img == null) {
      //        p.println("but got a null one");
      //      }
      // try again?
      // but this is a bit risky, TODO: keep track of attempts
      queue.add(coord);
      pending.remove(coord);  
    }
  }

  void processQueue() {
    while (pending.size() < MAX_PENDING && queue.size() > 0) {
      Coordinate coord = (Coordinate)queue.remove(0);
      TileLoader tileLoader = new TileLoader(coord);
      pending.put(coord, tileLoader);
      new Thread(tileLoader).start();
    }  
  }

  class QueueSorter implements Comparator {
    Coordinate center;
    public void setCenter(Coordinate center) {
      this.center = center;
    } 
    public int compare(Object o1, Object o2) {
      Coordinate c1 = (Coordinate)o1; 
      Coordinate c2 = (Coordinate)o2;
      if (c1.zoom == center.zoom) {
        if (c2.zoom == center.zoom) {
          float d1 = p.dist(center.column, center.row, c1.column, c1.row);
          float d2 = p.dist(center.column, center.row, c2.column, c2.row);
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
        float d1 = p.abs(c1.zoom - center.zoom);
        float d2 = p.abs(c2.zoom - center.zoom);
        return  d1 < d2 ? -1 : d1 > d2 ? 1 : 0;
      }
    }
  }

  class ZoomComparator implements Comparator {
    public int compare(Object o1, Object o2) {
      Coordinate c1 = (Coordinate)o1;
      Coordinate c2 = (Coordinate)o2;
      return c1.zoom < c2.zoom ? -1 : c1.zoom > c2.zoom ? 1 : 0;
    }
  }

}
