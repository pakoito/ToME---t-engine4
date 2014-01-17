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

local starts = {}
for i = 1, 4 do
	starts[#starts+1] = { a = math.rad(rng.range(0, 360)), r = rng.range(6, 20) }
end

-- Populate the beam based on the forks
return { generator = function()
	local rad = rng.range(-3,3)
	local s = rng.table(starts)
	local ra = s.a
	local r = s.r

	return {
		life = 4,
		size = rng.range(4, 6), sizev = -0.1, sizea = 0,

		x = 2 * math.cos(ra), xv = 0, xa = 0,
		y = 2 * math.sin(ra), yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 0xD7/255, rv = 0, ra = 0,
		g = 0x8E/255, gv = 0, ga = 0,
		b = 0x45/255, bv = 0, ba = 0,
		a = rng.range(100, 220)/255,	av = 0.05, aa = 0,
	}
end, },
function(self)
	self.ps:emit(30 * 4)
end,
4*30*4
