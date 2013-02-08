GeomSeeker = inheritsFrom(GeomEnemy)
GeomSeeker.DEFAULT_CROSSHAIR_TEXTURE = "Resources/Images/crosshairs.png"
GeomSeeker.DEFAULT_CROSSHAIR_SIZE = 32
GeomSeeker.DEFAULT_CROSSHAIR_COLOR = {1, 0, 0, 0}


function GeomSeeker:constructor(w, h, x, y)
	if x and y then
		self.posX = x
		self.posY = y
	elseif x and not y then
		self.posX = _G.screenWidth/2
		self.posY = _G.game.player.posX
	else
		self.posX = _G.screenWidth/2
		self.posY = _G.game.player.posX
	end
	GeomEnemy.constructor(self, w, h, self.posX, self.posY)
end

function GeomSeeker:animate()
	local timer = self:enterRight()
	while timer:getTime() < .5 do
		coroutine.yield()
	end
	self.crosshairs:setLoc(_G.game.player.centerX - self.DEFAULT_CROSSHAIR_SIZE/2, _G.game.player.centerY - self.DEFAULT_CROSSHAIR_SIZE/2 )
	self.seekX, self.seekY = _G.game.player.centerX, _G.game.player.centerY
	self.curveX:setKey(4, 2.8, math.floor(self.seekX), MOAIEaseType.SHARP_EASE_IN)
	self.curveY:setKey(3, 2.8, math.floor(self.seekY))

	while timer:getTime() < 1 do
		coroutine.yield()
	end
	while timer:getTime() < 3.5 do 
		coroutine.yield()	
	end
	self:destroy()
	print("after destroy")
end

function GeomSeeker:enterRight(posY)
	self.curveX = MOAIAnimCurve.new()
	self.curveX:reserveKeys(5)
	self.curveX:setKey(1, 0.0, self.posX, MOAIEaseType.SHARP_EASE_OUT)
	self.curveX:setKey(2, 0.5, self.posX - _G.screenWidth/6, MOAIEaseType.SOFT_EASE_IN)
	self.curveX:setKey(3, 1.0, self.posX - _G.screenWidth/6, MOAIEaseType.SHARP_EASE_OUT)
	self.curveX:setKey(4, 2.8, self.seekX, MOAIEaseType.SHARP_EASE_IN)
	self.curveX:setKey(5, 3.4, self.destroyAt)

	self.timerX = MOAITimer.new()
	self.timerX:setSpan(0, 3.4)

	self.curveY = MOAIAnimCurve.new()
	self.curveY:reserveKeys(3)
	self.curveY:setKey(1, 0.0, posY, MOAIEaseType.SOFT_EASE_OUT)
	self.curveY:setKey(2, 1.0, posY, MOAIEaseType.LINEAR)
	self.curveY:setKey(3, 2.8, self.seekY, MOAIEaseType.LINEAR)

	self.timerY = MOAITimer.new()
	self.timerY:setSpan(0, 3.4)

	self:flashCrosshairs()

	self.body:setAttrLink(MOAITransform.ATTR_X_LOC, self.curveX, MOAIAnimCurve.ATTR_VALUE)
	self.curveX:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timerX, MOAITimer.ATTR_TIME)
	self.timerX:attach(self.thread)

	self.body:setAttrLink(MOAITransform.ATTR_Y_LOC, self.curveY, MOAIAnimCurve.ATTR_VALUE)
	self.curveY:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timerY, MOAITimer.ATTR_TIME)
	self.timerY:attach(self.thread)

	return self.timerX
end

function GeomSeeker:flashCrosshairs()
	local crosshairCurve = MOAIAnimCurve.new()
	crosshairCurve:reserveKeys(2)
	crosshairCurve:setKey(1, 0.0, .5, MOAIEaseType.SOFT_EASE_OUT)
	crosshairCurve:setKey(2, 1.3, 1.0)

	local alphaCurve = MOAIAnimCurve.new()
	alphaCurve:reserveKeys(7)
	alphaCurve:setKey(1, 0, 0, MOAIEaseType.FLAT)
	alphaCurve:setKey(2, .6, 1, MOAIEaseType.FLAT)
	alphaCurve:setKey(3, .7, 0, MOAIEaseType.FLAT)
	alphaCurve:setKey(4, .8, 1, MOAIEaseType.FLAT)
	alphaCurve:setKey(5, .9, 0, MOAIEaseType.FLAT)
	alphaCurve:setKey(6, 1.0, 1, MOAIEaseType.LINEAR)
	alphaCurve:setKey(7, 1.5, 0, MOAIEaseType.FLAT)

	local gfxQuad = MOAIGfxQuad2D.new()
	gfxQuad:setTexture(self.DEFAULT_CROSSHAIR_TEXTURE)
	gfxQuad:setRect(0, 0, self.DEFAULT_CROSSHAIR_SIZE, self.DEFAULT_CROSSHAIR_SIZE)

	self.crosshairs = MOAIProp2D.new()
	self.crosshairs:setDeck(gfxQuad)
	self.crosshairs:setColor(unpack(self.DEFAULT_CROSSHAIR_COLOR))
	self.crosshairs:setLoc(_G.game.player.centerX - self.DEFAULT_CROSSHAIR_SIZE/2, _G.game.player.centerY - self.DEFAULT_CROSSHAIR_SIZE/2)

	_G.gameLayer:insertProp(self.crosshairs)
	self.crosshairs:setBlendMode( MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA )


	self.crosshairs:setAttrLink(MOAIColor.ATTR_A_COL, alphaCurve, MOAIAnimCurve.ATTR_VALUE)
	alphaCurve:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timerX, MOAITimer.ATTR_TIME)
end

function GeomSeeker:destroy()
	self.body:setLinearVelocity(0,0)
	_G.gameLayer:removeProp(self.crosshairs)

	GeomEnemy.destroy(self)
	print("finished GeomSeeker destroy")
end