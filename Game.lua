local _L = {}

_L.__index = _L

_L.PATTERN_DELAY = 120

function _L.begin(pattern)
	local game = {}
	setmetatable(game, _L)

	Player = require "Player"
	game.player = Player.new()

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

	local framesUntilNextPattern = self.PATTERN_DELAY
	if not pattern then pattern = #self.patterns.level1 end
	i = 1
	while self.player:isAlive() do
		coroutine.yield()
		if framesUntilNextPattern == 0 then
			local patternWidth = self:renderPattern(pattern)
			framesInCurrentPattern = (patternWidth / math.abs(self.player.speed)) * FRAME_RATE
			pattern = math.random(1, #self.patterns.level1)
			framesUntilNextPattern = math.floor(self.PATTERN_DELAY + framesInCurrentPattern)
		elseif framesUntilNextPattern > 0 then
			framesUntilNextPattern = framesUntilNextPattern - 1
		else
			print("frames less than zero")
		end
		self.player:accelerate()

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
		local w, h, x, y = unpack(item.params)
		local offset = math.abs((self.player.speed * item.time))
		if x and y then
			x = x
			y = y
		elseif x and not y then
			y = x
			x = _G.screenWidth/2 + offset
		elseif w and h then
			x = 0
			y = 0
		elseif w then
			x = _G.screenWidth/2 + offset
			y = w
			w = nil
			h = nil
		end
		local obj = _G[item.action].new(w, h, x, y)
		self.activeObjects[obj] = true


		if offset + obj.body.width > patternWidth then
			patternWidth = offset + obj.body.width
		end
	end
	Dispatch.triggerEvent("onUpdateSpeed")
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