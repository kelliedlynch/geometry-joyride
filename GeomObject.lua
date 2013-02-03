--------------------------------------------------------------------
-- BASE CLASS FOR ALL TERRAIN AND ENEMY OBJECTS
--------------------------------------------------------------------

GeomObject = inheritsFrom()

function GeomObject:constructor(w, h, x, y)
	if x and y then
		self.posX = x
		self.posY = y
	elseif x and not y then
		self.posX = 0
		self.posY = x
	else
		self.posX = 0
		self.posY = 0
	end

	self.width, self.height = w, h

	self.body = _G.world:addBody(MOAIBox2DBody.KINEMATIC)
	self.body.width, self.body.height = w, h
	self.destroyAt = -_G.screenWidth/2 - self.posX - w - 10
	self.body.object = self

	Dispatch.registerEvent("onUpdateSpeed", self, true)

	self.thread = MOAICoroutine.new()
	self.thread:run(self.animate, self)
end

function GeomObject:animate()
	while self.body:getPosition() > self.destroyAt do 
		coroutine.yield()
	end
	self:destroy()
end

function GeomObject:renderSprite()
	local gfxQuad1 = MOAIGfxQuad2D.new()
	gfxQuad1:setTexture(self.DEFAULT_HALO_TEXTURE)
	gfxQuad1:setRect (self.posX, self.posY, self.posX + self.width, self.posY + self.height)

	local halo = MOAIProp2D.new()
	halo:setDeck(gfxQuad1)
	halo:setColor(unpack(self.DEFAULT_COLOR))
	_G.gameLayer:insertProp(halo)

	local gfxQuad2 = MOAIGfxQuad2D.new()
	gfxQuad2:setTexture(self.DEFAULT_SHAPE_TEXTURE)
	gfxQuad2:setRect(self.posX, self.posY, self.posX + self.width, self.posY + self.height)

	local shape = MOAIProp2D.new()
	shape:setDeck(gfxQuad2)
	shape:setColor(unpack(self.DEFAULT_COLOR))
	_G.gameLayer:insertProp(shape)

	halo:setParent(shape)
	shape:setParent(self.body)
	self.shape = shape
	self.halo = halo
end

function GeomObject:setSpeed(speed)
	self.body:setLinearVelocity(speed, 0)
	self.body.speed = speed
end

function GeomObject:setPosition(x, y)
	self.body:setTransform(x, y)
	self.destroyAt = self.destroyAt - x
end

function GeomObject:___onUpdateSpeed()
	self:setSpeed(_G.game.player.speed)
end

function GeomObject:destroy()
	print("destroying object", self)
	self.thread:stop()
	self.thread = nil
	self.body:destroy()
	_G.gameLayer:removeProp(self.shape)
	_G.gameLayer:removeProp(self.halo)
	_G.game.activeObjects[self] = nil
	Dispatch.removeListener(self)
end

require "GeomRectangle"
require "GeomCoin"
require "GeomCircle"