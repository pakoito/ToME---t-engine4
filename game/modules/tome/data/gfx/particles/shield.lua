return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.range(10, 15)

	return {
		life = 10,
		size = 2, sizev = -0.1, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = 0, dira = 0,
		vel = 1, velv = 0, vela = 0,

		r = 0.8, rv = 0, ra = 0,
		g = 0,   gv = 0, ga = 0,
		b = 0.9, bv = 0, ba = 0,
		a = 1,   av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(100)
end
