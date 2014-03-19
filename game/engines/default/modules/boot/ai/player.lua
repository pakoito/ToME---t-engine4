-- ToME - Tales of Middle-Earth
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

local Astar = require "engine.Astar"

-- AI for the escort quest
-- the NPC will run toward the portal, if hostiles are in sight he attacks them
newAI("player_demo", function(self)
	if self:runAI("target_simple") then
		-- One in "talent_in" chance of using a talent
		if rng.chance(self.ai_state.talent_in or 6) and self:reactionToward(self.ai_target.actor) < 0 then
			self:runAI("dumb_talented")
		end
		if not self.energy.used then
			self:runAI("move_simple")
		end
		return true
	else
		self:runAI("move_player")
	end
end)

newAI("move_player", function(self)
	if self.player_waypoint then
		local path = self.player_waypoint
		if not path[1] then
			self.player_waypoint = nil
			return self:runAI("move_simple")
		else
			local ret = self:move(path[1].x, path[1].y)
			table.remove(path, 1)
			return ret
		end
	else
		local e = rng.table(game.level.e_array)
		while e == self do e = rng.table(game.level.e_array) end
		print("Selecting waypoint", e.x, e.y, "::", e.name)

		local a = Astar.new(game.level.map, self)
		self.player_waypoint = a:calc(self.x, self.y, e.x, e.y)
	end
end)
