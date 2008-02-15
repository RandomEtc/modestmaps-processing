
boolean runTests(boolean quiet) {
  boolean passed = true;
  passed = passed && doMapTests(quiet); 
  passed = passed && doYahooTests(quiet); 
  doTilesTest();
  doMicrosoftTest();
  doGoogleTest();
  doGeoTest();
  doCoreTest();
  return passed;
}


boolean doMapTests(boolean quiet) {
  if (!quiet) {
    println();
    println("map test");
    println();  
  }

  boolean passed = true;

  MMap m = new MMap(this, new Google.RoadProvider(), new Point2f(600, 600), new Coordinate(3165, 1313, 13), new Point2f(-144, -94));
  Point2f p = m.locationPoint(new Location(37.804274, -122.262940));
  passed = passed && p.toString().equals("(370.688, 342.438)");
  if (!quiet) println(passed);
  // !!! this is what the python version gives (probably floats vs doubles?)
  //println( p.toString().equals("(370.724, 342.549)") );
  Location l = m.pointLocation(p);
  passed = passed && l.toString().equals("(37.804, -122.263)");
  if (!quiet) println(passed);
  
  return passed;
}


boolean doYahooTests(boolean quiet) {
  if (!quiet) {
    println();
    println("yahoo test");
    println();  
  }
  
  boolean passed = true;
  
  AbstractMapProvider p = new Yahoo.RoadProvider();
  String[] urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println(urls);
  passed = passed && urls[0].startsWith("http://us.maps2.yimg.com/us.png.maps.yimg.com/png?v=");
  passed = passed && urls[0].endsWith("&t=m&x=10507&y=7445&z=2");
  if (!quiet) println("1: " + passed);
  
  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  passed = passed && urls[0].startsWith("http://us.maps2.yimg.com/us.png.maps.yimg.com/png?v=");
  passed = passed && urls[0].endsWith("&t=m&x=10482&y=7434&z=2");
  if (!quiet) println("2: " + passed);

  p = new Yahoo.AerialProvider();
  urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  passed = passed && urls[0].startsWith("http://us.maps3.yimg.com/aerial.maps.yimg.com/tile?v=");
  passed = passed && urls[0].endsWith("&t=a&x=10507&y=7445&z=2");
  if (!quiet) println("3: " + passed);

  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  passed = passed && urls[0].startsWith("http://us.maps3.yimg.com/aerial.maps.yimg.com/tile?v=");
  passed = passed && urls[0].endsWith("&t=a&x=10482&y=7434&z=2");
  if (!quiet) println("4: " + passed);

  p = new Yahoo.HybridProvider();
  urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  passed = passed && urls[0].startsWith("http://us.maps3.yimg.com/aerial.maps.yimg.com/tile?v=");
  passed = passed && urls[0].endsWith("&t=a&x=10507&y=7445&z=2");
  passed = passed && urls[1].startsWith("http://us.maps3.yimg.com/aerial.maps.yimg.com/png?v=");
  passed = passed && urls[1].endsWith("&t=h&x=10507&y=7445&z=2");
  if (!quiet) println("5: " + passed);

  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  passed = passed && urls[0].startsWith("http://us.maps3.yimg.com/aerial.maps.yimg.com/tile?v=");
  passed = passed && urls[0].endsWith("&t=a&x=10482&y=7434&z=2");
  passed = passed && urls[1].startsWith("http://us.maps3.yimg.com/aerial.maps.yimg.com/png?v=");
  passed = passed && urls[1].endsWith("&t=h&x=10482&y=7434&z=2");
  if (!quiet) println("6: " + passed);
  
  return passed;
}

