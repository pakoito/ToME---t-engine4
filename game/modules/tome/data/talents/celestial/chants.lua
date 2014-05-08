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

local function cancelChants(self)
	local chants = {self.T_CHANT_OF_FORTITUDE, self.T_CHANT_OF_FORTRESS, self.T_CHANT_OF_RESISTANCE, self.T_CHANT_OF_LIGHT}
	for i, t in ipairs(chants) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

-- Synergizes with melee classes (escort), Weapon of Wrath, healing mod (avoid overheal > healing efficiency), and low spellpower
newTalent{
	name = "Chant of Fortitude",
	type = {"celestial/chants", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 12,
	sustain_positive = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getResists = function(self, t) return self:combatTalentSpellDamage(t, 5, 70) end,
	getLifePct = function(self, t) return self:combatTalentLimit(t, 1, 0.05, 0.20) end, -- Limit < 100% bonus
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	activate = function(self, t)
		cancelChants(self)
		local power = t.getResists(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=t.getDamageOnMeleeHit(self, t)}),
			phys = self:addTemporaryValue("combat_physresist", power),
			spell = self:addTemporaryValue("combat_spellresist", power),
			life = self:addTemporaryValue("max_life", t.getLifePct(self, t)*self.max_life),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("combat_physresist", p.phys)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		self:removeTemporaryValue("max_life", p.life)
		return true
	end,
	info = function(self, t)
		local saves = t.getResists(self, t)
		local life = t.getLifePct(self, t)
		local damageonmeleehit = t.getDamageOnMeleeHit(self, t)
		return ([[You chant the glory of the Sun, granting you %d Physical Save and Spell Save and increasing your maximum life by %0.1f%% (Currently:  %d).
		In addition, this talent surrounds you with a shield of light, dealing %0.1f light damage to anything that hits you in melee.
		You may only have one Chant active at once.
		The saves and light damage will increase with your Spellpower and the life with talent level.]]):
		format(saves, life*100, life*self.max_life, damDesc(self, DamageType.LIGHT, damageonmeleehit))
	end,
}

-- Mostly the same code as Sanctuary
-- Just like Fortress we limit the interaction with spellpower a bit because this is an escort reward
-- This can be swapped to reactively with a projectile already in the air
newTalent{
	name = "Chant of Fortress",
	type = {"celestial/chants", 2},
	mode = "sustained",
	require = divi_req2,
	points = 5,
	cooldown = 12,
	sustain_positive = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getDamageChange = function(self, t)
		return -self:combatTalentLimit(t, 50, 14, 30) -- Limit < 50% damage reduction
	end,
	activate = function(self, t)
		cancelChants(self)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=t.getDamageOnMeleeHit(self, t)}),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		local range = -t.getDamageChange(self, t)
		local damageonmeleehit = t.getDamageOnMeleeHit(self, t)
		return ([[You chant the glory of the Sun, reducing the damage enemies 2 or more spaces away deal by %d%%.
		In addition, this talent surrounds you with a shield of light, dealing %0.1f light damage to anything that hits you in melee.
		You may only have one Chant active at once.
		The damage reduction will increase with talent level and light damage will increase with your Spellpower.]]):
		format(range, damDesc(self, DamageType.LIGHT, damageonmeleehit))
	end,
}

-- Escorts can't give this one so it should have the most significant spellpower scaling
-- Ideally at high spellpower this would almost always be the best chant to use, but we can't guarantee that while still differentiating the chants in interesting ways
-- People that don't want to micromanage/math out when the other chants are better will like this and it should still outperform Fortitude most of the time
newTalent{
	name = "Chant of Resistance",
	type = {"celestial/chants",3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	cooldown = 12,
	sustain_positive = 20,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	no_energy = true,
	range = 10,
	getResists = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	activate = function(self, t)
		cancelChants(self)
		local power = t.getResists(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=t.getDamageOnMeleeHit(self, t)}),
			res = self:addTemporaryValue("resists", {all = power}),
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
		local resists = t.getResists(self, t)
		local damage = t.getDamageOnMeleeHit(self, t)
		return ([[You chant the glory of the Sun, granting you %d%% resistance to all damage.
		In addition, this talent surrounds you with a shield of light, dealing %0.1f light damage to anything that hits you in melee.
		You may only have one Chant active at once.
		The effects will increase with your Spellpower.]]):
		format(resists, damDesc(self, DamageType.LIGHT, damage))
	end,
}

-- Extremely niche in the name of theme
-- A defensive chant is realistically always a better choice than an offensive one but we can mitigate this by giving abnormally high value at low talent investment
newTalent{
	name = "Chant of Light",
	type = {"celestial/chants", 4},
	mode = "sustained",
	require = divi_req4,
	points = 5,
	cooldown = 12,
	sustain_positive = 5,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getLightDamageIncrease = function(self, t) return self:combatTalentSpellDamage(t, 20, 50) end,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getLite = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6, "log")) end,
	activate = function(self, t)
		cancelChants(self)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=t.getDamageOnMeleeHit(self, t)}),
			phys = self:addTemporaryValue("inc_damage", {[DamageType.LIGHT] = t.getLightDamageIncrease(self, t), [DamageType.FIRE] = t.getLightDamageIncrease(self, t)}),
			lite = self:addTemporaryValue("lite", t.getLite(self, t)),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("inc_damage", p.phys)
		self:removeTemporaryValue("lite", p.lite)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getLightDamageIncrease(self, t)
		local damage = t.getDamageOnMeleeHit(self, t)
		local lite = t.getLite(self, t)
		return ([[You chant the glory of the Sun, empowering your light and fire elemental attacks so that they do %d%% additional damage.
		In addition, this talent surrounds you with a shield of light, dealing %0.1f light damage to anything that hits you in melee.
		Your lite radius is also increased by %d.
		You may only have one Chant active at once and this Chant costs less power to sustain.
		The effects will increase with your Spellpower.]]):
		format(damageinc, damDesc(self, DamageType.LIGHT, damage), lite)
	end,
}
