GeomCoin = inheritsFrom(GeomObject)
GeomCoin.COIN_VALUE = 1
GeomCoin.DEFAULT_WIDTH = 16
GeomCoin.DEFAULT_HEIGHT = 16
GeomCoin.DEFAULT_COLOR = {.2, 1, .4, 1}
GeomCoin.DEFAULT_HALO_TEXTURE = "Resources/Images/triglow.png"
GeomCoin.DEFAULT_SHAPE_TEXTURE = "Resources/Images/tritex.png"

function GeomCoin:constructor(w, h, x, y)
	GeomObject.constructor(self, self.DEFAULT_WIDTH, self.DEFAULT_HEIGHT, x, y)

	local poly = {
		self.width/2, 0,
		self.width, self.height,
		0, self.height,
	}
	self.fixture = self.body:addPolygon(poly)
	self.fixture:setFilter(FILTER_FRIENDLY_OBJECT)
	self.fixture:setCollisionHandler(self.onCoinCollision, MOAIBox2DArbiter.BEGIN, FILTER_PLAYER)
	self.fixture:setSensor(true)
	self.body:resetMassData()

	self:renderSprite()

	self.value = self.COIN_VALUE

	return self
end

function GeomCoin.onCoinCollision(arbiter, coinFixture, player)
	local coin = coinFixture:getBody().object
	Dispatch.triggerEvent("onCoinCollected", coin)
	coin:destroy()
end