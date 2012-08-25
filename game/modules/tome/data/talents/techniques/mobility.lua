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

local Map = require "engine.Map"

newTalent{
	name = "Hack'n'Back",
	type = {"technique/mobility", 1},
	points = 5,
	cooldown = 14,
	stamina = 30,
	tactical = { ESCAPE = 1, ATTACK = { weapon = 0.5 } },
	require = techs_dex_req1,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1) end,
	getDist = function(self, t) return 1 + math.ceil(self:getTalentLevel(t) / 2) end,
	on_pre_use = function(self, t)
		if self:attr("never_move") then return false end
		return true
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hitted then
			self:knockback(target.x, target.y, t.getDist(self, t))
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local dist = t.getDist(self, t)
		return ([[You hit your target doing %d%% damage, distracting it while you jump back %d squares away.]]):
		format(100 * damage, dist)
	end,
}

newTalent{
	name = "Mobile Defence",
	type = {"technique/mobility", 2},
	mode = "passive",
	points = 5,
	require = techs_dex_req2,
	getDef = function(self, t) return self:getTalentLevel(t) * 0.08 end,
	getHardiness = function(self, t) return self:getTalentLevel(t) * 0.06 end,
	info = function(self, t)
		return ([[Whilst wearing leather or lighter armour you gain %d%% defence and %d%% armour hardiness.]]):
		format(t.getDef(self, t) * 100, t.getHardiness(self, t) * 100)
	end,
}

newTalent{
	name = "Light of Foot",
	type = {"technique/mobility", 3},
	mode = "passive",
	points = 5,
	require = techs_dex_req3,
	on_learn = function(self, t)
		self.fatigue = (self.fatigue or 0) - 1.5
		if self:getTalentLevelRaw(t) == 3 then self:attr("avoid_pressure_traps", 1) end
	end,
	on_unlearn = function(self, t)
		self.fatigue = (self.fatigue or 0) + 1.5
		if self:getTalentLevelRaw(t) == 2 then self:attr("avoid_pressure_traps", -1) end
	end,
	info = function(self, t)
		return ([[You are light on foot, handling your armour better. Each step you take regenerates %0.2f stamina and your fatigue is permanently reduced by %d%%.
		At level 3 you are able to walk so lightly that you never trigger traps that require pressure.]]):
		format(self:getTalentLevelRaw(t) * 0.2, self:getTalentLevelRaw(t) * 1.5)
	end,
}

newTalent{
	name = "Strider",
	type = {"technique/mobility", 4},
	mode = "passive",
	points = 5,
	require = techs_dex_req4,
	on_learn = function(self, t)
		self.movement_speed = self.movement_speed + 0.02
		self.talent_cd_reduction[Talents.T_RUSH] = (self.talent_cd_reduction[Talents.T_RUSH] or 0) + 1
		self.talent_cd_reduction[Talents.T_HACK_N_BACK] = (self.talent_cd_reduction[Talents.T_HACK_N_BACK] or 0) + 1
		self.talent_cd_reduction[Talents.T_DISENGAGE] = (self.talent_cd_reduction[Talents.T_DISENGAGE] or 0) + 1
		self.talent_cd_reduction[Talents.T_EVASION] = (self.talent_cd_reduction[Talents.T_EVASION] or 0) + 1
	end,
	on_unlearn = function(self, t)
		self.movement_speed = self.movement_speed - 0.02
		self.talent_cd_reduction[Talents.T_RUSH] = (self.talent_cd_reduction[Talents.T_RUSH] or 0) - 1
		self.talent_cd_reduction[Talents.T_HACK_N_BACK] = (self.talent_cd_reduction[Talents.T_HACK_N_BACK] or 0) - 1
		self.talent_cd_reduction[Talents.T_DISENGAGE] = (self.talent_cd_reduction[Talents.T_DISENGAGE] or 0) - 1
		self.talent_cd_reduction[Talents.T_EVASION] = (self.talent_cd_reduction[Talents.T_EVASION] or 0) - 1
	end,
	info = function(self, t)
		return ([[You literally dance around your foes, increasing movement speed by %d%% and reducing the cooldown of Hack'n'Back, Rush, Disengage and Evasion by %d turns.]]):
		format(self:getTalentLevelRaw(t) * 2, self:getTalentLevelRaw(t))
	end,
}

