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

base_size = 32

local toggle = false

return { generator = function()
	local ad = rng.range(0, 15) * 360 / 16
	local a = math.rad(ad)
	local dir = -math.rad(ad)
	local r = rng.range(5, 25)
	local dirchance = rng.chance(2)

	return {
		life = 10,
		size = 6, sizev = -0.3, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = 0, dira = 0,
		vel = -0.4, velv = 0, vela = dirchance and -0.02 or 0.02,

		r = 100 / 255,  rv = 0, ra = 0,
		g = 120 / 255,  gv = 0, ga = 0,
		b = rng.percent(5) and 80 / 255 or 160 / 255,  bv = 0, ba = 0,
		a = rng.range(120, 200) / 255,  av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(1)
end,
100
