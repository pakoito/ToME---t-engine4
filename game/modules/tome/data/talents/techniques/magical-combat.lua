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

newTalent{
	name = "Arcane Combat",
	type = {"technique/magical-combat", 1},
	mode = "sustained",
	points = 5,
	require = techs_req1,
	sustain_stamina = 20,
	no_energy = true,
	cooldown = 5,
	tactical = { BUFF = 2 },
	do_trigger = function(self, t, target)
		if rng.percent(200 + self:getTalentLevel(t) * (1 + self:getDex(9, true))) then
			local spells = {}
			local fatigue = (100 + 2 * self:combatFatigue()) / 100
			local mana = self:getMana() - 1
			if self:knowTalent(self.T_FLAME) and mana > self:getTalentFromId(self.T_FLAME).mana * fatigue then spells[#spells+1] = self.T_FLAME end
			if self:knowTalent(self.T_LIGHTNING) and mana > self:getTalentFromId(self.T_LIGHTNING).mana * fatigue then spells[#spells+1] = self.T_LIGHTNING end
			local tid = rng.table(spells)
			if tid then
				-- Extending beam target, assumes a maximum range of 10
				local current_angle = math.atan2((target.y - self.y), (target.x - self.x)) + math.pi
				target_x = self.x - math.floor(0.5 + (10 * math.cos(current_angle)))
				target_y = self.y - math.floor(0.5 + (10 * math.sin(current_angle)))
				local l = line.new(self.x, self.y, target_x, target_y)
				local lx, ly = l()
				target_x, target_y = lx, ly
				-- Check for terrain and friendly actors
				while lx and ly do
					local actor = game.level.map(lx, ly, engine.Map.ACTOR)
					if actor and (self:reactionToward(actor) >= 0) then
						break
					elseif game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then
						target_x, target_y = lx, ly
						break
					end
					target_x, target_y = lx, ly
					lx, ly = l()
				end
				print("[ARCANE COMBAT] autocast ",self:getTalentFromId(tid).name)
				local old_cd = self:isTalentCoolingDown(self:getTalentFromId(tid))
				self:forceUseTalent(tid, {ignore_energy=true, force_target={x=target_x, y=target_y, __no_self=true}})
				-- Do not setup a cooldown
				if not old_cd then
					self.talents_cd[tid] = nil
				end
				self.changed = true
			end
		end
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Allows one to use a melee weapon to focus spells, granting %d%% chance per melee attack to deliver a Flame, or Lightning spell as a free action on the target.
		Delivering the spell this way will not trigger a spell cooldown, but only works if the spell is not cooling-down.
		The chance increases with dexterity.]]):
		format(20 + self:getTalentLevel(t) * (1 + self:getDex(9, true)))
	end,
}

newTalent{
	name = "Arcane Dexterity",
	type = {"technique/magical-combat", 2},
	mode = "passive",
	points = 5,
	require = techs_req2,
	info = function(self, t)
		return ([[The user gains a bonus to spellpower equal to %d%% of their dexterity.]]):
		format(15 + self:getTalentLevel(t) * 5)
	end,
}

newTalent{
	name = "Arcane Feed",
	type = {"technique/magical-combat", 3},
	mode = "sustained",
	points = 5,
	cooldown = 5,
	sustain_stamina = 40,
	require = techs_req3,
	range = 10,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		local power = self:getTalentLevel(t) / 14
		return {
			regen = self:addTemporaryValue("mana_regen", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("mana_regen", p.regen)
		return true
	end,
	info = function(self, t)
		return ([[Regenerates %0.2f mana per turn while active.]]):format(self:getTalentLevel(t) / 14)
	end,
}

newTalent{
	name = "Arcane Destruction",
	type = {"technique/magical-combat", 4},
	mode = "passive",
	points = 5,
	require = techs_req4,
	info = function(self, t)
		return ([[Raw magical damage channels through the caster's weapon, increasing physical damage by %d.
		The damage scales with Magic and Dexterity.]]):
		format(self:combatSpellpower() * self:getTalentLevel(Talents.T_ARCANE_DESTRUCTION) / 9)
	end,
}
