-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

--- Computes a direct line path from start to end
module(..., package.seeall, class.make)

--- Initializes DirectPath for a map and an actor
function _M:init(map, actor)
	self.map = map
	self.actor = actor
end

--- Compute path from sx/sy to tx/ty
-- @param sx the start coord
-- @param sy the start coord
-- @param tx the end coord
-- @param ty the end coord
-- @param use_has_seen if true the astar wont consider non-has_seen grids
-- @return either nil if no path or a list of nodes in the form { {x=...,y=...}, {x=...,y=...}, ..., {x=tx,y=ty}}
function _M:calc(sx, sy, tx, ty, use_has_seen)
	local path = {}
	local l = line.new(sx, sy, tx, ty)
	local nx, ny = l()
	while nx and ny do
		if (not use_has_seen or self.map.has_seens(nx, ny)) and self.map:isBound(nx, ny) and not self.map:checkEntity(nx, ny, Map.TERRAIN, "block_move", self.actor, nil, true) then
			path[#path+1] = {x=nx, y=ny}
		else
			break
		end
		nx, ny = l()
	end
	return path
end
