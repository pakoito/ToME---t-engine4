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

local nb = 0

return { generator = function()
	local radius = 0
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) * 0.5
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(0.1, sradius * 0.5)
	local x = r * math.cos(a)
	local y = r * math.sin(a)

	return {
		trail = 1,
		life = 3 + 9 * (sradius - r) / sradius,
		size = 3, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = rng.range(200, 255)/255,   rv = 0, ra = 1,
		g = rng.range(200, 255)/255,   gv = 0, ga = 1,
		b = rng.range(200, 255)/255,   bv = 0, ba = 1,
		a = 1, av = 1, aa = 1,
	}
end, },
function(self)
	if nb < 1 then
		self.ps:emit(6)
	end
	nb = nb + 1
end,
30
