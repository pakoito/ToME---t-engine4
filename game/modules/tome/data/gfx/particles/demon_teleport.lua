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
	local ad = rng.float(0, 360)
	local dir = math.rad(ad)

	if rng.chance(2) then
		return {
			x = math.cos(dir) * 2, y = math.sin(dir) * 2,
			dir = dir, vel = rng.float(2, 5),

			life = rng.range(20, 30),
			size = rng.range(3, 7), sizev = 0, sizea = 0,

			r = rng.range(200, 255)/255, rv = 0, ra = 0,
			g = rng.range(120, 170)/255, gv = 0, ga = 0,
			b = rng.range(0,   100)/255, bv = 0, ba = 0,
			a = 1, av = 0, aa = 0,
		}
	else
		return {
			x = math.cos(dir) * 5, y = math.sin(dir) * 5,
			dir = dir, vel = rng.float(2, 5),

			life = rng.range(20, 30),
			size = rng.range(3, 7), sizev = 0, sizea = 0,

			r = rng.range(0, 40)/255,   rv = 0, ra = 0,
			g = rng.range(0, 40)/255,   gv = 0.005, ga = 0.0005,
			b = rng.range(0, 40)/255,      bv = 0, ba = 0,
			a = 1,    av = 0, aa = 0.005,
		}
	end
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 6 then
		self.ps:emit(100)
	end
end,
600