void doTilesTest() {
  println();
  println("tiles test");
  println();  

  println( "1".equals(binary(1)) );
  println( "10".equals(binary(2)) );
  println( "11".equals(binary(3)) );
  println( "100".equals(binary(4)) );

  println( 1 == unbinary("1") );
  println( 3 == unbinary("11") );
  println( 5 == unbinary("101") );
  println( 9 == unbinary("1001") );

/*
>>> fromGoogleRoad(0, 0, 16)
   (0, 0, 1)
   >>> fromGoogleRoad(10507, 25322, 1)
   (10507, 25322, 16)
   >>> fromGoogleRoad(10482, 25333, 1)
   (10482, 25333, 16)
   
   >>> toGoogleRoad(0, 0, 1)
   (0, 0, 16)
   >>> toGoogleRoad(10507, 25322, 16)
   (10507, 25322, 1)
   >>> toGoogleRoad(10482, 25333, 16)
   (10482, 25333, 1)
   
   >>> fromGoogleAerial('tq')
   (0, 0, 1)
   >>> fromGoogleAerial('tqtsqrqtrtttqsqsr')
   (10507, 25322, 16)
   >>> fromGoogleAerial('tqtsqrqtqssssqtrt')
   (10482, 25333, 16)
   
   >>> toGoogleAerial(0, 0, 1)
   'tq'
   >>> toGoogleAerial(10507, 25322, 16)
   'tqtsqrqtrtttqsqsr'
   >>> toGoogleAerial(10482, 25333, 16)
   'tqtsqrqtqssssqtrt'
*/
/*   
   >>> fromYahooRoad(0, 0, 17)
   (0, 0, 1)
   >>> fromYahooRoad(10507, 7445, 2)
   (10507, 25322, 16)
   >>> fromYahooRoad(10482, 7434, 2)
   (10482, 25333, 16)
   
   >>> toYahooRoad(0, 0, 1)
   (0, 0, 17)
   >>> toYahooRoad(10507, 25322, 16)
   (10507, 7445, 2)
   >>> toYahooRoad(10482, 25333, 16)
   (10482, 7434, 2)
   
   >>> fromYahooAerial(0, 0, 17)
   (0, 0, 1)
   >>> fromYahooAerial(10507, 7445, 2)
   (10507, 25322, 16)
   >>> fromYahooAerial(10482, 7434, 2)
   (10482, 25333, 16)
   
   >>> toYahooAerial(0, 0, 1)
   (0, 0, 17)
   >>> toYahooAerial(10507, 25322, 16)
   (10507, 7445, 2)
   >>> toYahooAerial(10482, 25333, 16)
   (10482, 7434, 2)
   
   */

  Coordinate c = Tiles.fromMicrosoftRoad("0");
  println(c.column == 0.0 && c.row == 0.0 && c.zoom == 1.0);
  Coordinate d = Tiles.fromMicrosoftRoad("0230102122203031");
  println(d.column == 25322.0 && d.row == 10507.0 && d.zoom == 16.0);
  Coordinate e = Tiles.fromMicrosoftRoad("0230102033330212");
  println(e.column == 25333.0 && e.row == 10482.0 && e.zoom == 16.0);

  println( "0".equals( Tiles.toMicrosoftRoad(0, 0, 1) ) );
  println( "0230102122203031".equals(Tiles.toMicrosoftRoad(10507, 25322, 16) ) );
  println( "0230102033330212".equals(Tiles.toMicrosoftRoad(10482, 25333, 16) ) );

  c = Tiles.fromMicrosoftAerial("0");
  println(c.column == 0.0 && c.row == 0.0 && c.zoom == 1.0);
  d = Tiles.fromMicrosoftAerial("0230102122203031");
  println(d.column == 25322.0 && d.row == 10507.0 && d.zoom == 16.0);
  e = Tiles.fromMicrosoftAerial("0230102033330212");
  println(e.column == 25333.0 && e.row == 10482.0 && e.zoom == 16.0);

  println( "0".equals( Tiles.toMicrosoftAerial(0, 0, 1) ) );
  println( "0230102122203031".equals(Tiles.toMicrosoftAerial(10507, 25322, 16) ) );
  println( "0230102033330212".equals(Tiles.toMicrosoftAerial(10482, 25333, 16) ) );

}

