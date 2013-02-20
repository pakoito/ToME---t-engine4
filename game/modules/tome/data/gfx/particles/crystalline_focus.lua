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
	local r = rng.range(18, 22)
	local dirchance = rng.chance(2)

	return {
		life = 20,
		size = 4, sizev = -0.05, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = 0.1, dira = 0,
		vel = dirchance and 0.2 or -0.2, velv = 0, vela = dirchance and -0.02 or 0.02,

		r = rng.range(0, 0)/255, rv = rng.range(0, 10)/100, ra = 0,
		g = rng.range(80, 200)/255,  gv = 0.005, ga = 0.0005,
		b = 0,	bv = 0, ba = 0,
		a = rng.range(70, 255)/255,	av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(4)
end,
80
