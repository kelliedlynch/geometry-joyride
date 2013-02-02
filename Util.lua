--------------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------------

-- return float with the specified number of decimal places
function round(number, decimal)
	local multiplier = 10^(decimal or 0)
	return math.floor(number * multiplier + .5) / multiplier
end

-- Subclass inheritance function from lua-users wiki
function inheritsFrom( baseClass )
	local new_class = {}
	local class_mt = { __index = new_class }

	function new_class:init()
		local newinst = {}
			setmetatable( newinst, class_mt )
		return newinst
	end

	if baseClass then
		setmetatable( new_class, { __index = baseClass } )
	end

	return new_class
end