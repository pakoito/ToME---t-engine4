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

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 180)
	local r = rng.range(14, 18)
	local life = 40
	local v = r * 2 / life
	local dirchance = rng.chance(2)

	return {
		life = life,
		size = 7, sizev = -4 / life, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = 0, dira = dirchance and 0.1 or -0.1,
		vel = v, velv = 0, vela = 0,

		r = rng.range(120, 240) / 255,  rv = 0, ra = 0,
		g = rng.range(40, 80) / 255,  gv = 0, ga = 0,
		b = rng.range(120, 180),  bv = 0, ba = 0,
		a = 160 / 255,  av = 0 / 255, aa = 0,
	}
end, },
function(self)
	self.ps:emit(2)
end,
80
