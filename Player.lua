local _P = {}

_P.__index = _P

_P.STARTING_SPEED = -100
_P.MAX_SPEED = -400
_P.SPRITE_SIZE = 24

function _P.new(r)
	local player = {}
	setmetatable(player, _P)
	local startX = -_G.screenWidth/2 + _G.screenWidth/5
	player:drawSprite(r, startX)

	local body = _G.world:addBody(MOAIBox2DBody.DYNAMIC)
	body:setFixedRotation(true)
	local fixture = body:addCircle(startX, 0, r)
	fixture:setDensity(1)
	fixture:setFilter(FILTER_PLAYER)
	fixture:setCollisionHandler(player.onCollision, MOAIBox2DArbiter.ALL)
	player.shape:setParent(body)
	body:resetMassData()
	player.body = body
	player.coins = 0

	Dispatch.registerEvent("onCoinCollected", player, true)

	return player
end

function _P:isAlive()
	if self.body then
		return true
	else
		return false
	end
end

function _P:getStartSpeed()
	self.speed = _P.STARTING_SPEED
	return self.speed
end

function _P:drawSprite(r, startX)
	print("drawing sprite", startX, r)
	local gfxQuad1 = MOAIGfxQuad2D.new()
	gfxQuad1:setTexture("Resources/Images/circle1glow.png")
	gfxQuad1:setRect (startX-r, -r, startX+r, r )

	local halo = MOAIProp2D.new()
	halo:setDeck(gfxQuad1)
	halo:setColor(.8, .8, 1, 1)
	_G.gameLayer:insertProp(halo)

	local gfxQuad2 = MOAIGfxQuad2D.new()
	gfxQuad2:setTexture("Resources/Images/circle1tex.png")
	gfxQuad2:setRect(startX-r, -r, startX + r, r)

	local shape = MOAIProp2D.new()
	shape:setDeck(gfxQuad2)
	shape:setColor(.7, .7, 1, 1)
	_G.gameLayer:insertProp(shape)

	halo:setParent(shape)
	self.shape = shape
	self.halo = halo
end

function _P.onCollision(event, player, obstacle)
	if event == MOAIBox2DArbiter.BEGIN then
		if obstacle:getFilter() == FILTER_DEADLY_OBJECT then
			_G.game.player.beginDeadlyCollision(_G.game.player, player, obstacle)
		elseif obstacle:getFilter() == FILTER_FRIENDLY_OBJECT then
			print("friendly collision")
		end
	end
	if event == MOAIBox2DArbiter.END then  end
	if event == MOAIBox2DArbiter.PRE_SOLVE then  end
	if event == MOAIBox2DArbiter.POST_SOLVE then  end
end

function _P:beginDeadlyCollision(player, obstacle)
	print("begin deadly collision")
	self:destroy()
	_G.game:stopScrolling()
	_G.game.thread:stop()
	local thread = MOAICoroutine.new()
	thread:run(
		function()
			while not sparkSystem:isIdle() do
				coroutine.yield()
			end
			print("done exploding")
			Dispatch.triggerEvent("onPlayerDestroyed")
		end
		)
end

function _P:destroy()
	print("destroying")
	self:explode()
	_G.gameLayer:removeProp(self.shape)
	_G.gameLayer:removeProp(self.halo)
	self.shape = nil
	self.halo = nil
	self.body:destroy()
	self.body = nil
end

function _P:explode()
	local x, y = self.body:getWorldCenter()
	print("explode", x, y)
	local texture = MOAIImageTexture.new()
	texture:init(16,16)
	texture:setRGBA(15, 8, .5, .5, 1, .5)
	texture:setRGBA(0, 8, .5, .5, 1, 1)
	texture:setRGBA(8, 0, .5, .5, 1, 1)
	texture:setRGBA(8, 15, .5, .5, 1, 1)


	sparkDeck = MOAIGfxQuad2D.new ()
	sparkDeck:setTexture(texture)
	sparkDeck:setRect (-24, -24, 24, 24 )

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

	-- this does the same over the y axis
	sparkRenderScript:easeDelta(MOAIParticleScript.PARTICLE_Y, CONST(0), reg2, MOAIEaseType.SHARP_EASE_IN)

	-- this sets a random starting rotation for each particle
	sparkRenderScript:set ( MOAIParticleScript.SPRITE_ROT, reg3 )

	-- this makes the particle fade out near the end of its lifetime
	sparkRenderScript:ease ( MOAIParticleScript.SPRITE_OPACITY, CONST(.5), CONST(0), MOAIEaseType.EASE_IN )

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
	_G.gameLayer:insertProp(sparkSystem)

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

	-- sets the system to this state
	sparkSystem:setState ( 1, sparkState )
	sparkSystem:surge(128, x, y, 0, 0)
end

function _P:___onCoinCollected(coin)
	print("coin, value", coin, coin.value)
	self.coins = self.coins + coin.value
	_G.game.coinCounter:update(self.coins)
end

return _P