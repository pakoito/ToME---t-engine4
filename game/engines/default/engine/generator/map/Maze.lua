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
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, grid_list, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = zone.grid_list
	self.floor = self:resolve("floor")
	self.wall = self:resolve("wall")
	self.up = self:resolve("up")
	self.down = self:resolve("down")
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.wall)
	end end

	local xpos, ypos = 1, 1
	local moves = {{xpos,ypos}}
	while #moves > 0 do
		local dir = {}
		if self.map(xpos+2, ypos, Map.TERRAIN) == self.wall and xpos+2>0 and xpos+2<self.map.w-1 then
			dir[#dir+1] = 6
		end
		if self.map(xpos-2, ypos, Map.TERRAIN) == self.wall and xpos-2>0 and xpos-2<self.map.w-1 then
			dir[#dir+1] = 4
		end
		if self.map(xpos, ypos-2, Map.TERRAIN) == self.wall and ypos-2>0 and ypos-2<self.map.h-1 then
			dir[#dir+1] = 8
		end
		if self.map(xpos, ypos+2, Map.TERRAIN) == self.wall and ypos+2>0 and ypos+2<self.map.h-1 then
			dir[#dir+1] = 2
		end

		if #dir > 0 then
			local d = dir[rng.range(1, #dir)]
			if d == 4 then
				self.map(xpos-2, ypos, Map.TERRAIN, self.floor)
				self.map(xpos-1, ypos, Map.TERRAIN, self.floor)
				xpos = xpos - 2
			elseif d == 6 then
				self.map(xpos+2, ypos, Map.TERRAIN, self.floor)
				self.map(xpos+1, ypos, Map.TERRAIN, self.floor)
				xpos = xpos + 2
			elseif d == 8 then
				self.map(xpos, ypos-2, Map.TERRAIN, self.floor)
				self.map(xpos, ypos-1, Map.TERRAIN, self.floor)
				ypos = ypos - 2
			elseif d == 2 then
				self.map(xpos, ypos+2, Map.TERRAIN, self.floor)
				self.map(xpos, ypos+1, Map.TERRAIN, self.floor)
				ypos = ypos + 2
			end
			table.insert(moves, {xpos, ypos})
		else
			local back = table.remove(moves)
			xpos = back[1]
			ypos = back[2]
		end
	end
	-- Always starts at 1, 1
	local ux, uy = 1, 1
	local dx, dy = math.floor(self.map.w/2)*2-1-2*(1-math.mod(self.map.w,2)), math.floor(self.map.h/2)*2-1-2*(1-math.mod(self.map.h,2))
	self.map(ux, uy, Map.TERRAIN, self.up)
	self.map.room_map[ux][uy].special = "exit"
	if lev < self.zone.max_level or self.data.force_last_stair then
		self.map(dx, dy, Map.TERRAIN, self.down)
		self.map.room_map[dx][dy].special = "exit"
	end
	return ux, uy, dx, dy
end
