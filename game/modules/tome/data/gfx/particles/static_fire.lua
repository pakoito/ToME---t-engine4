-- ToME - Tales of Maj'Eyal
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

local epi = { x=0, y=0 }
local size = engine.Map.tile_w * radius * 2

return { generator = function()
	return {
		life = 10,
		size = rng.range(2,4), sizev = -0.2, sizea = 0,

		x = epi.x+rng.avg(-size/2, size/2, 3), xv = rng.range(-10, 10) / 20, xa = 0,
		y = epi.y+rng.avg(-size/2, size/2, 3), yv = rng.range(-10, 10) / 20, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 0, gv = rng.range(1, 5) / 20, ga = 0,
		b = 0, bv = 0, ba = 0,
		a = 1, av = -0.05, aa = 0,
	}
end, },
function(self)
	epi.x = util.bound(epi.x + rng.range(-5, 5), -size/2, size/2)
	epi.y = util.bound(epi.y + rng.range(-5, 5), -size/2, size/2)
	self.ps:emit(30 * radius * radius)
end, 300 * radius * radius
