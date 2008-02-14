
/*

ROAD_VERSION = 'w2.66'
AERIAL_VERSION = '24'
HYBRID_VERSION = 'w2t.66'
TERRAIN_VERSION = 'w2p.64'

class AbstractProvider(IMapProvider):
    def __init__(self):
        t = Transformation(1.068070779e7, 0, 3.355443185e7,
		                   0, -1.068070890e7, 3.355443057e7)

        self.projection = MercatorProjection(26, t)

    def getZoomString(self, coordinate):
        raise NotImplementedError()

    def tileWidth(self):
        return 256

    def tileHeight(self):
        return 256

class RoadProvider(AbstractProvider):
    def getTileUrls(self, coordinate):
        return ('http://mt%d.google.com/mt?n=404&v=%s&%s' % (random.randint(0, 3), ROAD_VERSION, self.getZoomString(self.sourceCoordinate(coordinate))),)
        
    def getZoomString(self, coordinate):
        return 'x=%d&y=%d&zoom=%d' % Tiles.toGoogleRoad(int(coordinate.column), int(coordinate.row), int(coordinate.zoom))

class AerialProvider(AbstractProvider):
    def getTileUrls(self, coordinate):
        return ('http://kh%d.google.com/kh?n=404&v=%s&t=%s' % (random.randint(0, 3), AERIAL_VERSION, self.getZoomString(self.sourceCoordinate(coordinate))),)

    def getZoomString(self, coordinate):
        return Tiles.toGoogleAerial(int(coordinate.column), int(coordinate.row), int(coordinate.zoom))

class HybridProvider(AbstractProvider):
    def getTileUrls(self, coordinate):
        under = AerialProvider().getTileUrls(coordinate)[0]
        over = 'http://mt%d.google.com/mt?n=404&v=%s&%s' % (random.randint(0, 3), HYBRID_VERSION, RoadProvider().getZoomString(self.sourceCoordinate(coordinate)))
        return (under, over)

class TerrainProvider(RoadProvider):
    def getTileUrls(self, coordinate):
        return ('http://mt%d.google.com/mt?n=404&v=%s&%s' % (random.randint(0, 3), TERRAIN_VERSION, self.getZoomString(self.sourceCoordinate(coordinate))),)

*/
