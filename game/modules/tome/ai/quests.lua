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

local Astar = require "engine.Astar"

-- AI for the escort quest
-- the NPC will run on the given path up to the end and then start summoning
-- This allows him to buildup his distancemap to make demons follow him
newAI("move_quest_limmir", function(self)
	if self.limmir_target then
		local tx, ty = self.limmir_target.x, self.limmir_target.y
		local a = Astar.new(game.level.map, self)
		local path = a:calc(self.x, self.y, tx, ty)
		if not path then
			return true
		else
			local ret = self:move(path[1].x, path[1].y)

			if self.x == tx and self.y == ty then
				self.limmir_target = self.limmir_target2
				self.limmir_target2 = nil
			end

			return ret
		end
	else
		game.level.turn_counter = 370 * 10
		game.level.max_turn_counter = 370 * 10
		game.level.turn_counter_desc = "Protect Limmir from the demons coming from north-east. Hold them off!"
		game.player.changed = true
		self.ai = "none"
		self:doEmote("This place is corrupted! I will cleanse it! Protect me while I do it!", 120)
	end
end)
