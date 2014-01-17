-- TE4 - T-Engine 4
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

require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, grid_list, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	data.widen_w = data.widen_w or 1
	data.widen_h = data.widen_h or 1
	data.w = data.w or math.floor(map.w / data.widen_w)
	data.h = data.h or math.floor(map.h / data.widen_h)
	self.grid_list = self.zone.grid_list
end

function _M:generate(lev, old_lev)
	local do_tile = function(i, j, wall)
		for ii = 0, self.data.widen_w-1 do for jj = 0, self.data.widen_h-1 do
			self.map(i*self.data.widen_w+ii, j*self.data.widen_h+jj, Map.TERRAIN, self:resolve(wall and "wall" or "floor"))
		end end
		self.map.room_map[i][j].maze_wall = wall
	end

	for i = 0, self.data.w - 1 do for j = 0, self.data.h - 1 do
		do_tile(i, j, true)
	end end

	local xpos, ypos = 1, 1
	local moves = {{xpos,ypos}}
	local pickp = rng.range(1,4)
	while #moves > 0 do
		local pickn = #moves - math.floor((rng.range(1,100000)/100001)^pickp * #moves)
		local pick = moves[pickn]
		xpos = pick[1]
		ypos = pick[2]
		local dir = {}
		if self.map.room_map[xpos+2] and self.map.room_map[xpos+2][ypos] and self.map.room_map[xpos+2][ypos].maze_wall and xpos+2>0 and xpos+2<self.map.w-1 then
			dir[#dir+1] = 6
		end
		if self.map.room_map[xpos-2] and self.map.room_map[xpos-2][ypos] and self.map.room_map[xpos-2][ypos].maze_wall and xpos-2>0 and xpos-2<self.map.w-1 then
			dir[#dir+1] = 4
		end
		if self.map.room_map[xpos] and self.map.room_map[xpos][ypos-2] and self.map.room_map[xpos][ypos-2].maze_wall and ypos-2>0 and ypos-2<self.map.h-1 then
			dir[#dir+1] = 8
		end
		if self.map.room_map[xpos] and self.map.room_map[xpos][ypos+2] and self.map.room_map[xpos][ypos+2].maze_wall and ypos+2>0 and ypos+2<self.map.h-1 then
			dir[#dir+1] = 2
		end

		if #dir > 0 then
			local d = dir[rng.range(1, #dir)]
			if d == 4 then
				do_tile(xpos-2, ypos, false)
				do_tile(xpos-1, ypos, false)
				xpos = xpos - 2
			elseif d == 6 then
				do_tile(xpos+2, ypos, false)
				do_tile(xpos+1, ypos, false)
				xpos = xpos + 2
			elseif d == 8 then
				do_tile(xpos, ypos-2, false)
				do_tile(xpos, ypos-1, false)
				ypos = ypos - 2
			elseif d == 2 then
				do_tile(xpos, ypos+2, false)
				do_tile(xpos, ypos+1, false)
				ypos = ypos + 2
			end
			table.insert(moves, {xpos, ypos})
		else
			local back = table.remove(moves,pickn)
		end
	end
	-- Always starts at 1, 1
	local ux, uy = 1 * self.data.widen_w, 1 * self.data.widen_h
	local dx, dy = math.floor(self.map.w/2)*2-1-2*(1-math.mod(self.map.w,2)), math.floor(self.map.h/2)*2-1-2*(1-math.mod(self.map.h,2))
	self.map(ux, uy, Map.TERRAIN, self:resolve("up"))
	self.map.room_map[ux][uy].special = "exit"
	if lev < self.zone.max_level or self.data.force_last_stair then
		self.map(dx, dy, Map.TERRAIN, self:resolve("down"))
		self.map.room_map[dx][dy].special = "exit"
	end
	return ux, uy, dx, dy
end
