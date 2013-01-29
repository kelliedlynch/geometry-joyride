_P = {}

_P.__index = _P

function _P.new(r)
	_P:drawSprite(r)

	local body = world:addBody(MOAIBox2DBody.DYNAMIC)
	local fixture = body:addCircle(0, 0, r)
	fixture:setDensity(1)
	fixture:setCollisionHandler(_P.onCollideWithTerrain, MOAIBox2DArbiter.ALL, FILTER_ACTIVE_TERRAIN)
	_P.shape:setParent(body)
	body:resetMassData()
	_P.body = body

end

function _P:drawSprite(r)
	local gfxQuad1 = MOAIGfxQuad2D.new()
	gfxQuad1:setTexture("circleglow.png")
	gfxQuad1:setRect (-r, -r, r, r )

	local halo = MOAIProp2D.new()
	halo:setDeck(gfxQuad1)
	halo:setColor(.8, .8, 1, 1)
	layer:insertProp(halo)

	local gfxQuad2 = MOAIGfxQuad2D.new()
	gfxQuad2:setTexture("circletex.png")
	gfxQuad2:setRect(-r, -r, r, r)

	local shape = MOAIProp2D.new()
	shape:setDeck(gfxQuad2)
	shape:setColor(.5, .5, 1, 1)
	layer:insertProp(shape)

	halo:setParent(shape)
	self.shape = shape
	self.halo = halo
end

function _P.onCollideWithTerrain(event, player, obstacle)
	if event == MOAIBox2DArbiter.BEGIN then _P.beginTerrainCollision(player, obstacle) end
	if event == MOAIBox2DArbiter.END then  end
	if event == MOAIBox2DArbiter.PRE_SOLVE then  end
	if event == MOAIBox2DArbiter.POST_SOLVE then  end
end

function _P.beginTerrainCollision(player, obstacle)
	print("collide")
	local x, y = player:getBody():getWorldCenter()
	_P.explode(x, y)
	_P.body = nil
	layer:removeProp(_P.shape)
	layer:removeProp(_P.halo)
	_P.shape = nil
	_P.halo = nil
	player:getBody():destroy()
	stopAction()
	spawnTerrain:stop()
	local thread = MOAICoroutine.new()
	thread:run(
		function()
			while not sparkSystem:isIdle() do
				coroutine.yield()
				--MOAICoroutine.blockOnAction(sparkSystem)
				
			end
			print("done")
			for body, v in pairs(activeTerrainBoxes) do
				layer:removeProp(body.shape)
				layer:removeProp(body.halo)
				body:destroy()
				activeTerrainBoxes[body] = nil
			end
			Player.new(24)
			TerrainGenerator.scrollTerrain()
		end
		)

end

function stopAction()
	for body, v in pairs(activeTerrainBoxes) do
		body:setLinearVelocity(0,0)
	end
end

