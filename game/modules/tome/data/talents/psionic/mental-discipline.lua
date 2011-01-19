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
	name = "Highly Trained Mind",
	type = {"psionic/mental-discipline", 1},
	mode = "passive",
	require = psi_wil_req1,
	points = 5,
	on_learn = function(self, t)
		self.inc_stats[self.STAT_WIL] = self.inc_stats[self.STAT_WIL] + 1
		self:onStatChange(self.STAT_WIL, 1)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] + 1
		self:onStatChange(self.STAT_CUN, 1)
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_WIL] = self.inc_stats[self.STAT_WIL] - 1
		self:onStatChange(self.STAT_WIL, -1)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] - 1
		self:onStatChange(self.STAT_CUN, -1)
	end,
	info = function(self, t)
		return ([[A life of the mind has had predictably good effects on your Willpower and Cunning.
		Increases Willpower and Cunning (as well as their maximum values) by %d.]]):format(self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Iron Will",
	type = {"psionic/mental-discipline", 2},
	require = psi_wil_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.combat_mentalresist = self.combat_mentalresist + 6
		self.stun_immune = (self.stun_immune or 0) + .1
	end,

	on_unlearn = function(self, t)
		self.combat_mentalresist = self.combat_mentalresist - 6
		self.stun_immune = (self.stun_immune or 0) - .1
	end,
	info = function(self, t)
		return ([[Improves mental saves by %d and stun immunity by %d%%]]):
		format(self:getTalentLevelRaw(t)*6, self:getTalentLevelRaw(t)*10)
	end,
}

newTalent{
	name = "Shield Discipline",
	type = {"psionic/mental-discipline", 3},
	require = psi_wil_req3,
	cooldown = function(self, t)
		return 120 - self:getTalentLevel(t)*12
	end,
	psi = 15,
	points = 5,
	no_energy = true,
	tactical = { BUFF = 3 },
	action = function(self, t)
		if self.talents_cd[self.T_KINETIC_SHIELD] == nil and self.talents_cd[self.T_THERMAL_SHIELD] == nil and self.talents_cd[self.T_CHARGED_SHIELD] == nil then
			return
		else
			self.talents_cd[self.T_KINETIC_SHIELD] = (self.talents_cd[self.T_KINETIC_SHIELD] or 0) - 10 - 2 * self:getTalentLevelRaw(t)
			self.talents_cd[self.T_THERMAL_SHIELD] = (self.talents_cd[self.T_THERMAL_SHIELD] or 0) - 10 - 2 * self:getTalentLevelRaw(t)
			self.talents_cd[self.T_CHARGED_SHIELD] = (self.talents_cd[self.T_CHARGED_SHIELD] or 0) - 10 - 2 * self:getTalentLevelRaw(t)
			return true
		end
	end,

	info = function(self, t)
		return ([[When activated, reduces the cooldowns of all shields by %d. Additional talent points spent in Shield Discipline improve this value and allow it to be used more frequently.]]):
		format(10+self:getTalentLevelRaw(t)*2)
	end,
}

newTalent{
	name = "Aura Discipline",
	type = {"psionic/mental-discipline", 4},
	require = psi_wil_req4,
	cooldown = function(self, t)
		return 120 - self:getTalentLevel(t)*12
	end,
	psi = 15,
	points = 5,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		if self.talents_cd[self.T_KINETIC_AURA] == nil and self.talents_cd[self.T_THERMAL_AURA] == nil and self.talents_cd[self.T_CHARGED_AURA] == nil then
			return
		else
			if self:isTalentActive(self.T_CONDUIT) then
				local auras = self:isTalentActive(self.T_CONDUIT)
				if not auras.k_aura_on then
					self.talents_cd[self.T_KINETIC_AURA] = (self.talents_cd[self.T_KINETIC_AURA] or 0) - 4 - 1 * self:getTalentLevelRaw(t)
				end
				if not auras.t_aura_on then
					self.talents_cd[self.T_THERMAL_AURA] = (self.talents_cd[self.T_THERMAL_AURA] or 0) - 4 - 1 * self:getTalentLevelRaw(t)
				end
				if not auras.c_aura_on then
					self.talents_cd[self.T_CHARGED_AURA] = (self.talents_cd[self.T_CHARGED_AURA] or 0) - 4 - 1 * self:getTalentLevelRaw(t)
				end
			else
				self.talents_cd[self.T_KINETIC_AURA] = (self.talents_cd[self.T_KINETIC_AURA] or 0) - 4 - 1 * self:getTalentLevelRaw(t)
				self.talents_cd[self.T_THERMAL_AURA] = (self.talents_cd[self.T_THERMAL_AURA] or 0) - 4 - 1 * self:getTalentLevelRaw(t)
				self.talents_cd[self.T_CHARGED_AURA] = (self.talents_cd[self.T_CHARGED_AURA] or 0) - 4 - 1 * self:getTalentLevelRaw(t)
			end
			return true
		end
	end,

	info = function(self, t)
		local red = 4 + self:getTalentLevelRaw(t)
		return ([[When activated, reduces the cooldown of all auras by %d. Additional talent points spent in Aura Discipline improve this value and allow it to be used more frequently.]]):
		format(red)
	end,
}

