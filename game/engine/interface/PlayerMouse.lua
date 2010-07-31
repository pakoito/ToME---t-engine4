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
local Astar = require"engine.Astar"
local DirectPath = require"engine.DirectPath"

--- Handles player default mouse actions
-- Defines some methods to help use the mouse in an uniform way in all modules
module(..., package.seeall, class.make)

--- Runs to the clicked mouse spot
-- if no monsters in sight it will try to make an A* path, if it fails it will do a direct path<br/>
-- if there are monsters in sight it will move one stop in the direct path direction<br/>
-- this method requires to use PlayerRun interface
-- @param tmx the coords clicked
-- @param tmy the coords clicked
-- @param spotHostiles a function taking only the player as a parameter that must return true if hostiles are in sight
function _M:mouseMove(tmx, tmy, spotHostiles)
	if config.settings.tome.cheat and core.key.modState("ctrl") then
		game.log("[CHEAT] teleport to %dx%d", tmx, tmy)
		self:move(tmx, tmy, true)
	else
		-- If hostiles, attack!
		if (spotHostiles and spotHostiles(self)) or math.floor(core.fov.distance(self.x, self.y, tmx, tmy)) == 1 then
			local l = line.new(self.x, self.y, tmx, tmy)
			local nx, ny = l()
			self:move(nx or self.x, ny or self.y)
			return
		end

		local a = Astar.new(game.level.map, self)
		local path = a:calc(self.x, self.y, tmx, tmy, true)
		-- No Astar path ? jsut be dumb and try direct line
		if not path then
			local d = DirectPath.new(game.level.map, self)
			path = d:calc(self.x, self.y, tmx, tmy, true)
		end

		if path then
			-- Should we just try to move in the direction, aka: attack!
			if path[1] and game.level.map:checkAllEntities(path[1].x, path[1].y, "block_move", self) then self:move(path[1].x, path[1].y) return end

			 -- Insert the player coords, running needs to find the player
			table.insert(path, 1, {x=self.x, y=self.y})

			-- Move along the projected A* path
			self:runFollow(path)
		end
	end
end

local moving_around = false
local derivx, derivy = 0, 0

--- Handles mouse scrolling the map
-- @param map the Map to scroll
-- @param xrel the x movement velocity, gotten from a mouse event
-- @param yrel the y movement velocity, gotten from a mouse event
function _M:mouseScrollMap(map, xrel, yrel)
	derivx = derivx + xrel
	derivy = derivy + yrel
	map.changed = true
	if derivx >= map.tile_w then
		map.mx = map.mx - 1
		derivx = derivx - map.tile_w
	elseif derivx <= -map.tile_w then
		map.mx = map.mx + 1
		derivx = derivx + map.tile_w
	end
	if derivy >= map.tile_h then
		map.my = map.my - 1
		derivy = derivy - map.tile_h
	elseif derivy <= -map.tile_h then
		map.my = map.my + 1
		derivy = derivy + map.tile_h
	end
	map._map:setScroll(map.mx, map.my)
end

--- Handles global mouse event
-- This will handle events like this:<ul>
-- <li>Left click: player mouse movement</li>
-- <li>Shift + left click: map scroll</li>
-- <li>Any other click: pass on the click as a key event, to allow actiosnto be bound to the mouse</li>
-- </ul>
-- @param key the Key object to which to pass the event if not treated, this should be your game default key handler probably
-- @param allow_move true if this will allow player movement (you should use it to check that you are not in targetting mode)
function _M:mouseHandleDefault(key, allow_move, button, mx, my, xrel, yrel)
	local tmx, tmy = game.level.map:getMouseTile(mx, my)

	-- Move
	if button == "left" and not core.key.modState("shift") and not moving_around and not xrel and not yrel then
		if allow_move then self:mouseMove(tmx, tmy) end

	-- Move map around
	elseif button == "left" and xrel and yrel and core.key.modState("shift") then
		self:mouseScrollMap(game.level.map, xrel, yrel)
		moving_around = true
	-- Zoom map
--	elseif button == "wheelup" then
--		game.level.map:setZoom(0.1, tmx, tmy)
--	elseif button == "wheeldown" then
--		game.level.map:setZoom(-0.1, tmx, tmy)
	-- Pass any other buttons to the keybinder
	elseif button ~= "none" and not xrel and not yrel then
		key:receiveKey(button, core.key.modState("ctrl") and true or false, core.key.modState("shift") and true or false, core.key.modState("alt") and true or false, core.key.modState("meta") and true or false, nil, false, true)
	end

	if not xrel and not yrel then moving_around = false end
end
