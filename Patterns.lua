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
				time = 0,
				action = "rectangle",
				params = {100, 30, 60},
			},
			[2] = {
				time = 0,
				action = "rectangle",
				params = {100, -30, -60},
			},
		},
		[2] = {
			[1] = {
				time = 0,
				action = "coin",
				params = {-100},
			},
			[2] = {
				time = .3,
				action = "coin",
				params = {-100},
			},
			[3] = {
				time = .6,
				action = "coin",
				params = {-100},
			},
		},
		[3] = {
			[1] = {
				time = 0,
				action = "coin",
				params = {100},
			},
			[2] = {
				time = .1,
				action = "coin",
				params = {90},
			},
			[3] = {
				time = .2,
				action = "coin",
				params = {80},
			},
			[4] = {
				time = .3,
				action = "coin",
				params = {70},
			},
			[5] = {
				time = .4,
				action = "coin",
				params = {60},
			},
		},
		[4] = {
			[1] = {
				time = 0,
				action = "rectangle",
				params = {20, 110, -160},
			},
			[2] = {
				time = 1,
				action = "rectangle",
				params = {20, 110, 60},
			},
			[3] = {
				time = 2,
				action = "rectangle",
				params = {20, 110, -160},
			},
			[4] = {
				time = 3,
				action = "rectangle",
				params = {20, 110, 60},
			},
		},
		-- [5] = {
		-- 	[1] = {
		-- 		time = 0,
		-- 		action = "enemy",
		-- 		params = {24},
		-- 	},
		-- },
	},
}

return _P