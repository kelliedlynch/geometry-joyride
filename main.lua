require "Util"
require "EventDispatcher"
require "GeomObject"

-- DEBUG MODE
DEBUG = true

if(DEBUG) then
  MOAIDebugLines.setStyle ( MOAIDebugLines.PARTITION_CELLS, 2, 0, 0, 1, 1 )
  MOAIDebugLines.setStyle ( MOAIDebugLines.PARTITION_PADDED_CELLS, 1, 0, 1, 0, 1 )
  MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 1, 0, 0, 1 )
  MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_MODEL_BOUNDS, 2, 1, 1, 0, 1 )
  MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 2, 1, 0, 1, 1 )
  --MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_BASELINES, 2, 1, 1, 0, 1 )
  --MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_LAYOUT, 2, 1, 1, 0, 1 )
  --MOAIDebugLines.setStyle ( MOAIDebugLines.TOTAL_STYLES, 2, 1, 1, 0, 1 )
end

FRAME_RATE = 60
-- Create the window
local deviceHeight = MOAIEnvironment.horizontalResolution
local deviceWidth = MOAIEnvironment.verticalResolution
if deviceWidth == nil then deviceWidth = 480 end
if deviceHeight == nil then deviceHeight = 320 end
MOAISim.openWindow("Geometry Joyride", deviceWidth, deviceHeight)
MOAISim.setStep(1/FRAME_RATE)

viewport = MOAIViewport.new()
viewport:setSize(deviceWidth, deviceHeight)
_G.screenWidth, _G.screenHeight = 480, 320
viewport:setScale(480, 320)

--------------------------------------------------------------------
-- INITIALIZE GAME LAYERS
--
_G.gameLayer = MOAILayer2D.new()
_G.gameLayer:setViewport(viewport)
MOAISim.pushRenderPass(_G.gameLayer)
_G.hudLayer = MOAILayer2D.new()
_G.hudLayer:setViewport(viewport)
MOAISim.pushRenderPass(_G.hudLayer)
--
-- END GAME LAYERS
--------------------------------------------------------------------

_G.world = MOAIBox2DWorld.new()
_G.world:setGravity(0, -9)
_G.world:setUnitsToMeters(1/50)
_G.world:setDebugDrawEnabled(true)
_G.world:start()
_G.gameLayer:setBox2DWorld(_G.world)

--------------------------------------------------------------------
-- PHYSICS OBJECT FILTERS
-- 
FILTER_PLAYER = 0x01
FILTER_DEADLY_OBJECT = 0x02
FILTER_FRIENDLY_OBJECT = 0x04
FILTER_INACTIVE_TERRAIN = 0x08
FILTER_GOAL = 0x16
--
-- END PHYSICS OBJECT FILTERS
--------------------------------------------------------------------

--------------------------------------------------------------------
-- FONTS AND STYLES
--
DEFAULT_FONT = MOAIFont.new()
DEFAULT_FONT:load('Resources/Fonts/arial-rounded.TTF')

DEFAULT_STYLE = MOAITextStyle.new()
DEFAULT_STYLE:setFont(DEFAULT_FONT)
DEFAULT_STYLE:setSize(24)
--
-- END FONTS AND STYLES
--------------------------------------------------------------------



TerrainBody = _G.world:addBody(MOAIBox2DBody.STATIC)

local levelWidth, levelHeight = 480, 310

-- draw the edges of the screen
local left = TerrainBody:addChain({-levelWidth/2, -levelHeight/2, -levelWidth/2, levelHeight/2})
--local right = TerrainBody:addChain({levelWidth/2, -levelHeight/2, levelWidth/2, levelHeight/2})
local ceiling = TerrainBody:addChain({-levelWidth/2, levelHeight/2, levelWidth/2, levelHeight/2})
local floor = TerrainBody:addChain({-levelWidth/2, -levelHeight/2, levelWidth/2, -levelHeight/2})

require "GeomObject"

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
			_G.game.player.body:applyForce(0, 2000000)
		end
		coroutine.yield()
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