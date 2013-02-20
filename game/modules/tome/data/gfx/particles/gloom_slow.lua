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

base_size = 32

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad)
	local r = rng.range(1, 20)
	local dirchance = rng.chance(2)

	return {
--		rail = 1,
		life = 20,
		size = 8, sizev = -0.2, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = 0.1, dira = 0,
		vel = dirchance and 0.01 or -0.01, velv = 0, vela = 0,

		r = 255 / 255,  rv = 0, ra = 0,
		g = 255 / 255,  gv = 0, ga = 0,
		b = 255 / 255,  bv = 0, ba = 0,
		a = 80 / 255,  av = -5 / 255, aa = 0,
	}
end, },
function(self)
	self.ps:emit(1)
end,
20
