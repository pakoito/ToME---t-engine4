return {
	base = 1000,

	angle = { 0, 360 }, anglev = { 2000, 4000 }, anglea = { 20, 60 },

	life = { 3, 6 },
	size = { 1, 3 }, sizev = {0, 0}, sizea = {0, 0},

	r = {200, 230}, rv = {0, 10}, ra = {0, 0},
	g = {130, 160}, gv = {0, 0}, ga = {0, 0},
	b = {50, 70},  bv = {0, 10}, ba = {0, 0},
	a = {255, 255}, av = {0, 0}, aa = {0, 0},

}, function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 6 then
		self.ps:emit(100)
	end
end
