GeomChaser = inheritsFrom(GeomEnemy)

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
	while not timer:isDone() do
		coroutine.yield()
		--print("timer running")
		--print("posX, posY", self.body:getWorldLoc())
	end
	timer:stop()
	timer = nil

	self:aniSeek()
--print("posX, posY", self.body:getWorldLoc())
	--while self.body:getWorldLoc() > self.destroyAt do 
	while not self.timerX:isDone() do
		-- print("self.timerX running")
		-- print("posX, posY", self.body:getWorldLoc())
		coroutine.yield()
		-- if self.curveX then
		-- 	local dx = self.curveLength - (_G.game.player.speed - _G.game.player.STARTING_SPEED)/3
		-- 	self.curveX:setKey(2, .5, self.posX-dx, MOAIEaseType.LINEAR)
		-- end		
	end
	--print("posX, posY", self.body:getWorldLoc())
	print("posX, posY", self.body:getPosition())
	self:destroy()
end

function GeomChaser:aniSeek()
	local x, y = _G.game.player.body:getPosition()
	local posX, posY = self.body:getPosition()

	self.curveX = MOAIAnimCurve.new()
	self.curveX:reserveKeys(2)
	self.curveX:setKey(1, 0.0, posX, MOAIEaseType.SHARP_EASE_OUT)
	--self.curveX:setKey(2, 1, _G.screenWidth/2 - _G.screenWidth/6)
	self.curveX:setKey(2, 3.5, self.destroyAt, MOAIEaseType.LINEAR)
	print("moving from", posX, "to", self.destroyAt)
	--self.curveX:setKey(3, 2.1, x-1, MOAIEaseType.LINEAR)
	--self.curveX:setWrapMode(MOAIAnimCurve.APPEND)

	self.curveY = MOAIAnimCurve.new()
	self.curveY:reserveKeys(2)
	self.curveY:setKey(1, 0.0, posY, MOAIEaseType.SOFT_EASE_OUT)
	self.curveY:setKey(2, 2.5, y, MOAIEaseType.SOFT_EASE_OUT)
	--self.curveY:setWrapMode(MOAIAnimCurve.APPEND)

	self.timerX = MOAITimer.new()
	self.timerX:setSpan(0, 3.5)

	self.timerY = MOAITimer.new()
	self.timerY:setSpan(0, 3.5)
	--self.timerY:setMode(MOAITimer.CONTINUE)

	--self.timerYX:setMode(MOAITimer.CONTINUE)
	print("before clear", self.body:getAttrLink(MOAITransform.ATTR_X_LOC))
	self.body:clearAttrLink(MOAITransform.ATTR_X_LOC)
	print("after clear", self.body:getAttrLink(MOAITransform.ATTR_X_LOC))
	--self.body:clearAttrLink(MOAIAnimCurve.ATTR_VALUE)
	self.body:setAttrLink(MOAITransform.ATTR_X_LOC, self.curveX, MOAIAnimCurve.ATTR_VALUE)
	self.body:setAttrLink(MOAITransform.ATTR_Y_LOC, self.curveY, MOAIAnimCurve.ATTR_VALUE)
	self.curveX:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timerX, MOAITimer.ATTR_TIME)
	self.curveY:setAttrLink(MOAIAnimCurve.ATTR_TIME, self.timerY, MOAITimer.ATTR_TIME)
	print("after set", self.body:getAttrLink(MOAITransform.ATTR_X_LOC))

	self.timerX:attach(self.thread)
	self.timerY:attach(self.thread)
end