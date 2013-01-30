-- Create the window
local deviceHeight = MOAIEnvironment.horizontalResolution
local deviceWidth = MOAIEnvironment.verticalResolution
if deviceWidth == nil then deviceWidth = 480 end
if deviceHeight == nil then deviceHeight = 320 end
MOAISim.openWindow("Geometry Joyride", deviceWidth, deviceHeight)
MOAISim.setStep(1/60)

viewport = MOAIViewport.new()
viewport:setSize(deviceWidth, deviceHeight)
_G.screenWidth, _G.screenHeight = 480, 320
viewport:setScale(480, 320)

_G.gameLayer = MOAILayer2D.new()
_G.gameLayer:setViewport(viewport)
MOAISim.pushRenderPass(_G.gameLayer)

_G.world = MOAIBox2DWorld.new()
_G.world:setGravity(0, -6)
_G.world:setUnitsToMeters(1/50)
_G.world:setDebugDrawEnabled(0)
_G.world:start()
_G.gameLayer:setBox2DWorld(_G.world)

--------------------------------------------------------------------
-- FILTER REFERENCE
-- 
FILTER_PLAYER = 0x01
FILTER_ACTIVE_TERRAIN = 0x02
FILTER_INACTIVE_BOX = 0x04
FILTER_INACTIVE_TERRAIN = 0x08
FILTER_GOAL = 0x16


TerrainBody = _G.world:addBody(MOAIBox2DBody.STATIC)

local levelWidth, levelHeight = 480, 310

-- draw the edges of the screen
local left = TerrainBody:addChain({-levelWidth/2, -levelHeight/2, -levelWidth/2, levelHeight/2})
local right = TerrainBody:addChain({levelWidth/2, -levelHeight/2, levelWidth/2, levelHeight/2})
local ceiling = TerrainBody:addChain({-levelWidth/2, levelHeight/2, levelWidth/2, levelHeight/2})
local floor = TerrainBody:addChain({-levelWidth/2, -levelHeight/2, levelWidth/2, -levelHeight/2})


Game = require "Game"
_G.game = Game.begin()

function move_up()
	local thread = MOAICoroutine.new()
	thread:run(yield)
end

function yield()
	while touchDown do
		if _G.game.player.body then
			x,y = _G.game.player.shape:getLoc()
		--local action = _G.player.shape:moveLoc(0, 1, .01, MOAIEaseType.LINEAR)
		
			_G.game.player.body:applyForce(0, 1000000)
		end
		--while action:isBusy() do
			coroutine.yield()
		--end
	end
end

function clickCallback(down)
	if down then
		-- if _G.game.thread(isBusy) then
		-- 	_G.game:clickCallback(down)
		-- end
		touchDown = true
		local thread = MOAICoroutine.new()
		thread:run(yield)
	else
		touchDown = false
	end
end

function pointerCallback()

end 

if MOAIInputMgr.device.pointer then
	MOAIInputMgr.device.pointer:setCallback(pointerCallback)
	MOAIInputMgr.device.mouseLeft:setCallback(clickCallback)
else
	-- touch input
	MOAIInputMgr.device.touch:setCallback (

	function ( eventType, idx, x, y, tapCount )
		-- pointerCallback ( x, y )
		if eventType == MOAITouchSensor.TOUCH_DOWN then
			clickCallback ( true )
		elseif eventType == MOAITouchSensor.TOUCH_UP then
			clickCallback ( false )
		end
	end
	)
end
