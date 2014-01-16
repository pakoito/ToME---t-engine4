-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

base_size = 32

return { generator = function()
	-- Make a random palette from light brown, dark brown, green, and black.
	-- This lets us avoid "weird" colors like yellow, orange, and blue, and
	-- these particles should still be clearly visible over a variety of terrain.
	local r1 = rng.float(0, 1)
	local r2 = rng.float(0, 1)
	local r3 = rng.float(0, 0.5)
	local r4 = rng.float(0, 1.5)
	local tot = r1 + r2 + r3 + r4
	r1 = r1 / tot
	r2 = r2 / tot
	r3 = r3 / tot

	return {
		trail = 1,
		life = rng.range(35, 50),
		size = rng.float(2, 3), sizev = 0, sizea = 0,

		x = rng.range(-12, 12), xv = rng.float(-0.3, 0.3), xa = 0,
		y = rng.range(-10, 16), yv = rng.float(-0.5, -0.3), ya = 0.02,
		dir = 0, dirv = 0, dira = 0,
		vel = 0.0, velv = 0, vela = 0,

		r = r1*0.55 + r2*0.42 + r3*0.10, rv = 0, ra = 0,
		g = r1*0.45 + r2*0.26 + r3*0.55, gv = 0, ga = 0,
		b = r1*0.33 + r2*0.15 + r3*0.10, bv = 0, ba = 0,
		a = 1.0, av = 0, aa = -0.0006,
	}
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 30 then
		self.ps:emit(6)
	end
end,
40

