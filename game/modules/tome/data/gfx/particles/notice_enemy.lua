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

local nb = 0

return { generator = function()
	local f = 1.5 - nb/36
	local life = 32

	local xv = rng.float(-1, 1)
	local yv = rng.float(-1, 1)
	local tv = math.max(math.abs(xv), math.abs(yv))
	xv = 0.9 * base_size / life * xv / tv
	yv = 0.9 * base_size / life * yv / tv

	return {
		trail = 1,
		life = life / f,
		size = 3, sizev = 0, sizea = 0,

		x = -1, xv = xv, xa = -xv / life / f,
		y = -1, yv = yv, ya = -yv / life / f,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = rng.float(0.60, 0.80),  rv = 0, ra = 0,
		g = 0.08,  gv = 0, ga = 0,
		b = 0.08,  bv = 0, ba = 0,
		a = rng.float(0.3, 0.7),  av = -0.6 * f / life, aa = 0,
	}
end, },
function(self)
	if nb == 0 then self.ps:emit(300) end
	nb = nb + 1
end,
300, nil, true
