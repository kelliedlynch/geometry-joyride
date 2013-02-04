GeomRectangle = inheritsFrom(GeomObject)
GeomRectangle.DEFAULT_WIDTH = 16
GeomRectangle.DEFAULT_HEIGHT = 16
GeomRectangle.DEFAULT_COLOR = {.2, 1, .4, 1}
GeomRectangle.DEFAULT_HALO_TEXTURE = "Resources/Images/rectglow.png"
GeomRectangle.DEFAULT_SHAPE_TEXTURE = "Resources/Images/recttex.png"

function GeomRectangle:constructor(w, h, x, y)
	GeomObject.constructor(self, w, h, x, y)

	self.fixture = self.body:addRect(0, 0, w, h)
	self.fixture:setFilter(FILTER_DEADLY_OBJECT)
	self.body:resetMassData()

	self:renderSprite()

	return self
end