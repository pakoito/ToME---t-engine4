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

use_shader = {type="distort", power=0.05, power_time=200, blacken=0, power_amp=0.3} alterscreen = true
dir = dir or math.rad(110)
factor = factor or 1

r = r or 1
g = g or 1
b = b or 1
rv = rv or 1
gv = gv or 1
bv = bv or 1

return { generator = function()
	local x, y = rng.range(-width/2, width), rng.range(-height/2, height)
	local vel = rng.float(5, 20)
	local dir = dir + math.rad(rng.float(-10, 10))

	return {
		trail = 0,
		life = 30,
		size = rng.float(90, 160), sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = dir, dirv = blur, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = r, rv = rv, ra = 0,
		g = g, gv = gv, ga = 0,
		b = b, bv = bv, ba = 0,
		a = rng.float(0.6, 0.9), av = 0, aa = 0,
	}
end, },
function(self)
	if first then
		self.ps:emit(400 * factor)
	else
		self.ps:emit(2 * factor)
	end
	first = false
end,
600 * factor,
--"weather/snowflake"
"particles_images/distort_shield"
