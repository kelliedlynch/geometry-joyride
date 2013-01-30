local _L = {}

_G.activeTerrainBoxes = {}

_L.__index = _L

function _L.begin(pattern)
	local game = {}
	setmetatable(game, _L)

	Player = require "Player"
	game.player = Player.new(24)

	game.objects = require "Objects"
	game.patterns = require "Patterns"
	game.thread = MOAICoroutine.new()
	game.thread:run(game.scroll, game)

	return game
end

function _L:beginScrolling()
scroll = MOAICoroutine.new ()
scroll:run (
	function ()
		self.player.speed = -100
		local speedFrames = 0
		while true do
			coroutine.yield ()
			if self.player.speed > -400 then self.player.speed = self.player.speed - .2 end
			speedFrames = speedFrames + 1
			for body, v in pairs(_G.activeTerrainBoxes) do
				if speedFrames >= 60 then
					body:setLinearVelocity(_G.speed, 0)
				end
				local x, y = body:getPosition()
				if x <= body.destroyAt then
					body:destroy()
					_G.gameLayer:removeProp(body.shape)
					_G.gameLayer:removeProp(body.halo)
					_G.activeTerrainBoxes[body] = nil
				end
			end
			if speedFrames >= 60 then speedFrames = 0 end
		end
	end
	)
end

function _L:scroll(pattern)
	local frames = 0
	local step = 1
	_G.speed = -100
	local speedFrames = 0
	if not pattern then pattern = 1 end
	while game.player:isAlive() do
		coroutine.yield()
		local time, obj, params = self.patterns[pattern][step].time, self.patterns[pattern][step].action, self.patterns[pattern][step].params
		frames = frames + 1
		if frames == math.floor(time*60) then
			self.objects[obj](unpack(params))
			step = step + 1
			if not self.patterns[pattern][step] then 
				step = 1
				frames = 0
			end
		end
		if _G.speed > -400 then _G.speed = _G.speed - .2 end
		speedFrames = speedFrames + 1
		for body, v in pairs(_G.activeTerrainBoxes) do
			if speedFrames >= 60 then
				body:setLinearVelocity(_G.speed, 0)
			end
			local x, y = body:getPosition()
			if x <= body.destroyAt then
				body:destroy()
				_G.gameLayer:removeProp(body.shape)
				_G.gameLayer:removeProp(body.halo)
				_G.activeTerrainBoxes[body] = nil
			end
		end
		if speedFrames >= 60 then speedFrames = 0 end
	end
end

return _L