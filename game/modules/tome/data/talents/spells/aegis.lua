
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
	cooldown = 14,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return 40 + self:combatTalentSpellDamage(t, 40, 420) end,
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
	name = "Regeneration",
	type = {"spell/aegis", 2},
	require = spells_req2,
	points = 5,
	mana = 30,
	cooldown = 10,
	tactical = { HEAL = 2 },
	getRegeneration = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REGENERATION) end,
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=t.getRegeneration(self, t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local regen = t.getRegeneration(self, t)
		return ([[Call upon the forces of nature to regenerate your body for %d life every turn for 10 turns.
		The life healed will increase with the Magic stat]]):
		format(regen)
	end,
}

newTalent{
	name = "Restoration",
	type = {"spell/aegis", 3},
	require = spells_req3,
	points = 5,
	mana = 30,
	cooldown = 15,
	tactical = { PROTECT = 1 },
	getCureCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	action = function(self, t)
		local target = self
		local effs = {}

		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type == "poison" or e.type == "disease" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getCureCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			end
		end

		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local curecount = t.getCureCount(self, t)
		return ([[Call upon the forces of nature to cure your body of %d poisons and diseases (at level 3).]]):
		format(curecount)
	end,
}

newTalent{
	name = "Arcane Shield",
	type = {"spell/aegis", 4},
	require = spells_req4,
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
		Each time you receive a direct heal (not a life regeneration effect) you automatically get a damage shield of %d%% of the heal value for 3 turns.]]):
		format(shield)
	end,
}
