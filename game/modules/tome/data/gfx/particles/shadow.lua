-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	local dir = math.rad(ad + 180)
	local r = rng.range(12, 20)
	local col = rng.range(20, 80)/255

	return {
		trail = 1,
		life = 10,
		size = 4, sizev = 0.08, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = math.rad(3), dira = math.rad(3) / 3,
		vel = 1.4, velv = 0, vela = 0,

		r = col,  rv = 0, ra = 0,
		g = col,  gv = 0, ga = 0,
		b = col,  bv = 0, ba = 0,
		a = rng.range(220, 255)/255,  av = 0, aa = 0,
	}
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 4 then
		self.ps:emit(20)
	end
end,
800
