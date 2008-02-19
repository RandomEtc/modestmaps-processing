
class Button {
  
  float x, y, w, h;
  
  Button(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  } 
  
  boolean mouseOver() {
    return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
  }
  
  void draw() {
    stroke(80);
    fill(mouseOver() ? 255 : 220);
    rect(x,y,w,h); 
  }
  
}

class ZoomButton extends Button {
  
  boolean in = false;
  
  ZoomButton(float x, float y, float w, float h, boolean in) {
    super(x, y, w, h);
    this.in = in;
  }
  
  void draw() {
    super.draw();
    stroke(0);
    line(x+3,y+h/2,x+w-3,y+h/2);
    if (in) {
      line(x+w/2,y+3,x+w/2,y+h-3);
    }
  }
  
}

class PanButton extends Button {
  
  int dir = UP;
  
  PanButton(float x, float y, float w, float h, int dir) {
    super(x, y, w, h);
    this.dir = dir;
  }
  
  void draw() {
    super.draw();
    stroke(0);
    switch(dir) {
      case UP:
        line(x+w/2,y+3,x+w/2,y+h-3);
        line(x-3+w/2,y+6,x+w/2,y+3);
        line(x+3+w/2,y+6,x+w/2,y+3);
        break;
      case DOWN:
        line(x+w/2,y+3,x+w/2,y+h-3);
        line(x-3+w/2,y+h-6,x+w/2,y+h-3);
        line(x+3+w/2,y+h-6,x+w/2,y+h-3);
        break;
      case LEFT:
        line(x+3,y+h/2,x+w-3,y+h/2);
        line(x+3,y+h/2,x+6,y-3+h/2);
        line(x+3,y+h/2,x+6,y+3+h/2);
        break;
      case RIGHT:
        line(x+3,y+h/2,x+w-3,y+h/2);
        line(x+w-3,y+h/2,x+w-6,y-3+h/2);
        line(x+w-3,y+h/2,x+w-6,y+3+h/2);
        break;
    }
  }
  
}
