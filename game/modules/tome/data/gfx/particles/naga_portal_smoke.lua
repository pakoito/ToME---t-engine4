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

base_size = 64

return { generator = function()
	local ad = rng.range(20+90, 160+90)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.range(1, 20)
	local dirv = math.rad(rng.float(-1,1))
	local life = rng.range(30,50)

	return {
		trail = 1,
		life = life,
		size = rng.range(8, 20), sizev = -0.2, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a) + 32, yv = -1, ya = 0.01,
		dir = dir, dirv = dirv, dira = -dirv/life,
		vel = rng.float(0.3, 1), velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = 0, av = 1 / (life/3), aa = -0.006,
	}
end, },
function(self)
	self.ps:emit(1)
end,
50, smoke, true
