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

base = 64

local nb = 0

return { generator = function()
	local size = rng.float(32, 64)
	local x = rng.range(-size/2, size/2)
	local y = rng.range(-size/2, size/2)
	local vel = 0.25
	local a = math.rad(rng.float(0, 360))
	local grey = rng.float(0.7, 1)

	local last = {
		life = 60,
		size = size, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = blur, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = grey, rv = 0, ra = 0,
		g = grey, gv = 0, ga = 0,
		b = grey, bv = 0, ba = 0,
		a = 0.4, av = -0.4/60, aa = 0,
	}
	return last
end, },
function(self)
	if nb == 0 then self.ps:emit(1) end
	nb = nb + 1
	if nb == 2 then nb = 0 end
end,
30,
"weather/dark_cloud_01", true
