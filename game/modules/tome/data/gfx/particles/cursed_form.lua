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

base_size = 32

local life = 10
local first = true
local count = power or 1

return { generator = function()
	local angle = math.rad(rng.range(0, 360))
	local r = rng.range(0, 14)
	local color = rng.chance(2)
	local size = rng.float(14, 20)

	return {
		life = life,
		size = size, sizev = 0, sizea = 0,

		x = r * math.cos(angle), xv = 0, xa = 0,
		y = r * math.sin(angle), yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = (color and 172 or 213) / 255,  rv = 0, ra = 0,
		g = (color and 15 or 111) / 255,  gv = 0, ga = 0,
		b = (color and 126 or 106) / 255,  bv = 0, ba = 0,
		a = 1,  av = -1 / life, aa = 0
	}
end, },
function(self)
	if count > 0 then
		self.ps:emit(1)
		count = count - 1
	end
end,
10