void doMicrosoftTest() {
  println();
  println("microsoft test");
  println();
  
  AbstractMapProvider p = new Microsoft.RoadProvider();
  String[] urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println( urls[0].startsWith("http://r") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/r0230102122203031.png?g=90&shading=hill") );
  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println( urls[0].startsWith("http://r") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/r0230102033330212.png?g=90&shading=hill") );

  p = new Microsoft.AerialProvider();
  urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println( urls[0].startsWith("http://a") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/a0230102122203031.jpeg?g=90") );
  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println( urls[0].startsWith("http://a") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/a0230102033330212.jpeg?g=90") );

  p = new Microsoft.HybridProvider();
  urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println( urls[0].startsWith("http://h") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/h0230102122203031.jpeg?g=90") );
  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println( urls[0].startsWith("http://h") && urls[0].endsWith(".ortho.tiles.virtualearth.net/tiles/h0230102033330212.jpeg?g=90") );

}

void doGoogleTest() {

  println();
  println("google test");
  println();

  AbstractMapProvider p = new Google.RoadProvider();
  String[] urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println(urls);
  println( urls[0].startsWith("http://mt") && urls[0].endsWith("&x=10507&y=25322&zoom=1") ); //('....google.com/mt?n=404&v=...',)

  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println( urls[0].startsWith("http://mt") && urls[0].endsWith("&x=10482&y=25333&zoom=1") ); //('....google.com/mt?n=404&v=...',)

  p = new Google.AerialProvider();
  urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println( urls[0].startsWith("http://kh") && urls[0].endsWith("&t=tqtsqrqtrtttqsqsr") ); //google.com/kh?n=404&v=

  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println( urls[0].startsWith("http://kh") && urls[0].endsWith("&t=tqtsqrqtqssssqtrt") ); //google.com/kh?n=404&v=

  p = new Google.HybridProvider();
  urls = p.getTileUrls(new Coordinate(25322, 10507, 16));
  println(urls);
  println( urls[0].startsWith("http://kh") && urls[0].endsWith("&t=tqtsqrqtrtttqsqsr") ); //google.com/kh?n=404&v=
  println( urls[1].startsWith("http://mt") && urls[1].endsWith("&x=10507&y=25322&zoom=1") ); //google.com/mt?n=404&v=

  urls = p.getTileUrls(new Coordinate(25333, 10482, 16));
  println(urls);
  println( urls[0].startsWith("http://kh") && urls[0].endsWith("&t=tqtsqrqtqssssqtrt") ); //google.com/kh?n=404&v=
  println( urls[1].startsWith("http://mt") && urls[1].endsWith("&x=10482&y=25333&zoom=1") ); //google.com/mt?n=404&v=
}

void doGeoTest() {

  println();
  println("geo test");
  println();

  Transformation t = new Transformation(1, 0, 0, 0, 1, 0);
  Point2f p = new Point2f(1, 1);
  println( p.toString().equals("(1.000, 1.000)") );

  Point2f p_ = t.transform(p);
  println( p_.toString().equals("(1.000, 1.000)") );
  
  Point2f p__ = t.untransform(p_);
  println( p__.toString().equals("(1.000, 1.000)") );

  t = new Transformation(0, 1, 0, 1, 0, 0);
  p = new Point2f(0, 1);
  println( p.toString().equals("(0.000, 1.000)") );
  p_ = t.transform(p);
  println( p_.toString().equals("(1.000, 0.000)") );
  p__ = t.untransform(p_);
  // !!! I will accept -0 here, but clearly something is a bit hairy
  println( p__.toString().equals("(0.000, 1.000)") || p__.toString().equals("(-0.000, 1.000)") );

  t = new Transformation(1, 0, 1, 0, 1, 1);
  p = new Point2f(0, 0);
  println( p.toString().equals("(0.000, 0.000)") );
  p_ = t.transform(p);
  println( p_.toString().equals("(1.000, 1.000)") );
  p__ = t.untransform(p_);
  // !!! I will accept -0 here, but clearly something is a bit hairy
  println( p__.toString().equals("(0.000, 0.000)") || p__.toString().equals("(0.000, -0.000)") );

  AbstractProjection m = new MercatorProjection(10);
  Coordinate c = m.locationCoordinate(new Location(0, 0));
  // !!! python version has a negative here, but I think this is OK
  println( c.toString().equals("(-0.000, 0.000 @10.000)") || c.toString().equals("(0.000, 0.000 @10.000)") );

  Location l = m.coordinateLocation(new Coordinate(0, 0, 10));
  println( l.toString().equals("(0.000, 0.000)") );

  c = m.locationCoordinate(new Location(37, -122));
  println( c.toString().equals("(0.696, -2.129 @10.000)") );
  
  l = m.coordinateLocation(new Coordinate(0.696, -2.129, 10.000));
  println( l.toString().equals("(37.001, -121.983)") );

}

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
