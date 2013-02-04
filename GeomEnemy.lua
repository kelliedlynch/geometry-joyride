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
	self.fixture:setFilter(FILTER_DEADLY_OBJECT)
	self.body:resetMassData()

	self:renderSprite()

	return self
end

function GeomEnemy:animate()
	self:aniWave(10, 60)

	while self.body:getPosition() > self.destroyAt do 
		coroutine.yield()
	if self.curveX then
		local dx = self.curveLength - (_G.game.player.speed - _G.game.player.STARTING_SPEED)/3
		print("newLength", dx)
		self.curveX:setKey(2, .5, self.posX-dx, MOAIEaseType.LINEAR)
		--i = i+1
	end		
	end
	self:destroy()
end

function GeomEnemy:setSpeed(speed)

end

function GeomEnemy:___onUpdateSpeed()
	--self:setSpeed(_G.game.player.speed)


end

function GeomEnemy:destroy()
	GeomObject.destroy(self)
	self.timer:stop()
	self.timer = nil
	self.timer2:stop()
	self.timer = nil
end

function GeomEnemy:aniWave(length, amplitude)
	--i = 1
	print("animating wave")
	print("x, y, length, amplitude", self.posX, self.posY, length, amplitude)
	self.curveLength = length
	local dx = -(length - (_G.game.player.speed + _G.game.player.STARTING_SPEED)/3)
	print("starting length", self.curveLength)
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

	self.timer = MOAITimer.new()
	self.timer:setSpan(0, .5)
	self.timer:setMode(MOAITimer.CONTINUE)

	--timer:setListener(MOAITimer.EVENT_TIMER_LOOP, applyForce)

	self.timer2 = MOAITimer.new()
	self.timer2:setSpan(0, .5)
	self.timer2:setMode(MOAITimer.CONTINUE)
	print("body location", self.body:getWorldLoc())
	self.body:setAttrLink(MOAITransform.ATTR_X_LOC, self.curveX, MOAIAnimCurve.ATTR_VALUE)
	self.body:setAttrLink(MOAITransform.ATTR_Y_LOC, self.curveY, MOAIAnimCurve.ATTR_VALUE)
	self.curveX:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timer2, MOAITimer.ATTR_TIME)
	self.curveY:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timer, MOAITimer.ATTR_TIME)

	-- self.timer:start()
	-- self.timer2:start()
	self.timer:attach(self.thread)
	self.timer2:attach(self.thread)
end