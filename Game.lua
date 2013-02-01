local _L = {}

_L.__index = _L

function _L.begin(pattern)
	local game = {}
	setmetatable(game, _L)

	Player = require "Player"
	game.player = Player.new(24)

	game.objects = require "Objects"
	game.patterns = require "Patterns"
	game.activeObjects = {}

	game:displayHUD()

	game.thread = MOAICoroutine.new()
	game.thread:run(game.scroll, game)

	return game
end

function _L:scroll(pattern)
	local totalFrames = 0
	local patternFrames = 0
	local step = 1
	local speed = self.player.speed
	local speedFrames = 0
	if not pattern then pattern = math.random(1, #self.patterns.level1) end
	while game.player:isAlive() do
		coroutine.yield()
		local time, obj, params = self.patterns.level1[pattern][step].time, self.patterns.level1[pattern][step].action, self.patterns.level1[pattern][step].params
		patternFrames = patternFrames + 1
		if patternFrames == math.floor(time*60) then
			self.objects[obj](unpack(params))
			step = step + 1
			if not self.patterns.level1[pattern][step] then 
				step = 1
				patternFrames = 0
				pattern = math.random(1, #self.patterns.level1)
			end
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
		totalFrames = totalFrames + 1
		if totalFrames % 10 == 0 then
			local distanceTraveled = math.abs(totalFrames *(self.player.speed / 10000))
			self:updateHUD(distanceTraveled)
		end
		if speedFrames >= 60 then speedFrames = 0 end
	end
end

function _L:stopScrolling()
	for body, v in pairs(self.activeObjects) do
		body:setLinearVelocity(0,0)
	end
end

function _L:displayHUD()
	self.distanceDisplay = MOAITextBox.new()
	self.distanceDisplay:setString("0.0")
	self.distanceDisplay:setRect(160, -160, 240, -130)
	self.distanceDisplay:setStyle(DEFAULT_STYLE)
	self.distanceDisplay:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
	self.distanceDisplay:setYFlip(true)
	_G.hudLayer:insertProp(self.distanceDisplay)
end

function _L:updateHUD(dist)
	dist = round(dist, 1)
	self.distanceDisplay:setString(""..dist)
end


return _L