function _P.explode(x, y)
	print("explode", x, y)
	local texture = MOAIImageTexture.new()
	texture:init(16,16)
	texture:setRGBA(15, 8, .5, .5, 1, .5)
	texture:setRGBA(0, 8, .5, .5, 1, 1)
	texture:setRGBA(8, 0, .5, .5, 1, 1)
	texture:setRGBA(8, 15, .5, .5, 1, 1)


	sparkDeck = MOAIGfxQuad2D.new ()
	sparkDeck:setTexture(texture)
	--sparkDeck:setTexture ( "moai.png" )
	sparkDeck:setRect (-32, -32, 32, 32 )

	------------------------------
	-- Particle scripts
	------------------------------

	-- pack registers for scripts
	reg1 = MOAIParticleScript.packReg(1)
	reg2 = MOAIParticleScript.packReg(2)
	reg3 = MOAIParticleScript.packReg(3)
	reg4 = MOAIParticleScript.packReg(4)
	reg5 = MOAIParticleScript.packReg(5)

	CONST = MOAIParticleScript.packConst

	----------
	--init script
	----------
	sparkInitScript = MOAIParticleScript.new ()

	-- this takes the registers you created above and turns them into random number generators
	-- returning values between the last two parameters
	sparkInitScript:randVec(reg1, reg2, CONST(0), CONST(80))
	sparkInitScript:rand(reg3, CONST(0), CONST(90))
	sparkInitScript:rand(reg4, CONST(.1), CONST(1.0))

	----------
	-- render script
	----------
	sparkRenderScript = MOAIParticleScript.new()

	--this makes the sprite appear
	sparkRenderScript:sprite()

	-- this controls the amount your particle cloud will spread out over the x axis
	-- and how fast / smooth it spreads. Note it is getting a random value from
	-- one of the script registers
	sparkRenderScript:easeDelta(MOAIParticleScript.PARTICLE_X, CONST(0), reg1, MOAIEaseType.SHARP_EASE_IN)
	--sparkRenderScript:easeDelta(MOAIParticleScript.PARTICLE_X, CONST(0), reg1, MOAIEaseType.SHARP_SMOOTH)

	-- this does the same over the y axis
	sparkRenderScript:easeDelta(MOAIParticleScript.PARTICLE_Y, CONST(0), reg2, MOAIEaseType.SHARP_EASE_IN)
	--sparkRenderScript:easeDelta(MOAIParticleScript.PARTICLE_Y, CONST(0), reg2, MOAIEaseType.SHARP_SMOOTH)


	-- resize
	--sparkRenderScript:ease(MOAIParticleScript.SPRITE_X_SCL, reg4, CONST(0.01), MOAIEaseType.EASE_IN)
	--sparkRenderScript:ease(MOAIParticleScript.SPRITE_Y_SCL, reg4, CONST(0.01), MOAIEaseType.EASE_IN)

	-- creates sparkling color
	--sparkRenderScript:set(MOAIParticleScript.SPRITE_GLOW, reg3)
	-- sparkRenderScript:set(MOAIParticleScript.SPRITE_RED, reg3 )
	-- sparkRenderScript:set(MOAIParticleScript.SPRITE_BLUE, reg4 )
	-- sparkRenderScript:set(MOAIParticleScript.SPRITE_GREEN, reg4 )

	-- this sets a random starting rotation for each particle
	sparkRenderScript:set ( MOAIParticleScript.SPRITE_ROT, reg3 )

	-- this applies a random amount of rotation to each particle during its lifetime
	--sparkRenderScript:ease ( MOAIParticleScript.SPRITE_ROT, CONST(0), reg3, MOAIEaseType.LINEAR )
	--sparkRenderScript:ease                            ( MOAIParticleScript.SPRITE_ROT, CONST ( 0), CONST ( 360),MOAIEaseType.LINEAR)

	-- this makes the particle fade out near the end of its lifetime
	sparkRenderScript:ease ( MOAIParticleScript.SPRITE_OPACITY, CONST(.5), CONST(0), MOAIEaseType.EASE_IN )

	-- this makes each particle randomly bigger or smaller than the original size
	--sparkRenderScript:ease(MOAIParticleScript.SPRITE_X_SCL, CONST(0), CONST(1), MOAIEaseType.EASE_IN)
	--sparkRenderScript:ease(MOAIParticleScript.SPRITE_Y_SCL, CONST(0), CONST(1), MOAIEaseType.EASE_IN)

	------------------------------
	-- Particle system
	------------------------------
	sparkSystem = MOAIParticleSystem.new ()

	-- max num of particles, size of each
	sparkSystem:reserveParticles ( 128, 10 )

	-- max num of sprites
	sparkSystem:reserveSprites(128 )
	sparkSystem:reserveStates(1 )

	-- deck can be set like a prop
	sparkSystem:setDeck(sparkDeck)
	sparkSystem:start()

	-- particle system can be inserted like a prop
	layer:insertProp(sparkSystem)
	--sparkSystem:setLoc(0,0)

	-- sparkSystem = MOAIParticleEmitter.new()
	-- sparkSystem:setRadius(30)
	-- sparkSystem:setDeck(Deck)
	-- sparkSystem:start()
	-- layer:insertProp(sparkSystem)


	------------------------------
	-- Particle forces
	------------------------------
	gravity = MOAIParticleForce.new()
	gravity:initLinear(0, -100)
	gravity:setType(MOAIParticleForce.FORCE)

	------------------------------
	-- Particle state
	------------------------------

	-- a state holds a particle cloud's lifetime, physics properties
	-- and which scripts govern its behavior
	sparkState = MOAIParticleState.new()

	-- particle lifetime, random between the two values in seconds
	sparkState:setTerm( 1, 3 )
	sparkState:setInitScript(sparkInitScript )
	sparkState:setRenderScript(sparkRenderScript )
	--sparkState:setDamping(10)
	--sparkState:pushForce (gravity)

	-- sets the system to this state
	sparkSystem:setState ( 1, sparkState )
	sparkSystem:surge(128, x, y, 0, 0)
end

return _P