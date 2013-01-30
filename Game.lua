local _L = {}

_G.activeTerrainBoxes = {}

_L.__index = _L

function _L.begin(pattern)
	local game = {}
	setmetatable(game, _L)

	Player = require "Player"
	game.player = Player.new(24)

	game.patterns = require "Patterns"
	game.thread = MOAICoroutine.new()
	game.thread:run(game.scroll, game)
	game:beginScrolling()

	return game
end

function _L.randomTerrain()
spawnTerrain = MOAICoroutine.new ()
spawnTerrain:run (
	function ()
		_G.speed = -10
		local speedFrames = 0
		local spawnFrames = 0
		local nextSpawn = math.random(60, 90)
		while true do
			coroutine.yield ()
			if _G.speed > -400 then _G.speed = _G.speed - .2 end
			speedFrames = speedFrames + 1
			spawnFrames = spawnFrames + 1
			if spawnFrames >= nextSpawn then
				_L.rectangle()
				spawnFrames = 0
			end
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

function _L:beginScrolling()
scroll = MOAICoroutine.new ()
scroll:run (
	function ()
		_G.speed = -100
		local speedFrames = 0
		--local spawnFrames = 0
		--local nextSpawn = math.random(60, 90)
		while true do
			coroutine.yield ()
			if _G.speed > -400 then _G.speed = _G.speed - .2 end
			speedFrames = speedFrames + 1
			--spawnFrames = spawnFrames + 1
			-- if spawnFrames >= nextSpawn then
			-- 	_L.rectangle()
			-- 	spawnFrames = 0
			-- end
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
	if not pattern then pattern = 1 end
	while game.player:isAlive() do
		coroutine.yield()
		local time, action, params = self.patterns[pattern][step].time, self.patterns[pattern][step].action, self.patterns[pattern][step].params
		frames = frames + 1
		if frames == math.floor(time*60) then
			self[action](unpack(params))
			step = step + 1
			if not self.patterns[pattern][step] then 
				step = 1
				frames = 0
			end
		end
	end
end


function _L.loadPattern(pattern)
	local thread = MOAICoroutine.new()
	thread:run(
		function()
			--local time, action, params = unpack(_G.patterns[pattern])
			local frames = 0
			local step = 1
--print("pattern", pattern)
			--print("_G.patterns", _G.patterns[pattern])
			while _G.patterns[pattern][step] do
				coroutine.yield()
				local time, action, params = _G.patterns[pattern][step].time, _G.patterns[pattern][step].action, _G.patterns[pattern][step].params
				--print("params", unpack(params))
				--if _G.patterns[pattern][step] then
					frames = frames + 1
					if frames == math.floor(time*60) then
						TerrainGenerator[action](unpack(params))
						step = step + 1
					end
				--else
				--end
			end
			print("done")
		end
	)
end

function _L.rectangle(w, h, y)
	if not w then
		local junk = math.random()
		w = math.random(80, 130)
		h = math.random(20, 60)
		--posX = math.random(_G.screenWidth/2 + 10, _G.screenWidth + _G.screenWidth/2)
	end
	posX = _G.screenWidth/2
	if not y then
		posY = math.random(-_G.screenHeight/2 + 10, _G.screenHeight/2 - 10 - h)
	else
		posY = y
	end
	print("x,y, w,h", posX, posY, w, h)

	local kbody = _G.world:addBody(MOAIBox2DBody.KINEMATIC)
	local kfix = kbody:addRect(posX, posY, posX + w, posY + h)
	kfix:setFilter(FILTER_ACTIVE_TERRAIN)
	kfix:setCollisionHandler(_L.onCollision, MOAIBox2DArbiter.ALL)
	kbody:resetMassData()
	kbody:setLinearVelocity(_G.speed, 0)

	local gfxQuad1 = MOAIGfxQuad2D.new()
	gfxQuad1:setTexture("Resources/Images/rectglow.png")
	gfxQuad1:setRect (posX, posY, posX + w, posY + h)

	local halo = MOAIProp2D.new()
	halo:setDeck(gfxQuad1)
	halo:setColor(.2, 1, .4, 1)
	_G.gameLayer:insertProp(halo)

	local gfxQuad2 = MOAIGfxQuad2D.new()
	gfxQuad2:setTexture("Resources/Images/recttex.png")
	gfxQuad2:setRect(posX, posY, posX + w, posY + h)

	local shape = MOAIProp2D.new()
	shape:setDeck(gfxQuad2)
	shape:setColor(.2, 1, .4, 1)
	_G.gameLayer:insertProp(shape)

	halo:setParent(shape)
	shape:setParent(kbody)
	kbody.shape = shape
	kbody.halo = halo

	_G.activeTerrainBoxes[kbody] = true

	kbody.destroyAt = -_G.screenWidth/2 - _G.screenWidth - posX - w/2 - 10
end

function _L.onCollision()
	print("box collision")
end


return _L