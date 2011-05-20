
-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	name = "Heal",
	type = {"spell/aegis", 1},
	require = spells_req1,
	points = 5,
	mana = 25,
	cooldown = 16,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return 40 + self:combatTalentSpellDamage(t, 140, 520) end,
	action = function(self, t)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[Call upon the forces of nature to heal your body for %d life.
		The life healed will increase with the Magic stat]]):
		format(heal)
	end,
}

newTalent{
	name = "Contingency",
	type = {"spell/aegis", 2},
	require = spells_req2,
	points = 5,
	mode = "sustained",
	sustain_mana = 40,
	cooldown = 14,
	tactical = { BUFF = 2 },
	getValue = function(self, t) return 50 - self:getTalentLevelRaw(t) * 6 end,
	getShield = function(self, t) return 20 + self:combatTalentSpellDamage(t, 5, 400) / 10 end,
	activate = function(self, t)
		self.contingency_disable = self.contingency_disable or {}
		local value = t.getValue(self, t)
		local shield = t.getShield(self, t)
		game:playSoundNear(self, "talents/arcane")
		local ret = {
			value = self:addTemporaryValue("contingency", value),
			shield = self:addTemporaryValue("contingency_shield", shield),
			disable = self:addTemporaryValue("contingency_disable", {[t.id] = 1}),
		}
		self:checkEncumbrance()
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("contingency", p.value)
		self:removeTemporaryValue("contingency_shield", p.shield)
		self:removeTemporaryValue("contingency_disable", p.disable)
		return true
	end,
	info = function(self, t)
		local value = t.getValue(self, t)
		local shield = t.getShield(self, t)
		return ([[Surround yourself with protective arcane forces.
		Each time you are hit for over %d%% of your total life you automatically get a damage shield of %d%% of the life lost for 3 turns.
		The spell will then unsustain itself.
		The shield value will increase with your Magic stat.]]):
		format(value, shield)
	end,
}

newTalent{
	name = "Arcane Shield",
	type = {"spell/aegis", 3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	sustain_mana = 60,
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
		The shield value will increase with your Magic stat.]]):
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
	tactical = { HEAL = 2 },
	getShield = function(self, t) return 50 + self:combatTalentSpellDamage(t, 5, 500) / 10 end,
	on_pre_use = function(self, t)
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.on_aegis then return true end
		end
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

			eff.p.dur = eff.p.dur * 2
			eff.e.on_aegis(self, eff.p, shield)
		end

		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local shield = t.getShield(self, t)
		return ([[Release arcane energies into any magical shield currently protection you, doubling its remaining time and increasing its remaining absorb value by %d%%.
		It will affect at most %d shield effects.
		Affected shields are: Damage Shield, Time Shield, Displacement Shield]]):
		format(shield, self:getTalentLevelRaw(t))
	end,
}
