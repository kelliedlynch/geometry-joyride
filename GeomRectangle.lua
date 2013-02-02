GeomRectangle = inheritsFrom(GeomObject)

function GeomRectangle:new(w, h, y)
	print("creating new rectangle")
	local newInstance = self:init()

	return newInstance
end
