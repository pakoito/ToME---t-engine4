-- ToME - Tales of Maj'Eyal
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

-- Defines AIs that can heal

-- Find an friendly target
-- this requires the ActorFOV interface, or an interface that provides self.fov.actors*
newAI("target_heal", function(self)
	if self.ai_target.actor and not self.ai_target.actor.dead and rng.percent(90) then return true end

	-- Find closer enemy and target it
	-- Get list of actors ordered by distance
	local arr = self.fov.actors_dist
	local act
	for i = 1, #arr do
		act = self.fov.actors_dist[i]
--		print("AI looking for target", self.uid, self.name, "::", act.uid, act.name, self.fov.actors[act].sqdist)
		-- find the closest enemy
		if act and self:reactionToward(act) >= 0 and not act.dead then
			self.ai_target.actor = act
			return true
		end
	end
end)

-- Randomly use talents
newAI("dumb_heal", function(self)
	-- Find available talents
	local avail = {}
	local target_dist = core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y)
	for tid, _ in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
--		print(self.name, self.uid, "dumb ai talents can try use", t.name, tid, "::", t.mode, not self:isTalentCoolingDown(t), target_dist <= self:getTalentRange(t), self:preUseTalent(t, true), self:canProject({type="bolt"}, self.ai_target.actor.x, self.ai_target.actor.y))
		if t.mode == "activated" and not self:isTalentCoolingDown(t) and target_dist <= self:getTalentRange(t) and self:preUseTalent(t, true) and self:canProject({type="bolt"}, self.ai_target.actor.x, self.ai_target.actor.y) then
			avail[#avail+1] = tid
			print(self.name, self.uid, "dumb ai talents can use", t.name, tid)
		elseif t.mode == "sustained" and not self:isTalentCoolingDown(t) and not self:isTalentActive(t) and self:preUseTalent(t, true) then
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

newAI("dumb_heal_simple", function(self)
	if self:runAI("target_heal") then
		-- One in "talent_in" chance of using a talent
		if rng.chance(self.ai_state.talent_in or 6) and self:reactionToward(self.ai_target.actor) >= 0 then
			self:runAI("dumb_heal")
		end
		if not self.energy.used then
			self:runAI(self.ai_state.ai_move or "move_simple")
		end
		return true
	end
end)

