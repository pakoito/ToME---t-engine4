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

local function cancelChants(self)
	local chants = {self.T_CHANT_OF_FORTITUDE, self.T_CHANT_OF_FORTRESS, self.T_CHANT_OF_RESISTANCE, self.T_CHANT_OF_LIGHT}
	for i, t in ipairs(chants) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

newTalent{
	name = "Chant of Fortitude",
	type = {"divine/chants", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 30,
	sustain_positive = 20,
	dont_provide_pool = true,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	activate = function(self, t)
		cancelChants(self)
		local power = self:combatTalentSpellDamage(t, 5, 70)
		local dam = self:combatTalentSpellDamage(t, 5, 25)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=dam}),
			phys = self:addTemporaryValue("combat_physresist", power),
			spell = self:addTemporaryValue("combat_spellresist", power),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("combat_physresist", p.phys)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		return true
	end,
	info = function(self, t)
		return ([[Chant the glory of the sun, granting you %d physical and spell save.
		In addition it surrounds you with a shield of light, damaging anything that attacks you for %0.2f light damage.
		You may only have one Chant active at once.
		The resistance and damage will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 5, 70), damDesc(self, DamageType.LIGHT, self:combatTalentSpellDamage(t, 5, 25)))
	end,
}

newTalent{
	name = "Chant of Fortress",
	type = {"divine/chants", 2},
	mode = "sustained",
	require = divi_req2,
	points = 5,
	cooldown = 30,
	sustain_positive = 20,
	dont_provide_pool = true,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	activate = function(self, t)
		cancelChants(self)
		local power = self:combatTalentSpellDamage(t, 5, 35)
		local dam = self:combatTalentSpellDamage(t, 5, 25)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=dam}),
			phys = self:addTemporaryValue("resists", {[DamageType.PHYSICAL] = power}),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("resists", p.phys)
		return true
	end,
	info = function(self, t)
		return ([[Chant the glory of the sun, granting you %d%% physical damage resistance.
		In addition it surrounds you with a shield of light, damaging anything that attacks you for %0.2f light damage.
		You may only have one Chant active at once.
		The resistance and damage will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 5, 35), damDesc(self, DamageType.LIGHT, self:combatTalentSpellDamage(t, 5, 25)))
	end,
}

newTalent{
	name = "Chant of Resistance",
	type = {"divine/chants",3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	cooldown = 30,
	sustain_positive = 20,
	dont_provide_pool = true,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	activate = function(self, t)
		cancelChants(self)
		local power = self:combatTalentSpellDamage(t, 5, 35)
		local dam = self:combatTalentSpellDamage(t, 5, 25)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=dam}),
			res = self:addTemporaryValue("resists", {
				[DamageType.FIRE] = power,
				[DamageType.LIGHTNING] = power,
				[DamageType.ACID] = power,
				[DamageType.COLD] = power,
			}),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("resists", p.res)
		return true
	end,
	info = function(self, t)
		return ([[Chant the glory of the sun, granting you %d%% elemental resistances.
		In addition it surrounds you with a shield of light, damaging anything that attacks you for %0.2f light damage.
		You may only have one Chant active at once.
		The resistance and damage will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 5, 35), damDesc(self, DamageType.LIGHT, self:combatTalentSpellDamage(t, 5, 25)))
	end,
}

newTalent{
	name = "Chant of Light",
	type = {"divine/chants", 4},
	mode = "sustained",
	require = divi_req4,
	points = 5,
	cooldown = 30,
	sustain_positive = 20,
	dont_provide_pool = true,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	activate = function(self, t)
		cancelChants(self)
		local power = self:combatTalentSpellDamage(t, 10, 50)
		local dam = self:combatTalentSpellDamage(t, 5, 25)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=dam}),
			phys = self:addTemporaryValue("inc_damage", {[DamageType.LIGHT] = power}),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("inc_damage", p.phys)
		return true
	end,
	info = function(self, t)
		return ([[Chant the glory of the sun, granting you %d%% more light damage.
		In addition it surrounds you with a shield of light, damaging anything that attacks you for %0.2f light damage.
		You may only have one Chant active at once.
		The damage will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 10, 50), damDesc(self, DamageType.LIGHT, self:combatTalentSpellDamage(t, 5, 25)))
	end,
}
