	package com.modestmaps;

	import processing.core.*;
	import java.util.*;
	import com.modestmaps.geo.*;
	import com.modestmaps.core.*;
	import com.modestmaps.providers.*;

	public class InteractiveMap implements PConstants {

	  // I have made the dumb mistake of getting these wrong before...
	  // it's REALLY unlikely you'll want to change them:
	  public int TILE_WIDTH = 256;
	  public int TILE_HEIGHT = 256;
	  
	  // unavoidable right now, for loadImage and float maths
	  public PApplet p;

	  // pan and zoom
	  public double tx = -TILE_WIDTH/2; // half the world width, at zoom 0
	  public double ty = -TILE_HEIGHT/2; // half the world height, at zoom 0
	  public double sc = 1;

	  // limit simultaneous calls to loadImage
	  public int MAX_PENDING = 4;
	  
	  // limit tiles in memory
	  // 256 would be 64 MB, you may want to lower this quite a bit for your app
	  public int MAX_IMAGES_TO_KEEP = 256;

	  // upping this can help appearances when zooming out, but also loads many more tiles
	  public int GRID_PADDING = 1;

	  // what kinda maps?
	  public AbstractMapProvider provider;

	  // how big?
	  public float width, height;

	  // loading tiles
	  public Hashtable pending = new Hashtable(); // coord -> TileLoader
	  // loaded tiles
	  public Hashtable images = new Hashtable();  // coord -> PImage
	  // coords waiting to load
	  public Vector queue = new Vector();
	  // a list of the most recent MAX_IMAGES_TO_KEEP PImages we've seen
	  public Vector recentImages = new Vector();

	  // for sorting coordinates by zoom
	  public ZoomComparator zoomComparator = new ZoomComparator();

	  // for loading tiles from the inside first
	  public QueueSorter queueSorter = new QueueSorter();

	  /** default to Microsoft Hybrid */
	  public InteractiveMap(PApplet p) {
	    this(p, new Microsoft.HybridProvider());
	  }

	  /** new map using applet width and height, and given provider */
	  public InteractiveMap(PApplet p, AbstractMapProvider provider) {
	    this(p, provider, p.width, p.height);
	  }

	  /** make a new interactive map, using the given provider, of the given width and height */
	  public InteractiveMap(PApplet p, AbstractMapProvider provider, float width, float height) {

	    this.p = p;
	    this.provider = provider;
	    this.width = width;
	    this.height = height;

	    // fit to screen
	    sc = p.ceil(p.min(height/(float)TILE_WIDTH, width/(float)TILE_HEIGHT));

	  }

	  /** draw the map on the given PApplet */
	  public void draw() {

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

	    // what power of 2 are we at?
	    // 0 when scale is around 1, 1 when scale is around 2, 
	    // 2 when scale is around 4, 3 when scale is around 8, etc.
	    int zoom = bestZoomForScale((float)sc);

	    // how many columns and rows of tiles at this zoom?
	    // (this is basically (int)sc, but let's derive from zoom to be sure 
	    int cols = (int)p.pow(2,zoom);
	    int rows = (int)p.pow(2,zoom);

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
		    Coordinate[] kids = { zoomed, zoomed.right(), zoomed.down(), zoomed.right().down() }; 
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
		  p.image(tile,coord.column*TILE_WIDTH,coord.row*TILE_HEIGHT,TILE_WIDTH,TILE_HEIGHT);
		  if (recentImages.contains(tile)) {
		    recentImages.remove(tile);
		  }
		  recentImages.add(tile);
		}
	      }
	      p.popMatrix();
	    }    

	    p.popMatrix();

	    // stop fetching things we can't see:
	    // (visibleKeys also has the parents and children, if needed, but that shouldn't matter)
	    queue.retainAll(visibleKeys);

	    // sort what's left by distance from center:
	    queueSorter.setCenter(new Coordinate( (minRow + maxRow) / 2.0f, (minCol + maxCol) / 2.0f, zoom));
	    Collections.sort(queue, queueSorter);

	    // load up to 4 more things:
	    processQueue();

	    // clear some images away if we have too many...
	    if (recentImages.size() > MAX_IMAGES_TO_KEEP) {
	      recentImages.subList(0, recentImages.size()-MAX_IMAGES_TO_KEEP).clear();
	      images.values().retainAll(recentImages);
	    }

	    // restore smoothing, if needed
	    if (smooth) {
	      p.smooth();
	    }

	  } 

	  /** @return zoom level of currently visible tile layer */
	  public int getZoom() {
	    return bestZoomForScale((float)sc);
	  }

	  public Location getCenter() {
	    return provider.coordinateLocation(getCenterCoordinate());
	  }

	  public Coordinate getCenterCoordinate() {
	    float row = (float)(ty*sc/-TILE_WIDTH);
	    float column = (float)(tx*sc/-TILE_HEIGHT);
	    float zoom = zoomForScale((float)sc);
	    return new Coordinate(row, column, zoom); 
	  }

	  public void setCenter(Coordinate center) {
	    //println("setting center to " + center);
	    sc = p.pow(2.0f, center.zoom);
	    tx = -TILE_WIDTH*center.column/sc;
	    ty = -TILE_HEIGHT*center.row/sc;
	  }

	  public void setCenter(Location location) {
	    setCenter(provider.locationCoordinate(location).zoomTo(getZoom()));
	  }

	  public void setCenterZoom(Location location, int zoom) {
	    setCenter(provider.locationCoordinate(location).zoomTo(zoom));
	  }

	  /** sets scale according to given zoom level, should leave you with pixel perfect tiles */
	  public void setZoom(int zoom) {
	    sc = p.pow(2.0f, zoom); 
	  }

	  public void zoom(int dir) {
	    sc = p.pow(2.0f, getZoom()+dir); 
	  }

	  public void zoomIn() {
	    sc = p.pow(2.0f, getZoom()+1); 
	  }  

	  public void zoomOut() {
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

	  public AbstractMapProvider getMapProvider() {
	    return this.provider;
	  }

	  public void setMapProvider(AbstractMapProvider provider) {
	    if (this.provider.getClass() != provider.getClass()) {
	      this.provider = provider;
	      images.clear();
	      queue.clear();
	      pending.clear();
	    }
	  }

	  public Point2f locationPoint(Location location) {
	    PMatrix2D m = new PMatrix2D();
	    m.translate(width/2, height/2);
	    m.scale((float)sc);
	    m.translate((float)tx, (float)ty);

	    Coordinate coord = provider.locationCoordinate(location).zoomTo(0);
	    float[] out = new float[2];
	    m.mult(new float[] {
	      coord.column*TILE_WIDTH, coord.row*TILE_HEIGHT    }
	    , out);

	    return new Point2f(out[0], out[1]);
	  }

	  public Location pointLocation(Point2f point) {
	    return pointLocation(point.x, point.y); 
	  }

	  public Location pointLocation(float x, float y) {

	    // TODO: create this matrix once and keep it around for drawing and projecting
	    PMatrix2D m = new PMatrix2D();
    m.translate(width/2, height/2);
    m.scale((float)sc);
    m.translate((float)tx, (float)ty);

    // find top left and bottom right positions of map in screenspace:
    float tl[] = new float[2];
    m.mult(new float[] { 
      0,0     }
    , tl);
    float br[] = new float[2];    
    m.mult(new float[] { 
      TILE_WIDTH, TILE_HEIGHT     }
    , br);

    float col = (x - tl[0]) / (br[0] - tl[0]);
    float row = (y - tl[1]) / (br[1] - tl[1]);
    Coordinate coord = new Coordinate(row, col, 0);

    return provider.coordinateLocation(coord);    
  }

  // TODO: pan by proportion of screen size, not by coordinate grid
  public void panUp() {
    setCenter(getCenterCoordinate().up());
  }
  public void panDown() {
    setCenter(getCenterCoordinate().down());
  }
  public void panLeft() {
    setCenter(getCenterCoordinate().left());
  }
  public void panRight() {
    setCenter(getCenterCoordinate().right());
  }

  public void panAndZoomIn(Location location) {
    // TODO: animate
    setCenterZoom(location, getZoom() + 1);
  }

  public void panTo(Location location) {
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

  public float scaleForZoom(int zoom) {
    return p.pow(2.0f, zoom);
  }

  public float zoomForScale(float scale) {
    return p.log(scale) / p.log(2);
  }

  public int bestZoomForScale(float scale) {
    return (int)p.min(20, p.max(1, (int)p.round(p.log(scale) / p.log(2))));
  }

  //////////////////////////////////////////////////////////////////////////

  public void mouseDragged() {
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

  public void grabTile(Coordinate coord) {
    if (!pending.containsKey(coord) && !queue.contains(coord) && !images.containsKey(coord)) {
      //    println("adding " + coord.toString() + " to queue");
      queue.add(coord);
    }
  }

  public class TileLoader implements Runnable {
    Coordinate coord;
    TileLoader(Coordinate coord) {
      this.coord = coord; 
    }
    public void run() {
      String[] urls = provider.getTileUrls(coord);
      PImage img = p.loadImage(urls[0], "unknown"); // use unknown to let loadImage decide
      if (img != null) {
        for (int i = 1; i < urls.length; i++) {
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
  public void tileDone(Coordinate coord, PImage img) {
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

  public void processQueue() {
    while (pending.size() < MAX_PENDING && queue.size() > 0) {
      Coordinate coord = (Coordinate)queue.remove(0);
      TileLoader tileLoader = new TileLoader(coord);
      pending.put(coord, tileLoader);
      new Thread(tileLoader).start();
    }  
  }

  public class QueueSorter implements Comparator {
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

  public class ZoomComparator implements Comparator {
    public int compare(Object o1, Object o2) {
      Coordinate c1 = (Coordinate)o1;
      Coordinate c2 = (Coordinate)o2;
      return c1.zoom < c2.zoom ? -1 : c1.zoom > c2.zoom ? 1 : 0;
    }
  }

}
