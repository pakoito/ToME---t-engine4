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

local toggle = false

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local size = rng.range(6, 10)
	local halfSize = size / 2

	return {
		trail = 1,
		life = 35,
		size = size, sizev = 0.3, sizea = -0.05,

		x = rng.range(-engine.Map.tile_w * 0.4 - halfSize, engine.Map.tile_w * 0.4 - halfSize), xv = 0, xa = 0,
		y = rng.range(-engine.Map.tile_h * 0.4 - halfSize, engine.Map.tile_h * 0.4 - halfSize), yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 0,   rv = 0, ra = 0,
		g = rng.range(170, 210)/255,   gv = 0, ga = 0,
		b = rng.range(200, 255)/255,   gv = 0, ga = 0,
		a = rng.range(80, 130)/255,   av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(2)
end,
100
