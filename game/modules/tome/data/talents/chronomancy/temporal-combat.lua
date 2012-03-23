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
	name = "Strength of Purpose",
	type = {"chronomancy/temporal-combat", 1},
	require = temporal_req1,
	mode = "sustained",
	points = 5,
	sustain_stamina = 50,
	sustain_paradox = 100,
	cooldown = 18,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return math.ceil((self:getTalentLevel(t) * 1.5) + self:combatTalentStatDamage(t, "wil", 5, 20)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			stats = self:addTemporaryValue("inc_stats", {[self.STAT_STR] = t.getPower(self, t)}),
			phys = self:addTemporaryValue("combat_physresist", t.getPower(self, t)),
			particle = self:addParticles(Particles.new("temporal_focus", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_stats", p.stats)
		self:removeTemporaryValue("combat_physresist", p.phys)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[You've learned to boost your strength through your control of the spacetime continuum.  Increases your strength and your physical saves by %d.
		The effect will scale with your Willpower stat.]]):format(power)
	end
}

newTalent{
	name = "Invigorate",
	type = {"chronomancy/temporal-combat", 2},
	require = temporal_req2,
	points = 5,
	paradox = 10,
	cooldown = 24,
	tactical = { STAMINA = 2 },
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	getPower = function(self, t) return self:getTalentLevel(t) end,
	action = function(self, t)
		self:setEffect(self.EFF_INVIGORATE, t.getDuration(self,t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[For the next %d turns you recover %d stamina each turn and all other talents on cooldown will refresh twice as fast as usual.
		The duration will scale with your Paradox.]]):format(duration, power)
	end,
}

newTalent{
	name = "Quantum Feed",
	type = {"chronomancy/temporal-combat", 3},
	require = temporal_req3,
	mode = "sustained",
	points = 5,
	sustain_stamina = 50,
	sustain_paradox = 100,
	cooldown = 18,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return math.ceil((self:getTalentLevel(t) * 1.5) + self:combatTalentStatDamage(t, "wil", 5, 20)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			stats = self:addTemporaryValue("inc_stats", {[self.STAT_MAG] = t.getPower(self, t)}),
			spell = self:addTemporaryValue("combat_spellresist", t.getPower(self, t)),
			particle = self:addParticles(Particles.new("arcane_power", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[You've learned to boost your magic through your control over the spacetime continuum.  Increases your magic and your spell saves by %d.
		The effect will scale with your Willpower stat.]]):format(power)
	end
}

newTalent{
	name = "Damage Smearing",
	type = {"chronomancy/temporal-combat",4},
	require = temporal_req4,
	points = 5,
	paradox = 25,
	cooldown = 25,
	tactical = { DEFEND = 2 },
	no_energy = true,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SMEARING, t.getDuration(self,t), {})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[For the next %d turns you convert all non-temporal damage you receive into temporal damage spread out over six turns.
		This spell takes no time to cast and the duration will scale with your Paradox.]]):format (duration)
	end,
}
