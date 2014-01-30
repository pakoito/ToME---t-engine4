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
	local r = 18
	local life = 35
	local x1 = r * math.cos(a)
	local y1 = r * math.sin(a) * 0.2 + 11
	local y2 = 11

	return {
		life = life,
		size = 12, sizev = -11 / life, sizea = 0,

		x = x1, xv = 0, xa = 0,
		y = y1, yv = (y2 - y1) / life, ya = 0,
		dir = math.rad(270), dirv = 0, dira = 0,
		vel = 5 / life, velv =  9 * (2 / life / life), vela = 0,

		r = (rng.percent(50) and 10 or 160) / 255,  rv = 0, ra = 0,
		g = 0,  gv = 0, ga = 0,
		b = 20 / 255,  bv = 0, ba = 0,
		a = 0.6,  av = .2 / life, aa = 0,
	}
end, },
function(self)
	self.ps:emit(3)
end,
200
