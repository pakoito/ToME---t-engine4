-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

density = density or 40
static = static or 40
life = life or 24
instop = instop or 34
svel = - radius / 2

return { generator = function()
	local radius = radius
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(sradius - 5, sradius)
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local static = rng.percent(static)

	return {
		trail = 1,
		life = life,
		size = 3, sizev = static and 0.05 or 0.1, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = static and a + math.rad(90) or a, dirv = 0, dira = 0,
		vel = static and svel or -r / instop, velv = 0, vela = static and svel/200 or 0,

		r = rng.range(rm, rM)/255,   rv = 0, ra = 0,
		g = rng.range(gm, gM)/255,   gv = 0.005, ga = 0.0005,
		b = rng.range(bm, bM)/255,   bv = 0, ba = 0,
		a = rng.range(am, aM)/255,   av = static and -0.034 or 0, aa = 0.005,
	}
end, },
function(self)
	self.ps:emit(radius * density)
end,
24*radius*density
