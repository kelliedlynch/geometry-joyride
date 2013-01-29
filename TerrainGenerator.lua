_T = {}

activeTerrainBoxes = {}

function _T.scrollTerrain()
spawnTerrain = MOAICoroutine.new ()
spawnTerrain:run (
	function ()
		local frames = 0
		local nextSpawn = math.random(60, 90)
		while true do
			coroutine.yield ()
			frames = frames + 1
			if frames >= nextSpawn then
				_T.rectangle()
				frames = 0
			end
			for body, v in pairs(activeTerrainBoxes) do
				--print("checking bodies")
				local x, y = body:getPosition()
				if x <= body.destroyAt then
					body:destroy()
					layer:removeProp(body.shape)
					layer:removeProp(body.halo)
					activeTerrainBoxes[body] = nil
				end
			end
		end
	end
	)
end

function _T.rectangle(w, h, speed)
	if not w then
		local junk = math.random()
		w = math.random(80, 130)
		h = math.random(20, 60)
		speed = math.random(-600, -200)
		posX = math.random(ScreenWidth/2 + 10, ScreenWidth + ScreenWidth/2)
		posY = math.random(-ScreenHeight/2 + 10, ScreenHeight/2 - 10 - h)
	end

	local kbody = world:addBody(MOAIBox2DBody.KINEMATIC)
	local kfix = kbody:addRect(posX, posY, posX + w, posY + h)
	kfix:setFilter(FILTER_ACTIVE_TERRAIN)
	kfix:setCollisionHandler(_T.onCollision, MOAIBox2DArbiter.ALL)
	kbody:resetMassData()
	kbody:setLinearVelocity(speed, 0)

	local gfxQuad1 = MOAIGfxQuad2D.new()
	gfxQuad1:setTexture("rectglow.png")
	gfxQuad1:setRect (posX, posY, posX + w, posY + h)

	local halo = MOAIProp2D.new()
	halo:setDeck(gfxQuad1)
	halo:setColor(.2, 1, .4, 1)
	layer:insertProp(halo)

	local gfxQuad2 = MOAIGfxQuad2D.new()
	gfxQuad2:setTexture("recttex.png")
	gfxQuad2:setRect(posX, posY, posX + w, posY + h)

	local shape = MOAIProp2D.new()
	shape:setDeck(gfxQuad2)
	shape:setColor(.2, 1, .4, 1)
	layer:insertProp(shape)

	halo:setParent(shape)
	shape:setParent(kbody)
	kbody.shape = shape
	kbody.halo = halo

	activeTerrainBoxes[kbody] = true
	kbody.destroyAt = -ScreenWidth/2 - ScreenWidth - posX - w/2 - 10
end

function _T.onCollision()
	print("box collision")
end


return _T