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
	local dir = math.rad(90)
	local r = rng.range(18, 22)
	local dirchance = rng.chance(2)
	local x = rng.range(-16, 16)
	local y = 16 - math.abs(math.sin(x / 16) * 8)

	return {
		trail = 1,
		life = rng.range(10, 18),
		size = rng.range(2, 3), sizev = 0, sizea = 0.005,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = -0.2,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = rng.range(0, 0)/255,      rv = 0, ra = 0,
		g = rng.range(80, 200)/255,   gv = 0.005, ga = 0.0005,
		b = rng.range(0, 0)/255,      bv = 0, ba = 0,
		a = rng.range(155, 255)/255,  av = 0, aa = 0.005,
	}
end, },
function(self)
	self.ps:emit(4)
end,
40
