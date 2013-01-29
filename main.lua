-- Create the window
local deviceHeight = MOAIEnvironment.horizontalResolution
local deviceWidth = MOAIEnvironment.verticalResolution
if deviceWidth == nil then deviceWidth = 480 end
if deviceHeight == nil then deviceHeight = 320 end
MOAISim.openWindow("Geom Glow Test", deviceWidth, deviceHeight)
MOAISim.setStep ( 1 / 60 )

viewport = MOAIViewport.new()
viewport:setSize(deviceWidth, deviceHeight)
ScreenWidth, ScreenHeight = 480, 320
viewport:setScale(480, 320)
--viewport:setOffset(-1, -1)

layer = MOAILayer2D.new()
layer:setViewport(viewport)
MOAISim.pushRenderPass(layer)

world = MOAIBox2DWorld.new()
world:setGravity(0, -4)
world:setUnitsToMeters(1/50)
world:setDebugDrawEnabled(0)
world:start()
layer:setBox2DWorld(world)

--------------------------------------------------------------------
-- FILTER REFERENCE
-- 
FILTER_PLAYER = 0x01
FILTER_ACTIVE_TERRAIN = 0x02
FILTER_INACTIVE_BOX = 0x04
FILTER_INACTIVE_TERRAIN = 0x08
FILTER_GOAL = 0x16


TerrainBody = world:addBody(MOAIBox2DBody.STATIC)

local levelWidth, levelHeight = 480, 320
local floorHeight = 1

-- draw the edges of the screen
local left = TerrainBody:addPolygon({-levelWidth/2, -levelHeight/2, -levelWidth/2, levelHeight/2, -levelWidth/2 - 1, -levelHeight/2})
local right = TerrainBody:addPolygon({levelWidth/2, -levelHeight/2, levelWidth/2, levelHeight/2, levelWidth/2, -levelHeight/2})
local ceiling = TerrainBody:addPolygon({-levelWidth/2, levelHeight/2, levelWidth/2, levelHeight/2, -levelWidth/2, levelHeight/2})
local floor = TerrainBody:addPolygon({-levelWidth/2, -levelHeight/2 + floorHeight, levelWidth/2, -levelHeight/2 + floorHeight, -levelWidth/2, -levelHeight/2 + floorHeight})

Player = require "Player"
Player.new(24)

TerrainGenerator = require "TerrainGenerator"
TerrainGenerator.scrollTerrain()

function move_up()
	local thread = MOAICoroutine.new()
	thread:run(yield)
end

function yield()
	while touchDown do
		if Player.body then
			x,y = Player.shape:getLoc()
		--local action = Player.shape:moveLoc(0, 1, .01, MOAIEaseType.LINEAR)
		
			Player.body:applyForce(0, 800000)
		end
		--while action:isBusy() do
			coroutine.yield()
		--end
	end
end

function clickCallback ( down )
	if down then
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
		if MOAITouchSensor:getTouch() then
			clickCallback(true)
		end

		-- pointerCallback ( x, y )
		-- if eventType == MOAITouchSensor.TOUCH_DOWN then
		-- 	clickCallback ( true )
		-- elseif eventType == MOAITouchSensor.TOUCH_UP then
		-- 	clickCallback ( false )
		-- end
	end
	)
end
