local _L = {}

_L.__index = _L

_L.PATTERN_DELAY = 120

function _L.begin(pattern)
	local game = {}
	setmetatable(game, _L)

	Player = require "Player"
	game.player = Player.new(24)

	game.objects = require "Objects"
	game.patterns = require "Patterns"
	game.activeObjects = {}
	game.coinsCollectedThisPattern = {}

	game:displayHUD()

	game.thread = MOAICoroutine.new()
	game.thread:run(game.scroll, game)
	game.thread:attach(_G.world)

	return game
end

function _L:scroll(pattern)
	local totalFrames = 0
	local speed = self.player:getStartSpeed()
	local speedFrames = 0
	local framesUntilNextPattern = self.PATTERN_DELAY
	if not pattern then pattern = math.random(1, #self.patterns.level1) end
	while game.player:isAlive() do
		coroutine.yield()
		if framesUntilNextPattern == 0 then
			-- render entire pattern off-screen
			for k, item in pairs(self.patterns.level1[pattern]) do
				local time, obj, params = item.time, item.action, item.params
				local body = self.objects[item.action](unpack(item.params))

				local xPos = 0
				local offset = math.abs((game.player.speed * item.time))
				xPos = _G.screenWidth/2 + offset
				self.objects:setXPos(body, xPos)
			end
			pattern = math.random(1, #self.patterns.level1)
			framesUntilNextPattern = self.PATTERN_DELAY
		else
			framesUntilNextPattern = framesUntilNextPattern - 1
		end

		if speed >= self.player.MAX_SPEED then 
			speed = speed - .2
			if speed < self.player.MAX_SPEED then
				speed = self.player.MAX_SPEED
			end
			self.player.speed = speed
		end
		speedFrames = speedFrames + 1
		for body, v in pairs(self.activeObjects) do
			if speedFrames >= 60 then
				body:setLinearVelocity(speed, 0)
			end
			local x, y = body:getPosition()
			if x <= body.destroyAt then
				body:destroy()
				_G.gameLayer:removeProp(body.shape)
				_G.gameLayer:removeProp(body.halo)
				self.activeObjects[body] = nil
			end
		end
		if speedFrames >= 60 then speedFrames = 0 end
		totalFrames = totalFrames + 1
		if totalFrames % 10 == 0 then
			local distanceTraveled = math.abs(totalFrames *(self.player.speed / 10000))
			distanceTraveled = round(distanceTraveled, 1)
			self.player.currentDistance = distanceTraveled
			self:updateHUD()
		end
		for fix, coins in pairs(self.coinsCollectedThisPattern) do
			self.player.coins = self.player.coins + coins
			self.coinsCollectedThisPattern[fix] = 0
		end
	end
end

function _L:stopScrolling()
	for body, v in pairs(self.activeObjects) do
		body:setLinearVelocity(0,0)
	end
end

function _L:displayHUD()
	self.distanceCounter = MOAITextBox.new()
	self.distanceCounter:setString("0.0")
	self.distanceCounter:setRect(160, -160, 240, -130)
	self.distanceCounter:setStyle(DEFAULT_STYLE)
	self.distanceCounter:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
	self.distanceCounter:setYFlip(true)
	_G.hudLayer:insertProp(self.distanceCounter)

	self.coinCounter = MOAITextBox.new()
	self.coinCounter:setString("0.0")
	self.coinCounter:setRect(-240, -160, -160, -130)
	self.coinCounter:setStyle(DEFAULT_STYLE)
	self.coinCounter:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
	self.coinCounter:setYFlip(true)
	_G.hudLayer:insertProp(self.coinCounter)
end

function _L:updateHUD()
	local dist = self.player.currentDistance
	--local coins = self.player.coins
	local dstr
	if math.floor(dist) == dist then
		dstr = dist..".0"
	else
		dstr = dist..""
	end
	self.distanceCounter:setString(""..dstr)
	self.coinCounter:setString(""..self.player.coins)
end

function _L:endGame()
	_G.hudLayer:removeProp(self.distanceCounter)
	_G.hudLayer:removeProp(self.coinCounter)
	self.player = nil
end

return _L