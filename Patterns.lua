local _P = {}

-- each pattern can occur at variable y-positions
-- x and y are the position of the shape within the pattern

-- rectangle(width, height, y, time)
-- time, action, params
_P[1] = {
	[1] = {
		time = 1,
		action = "rectangle",
		params = {100, 60, -100},
	},
	[2] = {
		time = 3,
		action = "rectangle",
		params = {100, 30, 100},
	},
	[3] = {
		time = 5,
		action = "rectangle",
		params = {50, 60, -40},
	},
}

return _P