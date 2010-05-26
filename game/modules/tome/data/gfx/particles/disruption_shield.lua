-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad)
	local r = rng.range(15, 18)

	return {
		trail = 1,
		life = 10,
		size = 4, sizev = -0.1, sizea = 0,

		x = r * math.cos(a), xv = 0.1, xa = 0,
		y = r * math.sin(a), yv = 0.1, ya = 0,
		dir = dir, dirv = 0.1, dira = 0,
		vel = 1, velv = 0, vela = -0.2,

		r = rng.range(130, 220)/255, rv = rng.range(0, 10), ra = 0,
		g = 0,   gv = 0, ga = 0,
		b = rng.range(170, 255)/255, bv = rng.range(0, 10), ba = 0,
		a = rng.range(70, 255)/255,   av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(10)
end,
100
