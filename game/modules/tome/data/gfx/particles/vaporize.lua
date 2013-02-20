-- ToME - Tales of Middle-Earth
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
local first = true

return { generator = function()
	return {
		life = 60,
		size = 1, sizev = 0, sizea = 0.3,

		x = 0, xv = 0, xa = 0,
		y = 0, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 255/255, rv = 0, ra = 0,
		g = 242/255, gv = 0, ga = 0,
		b = 128/255, gv = 0, ga = 0,
		a = 255/255, av = -1/60, aa = 0,
	}
end, },
function(self)
	if first then self.ps:emit(1) first = false end
end,
1