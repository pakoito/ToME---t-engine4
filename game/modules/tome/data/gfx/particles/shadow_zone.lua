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
	local dir = math.rad(ad + 90)
	local r = rng.range(1, 20)
	local dirv = math.rad(1)
	local col = rng.range(20, 80)/255

	return {
--		trail = 1,
		life = 10,
		size = 4, sizev = -0.1, sizea = 0,

		x = r * math.cos(a), xv = rng.float(-0.4, 0.4), xa = 0,
		y = r * math.sin(a), yv = rng.float(-0.4, 0.4), ya = 0,
		dir = dir, dirv = dirv, dira = dir / 20,
		vel = 1, velv = 0, vela = 0.1,

		r = col,  rv = 0, ra = 0,
		g = col,  gv = 0, ga = 0,
		b = col,  bv = 0, ba = 0,
		a = rng.range(220, 255)/255,  av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(4)
end,
40
