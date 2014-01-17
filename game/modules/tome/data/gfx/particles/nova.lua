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

local dur = 3

return { generator = function()
	local ad = rng.float(0, 360)
	local a = math.rad(ad)

	return {
		life = 16,
		size = 4, sizev = 0, sizea = 0,

		x = 0, xv = 0, xa = 0,
		y = 0, yv = 0, ya = 0,
		dir = ad, dirv = 0, dira = 0,
		vel = (5 + rng.float(0,1)) * dur, velv = 0, vela = 0,

		r = rng.range(140, 200)/255, rv = 0, ra = 0,
		g = rng.range(180, 220)/255, gv = 0, ga = 0,
		b = rng.range(220, 240)/255, bv = 0, ba = 0,
		a = rng.range(230, 255)/255, av = 0, aa = 0,
	}
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 4 then
		self.ps:emit(1000)
	end
end,
5000,
"particle_torus";
