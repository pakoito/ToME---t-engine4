-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

local dir = rng.range(0, 360)
local blur = blur or 0
local first = true
local life = (width + height) / 2
local sides
if dir >= 0 and dir < 90 then sides = {8,6}
elseif dir >= 90 and dir < 180 then sides = {8,4}
elseif dir >= 180 and dir < 270 then sides = {2,4}
else sides = {2,6}
end

dir = math.rad(dir)

return { generator = function()
	local side = rng.table(sides)
	local x, y
	if side == 2 then x = rng.range(0, width) y = height
	elseif side == 8 then x = rng.range(0, width) y = 0
	elseif side == 6 then x = 0 y = rng.range(0, height)
	else x = width y = rng.range(0, height)
	end
	local vel = rng.float(0.3, 2)

	return {
		life = life / vel,
		size = rng.float(1, 8), sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = dir, dirv = blur, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = rng.float(0.5, 1), av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(1)
end,
1000
