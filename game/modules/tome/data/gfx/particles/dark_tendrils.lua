-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	local dir = math.rad(rng.range(0, 360))
	local dirv = math.rad(rng.range(-40, 40))

	return {
		trail = 1,
		life = 100,
		size = 8, sizev = 0, sizea = 0,

		x = -3, xv = 0, xa = 0,
		y = -3, yv = 0, ya = 0,
		dir = dir, dirv = dirv, dira = -dirv / 30,
		vel = 0.4, velv = -0.005, vela = 0,

		r = 64 / 255, rv = 0, ra = 0,
		g = 32 / 255, gv = 0, ga = 0,
		b = 96 / 255, bv = 0, ba = 0,
		a = rng.range(140, 200) / 255, av = 0, aa = 0
	}
end, },
function(self)
	self.ps:emit(1)
end,
100
