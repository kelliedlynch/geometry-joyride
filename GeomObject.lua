--------------------------------------------------------------------
-- BASE CLASS FOR ALL TERRAIN AND ENEMY OBJECTS
--------------------------------------------------------------------

GeomObject = inheritsFrom()

function GeomObject:constructor(w, h, x, y)
	if x and y then
		self.posX = x
		self.posY = y
	elseif x and not y then
		self.posX = _G.screenWidth/2
		self.posY = x
	else
		self.posX = 0
		self.posY = 0
	end
	print("position at creation", self.posX, self.posY)

	self.width, self.height = w, h

	self.body = _G.world:addBody(MOAIBox2DBody.KINEMATIC)
	self.body.width, self.body.height = w, h
	self.body:setTransform(self.posX, self.posY)
	self.destroyAt = -_G.screenWidth/2 - w - 10
	self.body.object = self

	Dispatch.registerEvent("onUpdateSpeed", self, true)

	self.thread = MOAICoroutine.new()
	self.thread:run(self.animate, self)
	if _G.game then	self.thread:attach(_G.game.thread) end
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
	gfxQuad1:setRect (0, 0, self.width, self.height)

	local halo = MOAIProp2D.new()
	halo:setDeck(gfxQuad1)
	halo:setColor(unpack(self.DEFAULT_COLOR))
	--halo:setLoc(self.posX, self.posY)
	_G.gameLayer:insertProp(halo)

	local gfxQuad2 = MOAIGfxQuad2D.new()
	gfxQuad2:setTexture(self.DEFAULT_SHAPE_TEXTURE)
	gfxQuad2:setRect(0, 0, self.width, self.height)

	local shape = MOAIProp2D.new()
	shape:setDeck(gfxQuad2)
	shape:setColor(unpack(self.DEFAULT_COLOR))
	--shape:setLoc(self.posX, self.posY)
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

-- function GeomObject:setPosition(x, y)
-- 	self.body:setTransform(x, y)
-- 	self.destroyAt = self.destroyAt - x
-- end

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
	self = nil
end

function GeomObject:enterRight(posY)
	if not posY then _, posY = _G.game.player.body:getPosition() end
	self.body:setTransform(self.posX, posY)
	local enterCurveX = MOAIAnimCurve.new()
	enterCurveX:reserveKeys(3)
	enterCurveX:setKey(1, 0.0, self.posX, MOAIEaseType.SHARP_EASE_OUT)
	enterCurveX:setKey(2, 0.5, self.posX - _G.screenWidth/6, MOAIEaseType.SHARP_EASE_OUT)
	enterCurveX:setKey(3, 1.0, self.posX - _G.screenWidth/6)
	--enterCurveX:setWrapMode(MOAIAnimCurve.WRAP)
	print("moving from", self.posX, "to", self.posX - _G.screenWidth/6)

	local timer = MOAITimer.new()
	timer:setSpan(0, 1)

	self.body:setAttrLink(MOAITransform.ATTR_X_LOC, enterCurveX, MOAIAnimCurve.ATTR_VALUE)
	enterCurveX:setAttrLink(MOAIAnimCurve.ATTR_TIME, timer, MOAITimer.ATTR_TIME)
	print("after enter set", self.body:getAttrLink(MOAITransform.ATTR_X_LOC))
	timer:attach(self.thread)

	return timer
end

function GeomObject:targetPlayer()
	self.targetX, self.targetY = _G.game.player.body:getPosition()
end

require "GeomRectangle"
require "GeomCoin"
require "GeomCircle"
require "GeomEnemy"
require "GeomChaser"