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

require "engine.class"
local Tooltip = require "engine.Tooltip"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Tooltip))

tooltip_bound_y2 = function() return game.uiset.map_h_stop_tooltip end

function _M:init(...)
	Tooltip.init(self, ...)
end

--- Gets the tooltips at the given map coord
function _M:getTooltipAtMap(tmx, tmy, mx, my)
	local tt = {}
	local seen = game.level.map.seens(tmx, tmy)
	local remember = game.level.map.remembers(tmx, tmy)
	local ctrl_state = core.key.modState("ctrl")
	
	local check = function(check_type)
		local to_add = game.level.map:checkEntity(tmx, tmy, check_type, "tooltip", game.level.map.actor_player)
		if to_add then 
			if type(to_add) == "string" then to_add = to_add:toTString() end
			tt[#tt+1] = to_add 
		end
	end
	
	if seen and not ctrl_state then
		check(Map.PROJECTILE)
		check(Map.ACTOR)
	end
	if seen or remember then
		local obj = check(Map.OBJECT)
		if not ctrl_state or not obj then
			check(Map.TRAP)
			check(Map.TERRAIN)
		end
	end
	
	if #tt > 0 then
		return tt
	end
	if self.add_map_str then return self.add_map_str:toTString() end
	return nil
end
