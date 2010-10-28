-- ToME - Tales of Maj'Eyal
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

local Object = require "engine.Object"
local DamageType = require "engine.DamageType"

-- Very special AI for sandworm tunnelers in the sandworm lair
-- Does not care about a target, simple crawl toward a level spot and when there, go for the next
newAI("sandworm_tunneler", function(self)
	-- Get a spot
	if not self.ai_state.spot_x then
		if game.level.default_up and rng.chance(#game.level.spots + 2) then
			-- Go for the stairs
			self.ai_state.spot_x = game.level.default_up.x
			self.ai_state.spot_y = game.level.default_up.y
		elseif game.level.default_down and rng.chance(#game.level.spots + 2) then
			-- Go for the stairs
			self.ai_state.spot_x = game.level.default_down.x
			self.ai_state.spot_y = game.level.default_down.y
		else
			local s = rng.table(game.level.spots)
			self.ai_state.spot_x = s.x
			self.ai_state.spot_y = s.y
		end
	end

	-- Move toward it, digging your way to it
	local l = line.new(self.x, self.y, self.ai_state.spot_x or self.x, self.ai_state.spot_y or self.y)
	local lx, ly = l()
	if not lx then
		self.ai_state.spot_x = nil
		self.ai_state.spot_y = nil
		self:useEnergy()
	else
		local feat = game.level.map(lx, ly, engine.Map.TERRAIN)
		if feat:check("block_move") then
			self:project({type="hit"}, lx, ly, DamageType.DIG, 1)
		end
		self:move(lx, ly)

		-- if we could not move, find a new spot
		if self.x ~= lx or self.y ~= ly then
			local s = rng.table(game.level.spots)
			self.ai_state.spot_x = s.x
			self.ai_state.spot_y = s.y
		end
	end
end)
