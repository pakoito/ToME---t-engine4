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

newTalent{
	name = "Disperse Magic",
	type = {"spell/meta",1},
	require = spells_req1,
	points = 5,
	mana = 40,
	cooldown = 7,
	action = function(self, t)
		local target = self

		if self:getTalentLevel(t) >= 3 then
			local tx, ty = self:getTarget{type="hit", range=self:getTalentRange(t)}
			if game.level.map(tx, ty, Map.ACTOR) then
				target = game.level.map(tx, ty, Map.ACTOR)
			end
		end

		local effs = {}

		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type == "magical" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		-- Go through all sustained spells
		for tid, act in pairs(target.sustain_talents) do
			if act then
				effs[#effs+1] = {"talent", tid}
			end
		end

		for i = 1, math.floor(self:getTalentLevel(t)) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			else
				local old = target.energy.value
				target:useTalent(eff[2])
				-- Prevent using energy
				target.energy.value = old
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Removes up to %d magical effects (both good or bad) from the target.
		At level 3 it can be targetted.
		]]):format(self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Spell Shaping",
	type = {"spell/meta",2},
	require = spells_req2,
	points = 5,
	mode = "passive",
	info = function(self, t)
		return ([[You learn to shape your area spells, allowing you to carve a hole in them to not get hit with a chance of %d%%.]]):
		format(self:getTalentLevelRaw(t) * 20)
	end,
}

newTalent{
	name = "Quicken Spells",
	type = {"spell/meta",3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	sustain_mana = 150,
	cooldown = 30,
	tactical = {
		BUFF = 10,
	},
	activate = function(self, t)
		local power = util.bound(self:getTalentLevel(t) / 15, 0.05, 0.3)
		return {
			cd = self:addTemporaryValue("spell_cooldown_reduction", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("spell_cooldown_reduction", p.cd)
		return true
	end,
	info = function(self, t)
		return ([[Reduces the cooldown of all spells by %d%%.
		The reduction increases with the Magic stat]]):format(util.bound(self:getTalentLevel(t) / 15, 0.05, 0.3) * 100)
	end,
}

newTalent{
	name = "Metaflow",
	type = {"spell/meta",4},
	require = spells_req4,
	points = 5,
	mana = 70,
	cooldown = 50,
	action = function(self, t)
		local nb = math.ceil(self:getTalentLevel(t) + 2)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[2] <= self:getTalentLevelRaw(t) and tt.type[1]:find("^spell/") then
				tids[#tids+1] = tid
			end
		end
		for i = 1, nb do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		return true
	end,
	info = function(self, t)
		return ([[Your mastery of the arcane flows allow you to reset the cooldown of %d of your spells of level %d or less.]]):
		format(math.ceil(self:getTalentLevel(t) + 2), self:getTalentLevelRaw(t))
	end,
}
