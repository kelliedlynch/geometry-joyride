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
	Enemy = require "Enemy"
	game.activeObjects = {}
	game.coinsCollectedThisPattern = {}

	game:displayHUD()

	game.thread = MOAICoroutine.new()
	game.thread:run(game.scroll, game)
	game.thread:attach(_G.world)

	Dispatch.registerEvent("onPlayerDestroyed", game)

	return game
end

function _L:scroll(pattern)
	local totalFrames = 0
	local speed = self.player:getStartSpeed()
	local speedFrames = 0
	local framesUntilNextPattern = self.PATTERN_DELAY
	if not pattern then pattern = #self.patterns.level1 end
	while self.player:isAlive() do
		coroutine.yield()
		if framesUntilNextPattern == 0 then
			local patternWidth = self:renderPattern(pattern)
			framesInCurrentPattern = (patternWidth / math.abs(self.player.speed)) * FRAME_RATE
			pattern = math.random(1, #self.patterns.level1)
			framesUntilNextPattern = math.floor(self.PATTERN_DELAY + framesInCurrentPattern)
		else
			framesUntilNextPattern = framesUntilNextPattern - 1
		end

		if speed > self.player.MAX_SPEED then 
			speed = speed - .2
			if speed < self.player.MAX_SPEED then
				speed = self.player.MAX_SPEED
			end
			self.player.speed = speed
		end
		speedFrames = speedFrames + 1
		if speedFrames >= 60 then 
			Dispatch.triggerEvent("onUpdateSpeed")
			speedFrames = 0
		end
		totalFrames = totalFrames + 1
		if totalFrames % 10 == 0 then
			local distanceTraveled = math.abs(totalFrames *(self.player.speed / 10000))
			distanceTraveled = round(distanceTraveled, 1)
			self.player.currentDistance = distanceTraveled
			self:updateHUD()
		end
	end
end

function _L:renderPattern(pattern)
	local patternWidth = 0
	for k, item in pairs(self.patterns.level1[pattern]) do
		print("game", self)
		local obj = _G[item.action].new(unpack(item.params))

		local xPos = 0
		local offset = math.abs((self.player.speed * item.time))
		xPos = _G.screenWidth/2 + offset
		obj:setPosition(xPos, 0)
		if offset + obj.body.width > patternWidth then
			patternWidth = offset + obj.body.width
		end
	end
	return patternWidth
end

function _L:stopScrolling()
	for obj, v in pairs(self.activeObjects) do
		obj:setSpeed(0)
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
	self.coinCounter:setString("0")
	self.coinCounter:setRect(-240, -160, -160, -130)
	self.coinCounter:setStyle(DEFAULT_STYLE)
	self.coinCounter:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
	self.coinCounter:setYFlip(true)
	_G.hudLayer:insertProp(self.coinCounter)

	function self.coinCounter:update(value)
		self:setString(""..value)
	end
end

function _L:updateHUD()
	local dist = self.player.currentDistance
	local dstr
	if math.floor(dist) == dist then
		dstr = dist..".0"
	else
		dstr = dist..""
	end
	self.distanceCounter:setString(""..dstr)
end

function _L:endGame()
	_G.hudLayer:removeProp(self.distanceCounter)
	_G.hudLayer:removeProp(self.coinCounter)
	self.player = nil
	for obj, v in pairs(self.activeObjects) do
		obj:destroy()
	end
end

function _L:___onPlayerDestroyed()
	self:endGame()
	Dispatch.removeListener(self)
	_G.game = Game.begin()
end

return _L