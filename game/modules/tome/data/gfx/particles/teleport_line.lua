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

local bars = {}
for i = 1, 10 do bars[#bars+1] = rng.range(-30, 30) end

return { generator = function()
	return {
		life = 10,
		size = rng.range(8, 16), sizev = -0.1, sizea = 0,

		x = rng.avg(-20, 20), xv = 0, xa = 0,
		y = rng.table(bars), yv = rng.float(-0.5, 0.5), ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = rng.range(220, 255)/255,  rv = 0, ra = 0,
		g = rng.range(200, 230)/255,  gv = 0, ga = 0,
		b = 0,                        bv = 0, ba = 0,
		a = rng.range(25, 220)/255,   av = 0, aa = 0,
	}
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 3 then
		self.ps:emit(15)
	end
end,
45, "line_particle"
