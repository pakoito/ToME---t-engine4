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
	local angle = rng.float(-math.pi, math.pi)
	local r1 = rng.float(10, 18)
	local r2 = rng.float(10, 18)
	local life = rng.range(8, 14)
	local colorChoice = rng.percent(50)
	return {
		life = life,
		size = rng.float(5, 8), sizev = 0, sizea = 0,

		x = r1 * math.cos(angle), xv = -(r1 + r2) * math.cos(angle) / life, xa = 0,
		y = r1 * math.sin(angle), yv = -(r1 + r2) * math.sin(angle) / life, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = (colorChoice and 10 or 160) / 255,  rv = 0, ra = 0,
		g = 0,  gv = 0, ga = 0,
		b = 20 / 255,  bv = 0, ba = 0,
		a = rng.float(0.6, 0.9), av = -0.2 / life, aa = 0,
	}
end, },
function(self)
	if nb == 0 then
		self.ps:emit(1)
	end
	nb = (nb + 1) % 2
end,
40, nil, true
