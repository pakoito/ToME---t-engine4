-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local Object = require "engine.Object"

newTalent{
	name = "Frost Infusion",
	type = {"spell/frost-alchemy", 1},
	mode = "sustained",
	require = spells_req1,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:combatTalentScale(t, 0.05, 0.25) * 100 end,
	activate = function(self, t)
		cancelAlchemyInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		local ret = {}
		self:talentTemporaryValue(ret, "inc_damage", {[DamageType.COLD] = t.getIncrease(self, t)})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with cold damage that can freeze your foes.
		In addition all cold damage you do is increased by %d%%.]]):
		format(daminc)
	end,
}

newTalent{
	name = "Ice Armour",
	type = {"spell/frost-alchemy", 2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 2, 0, 10, 8)) end,
	getArmor = function(self, t) return self:combatTalentSpellDamage(t, 10, 25) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 70) end,
	applyEffect = function(self, t, golem)
		local duration = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		local armor = t.getArmor(self, t)
		golem:setEffect(golem.EFF_ICE_ARMOUR, duration, {armor=armor, dam=dam})
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local dam = self.alchemy_golem and self.alchemy_golem:damDesc(engine.DamageType.COLD, t.getDamage(self, t)) or 0
		local armor = t.getArmor(self, t)
		return ([[While Frost Infusion is active, your bombs deposit a layer of ice on your golem for %d turns when they hit it.
		This ice provides your golem with %d additional armour, melee attacks against it deal %0.1f Cold damage to the attacker, and 50%% of its damage is converted to Cold.
		The effects increase with your talent level and with the Spellpower and damage modifiers of your golem.]]):
		format(duration, armor, dam)
	end,
}

newTalent{
	name = "Flash Freeze",
	type = {"spell/frost-alchemy",3},
	require = spells_req3,
	points = 5,
	mana = 30,
	cooldown = 20,
	requires_target = true,
	tactical = { DISABLE = { stun = 1 }, ATTACKAREA = { COLD = 2 } },
	no_energy = true,
	range = 0,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 2, 0, 10, 8)) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 250) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.COLDNEVERMOVE, {dur=t.getDuration(self, t), dam=t.getDamage(self, t)})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_ice", {radius=tg.radius})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Invoke a blast of cold all around you with a radius of %d, doing %0.1f Cold damage and freezing creatures to the ground for %d turns.
		Affected creatures can still act, but cannot move.
		The duration will increase with your Spellpower.]]):format(radius, damDesc(self, DamageType.COLD, t.getDamage(self, t)), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Ice Core", short_name = "BODY_OF_ICE",
	type = {"spell/frost-alchemy",4},
	require = spells_req4,
	mode = "sustained",
	cooldown = 40,
	sustain_mana = 100,
	points = 5,
	range = 6,
	tactical = { BUFF=1 },
	critResist = function(self, t) return self:combatTalentScale(t, 10, 50) end,
	getResistance = function(self, t) return self:combatTalentSpellDamage(t, 5, 45) end,
	getAffinity = function(self, t) return self:combatTalentLimit(t, 50, 5, 20) end, -- Limit <50%
	activate = function(self, t)
		game:playSoundNear(self, "talents/ice")
		local ret = {}
		self:addShaderAura("body_of_ice", "crystalineaura", {}, "particles_images/spikes.png")
		ret.particle = self:addParticles(Particles.new("snowfall", 1))
		self:talentTemporaryValue(ret, "resists", {[DamageType.PHYSICAL] = t.getResistance(self, t) * 0.6})
		self:talentTemporaryValue(ret, "damage_affinity", {[DamageType.COLD] = t.getAffinity(self, t)})
		self:talentTemporaryValue(ret, "ignore_direct_crits", t.critResist(self, t))
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeShaderAura("body_of_ice")
		return true
	end,
	info = function(self, t)
		local resist = t.getResistance(self, t)
		local crit = t.critResist(self, t)
		return ([[Turn your body into pure ice, increasing your Cold damage affinity by %d%% and your physical resistance by %d%%.
		All direct critical hits (physical, mental, spells) against you have a %d%% lower Critical multiplier (but always do at least normal damage).
		The effects increase with your Spellpower.]]):
		format(t.getAffinity(self, t), resist, resist * 0.6, crit)
	end,
}
