Player = inheritsFrom(GeomObject)
Player.DEFAULT_WIDTH = 48
Player.DEFAULT_HEIGHT = 48
Player.DEFAULT_COLOR = {.7, .7, 1, 1}
Player.DEFAULT_HALO_TEXTURE = "Resources/Images/circle1glow.png"
Player.DEFAULT_SHAPE_TEXTURE = "Resources/Images/circle1tex.png"
Player.STARTING_SPEED = -800
Player.MAX_SPEED = -800

function Player:constructor(w, h, x, y)
	
	local w, h, x, y = self.DEFAULT_WIDTH, self.DEFAULT_HEIGHT, -_G.screenWidth/2 + _G.screenWidth/5, -self.DEFAULT_HEIGHT/2
	print("creating player with params", self, w, h, x, y)
	GeomObject.constructor(self, w, h, x, y)

	self.body = _G.world:addBody(MOAIBox2DBody.DYNAMIC)
	self.body:setFixedRotation(true)
	self.body:setTransform(self.posX, self.posY)
	self.fixture = self.body:addCircle(w/2, w/2, w/2)
	self.fixture:setDensity(1)
	self.fixture:setFilter(FILTER_PLAYER)
	self.fixture:setCollisionHandler(self.onCollision, MOAIBox2DArbiter.ALL)
	self.body:resetMassData()
	self:renderSprite()

	self.coins = 0

	Dispatch.registerEvent("onCoinCollected", self, true)

	return self
end

function Player:animate()

end

function Player:accelerate(value)
	if not self.speed then self.speed = self.STARTING_SPEED end
	if not value then value = .2 end
	if self.speed > self.MAX_SPEED then
		self.speed = self.speed - value
		Dispatch.triggerEvent("onUpdateSpeed")
	elseif self.speed < self.MAX_SPEED then
		self.speed = self.MAX_SPEED
		Dispatch.triggerEvent("onUpdateSpeed")
	end
end

function Player:___onUpdateSpeed()
	--self.speed = speed
end

function Player:isAlive()
	if self.body then
		return true
	else
		return false
	end
end

function Player:getStartSpeed()
	self.speed = Player.STARTING_SPEED
	return self.speed
end

function Player.onCollision(event, player, obstacle)
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

function Player:beginDeadlyCollision(player, obstacle)
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

function Player:destroy()
	print("destroying")
	self:explode()
	_G.gameLayer:removeProp(self.shape)
	_G.gameLayer:removeProp(self.halo)
	self.shape = nil
	self.halo = nil
	self.body:destroy()
	self.body = nil
end

function Player:explode()
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

function Player:___onCoinCollected(coin)
	print("coin, value", coin, coin.value)
	self.coins = self.coins + coin.value
	_G.game.coinCounter:update(self.coins)
end

return Player