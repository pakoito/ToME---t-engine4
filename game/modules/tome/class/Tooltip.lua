-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
local Tooltip = require "engine.Tooltip"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Tooltip))

function _M:init(...)
	Tooltip.init(self, ...)
end

--- Gets the tooltips at the given map coord
function _M:getTooltipAtMap(tmx, tmy, mx, my)
	local tt = {}
	local seen = game.level.map.seens(tmx, tmy)
	local remember = game.level.map.remembers(tmx, tmy)
	tt[#tt+1] = seen and game.level.map:checkEntity(tmx, tmy, Map.PROJECTILE, "tooltip", game.level.map.actor_player) or nil
	tt[#tt+1] = seen and game.level.map:checkEntity(tmx, tmy, Map.ACTOR, "tooltip", game.level.map.actor_player) or nil
	tt[#tt+1] = (seen or remember) and game.level.map:checkEntity(tmx, tmy, Map.OBJECT, "tooltip", game.level.map.actor_player) or nil
	tt[#tt+1] = (seen or remember) and game.level.map:checkEntity(tmx, tmy, Map.TRAP, "tooltip", game.level.map.actor_player) or nil
	tt[#tt+1] = (seen or remember) and game.level.map:checkEntity(tmx, tmy, Map.TERRAIN, "tooltip", game.level.map.actor_player) or nil
	if #tt > 0 then
		local ts = tstring{}
		for i = 1, #tt do
			ts:merge(tt[i]:toTString())
			if i < #tt then ts:add(true, "---", true) end
		end
		ts:add("TOTOOTOT")
		return ts
	end
	return nil
end
