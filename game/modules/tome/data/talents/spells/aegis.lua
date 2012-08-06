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

newTalent{
	name = "Arcane Reconstruction", short_name = "HEAL",
	type = {"spell/aegis", 1},
	require = spells_req1,
	points = 5,
	mana = 25,
	cooldown = 16,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return 40 + self:combatTalentSpellDamage(t, 10, 520) end,
	is_heal = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[Imbues your body with arcane forces, reconstructing it to a default state, healing for %d life.
		The life healed will increase with your Spellpower.]]):
		format(heal)
	end,
}

newTalent{
	name = "Shielding",
	type = {"spell/aegis", 2},
	require = spells_req2,
	points = 5,
	mode = "sustained",
	sustain_mana = 40,
	cooldown = 14,
	tactical = { BUFF = 2 },
	getDur = function(self, t) return self:getTalentLevel(t) >= 5 and 1 or 0 end,
	getShield = function(self, t) return 20 + self:combatTalentSpellDamage(t, 5, 400) / 10 end,
	activate = function(self, t)
		local dur = t.getDur(self, t)
		local shield = t.getShield(self, t)
		game:playSoundNear(self, "talents/arcane")
		local ret = {
			shield = self:addTemporaryValue("shield_factor", shield),
			dur = self:addTemporaryValue("shield_dur", dur),
		}
		self:checkEncumbrance()
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("shield_factor", p.shield)
		self:removeTemporaryValue("shield_dur", p.dur)
		return true
	end,
	info = function(self, t)
		local shield = t.getShield(self, t)
		local dur = t.getDur(self, t)
		return ([[Surround yourself with strengthening arcane forces.
		Every damage shield, time shield, displacement shield, disruption shield affecting you has its power increased by %d%%.
		At level 5 it also increases the duration of all shields by 1 turn.
		The shield value will increase with your Spellpower.]]):
		format(shield, dur)
	end,
}

newTalent{
	name = "Arcane Shield",
	type = {"spell/aegis", 3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getShield = function(self, t) return 20 + self:combatTalentSpellDamage(t, 5, 500) / 10 end,
	activate = function(self, t)
		local shield = t.getShield(self, t)
		game:playSoundNear(self, "talents/arcane")
		local ret = {
			shield = self:addTemporaryValue("arcane_shield", shield),
		}
		self:checkEncumbrance()
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("arcane_shield", p.shield)
		return true
	end,
	info = function(self, t)
		local shield = t.getShield(self, t)
		return ([[Surround yourself with protective arcane forces.
		Each time you receive a direct heal (not a life regeneration effect) you automatically get a damage shield of %d%% of the heal value for 3 turns.
		The shield value will increase with your Spellpower.]]):
		format(shield)
	end,
}

newTalent{
	name = "Aegis",
	type = {"spell/aegis", 4},
	require = spells_req4,
	points = 5,
	mana = 50,
	cooldown = 25,
	no_energy = true,
	tactical = { HEAL = 2 },
	getShield = function(self, t) return 40 + self:combatTalentSpellDamage(t, 5, 500) / 10 end,
	on_pre_use = function(self, t)
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.on_aegis then return true end
		end
		if self:isTalentActive(self.T_DISRUPTION_SHIELD) then return true end
	end,
	action = function(self, t)
		local target = self
		local shield = t.getShield(self, t)
		local effs = {}

		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.on_aegis then
				effs[#effs+1] = {id=eff_id, e=e, p=p}
			end
		end

		for i = 1, self:getTalentLevelRaw(t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			eff.e.on_aegis(self, eff.p, shield)
		end

		if self:isTalentActive(self.T_DISRUPTION_SHIELD) then
			self:setEffect(self.EFF_MANA_OVERFLOW, math.ceil(2 + self:getTalentLevel(t)), {power=shield})
		end

		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local shield = t.getShield(self, t)
		return ([[Release arcane energies into any magical shield currently protecting you, further charging it by %d%% of its max absorb value.
		It will affect at most %d shield effects.
		Affected shields are: Damage Shield, Time Shield, Displacement Shield, Disruption Shield.
		The charging will increase with your Spellpower.]]):
		format(shield, self:getTalentLevelRaw(t))
	end,
}
