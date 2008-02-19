
//
// This is a test of the interactive Modest Maps library for Processing
// the modestmaps.jar in the code folder of this sketch might not be 
// entirely up to date - you have been warned!
//

// this is the only bit that's needed to show a map:
InteractiveMap map;

// buttons take x,y and width,height:
ZoomButton out = new ZoomButton(5,5,14,14,false);
ZoomButton in = new ZoomButton(22,5,14,14,true);
PanButton up = new PanButton(14,25,14,14,UP);
PanButton down = new PanButton(14,57,14,14,DOWN);
PanButton left = new PanButton(5,41,14,14,LEFT);
PanButton right = new PanButton(22,41,14,14,RIGHT);

// all the buttons in one place, for looping:
Button[] buttons = { in, out, up, down, left, right };

PFont font;

void setup() {
  size(600, 400);
  smooth();

  // create a new map, optionally specify a provider
  map = new InteractiveMap(this, new Microsoft.HybridProvider());

  // set the initial location and zoom level to London:
  map.setCenterZoom(new Location(51.500, -0.126), 11);
  // zoom 0 is the whole world, 19 is street level
  // (try some out, or use getlatlon.com to search for more)

  // set a default font for labels
  font = createFont("Helvetica", 12);

  // enable the mouse wheel, for zooming
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }
  }); 

}

void draw() {
  background(0);

  // draw the map:
  map.draw();
  // (that's it! really... everything else is interactions now)

  // draw all the buttons and check for mouse-over
  boolean hand = false;
  for (int i = 0; i < buttons.length; i++) {
    buttons[i].draw();
    hand = hand || buttons[i].mouseOver();
  }

  // if we're over a button, use the finger pointer
  // otherwise use the cross
  // (I wish Java had the open/closed hand for "move" cursors)
  cursor(hand ? HAND : CROSS);

  // see if the arrow keys or +/- keys are pressed:
  // (also check space and z, to reset or round zoom levels)
  if (keyPressed) {
    if (key == CODED) {
      if (keyCode == LEFT) {
        map.tx += 5.0/map.sc;
      }
      else if (keyCode == RIGHT) {
        map.tx -= 5.0/map.sc;
      }
      else if (keyCode == UP) {
        map.ty += 5.0/map.sc;
      }
      else if (keyCode == DOWN) {
        map.ty -= 5.0/map.sc;
      }
    }  
    else if (key == '+' || key == '=') {
      map.sc *= 1.05;
    }
    else if (key == '_' || key == '-' && map.sc > 2) {
      map.sc *= 1.0/1.05;
    }
    else if (key == 'z' || key == 'Z') {
      map.sc = pow(2, map.getZoom());
    }
    else if (key == ' ') {
      map.sc = 2.0;
      map.tx = -128;
      map.ty = -128; 
    }
  }

  textFont(font, 12);

  // grab the lat/lon location under the mouse point:
  Location location = map.pointLocation(mouseX, mouseY);
  
  // draw the mouse location, bottom left:
  fill(0);
  noStroke();
  rect(5, height-5-g.textSize, textWidth("mouse: " + location), g.textSize+textDescent());
  fill(255,255,0);
  textAlign(LEFT, BOTTOM);
  text("mouse: " + location, 5, height-5);
  
  // grab the center
  location = map.pointLocation(width/2, height/2);
  
  // draw the center location, bottom right:
  fill(0);
  noStroke();
  float rw = textWidth("map: " + location);
  rect(width-5-rw, height-5-g.textSize, rw, g.textSize+textDescent());
  fill(255,255,0);
  textAlign(RIGHT, BOTTOM);
  text("map: " + location, width-5, height-5);
}

// see if we're over any buttons, otherwise tell the map to drag
void mouseDragged() {
  boolean hand = false;
  for (int i = 0; i < buttons.length; i++) {
    hand = hand || buttons[i].mouseOver();
    if (hand) break;
  }
  if (!hand) {
    map.mouseDragged(); 
  }
}

// zoom in or out:
void mouseWheel(int delta) {
  if (delta > 0) {
    map.sc *= 1.05;
  }
  else if (delta < 0) {
    map.sc *= 1.0/1.05; 
  }
}

// see if we're over any buttons, and respond accordingly:
void mouseClicked() {
  if (in.mouseOver()) {
    map.zoomIn();
  }
  else if (out.mouseOver()) {
    map.zoomOut();
  }
  else if (up.mouseOver()) {
    map.panUp();
  }
  else if (down.mouseOver()) {
    map.panDown();
  }
  else if (left.mouseOver()) {
    map.panLeft();
  }
  else if (right.mouseOver()) {
    map.panRight();
  }
}
