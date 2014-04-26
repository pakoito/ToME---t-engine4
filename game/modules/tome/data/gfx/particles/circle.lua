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

base_size = 64

local speed = speed or 0.023
local a = (a or 60) / 255
local basesize = 2 * radius * (engine.Map.tile_w + engine.Map.tile_h) / 2 + engine.Map.tile_w * 1.8 * (oversize or 1)
local appear = appear or 0

local nb = 0

return {
	system_rotation = 0, system_rotationv = speed,
	generator = function()
	if nb == 0 and appear > 0 then
		return {
			trail = 0,
			life = appear,
			size = basesize * 3, sizev = -basesize * 2 / appear, sizea = 0,

			x = 0, xv = 0, xa = 0,
			y = 0, yv = 0, ya = 0,
			dir = 0, dirv = dirv, dira = 0,
			vel = 0, velv = 0, vela = 0,

			r = 1, rv = 0, ra = 0,
			g = 1, gv = 0, ga = 0,
			b = 1, bv = 0, ba = 0,
			a = a, av = 0, aa = 0,
		}
	else
		return {
			trail = 0,
			life = 1000,
			size = basesize, sizev = 0, sizea = 0,

			x = 0, xv = 0, xa = 0,
			y = 0, yv = 0, ya = 0,
			dir = 0, dirv = dirv, dira = 0,
			vel = 0, velv = 0, vela = 0,

			r = 1, rv = 0, ra = 0,
			g = 1, gv = 0, ga = 0,
			b = 1, bv = 0, ba = 0,
			a = a, av = 0, aa = 0,
		}
	end
end, },
function(self)
	self.ps:emit(1)
	nb = nb + 1
end, 1, "particles_images/"..img, true
