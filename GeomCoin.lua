GeomCoin = inheritsFrom(GeomObject)
GeomCoin.COIN_VALUE = 1
GeomCoin.DEFAULT_WIDTH = 16
GeomCoin.DEFAULT_HEIGHT = 16
GeomCoin.DEFAULT_COLOR = {.2, 1, .4, 1}
GeomCoin.DEFAULT_HALO_TEXTURE = "Resources/Images/triglow.png"
GeomCoin.DEFAULT_SHAPE_TEXTURE = "Resources/Images/tritex.png"

function GeomCoin:constructor(y)
	GeomObject.constructor(self, self.DEFAULT_WIDTH, self.DEFAULT_HEIGHT, 0, y)

	local poly = {
		self.posX, self.posY,
		self.posX + self.width, self.posY,
		self.posX + self.width/2, self.posY + self.height,
	}
	local kfix = self.body:addPolygon(poly)
	kfix:setFilter(FILTER_FRIENDLY_OBJECT)
	kfix:setCollisionHandler(self.onCoinCollision, MOAIBox2DArbiter.BEGIN, FILTER_PLAYER)
	kfix:setSensor(true)
	self.body:resetMassData()
	self:setSpeed(_G.game.player.speed)

	self:renderSprite()

	self.value = self.COIN_VALUE

	return self
end

function GeomCoin.onCoinCollision(arbiter, coinFixture, player)
	local coin = coinFixture:getBody().object
	Dispatch.triggerEvent("onCoinCollected", coin)
	coin:destroy()
end