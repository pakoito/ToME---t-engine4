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
	name = "Sling Mastery",
	type = {"technique/archery-sling", 1},
	points = 10,
	require = { stat = { dex=function(level) return 12 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return ([[Increases damage done with slings by %d%%.]]):format(100 * (math.sqrt(self:getTalentLevel(t) / 10)))
	end,
}

newTalent{
	name = "Eye Shot",
	type = {"technique/archery-sling", 2},
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req2,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = 2, DISABLE = 2 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("sling") then if not silent then game.logPlayer(self, "You require a sling for this talent.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 10) and target:canBe("blind") then
			target:setEffect(target.EFF_BLINDED, 2 + self:getTalentLevelRaw(t), {})
		else
			game.logSeen(target, "%s resists!", target.name:capitalize())
		end
	end,
	action = function(self, t)
		if not self:hasArcheryWeapon("sling") then game.logPlayer(self, "You must wield a sling!") return nil end

		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5)})
		return true
	end,
	info = function(self, t)
		return ([[You fire a shot into your target's eyes, blinding it for %d turns and doing %d%% damage.
		Blind chance increase with your Dexterity stat.]])
		:format(2 + self:getTalentLevelRaw(t),
		100 * self:combatTalentWeaponDamage(t, 1, 1.5))
	end,
}

newTalent{
	name = "Inertial Shot",
	type = {"technique/archery-sling", 3},
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req3,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = 2, DISABLE = 2, ESCAPE = 1 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("sling") then if not silent then game.logPlayer(self, "You require a sling for this talent.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
			target:knockback(self.x, self.y, 4)
			game.logSeen(target, "%s is knocked back!", target.name:capitalize())
		else
			game.logSeen(target, "%s stands firm!", target.name:capitalize())
		end
	end,
	action = function(self, t)
		if not self:hasArcheryWeapon("sling") then game.logPlayer(self, "You must wield a sling!") return nil end

		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5)})
		return true
	end,
	info = function(self, t)
		return ([[You fire a mighty shot at your target doing %d%% damage and knocking it back.
		Knockback chance increase with your Dexterity stat.]]):format(100 * self:combatTalentWeaponDamage(t, 1, 1.5))
	end,
}

newTalent{
	name = "Multishot",
	type = {"technique/archery-sling", 4},
	no_energy = "fake",
	points = 5,
	cooldown = 12,
	stamina = 35,
	require = techs_dex_req4,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = 3 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("sling") then if not silent then game.logPlayer(self, "You require a sling for this talent.") end return false end return true end,
	action = function(self, t)
		if not self:hasArcheryWeapon("sling") then game.logPlayer(self, "You must wield a sling!") return nil end

		local targets = self:archeryAcquireTargets(nil, {multishots=2+self:getTalentLevelRaw(t)/2})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 0.3, 0.7)})
		return true
	end,
	info = function(self, t)
		return ([[You fire %d shots at your target, doing %d%% damage with each shot.]]):format(2+self:getTalentLevelRaw(t)/2, 100 * self:combatTalentWeaponDamage(t, 0.3, 0.7))
	end,
}
