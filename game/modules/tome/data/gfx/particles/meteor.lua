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

local nb = 1

return { generator = function()
	local sradius = 10 * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local x = sradius * math.cos(a)
	local y = sradius * math.sin(a)
	a = math.rad(ad + 180)
	local life = 10

	return {
		trail = 1,
		life = life,
		size = 44, sizev = 1, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = 0, dira = 0,
		vel = sradius / life, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = 1, av = 0, aa = 0,
	}
end, },
function(self)
	if nb > 0 then
		self.ps:emit(1)
		nb = nb - 1
	end
end,
1,
"shockbolt/object/lava_boulder"
