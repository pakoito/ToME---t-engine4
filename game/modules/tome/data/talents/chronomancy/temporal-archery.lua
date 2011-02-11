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
	name = "Phase Shot",
	type = {"chronomancy/temporal-archery", 1},
	require = temporal_req1,
	points = 5,
	paradox = 3,
	cooldown = 3,
	no_energy = "fake",
	range = 10,
	tactical = { ATTACK = 2 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	requires_target = true,
	action = function(self, t)
		local targets = self:archeryAcquireTargets({type="hit"}, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, {type="hit"}, {mult=self:combatTalentWeaponDamage(t, 1.1, 1.9) * getParadoxModifier(self, pm), damtype=DamageType.TEMPORAL, apr=1000})
		return true
	end,
	info = function(self, t)
		local weapon = 100 * (self:combatTalentWeaponDamage(t, 1.1, 1.9) * getParadoxModifier(self, pm))
		return ([[You fire a shot that phases out of time and space allowing it to pass through other creatures and virtually ignore armor.  The shot will deal %d%% weapon damage as temporal damage to it's target.
		The damage will scale with your Paradox.]]):
		format(damDesc(self, DamageType.TEMPORAL, weapon))
	end
}

newTalent{
	name = "Unerring Shot",
	type = {"chronomancy/temporal-archery", 2},
	require = temporal_req2,
	points = 5,
	paradox = 5,
	cooldown = 8,
	no_energy = "fake",
	range = 10,
	tactical = { ATTACK = 2 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt"}
		local targets = self:archeryAcquireTargets(tg)
		if not targets then return end
		self:setEffect(self.EFF_ATTACK, 1, {power=100})
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1.1, 2.1) * getParadoxModifier(self, pm)})
		return true
	end,
	info = function(self, t)
		local weapon = 100 * (self:combatTalentWeaponDamage(t, 1.1, 1.9) * getParadoxModifier(self, pm))
		return ([[You focus your aim and fire a shot with great accuracy, inflicting %d%% weapon damage.  Afterwords your attack will remain improved for one turn as the chronomantic effects linger.
		The damage will scale with your Paradox.]])
		:format(weapon)
	end,
}

newTalent{
	name = "Quick Shot",
	type = {"chronomancy/temporal-archery", 3},
	require = temporal_req3,
	points = 5,
	paradox = 10,
	cooldown = function(self, t) return 15 - 2 * self:getTalentLevelRaw(t) end,
	no_energy = true,
	range = 10,
	tactical = { ATTACK = 2 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	requires_target = true,
	action = function(self, t)
		local old = self.energy.value
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm)})
		self.energy.value = old
		return true
	end,
	info = function(self, t)
		local weapon = 100 * (self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm))
		return ([[You pause time around you long enough to fire a single shot, doing %d%% damage.
		The damage will scale with your Paradox and the cooldown will go down with more talent points invested.]]):format(weapon)
	end,
}

newTalent{
	name = "Perfect Aim",
	type = {"chronomancy/temporal-archery", 4},
	require = temporal_req4,
	points = 5,
	paradox = 10,
	cooldown = 20,
	tactical = { BUFF = 2 },
	no_energy = true,
	getDuration = function(self, t) return 1 + math.ceil((self:getTalentLevel(t)/2) * getParadoxModifier(self, pm)) end,
	getPower = function(self, t) return 10 + (self:combatTalentSpellDamage(t, 10, 40)*getParadoxModifier(self, pm)) end,
	action = function(self, t)
		self:setEffect(self.EFF_PERFECT_AIM, t.getDuration(self, t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return ([[You focus your aim for the next %d turns, increasing your physical and spell critical strike chance and your critical damage multiplier by %d%%..
		The effect will scale with your Paradox and the Magic stat.]]):format(duration, power)
	end,
}