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

-- Edge TODO: Sounds, Particles, Talent Icons; Trance of Focus; Deep Trance

local function cancelTrances(self)
	local trances = {self.T_TRANCE_OF_CLARITY, self.T_TRANCE_OF_PURITY, self.T_TRANCE_OF_FOCUS}
	for i, t in ipairs(trances) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

newTalent{
	name = "Trance of Purity",
	type = {"psionic/trance", 1},
	points = 5,
	require = psi_wil_req1,
	cooldown = 12,
	tactical = { BUFF = 2 },
	mode = "sustained",
	sustain_psi = 20,
	getSavingThrows = function(self, t) return self:combatTalentMindDamage(t, 5, 50) end,
	getPurgeChance = function(self, t) return 50 - math.min(30, self:combatTalentMindDamage(t, 0, 30)) end,
	activate = function(self, t)
		local effs = {}
		local chance = 100
		
		-- go through all timed effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.type ~= "other" and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end
		
		-- Check chance to remove effects and purge them if possible
		while chance > 0 and #effs > 0 do
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" and rng.percent(chance) then
				self:removeEffect(eff[2])
				chance = chance - t.getPurgeChance(self, t)
			end
		end
	
		-- activate sustain
		cancelTrances(self)
		local power = t.getSavingThrows(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			phys = self:addTemporaryValue("combat_physresist", power),
			spell = self:addTemporaryValue("combat_spellresist", power),
			mental = self:addTemporaryValue("combat_mentalresist", power),
		--	particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
	--	self:removeParticles(p.particle)
		self:removeTemporaryValue("combat_physresist", p.phys)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		self:removeTemporaryValue("combat_mentalresist", p.mental)
		return true
	end,
	info = function(self, t)
		local purge = t.getPurgeChance(self, t)
		local saves = t.getSavingThrows(self, t)
		return ([[Activate to purge negative status effects (100%% chance for the first effect, -%d%% less chance for each subsequent effect).  While this talent is sustained all your saving throws are increased by %d.
		The chance to purge and saving throw bonus will scale with your mindpower.
		Only one trance may be active at a time.]]):format(purge, saves)
	end,
}

newTalent{
	short_name = "TRANCE_OF_WELL_BEING",
	name = "Trance of Well-Being",
	type = {"psionic/trance", 2},
	points = 5,
	require = psi_wil_req2,
	cooldown = 12,
	tactical = { BUFF = 2 },
	mode = "sustained",
	sustain_psi = 20,
	getHeal = function(self, t) return self:combatTalentMindDamage(t, 20, 340) end,
	getHealingModifier = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getLifeRegen = function(self, t) return self:combatTalentMindDamage(t, 10, 50) / 10 end,
	activate = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:mindCrit(t.getHeal(self, t)))
		self:attr("allow_on_heal", -1)
	
		cancelTrances(self)	
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			heal_mod = self:addTemporaryValue("healing_factor", t.getHealingModifier(self, t)/100),
			regen = self:addTemporaryValue("life_regen", t.getLifeRegen(self, t)),
		}
		
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("healing_factor", p.heal_mod)
		self:removeTemporaryValue("life_regen", p.regen)
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		local healing_modifier = t.getHealingModifier(self, t)
		local regen = t.getLifeRegen(self, t)
		return ([[Activate to heal yourself for %0.2f life.  While this talent is sustained your healing modifier will be increased by %d%% and your life regen by %0.2f.
		The effects will scale with your mindpower.
		Only one trance may be active at a time.]]):format(heal, healing_modifier, regen)
	end,
}

newTalent{
	name = "Trance of Focus",
	type = {"psionic/trance", 3},
	points = 5,
	require = psi_wil_req3,
	cooldown = 12,
	tactical = { BUFF = 2 },
	mode = "sustained",
	sustain_psi = 20,
	getCriticalPower = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getCriticalChance = function(self, t) return self:combatTalentMindDamage(t, 4, 12) end,
	activate = function(self, t)
		self:setEffect(self.EFF_TRANCE_OF_FOCUS, 10, {t.getCriticalPower(self, t)})
		
		cancelTrances(self)	
		local power = t.getCriticalChance(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			phys = self:addTemporaryValue("combat_physcrit", power),
			spell = self:addTemporaryValue("combat_spellcrit", power),
			mental = self:addTemporaryValue("combat_mindcrit", power),
		}
		
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physcrit", p.phys)
		self:removeTemporaryValue("combat_spellcrit", p.spell)
		self:removeTemporaryValue("combat_mindcrit", p.mental)
		return true
	end,
	info = function(self, t)
		local power = t.getCriticalPower(self, t)
		local chance = t.getCriticalChance(self, t)
		return ([[Activate to increase your critical strike damage by %d%% for 10 turns.  While this talent is sustained your critical strike chance is improved by +%d%%.
		The effects will scale with your mindpower.
		Only one trance may be active at a time.]]):format(power, chance)
	end,
}

newTalent{
	name = "Deep Trance",
	type = {"psionic/trance", 4},
	points = 5,
	require = psi_wil_req4,
	mode = "passive",
	info = function(self, t)
		return ([[When you wield or wear an item infused by psionic, nature, or arcane-disrupting forces you improve all values under its 'when wielded/worn' field %d%%.
		Note this doesn't change the item itself, but rather the effects it has on your person (the item description will not reflect the improved values).]]):format(1)
	end,
}