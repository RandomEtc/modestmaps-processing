
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

  Coordinate c = fromMicrosoftRoad("0");
  println(c.column == 0.0 && c.row == 0.0 && c.zoom == 1.0);
  Coordinate d = fromMicrosoftRoad("0230102122203031");
  println(d.column == 25322.0 && d.row == 10507.0 && d.zoom == 16.0);
  Coordinate e = fromMicrosoftRoad("0230102033330212");
  println(e.column == 25333.0 && e.row == 10482.0 && e.zoom == 16.0);

  println( "0".equals( toMicrosoftRoad(0, 0, 1) ) );
  println( "0230102122203031".equals(toMicrosoftRoad(10507, 25322, 16) ) );
  println( "0230102033330212".equals(toMicrosoftRoad(10482, 25333, 16) ) );

  c = fromMicrosoftAerial("0");
  println(c.column == 0.0 && c.row == 0.0 && c.zoom == 1.0);
  d = fromMicrosoftAerial("0230102122203031");
  println(d.column == 25322.0 && d.row == 10507.0 && d.zoom == 16.0);
  e = fromMicrosoftAerial("0230102033330212");
  println(e.column == 25333.0 && e.row == 10482.0 && e.zoom == 16.0);
 
  println( "0".equals( toMicrosoftAerial(0, 0, 1) ) );
  println( "0230102122203031".equals(toMicrosoftAerial(10507, 25322, 16) ) );
  println( "0230102033330212".equals(toMicrosoftAerial(10482, 25333, 16) ) );

}



/*
String[] octalStrings = { "000", "001", "010", "011", "100", "101", "110", "111" };

def fromGoogleRoad(x, y, z) {
    """ Return column, row, zoom for Google Road tile x, y, z.
    """
    col = x
    row = y
    zoom = 17 - z
    return col, row, zoom

def toGoogleRoad(col, row, zoom) {
    """ Return x, y, z for Google Road tile column, row, zoom.
    """
    x = col
    y = row
    z = 17 - zoom
    return col, row, z

googleFromCorners = {'t' { '00', 's' { '01', 'q' { '10', 'r' { '11'}
googleToCorners = {'00' { 't', '01' { 's', '10' { 'q', '11' { 'r'}

def fromGoogleAerial(s) {
    """ Return column, row, zoom for Google Aerial tile string.
    """
    row, col = map(fromBinaryString, zip(*[list(googleFromCorners[c]) for c in s]))
    zoom = len(s) - 1
    row = int(math.pow(2, zoom) - row - 1)
    return col, row, zoom

def toGoogleAerial(col, row, zoom) {
    """ Return string for Google Road tile column, row, zoom.
    """
    x = col
    y = int(math.pow(2, zoom) - row - 1)
    z = zoom + 1
    y, x = toBinaryString(y).rjust(z, '0'), toBinaryString(x).rjust(z, '0')
    string = ''.join([googleToCorners[y[c]+x[c]] for c in range(z)])
    return string
*/

/*
def fromYahoo(x, y, z) {
    """ Return column, row, zoom for Yahoo x, y, z.
    """
    zoom = 18 - z
    row = int(math.pow(2, zoom - 1) - y - 1)
    col = x
    return col, row, zoom

def toYahoo(col, row, zoom) {
    """ Return x, y, z for Yahoo tile column, row, zoom.
    """
    x = col
    y = int(math.pow(2, zoom - 1) - row - 1)
    z = 18 - zoom
    return x, y, z

def fromYahooRoad(x, y, z) {
    """ Return column, row, zoom for Yahoo Road tile x, y, z.
    """
    return fromYahoo(x, y, z)

def toYahooRoad(col, row, zoom) {
    """ Return x, y, z for Yahoo Road tile column, row, zoom.
    """
    return toYahoo(col, row, zoom)

def fromYahooAerial(x, y, z) {
    """ Return column, row, zoom for Yahoo Aerial tile x, y, z.
    """
    return fromYahoo(x, y, z)

def toYahooAerial(col, row, zoom) {
    """ Return x, y, z for Yahoo Aerial tile column, row, zoom.
    """
    return toYahoo(col, row, zoom)

*/


//microsoftFromCorners = {'0' { '00', '1' { '01', '2' { '10', '3' { '11'}
//microsoftToCorners = {'00' { '0', '01' { '1', '10' { '2', '11' { '3'}


Coordinate fromMicrosoft(String s) {
  // Return column, row, zoom for Microsoft tile string.
  String rowS = "";
  String colS = "";
  for (int i = 0; i < s.length(); i++) {
    int v = parseInt("" + s.charAt(i));
    String bv = binary(v,2);
    rowS += bv.charAt(0);
    colS += bv.charAt(1);
  }
  return new Coordinate(unbinary(colS), unbinary(rowS), s.length());
}


String toMicrosoft(int col, int row, int zoom) {
  // Return string for Microsoft tile column, row, zoom
  String y = binary(row, zoom);
  String x = binary(col, zoom);
  String out = "";
  for (int i = 0; i < zoom; i++) {
    out += unbinary("" + y.charAt(i) + x.charAt(i));
  }
  return out;
}


Coordinate fromMicrosoftRoad(String s) {
  // Return column, row, zoom for Microsoft Road tile string.
  return fromMicrosoft(s);
}

String toMicrosoftRoad(int col, int row, int zoom) {
  // Return x, y, z for Microsoft Road tile column, row, zoom.
  return toMicrosoft(col, row, zoom);
}


Coordinate fromMicrosoftAerial(String s) {
  // Return column, row, zoom for Microsoft Aerial tile string.
  return fromMicrosoft(s);
} 

String toMicrosoftAerial(int col, int row, int zoom) {
  // Return x, y, z for Microsoft Aerial tile column, row, zoom.
  return toMicrosoft(col, row, zoom);
}
