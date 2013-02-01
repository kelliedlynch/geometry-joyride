local _O = {}

function _O.rectangle(w, h, y)
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
	kfix:setFilter(FILTER_DEADLY_OBJECT)
	kfix:setCollisionHandler(_O.onCollision, MOAIBox2DArbiter.ALL, FILTER_PLAYER)
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

	game.activeObjects[kbody] = true

	kbody.destroyAt = -_G.screenWidth/2 - _G.screenWidth - posX - w/2 - 10
end

function _O.coin(y)
	local w, h = 16, 16
	posX = _G.screenWidth/2
	if not y then
		posY = math.random(-_G.screenHeight/2 + 10, _G.screenHeight/2 - 10 - h)
	else
		posY = y
	end

	local kbody = _G.world:addBody(MOAIBox2DBody.KINEMATIC)
	local poly = {
		posX, posY,
		posX + w, posY,
		posX + w/2, posY + h,
	}
	local kfix = kbody:addPolygon(poly)
	kfix:setFilter(FILTER_FRIENDLY_OBJECT)
	kfix:setCollisionHandler(_O.coinCollision, MOAIBox2DArbiter.ALL, FILTER_PLAYER)
	kfix:setSensor(true)
	kbody:resetMassData()
	kbody:setLinearVelocity(_G.speed, 0)

	local gfxQuad1 = MOAIGfxQuad2D.new()
	gfxQuad1:setTexture("Resources/Images/triglow.png")
	gfxQuad1:setRect (posX, posY, posX + w, posY + h)

	local halo = MOAIProp2D.new()
	halo:setDeck(gfxQuad1)
	halo:setColor(.2, 1, .4, 1)
	_G.gameLayer:insertProp(halo)

	local gfxQuad2 = MOAIGfxQuad2D.new()
	gfxQuad2:setTexture("Resources/Images/tritex.png")
	gfxQuad2:setRect(posX, posY, posX + w, posY + h)

	local shape = MOAIProp2D.new()
	shape:setDeck(gfxQuad2)
	shape:setColor(.2, 1, .4, 1)
	_G.gameLayer:insertProp(shape)

	halo:setParent(shape)
	shape:setParent(kbody)
	kbody.shape = shape
	kbody.halo = halo

	game.activeObjects[kbody] = true

	kbody.destroyAt = -_G.screenWidth/2 - _G.screenWidth - posX - w/2 - 10
end

function _O.onCollision()
	print("terrain collision")
end

function _O.coinCollision(event, coin, player)
	print("object collision")
	if event == MOAIBox2DArbiter.BEGIN then _O.beginCoinCollision(coin, player) end
	if event == MOAIBox2DArbiter.END then  end
	if event == MOAIBox2DArbiter.PRE_SOLVE then  end
	if event == MOAIBox2DArbiter.POST_SOLVE then  end
end

function _O.beginCoinCollision(coin, player)
	game.activeObjects[coin:getBody()] = nil
	_G.gameLayer:removeProp(coin:getBody().shape)
	_G.gameLayer:removeProp(coin:getBody().halo)
	coin:getBody():destroy()
end

return _O