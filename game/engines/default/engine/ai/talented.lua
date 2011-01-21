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

-- Defines AIs that can use talents, either smartly or "dumbly"

-- Randomly use talents
newAI("dumb_talented", function(self)
	-- Find available talents
	local avail = {}
	local target_dist = math.floor(core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y))
	for tid, _ in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
--		print(self.name, self.uid, "dumb ai talents can try use", t.name, tid, "::", t.mode, not self:isTalentCoolingDown(t), target_dist <= self:getTalentRange(t), self:preUseTalent(t, true), self:canProject({type="bolt"}, self.ai_target.actor.x, self.ai_target.actor.y))
		if t.mode == "activated" and not t.no_npc_use and
		   not self:isTalentCoolingDown(t) and
		   target_dist <= self:getTalentRange(t)
		   and self:preUseTalent(t, true, true) and
		   self:canProject({type=util.getval(t.direct_hit, self, t) and "hit" or "bolt"}, self.ai_target.actor.x, self.ai_target.actor.y) and
		   self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y)
		   then
			avail[#avail+1] = tid
			print(self.name, self.uid, "dumb ai talents can use", t.name, tid)
		elseif t.mode == "sustained" and not t.no_npc_use and not self:isTalentCoolingDown(t) and
		   not self:isTalentActive(t.id) and
		   self:preUseTalent(t, true, true)
		   then
			avail[#avail+1] = tid
			print(self.name, self.uid, "dumb ai talents can activate", t.name, tid)
		end
	end
	if #avail > 0 then
		local tid = avail[rng.range(1, #avail)]
		print("dumb ai uses", tid)
		self:useTalent(tid)
		return true
	end
end)

newAI("dumb_talented_simple", function(self)
	if self:runAI(self.ai_state.ai_target or "target_simple") then
		-- One in "talent_in" chance of using a talent
		if (not self.ai_state.no_talents or self.ai_state.no_talents == 0) and rng.chance(self.ai_state.talent_in or 6) and self:reactionToward(self.ai_target.actor) < 0 then
			self:runAI("dumb_talented")
		end
		if not self.energy.used then
			self:runAI(self.ai_state.ai_move or "move_simple")
		end
		return true
	end
end)
