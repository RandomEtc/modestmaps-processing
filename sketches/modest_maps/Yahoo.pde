
/*

ROAD_VERSION = '3.52'
AERIAL_VERSION = '1.7'
HYBRID_VERSION = '2.2'

class AbstractProvider(IMapProvider):
    def __init__(self):
        t = Transformation(1.068070779e7, 0, 3.355443185e7,
		                   0, -1.068070890e7, 3.355443057e7)

        self.projection = MercatorProjection(26, t)

    def getZoomString(self, coordinate):
        return 'x=%d&y=%d&z=%d' % Tiles.toYahoo(int(coordinate.column), int(coordinate.row), int(coordinate.zoom))

    def tileWidth(self):
        return 256

    def tileHeight(self):
        return 256

class RoadProvider(AbstractProvider):
    def getTileUrls(self, coordinate):
        return ('http://us.maps2.yimg.com/us.png.maps.yimg.com/png?v=%s&t=m&%s' % (ROAD_VERSION, self.getZoomString(self.sourceCoordinate(coordinate))),)

class AerialProvider(AbstractProvider):
    def getTileUrls(self, coordinate):
        return ('http://us.maps3.yimg.com/aerial.maps.yimg.com/tile?v=%s&t=a&%s' % (AERIAL_VERSION, self.getZoomString(self.sourceCoordinate(coordinate))),)

class HybridProvider(AbstractProvider):
    def getTileUrls(self, coordinate):
        under = AerialProvider().getTileUrls(coordinate)[0]
        over = 'http://us.maps3.yimg.com/aerial.maps.yimg.com/png?v=%s&t=h&%s' % (HYBRID_VERSION, self.getZoomString(self.sourceCoordinate(coordinate)))
        return (under, over)

*/
