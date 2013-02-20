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

local toggle = false

return { generator = function()
	local ad = rng.range(0, 360)
	local ax = math.cos(math.rad(ad))
	local ay = math.sin(math.rad(ad))
	local r = rng.range(0, 20)

	return {
		life = 35,
		size = 15, sizev = 0.25, sizea = -0.04,

		x = r * ax, xv = 0, xa = 0,
		y = r * ay, yv = 0, ya = 0,
		dir = math.rad(270), dirv = 0, dira = 0,
		vel = 0.5, velv = 0, vela = 0,

		r = 200 / 255,  rv = 0, ra = 0,
		g = 16 / 255,  gv = 0, ga = 0,
		b = 17 / 255,  bv = 0, ba = 0,
		a = rng.range(55, 90) / 255,  av = -1 / 255, aa = 0
	}
end, },
function(self)
	self.ps:emit(1)
end,
35
