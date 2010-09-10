-- ToME - Tales of Middle-Earth
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

local Astar = require "engine.Astar"

-- AI for the escort quest
-- the NPC will run toward the portal, if hostiles are in sight he attacks them
newAI("escort_quest", function(self)
	if self:runAI("target_simple") then
		-- One in "talent_in" chance of using a talent
		if rng.chance(self.ai_state.talent_in or 6) and self:reactionToward(self.ai_target.actor) < 0 then
			self:runAI("dumb_talented")
		end
		if not self.energy.used then
			if self:reactionToward(self.ai_target.actor) < 0 and not self:hasLOS(self.escort_target.x, self.escort_target.y, "block_move") then
				self:runAI("move_dmap")
			else
				self:runAI("move_escort")
			end
		end
		return true
	end
end)

newAI("move_escort", function(self)
	if self.escort_target then
		-- Randomly stop to give time to the player
		if rng.percent(35) then self:useEnergy() return true end

		local tx, ty = self.escort_target.x, self.escort_target.y
		local a = Astar.new(game.level.map, self)
		local path = self.escort_path
		if not path or #path == 0 then path = a:calc(self.x, self.y, tx, ty) end
		if not path then
			return self:runAI("move_simple")
		else
			self.escort_path = {}
			for i = 1, 3 do
				if path[i+1] then self.escort_path[i] = path[i+1] end
			end
			return self:move(path[1].x, path[1].y)
		end
	end
end)
