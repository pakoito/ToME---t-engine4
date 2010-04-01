-- TE4 - T-Engine 4
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

require "engine.class"
module(..., package.seeall, class.make)

function _M:init(zone, map, level)
	self.zone = zone
	self.map = map
	self.level = level

	-- Setup the map's room-map
	if not map.room_map then
		map.room_map = {}
		for i = 0, map.w - 1 do
			map.room_map[i] = {}
			for j = 0, map.h - 1 do
				map.room_map[i][j] = {}
			end
		end
	end
end

function _M:generate()
end
