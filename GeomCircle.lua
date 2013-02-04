GeomCircle = inheritsFrom(GeomObject)
GeomCircle.DEFAULT_WIDTH = 16
GeomCircle.DEFAULT_HEIGHT = 16
GeomCircle.DEFAULT_COLOR = {1, .8, .8, 1}
GeomCircle.DEFAULT_HALO_TEXTURE = "Resources/Images/circle1glow.png"
GeomCircle.DEFAULT_SHAPE_TEXTURE = "Resources/Images/circle1tex.png"

function GeomCircle:constructor(w, h, x, y)
	GeomObject.constructor(self, w, h, x, y)

	self.fixture = self.body:addCircle(w/2, w/2, w/2)
	self.fixture:setFilter(FILTER_DEADLY_OBJECT)
	self.body:resetMassData()

	self:renderSprite()

	return self
end