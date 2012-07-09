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

dir = math.rad(110)
factor = factor or 1

return { generator = function()
	local x, y = rng.range(-width/2, width), rng.range(-height/2, height)
	local vel = rng.float(5, 20)
	local dir = dir + math.rad(rng.float(-10, 10))

	return {
		trail = 0,
		life = 30,
		size = rng.float(9, 12), sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = dir, dirv = blur, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = rng.float(0.6, 0.9), av = 0, aa = 0,
	}
end, },
function(self)
	if first then
		self.ps:emit(700 * factor)
	else
		self.ps:emit(2 * factor)
	end
	first = false
end,
1000 * factor,
"weather/snowflake"
