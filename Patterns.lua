local _P = {}
-- GeomRectangle(width, height, y)
-- GeomCoin(y)
-- time, action, params


_P = {
	--------------------------------------------------------------------
	-- LEVEL ONE PATTERNS
	--------------------------------------------------------------------
	level1 = {
		[1] = {
			[1] = {
				time = 0,
				action = "GeomRectangle",
				params = {100, 30, 60},
			},
			[2] = {
				time = 0,
				action = "GeomRectangle",
				params = {100, 30, -90},
			},
		},
		[2] = {
			[1] = {
				time = 0,
				action = "GeomCoin",
				params = {-100},
			},
			[2] = {
				time = .3,
				action = "GeomCoin",
				params = {-100},
			},
			[3] = {
				time = .6,
				action = "GeomCoin",
				params = {-100},
			},
		},
		[3] = {
			[1] = {
				time = 0,
				action = "GeomCoin",
				params = {100},
			},
			[2] = {
				time = .1,
				action = "GeomCoin",
				params = {90},
			},
			[3] = {
				time = .2,
				action = "GeomCoin",
				params = {80},
			},
			[4] = {
				time = .3,
				action = "GeomCoin",
				params = {70},
			},
			[5] = {
				time = .4,
				action = "GeomCoin",
				params = {60},
			},
		},
		[4] = {
			[1] = {
				time = 0,
				action = "GeomRectangle",
				params = {20, 110, -160},
			},
			[2] = {
				time = 1,
				action = "GeomRectangle",
				params = {20, 110, 60},
			},
			[3] = {
				time = 2,
				action = "GeomRectangle",
				params = {20, 110, -160},
			},
			[4] = {
				time = 3,
				action = "GeomRectangle",
				params = {20, 110, 60},
			},
		},
		[5] = {
			[1] = {
				time = 0,
				action = "GeomEnemy",
				params = {24, 24, 0},
			},
		},
	},
}

return _P