-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

return { generator = function()
	local pos = rng.range(-32, 32)
	local power = 32 - math.abs(pos)
	local life = power / 2
	local size = rng.range(2, 5)
	local angle = math.rad(angle)

	return {
		trail = 1,
		life = life * 6,
		size = size, sizev = -0.02, sizea = 0,

		x = pos * math.cos(angle+math.rad(90)), xv = 0, xa = 0,
		y = pos * math.sin(angle+math.rad(90)), yv = 0, ya = 0,
		dir = angle, dirv = 0, dira = 0,
		vel = 8, velv = 0, vela = 0,

		r = 00,  rv = 0, ra = 0,
		g = 0,  gv = 0, ga = 0,
		b = 255,  bv = 0, ba = 0,
		a = 1, av = -0.02, aa = 0,
	}
end, },
function(self)
	self.ps:emit(20)
end,
20 * 6
