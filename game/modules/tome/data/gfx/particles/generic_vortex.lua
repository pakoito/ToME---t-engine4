-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	local radius = radius
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 60)
	local r = rng.float(0, sradius)
	local dirv = math.rad(3)

	return {
		trail = 1,
		life = 2,
		size = 4, sizev = 0, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = 0, dira = 0,
		vel = -r/8, velv = 0, vela = 0,

		r = rng.range(rm, rM)/255,  		rv = 0.005, ra = 0.0005,
		g = rng.range(gm, gM)/255, 	 		gv = 0.005, ga = 0.0005,
		b = rng.range(bm, bM)/255, 			bv = 0.005, ba = 0.0005,
		a = rng.range(am, aM)/255, 	 	  	av = 0, aa = 0.005,
	}
end, },
function(self)
	self.ps:emit(200*radius)
end,
200*radius*2