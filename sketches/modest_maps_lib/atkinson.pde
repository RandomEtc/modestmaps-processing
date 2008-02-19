
PImage atkinsonDither(PImage toDither) {

  PImage img = createImage(toDither.width, toDither.height, ARGB);
  img.copy(toDither, 0, 0, toDither.width, toDither.height, 0, 0, toDither.width, toDither.height);
  
  img.loadPixels();
  
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {

      int old = (int)brightness(img.get(x, y));
      int nu = old < 128 ? 0 : 255;
      int err = (old - nu) >> 3; // divide by 8

      img.set(x, y, color(nu));

      int neighbors = 6;
      int nx[] = { x+1, x+2, x-1, x, x+1, x };
      int ny[] = { y, y, y+1, y+1, y+1, y+2 };

      for (int n = 0; n < neighbors; n++) {
        img.set(nx[n], ny[n], color( brightness(img.get(nx[n], ny[n])) + err));
      }
    }
  }

  img.updatePixels();

  return img;  
}
