local _P = {}
-- rectangle(width, height, y)
-- coin(y)
-- time, action, params


_P = {
	--------------------------------------------------------------------
	-- LEVEL ONE PATTERNS
	--------------------------------------------------------------------
	level1 = {
		[1] = {
			[1] = {
				time = 1,
				action = "rectangle",
				params = {100, 30, 100},
			},
			[2] = {
				time = 2,
				action = "rectangle",
				params = {50, 60, -40},
			},
		},
		[2] = {
			[1] = {
				time = 1,
				action = "coin",
				params = {-100},
			},
			[2] = {
				time = 1.15,
				action = "coin",
				params = {-100},
			},
			[3] = {
				time = 1.3,
				action = "coin",
				params = {-100},
			},
		},
		[3] = {
			[1] = {
				time = 1,
				action = "coin",
				params = {100},
			},
			[2] = {
				time = 2,
				action = "coin",
				params = {100},
			},
		},
	},
}

return _P