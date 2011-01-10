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

newAI("party_member", function(self)
	local master = game.player

	-- Stay close to the party master
	if math.floor(core.fov.distance(self.x, self.y, master.x, master.y)) > self.ai_state.tactic_leash then
		self:setTarget(master)
		print("[PARTY AI] leashing to master", self.name)
		return self:runAI(self.ai_state.ai_move or "move_simple")
	end

	-- When passive only accept targets from the master
--	if self.ai_state.tactic_behavior == "passive" then

--	end

	-- Run normal AI
	return self:runAI(self.ai_state.ai_party)
end)
