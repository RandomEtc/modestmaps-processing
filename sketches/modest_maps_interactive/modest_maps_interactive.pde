
InteractiveMap map;

ZoomButton in, out;
PanButton up, down, left, right;
Button[] buttons;

void setup() {
  size(screen.width/2, screen.height/2);
  smooth();

  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }
  }); 

  map = new InteractiveMap(this, new Microsoft.HybridProvider(), width, height);

  Location location = new Location(37.784, -122.406); // san francisco

  map.setCenterZoom(location, 18); 

  out = new ZoomButton(5,5,14,14,false);
  in = new ZoomButton(22,5,14,14,true);
  up = new PanButton(14,25,14,14,UP);
  down = new PanButton(14,57,14,14,DOWN);
  left = new PanButton(5,41,14,14,LEFT);
  right = new PanButton(22,41,14,14,RIGHT);

  buttons = new Button[] { 
    in, out, up, down, left, right     };

  textFont(createFont("Helvetica", 12), 12);

}

void draw() {
  background(0);

  map.draw();

  boolean hand = false;
  for (int i = 0; i < buttons.length; i++) {
    buttons[i].draw();
    hand = hand || buttons[i].mouseOver();
  }

  cursor(hand ? HAND : CROSS);

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

  Location location = map.pointLocation(mouseX, mouseY);
  
  fill(0);
  noStroke();
  rect(5, height-5-g.textSize, textWidth(location.toString()), g.textSize+textDescent());
  
  fill(255);
  textAlign(LEFT, BOTTOM);
  text(location.toString(), 5, height-5);

}

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

void mouseWheel(int delta) {
  if (delta > 0) {
    map.sc *= 1.05;
  }
  else if (delta < 0) {
    map.sc *= 1.0/1.05; 
  }
}

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
