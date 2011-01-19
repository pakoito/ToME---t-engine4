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
	name = "Strength of Purpose",
	type = {"chronomancy/temporal-combat", 1},
	require = temporal_req1,
	mode = "sustained",
	points = 5,
	sustain_stamina = 40,
	cooldown = 18,
	tactical = { BUFF = 2 },
	getPercentage = function(self, t) return ((15 + (self:getTalentLevel(t) * 5)) / 100) end,
	getPower = function(self, t) return math.floor (self:getWil() * t.getPercentage(self, t)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			stats = self:addTemporaryValue("inc_stats", {[self.STAT_STR] = t.getPower(self, t)}),
			particle = self:addParticles(Particles.new("temporal_focus", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_stats", p.stats)
		return true
	end,
	info = function(self, t)
		local percentage = t.getPercentage(self, t) * 100
		return ([[You've learned to overcome physical obstacles through mental determination.  You gain a bonus to strength equal to %d%% of your willpower.]]):
		format(percentage)
	end
}

newTalent{
	name = "Stimulance",
	type = {"chronomancy/temporal-combat", 2},
	require = temporal_req2,
	points = 5,
	paradox = 10,
	cooldown = 50,
	tactical = { STAMINA = 2 },
	getPower = function(self, t) return (20 + self:getTalentLevel(t) * 12)/5 end,
	action = function(self, t)
		self:setEffect(self.EFF_STIMULANCE, 5, {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[Regenerates %d stamina each turn for the next 5 turns.
		]]):format(power)
	end,
}

--[[newTalent{
	name = "Kinetic Folding",
	type = {"chronomancy/temporal-combat", 2},
	require = temporal_req2,
	points = 5,
	stamina = 8,
	paradox = 4,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	range = 6,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return (You momentarily fold the space between yourself and your target, attacking it at range for %d%% weapon damage.
		):
		format (damage*100)
	end,
}]]

newTalent{
	name = "Quantum Feed",
	type = {"chronomancy/temporal-combat", 3},
	require = temporal_req3,
	mode = "sustained",
	points = 5,
	sustain_stamina = 40,
	cooldown = 18,
	tactical = { BUFF = 2 },
	getPercentage = function(self, t) return ((15 + (self:getTalentLevel(t) * 5)) / 100) end,
	getPower = function(self, t) return math.floor (self:getWil() * t.getPercentage(self, t)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			stats = self:addTemporaryValue("inc_stats", {[self.STAT_MAG] = t.getPower(self, t)}),
			particle = self:addParticles(Particles.new("arcane_power", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local percentage = t.getPercentage(self, t) * 100
		return ([[You've learned to use some of your physical reserves to improve your control over the spacetime continuum.  You gain a bonus to magic equal to %d%% of your willpower.]]):
		format(percentage)
	end
}

newTalent{
	name = "Damage Smearing",
	type = {"chronomancy/temporal-combat",4},
	require = temporal_req4,
	points = 5,
	paradox = 25,
	cooldown = 50,
	tactical = { DEFEND = 2 },
	getDuration = function(self, t) return 2 + math.ceil(((self:getTalentLevel(t) / 2)) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SMEARING, t.getDuration(self,t), {power=10})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[For the next %d turns you spread all damage that deals 10 or more points out over five turns rather then taking it all at once.
		The duration will scale with your Paradox.]]):format (duration)
	end,
}
