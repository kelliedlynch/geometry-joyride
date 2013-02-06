GeomChaser = inheritsFrom(GeomEnemy)
GeomChaser.DEFAULT_CROSSHAIR_TEXTURE = "Resources/Images/crosshairs.png"
GeomChaser.DEFAULT_CROSSHAIR_SIZE = 32
GeomEnemy.DEFAULT_CROSSHAIR_COLOR = {1, 0, 0, 0}


function GeomChaser:constructor(w, h, x, y)
	print("w,h,x,y", w, h, x, y)
	if x and y then
		self.posX = x
		self.posY = y
	elseif x and not y then
		print("x and not y")
		self.posX = _G.screenWidth/2
		local _, y = _G.game.player.body:getWorldLoc()
		self.posY = y
	else
		print("getting world location")
		local _, y = _G.game.player.body:getWorldLoc()
		self.posX = _G.screenWidth/2
		self.posY = y
	end
	GeomEnemy.constructor(self, w, h, self.posX, self.posY)

	--if not x then y = _G.game.player.body:getPosition() end
end

function GeomChaser:animate()
	local timer = self:enterRight()
	--self.seekY = 0
	while timer:getTime() < 1 do
		coroutine.yield()
		self.seekX, self.seekY = _G.game.player.body:getPosition()
		print("seekX, seekY", self.seekX, self.seekY)
		--self.seekY = 0
		self.curveX:setKey(4, 2.3, math.floor(self.seekX), MOAIEaseType.LINEAR)
		self.curveY:setKey(3, 2.3, math.floor(self.seekY))
	end

	while self.body:getWorldLoc() > self.destroyAt do 
		local x = self.body:getWorldLoc()
		print("body x location, destroyAt", x, self.destroyAt)
		coroutine.yield()	
	end
	self:destroy()
	print("after destroy")
end

function GeomChaser:enterRight(posY)
	self.curveX = MOAIAnimCurve.new()
	self.curveX:reserveKeys(5)
	self.curveX:setKey(1, 0.0, self.posX, MOAIEaseType.SHARP_EASE_OUT)
	self.curveX:setKey(2, 0.5, self.posX - _G.screenWidth/6, MOAIEaseType.SOFT_EASE_IN)
	self.curveX:setKey(3, 1.0, self.posX - _G.screenWidth/6, MOAIEaseType.SOFT_EASE_OUT)
	self.curveX:setKey(4, 2.3, self.seekX, MOAIEaseType.LINEAR)
	self.curveX:setKey(5, 2.5, self.destroyAt)
	--------------------------------------------------------------------
	-- SOMETHING ABOUT THE TIMING ABOVE CAUSES MOAI TO CRASH WHEN THE
	-- CHASER IS DESTROYED AFTER COLLIDING WITH THE PLAYER.
	-- WHEN TIME VALUES ARE CHANGED, CRASH DOES NOT OCCUR.
	--------------------------------------------------------------------


	self.timerX = MOAITimer.new()
	self.timerX:setSpan(0, 3.0)

	self.curveY = MOAIAnimCurve.new()
	self.curveY:reserveKeys(3)
	self.curveY:setKey(1, 0.0, posY, MOAIEaseType.SOFT_EASE_OUT)
	self.curveY:setKey(2, 1.0, posY, MOAIEaseType.LINEAR)
	self.curveY:setKey(3, 2.3, self.seekY, MOAIEaseType.LINEAR)

	self.timerY = MOAITimer.new()
	self.timerY:setSpan(0, 3.0)

	self:flashCrosshairs()

	self.body:setAttrLink(MOAITransform.ATTR_X_LOC, self.curveX, MOAIAnimCurve.ATTR_VALUE)
	self.curveX:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timerX, MOAITimer.ATTR_TIME)
	self.timerX:attach(self.thread)

	self.body:setAttrLink(MOAITransform.ATTR_Y_LOC, self.curveY, MOAIAnimCurve.ATTR_VALUE)
	self.curveY:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timerY, MOAITimer.ATTR_TIME)
	self.timerY:attach(self.thread)

	return self.timerX
end

function GeomChaser:flashCrosshairs()
	local crosshairCurve = MOAIAnimCurve.new()
	crosshairCurve:reserveKeys(2)
	crosshairCurve:setKey(1, 0.0, .5, MOAIEaseType.SOFT_EASE_OUT)
	crosshairCurve:setKey(2, 1.3, 1.0)

	local alphaCurve = MOAIAnimCurve.new()
	alphaCurve:reserveKeys(7)
	alphaCurve:setKey(1, 0, 0, MOAIEaseType.FLAT)
	alphaCurve:setKey(2, .5, 1, MOAIEaseType.FLAT)
	alphaCurve:setKey(3, .6, 0, MOAIEaseType.FLAT)
	alphaCurve:setKey(4, .7, 1, MOAIEaseType.FLAT)
	alphaCurve:setKey(5, .8, 0, MOAIEaseType.FLAT)
	alphaCurve:setKey(6, .9, 1)
	alphaCurve:setKey(7, 2.0, 0)

	-- local x, y = _G.game.player.body:getPosition()
	-- local gfxQuad = MOAIGfxQuad2D.new()
	-- gfxQuad:setTexture(self.DEFAULT_CROSSHAIR_TEXTURE)
	-- gfxQuad:setRect(x - self.DEFAULT_CROSSHAIR_SIZE/2 + _G.game.player.width/2, y - self.DEFAULT_CROSSHAIR_SIZE/2 + _G.game.player.height/2, x + self.DEFAULT_CROSSHAIR_SIZE/2 + _G.game.player.width/2, y + self.DEFAULT_CROSSHAIR_SIZE/2 + _G.game.player.height/2)

	-- self.crosshairs = MOAIProp2D.new()
	-- self.crosshairs:setDeck(gfxQuad)
	-- self.crosshairs:setColor(unpack(self.DEFAULT_CROSSHAIR_COLOR))
	-- _G.gameLayer:insertProp(self.crosshairs)
	-- self.crosshairs:setBlendMode( MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA )


	-- self.crosshairs:setAttrLink(MOAIColor.ATTR_A_COL, alphaCurve, MOAIAnimCurve.ATTR_VALUE)
	-- alphaCurve:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timerX, MOAITimer.ATTR_TIME)
end

function GeomChaser:destroy()
	--_G.gameLayer:removeProp(self.crosshairs)

	GeomEnemy.destroy(self)
	print("finished GeomChaser destroy")
end