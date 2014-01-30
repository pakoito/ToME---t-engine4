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

local nb = 0

return { gas = {w=60, h=60},
generator = function()
	if nb < 10 then
		nb = nb + 1
		return {

			{ sx = 3, sy = 29, dx = 3, dy = -3 },
			{ sx = 3, sy = 30, dx = 3, dy = 0 },
			{ sx = 3, sy = 31, dx = 3, dy = 3 },

			{ sx = 4, sy = 29, dx = 3, dy = -3 },
			{ sx = 4, sy = 30, dx = 3, dy = 0 },
			{ sx = 4, sy = 31, dx = 3, dy = 3 },
--[[
			{ sx = 29, sy = 29, dx = -3, dy = -3 },
			{ sx = 31, sy = 29, dx =  3, dy = -3 },
			{ sx = 29, sy = 31, dx = -3, dy =  3 },
			{ sx = 31, sy = 31, dx =  3, dy =  3 },

			{ sx = 30, sy = 29, dx =  0, dy = -3 },
			{ sx = 30, sy = 31, dx =  0, dy =  3 },
			{ sx = 29, sy = 30, dx = -3, dy =  0 },
			{ sx = 31, sy = 30, dx =  3, dy =  0 },
--]]
		}
	else return {}
	end
end, },
function(self)end,
30*6
