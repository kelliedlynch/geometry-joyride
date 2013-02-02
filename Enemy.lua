_E = {}

_E.__index = _E

function _E.new(r)
	local enemy = {}
	setmetatable(enemy, _E)
	local startX = _G.screenWidth/2 - _G.screenWidth/5
	enemy:drawSprite(r, startX)

	local body = _G.world:addBody(MOAIBox2DBody.KINEMATIC)
	body:setFixedRotation(true)
	local fixture = body:addCircle(startX, 0, r)
	--fixture:setDensity(1)
	fixture:setFilter(FILTER_DEADLY_OBJECT)
	--fixture:setCollisionHandler(enemy.onCollision, MOAIBox2DArbiter.ALL)
	enemy.shape:setParent(body)
	body:resetMassData()
	enemy.body = body

	body.destroyAt = -_G.screenWidth/2 - startX - r - 10
	body.width = r*2
	body.shape = enemy.shape
	body.halo = enemy.halo
	print("body, fixture, sprite", body, fixture, enemy.shape)
	body:setLinearVelocity(_G.game.player.speed, 0)
	_G.game.activeObjects[body] = true

	return enemy
end

function _E:drawSprite(r, startX)
	print("drawing enemy", startX, r)
	local gfxQuad1 = MOAIGfxQuad2D.new()
	gfxQuad1:setTexture("Resources/Images/circle1glow.png")
	gfxQuad1:setRect(startX-r, -r, startX+r, r )

	local halo = MOAIProp2D.new()
	halo:setDeck(gfxQuad1)
	halo:setColor(1, .8, .8, 1)
	_G.gameLayer:insertProp(halo)

	local gfxQuad2 = MOAIGfxQuad2D.new()
	gfxQuad2:setTexture("Resources/Images/circle1tex.png")
	gfxQuad2:setRect(startX-r, -r, startX + r, r)

	local shape = MOAIProp2D.new()
	shape:setDeck(gfxQuad2)
	shape:setColor(1, .7, .7, 1)
	_G.gameLayer:insertProp(shape)

	halo:setParent(shape)
	self.shape = shape
	self.halo = halo
end

return _E