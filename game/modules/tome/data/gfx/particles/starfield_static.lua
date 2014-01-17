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

local side = rng.table{4,6,2,8}
local first = true
local life

local first = true

local stars = {}
for i = 1, nb do stars[#stars+1] = {x = rng.range(0, width), y = rng.range(0, height)} end

local idx = 1

return { generator = function()
	local x = stars[idx].x
	local y = stars[idx].y
	idx = idx + 1
	if idx > #stars then idx = 1 end

	return {
		life = 1000000,
		size = rng.float(size_min, size_max), sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = rng.float(a_min, a_max), av = 0, aa = 0,
	}
end, },
function(self)
	if first then self.ps:emit(nb) first = false end
end,
nb