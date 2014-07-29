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

newTalent{
	name = "Disperse Magic",
	type = {"spell/meta",1},
	require = spells_req1,
	points = 5,
	random_ego = "utility",
	mana = 40,
	cooldown = 7,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = function(self, t) return self:getTalentLevel(t) >= 3 end,
	range = 10,
	getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	action = function(self, t)
		local target = self

		if self:getTalentLevel(t) >= 3 then
			local tg = {type="hit", range=self:getTalentRange(t)}
			local tx, ty = self:getTarget(tg)
			if tx and ty and game.level.map(tx, ty, Map.ACTOR) then
				local _ _, tx, ty = self:canProject(tg, tx, ty)
				if not tx then return nil end
				target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return nil end

				target = game.level.map(tx, ty, Map.ACTOR)
			else return nil
			end
		end

		local effs = {}

		-- Go through all spell effects
		if self:reactionToward(target) < 0 then
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "beneficial" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			for tid, act in pairs(target.sustain_talents) do
				if act then
					local talent = target:getTalentFromId(tid)
					if talent.is_spell then effs[#effs+1] = {"talent", tid} end
				end
			end
		else
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			else
				target:forceUseTalent(eff[2], {ignore_energy=true})
			end
		end
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[Removes up to %d magical effects (good effects from foes, and bad effects from friends) from the target.
		At level 3, it can be targeted.]]):
		format(count)
	end,
}

newTalent{
	name = "Spellcraft",
	type = {"spell/meta",2},
	require = spells_req2,
	points = 5,
	sustain_mana = 70,
	cooldown = 30,
	mode = "sustained",
	tactical = { BUFF = 2 },
	getChance = function(self, t) return self:getTalentLevelRaw(t) * 20 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {
			cd = self:addTemporaryValue("spellshock_on_damage", self:combatTalentSpellDamage(t, 10, 320) / 4),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("spellshock_on_damage", p.cd)
		return true
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[You learn to finely craft and tune your offensive spells.
		You try to carve a hole in spells that affect an area to avoid damaging yourself.  The chance of success is %d%%.
		In addition, you hone your damaging spells to spellshock their targets. Whenever you deal damage with a spell you attempt to spellshock them with %d more Spellpower than normal. Spellshocked targets suffer a temporary 20%% penalty to damage resistances.]]):
		format(chance, self:combatTalentSpellDamage(t, 10, 320) / 4)
	end,
}

newTalent{
	name = "Quicken Spells",
	type = {"spell/meta",3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	sustain_mana = 80,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getCooldownReduction = function(self, t) return util.bound(self:getTalentLevelRaw(t) / 15, 0.05, 0.3) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {
			cd = self:addTemporaryValue("spell_cooldown_reduction", t.getCooldownReduction(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("spell_cooldown_reduction", p.cd)
		return true
	end,
	info = function(self, t)
		local cooldownred = t.getCooldownReduction(self, t)
		return ([[Reduces the cooldown of all spells by %d%%.]]):
		format(cooldownred * 100)
	end,
}

newTalent{
	name = "Metaflow",
	type = {"spell/meta",4},
	require = spells_req4,
	points = 5,
	mana = 70,
	cooldown = 50,
	fixed_cooldown = true,
	tactical = { BUFF = 2 },
	getTalentCount = function(self, t) return math.floor(self:combatTalentScale(t, 2, 7, "log")) end,
	getMaxLevel = function(self, t) return self:getTalentLevel(t) end,
	action = function(self, t)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if not tt.fixed_cooldown then
				if tt.type[2] <= t.getMaxLevel(self, t) and tt.is_spell then
					tids[#tids+1] = tid
				end
			end
		end
		for i = 1, t.getTalentCount(self, t) do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local talentcount = t.getTalentCount(self, t)
		local maxlevel = t.getMaxLevel(self, t)
		return ([[Your mastery of the arcane flows allow you to reset the cooldown of %d of most of your spells of tier %d or less.]]):
		format(talentcount, maxlevel)
	end,
}
