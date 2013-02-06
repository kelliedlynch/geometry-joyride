GeomEnemy = inheritsFrom(GeomObject)
GeomEnemy.DEFAULT_WIDTH = 32
GeomEnemy.DEFAULT_HEIGHT = 32
GeomEnemy.DEFAULT_COLOR = {1, .8, .8, 1}
GeomEnemy.DEFAULT_HALO_TEXTURE = "Resources/Images/circle1glow.png"
GeomEnemy.DEFAULT_SHAPE_TEXTURE = "Resources/Images/circle1tex.png"
GeomEnemy.DEFAULT_MOVE_PATTERN = 1

function GeomEnemy:constructor(w, h, x, y)
	GeomObject.constructor(self, w, h, x, y)

	self.fixture = self.body:addCircle(w/2, w/2, w/2)
--	self.fixture:setFilter(FILTER_DEADLY_OBJECT)
self.fixture:setSensor(true)
	self.body:resetMassData()

	self:renderSprite()
	print("posX, posY after creation", self.posX, self.posY)
	print("worldLoc after creation", self.body:getWorldLoc())
	print("position after creation", self.body:getPosition())

	return self
end

function GeomEnemy:animate()
	self:aniWave(10, 60)

	while self.body:getPosition() > self.destroyAt do 
		coroutine.yield()
		if self.curveX then
			local dx = self.curveLength - (_G.game.player.speed - _G.game.player.STARTING_SPEED)/2.8
			self.curveX:setKey(2, .5, self.posX-dx, MOAIEaseType.LINEAR)
		end		
	end
	self:destroy()
end

function GeomEnemy:aniWave(length, amplitude)
	self.curveLength = length
	--------------------------------------------------------------------
	-- I NEED TO LOOK AT THIS-- THE FORMULA IS NOT CORRECT
	--------------------------------------------------------------------
	local dx = -(length - (_G.game.player.speed + _G.game.player.STARTING_SPEED)/2.8)
	self.curveX = MOAIAnimCurve.new()
	self.curveX:reserveKeys(2)
	self.curveX:setKey(1, 0.0, self.posX, MOAIEaseType.LINEAR)
	self.curveX:setKey(2, 1, self.posX - dx, MOAIEaseType.LINEAR)
	self.curveX:setWrapMode(MOAIAnimCurve.APPEND)

	self.curveY = MOAIAnimCurve.new()
	self.curveY:reserveKeys(5)
	self.curveY:setKey(1, 0.0, self.posY, MOAIEaseType.SOFT_EASE_IN)
	self.curveY:setKey(2, .5, self.posY + amplitude, MOAIEaseType.SOFT_EASE_OUT)
	self.curveY:setKey(3, 1, self.posY, MOAIEaseType.SOFT_EASE_IN)
	self.curveY:setKey(4, 1.5, self.posY - amplitude, MOAIEaseType.SOFT_EASE_OUT)
	self.curveY:setKey(5, 2, self.posY, MOAIEaseType.SOFT_EASE_IN)
	self.curveY:setWrapMode(MOAIAnimCurve.WRAP)

	self.timerY = MOAITimer.new()
	self.timerY:setSpan(0, .5)
	self.timerY:setMode(MOAITimer.CONTINUE)

	self.timerX = MOAITimer.new()
	self.timerX:setSpan(0, .5)
	self.timerX:setMode(MOAITimer.CONTINUE)
	self.body:setAttrLink(MOAITransform.ATTR_X_LOC, self.curveX, MOAIAnimCurve.ATTR_VALUE)
	self.body:setAttrLink(MOAITransform.ATTR_Y_LOC, self.curveY, MOAIAnimCurve.ATTR_VALUE)
	self.curveX:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timerX, MOAITimer.ATTR_TIME)
	self.curveY:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timerY, MOAITimer.ATTR_TIME)

	self.timerY:attach(self.thread)
	self.timerX:attach(self.thread)
end

function GeomEnemy:setSpeed(speed)

end

function GeomEnemy:___onUpdateSpeed()

end

function GeomEnemy:destroy()
	self.timerX:stop()
	--self.timerX = nil
	self.timerY:stop()
	--self.timerY = nil
	GeomObject.destroy(self)
	print("finished GeomEnemy destroy")
end