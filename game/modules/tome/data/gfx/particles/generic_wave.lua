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

local nb = 12
local dir = 0
local spread = spread or 55/2
local radius = radius or 6

dir = math.deg(math.atan2(ty, tx))

return { generator = function()
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(dir - spread, dir + spread)
	local a = math.rad(ad)
	local r = 0
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local static = rng.percent(40)
	local vel = sradius * ((24 - nb * 1.4) / 24) / 6

	return {
		trail = 0,
		life = 6,
		size = 12 - (12 - nb) * 0.7, sizev = 0, sizea = 2,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = 0, dira = 0,
		vel = rng.float(vel * 0.6, vel * 1.2), velv = 0, vela = 0,


		r = rng.range(rm, rM)/255,  	rv = 0.005, ra = 0.0005,
		g = rng.range(gm, gM)/255, 	 	gv = 0.005, ga = 0.0005,
		b = rng.range(bm, bM)/255, 		bv = 0.005, ba = 0.0005,
		a = rng.range(am, aM)/255, 		av = 0, aa = 0,
	}
end, },
function(self)
	if nb > 0 then
		local i = math.min(nb, 6)
		i = (i * i) * radius
		self.ps:emit(i)
		nb = nb - 1
	end
end,
30*radius*7*12,
"particle_cloud"
