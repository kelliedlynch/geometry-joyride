--------------------------------------------------------------------
-- BASE CLASS FOR ALL TERRAIN AND ENEMY OBJECTS
--------------------------------------------------------------------

GeomObject = {}
GeomObject.__index = GeomObject

function GeomObject:init()
	local newInstance = {}
	setmetatable(newInstance, GeomObject)
	return newInstance
end


require "GeomRectangle"