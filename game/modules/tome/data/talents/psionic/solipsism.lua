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


-- TODO: Sounds and particles

newTalent{
	name = "Solipsism",
	type = {"psionic/solipsism", 1},
	points = 5,
	require = psi_wil_req1,
	mode = "passive",
	no_unlearn_last = true,
	damageToPsi = function(self, t) return math.min(self:getTalentLevel(t) * 0.15, 1) end,
	on_learn = function(self, t)
		self:incMaxPsi(10)
		if self:getTalentLevelRaw(t) == 1 then
			self.life_rating = 0
			self.psi_rating =  self.psi_rating + 10
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.2
		end
		return true
	end,
	on_unlearn = function(self, t)
		self:incMaxPsi(-10)
		if not self:knowTalent(t) then
			self.solipsism_threshold = self.solipsism_threshold - 0.2
		end
		return true
	end,
	info = function(self, t)
		local damage_to_psi = t.damageToPsi(self, t)
		return ([[You believe that your mind is the center of everything.  Permanently increases the amount of psi you gain per level by 10 and reduces your life rating (affects life at level up) to 0 (one time only adjustment).
		You also have learned to overcome physical damage with your mind alone and convert %d%% of all damage into psi damage.
		Increases your solipsism threshold by 20%% (first point only), reducing global speed if your Psi falls below the threshold (currently %d%%).
		Each talent point invested will also increase your max Psi by 10.]]):format(damage_to_psi * 100, self.solipsism_threshold * 100)
	end,
}

newTalent{
	name = "Balance",
	type = {"psionic/solipsism", 2},
	points = 5,
	require = psi_wil_req2,
	mode = "passive",
	getBalanceRatio = function(self, t) return math.min(self:getTalentLevel(t) * 0.15, 1) end,
	on_learn = function(self, t)
		self:incMaxPsi(10)
		if self:getTalentLevelRaw(t) == 1 then
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.1
		end
		return true
	end,
	on_unlearn = function(self, t)
		self:incMaxPsi(-10)
		if not self:knowTalent(t) then
			self.solipsism_threshold = self.solipsism_threshold - 0.1
		end
		return true
	end,
	info = function(self, t)
		local ratio = t.getBalanceRatio(self, t) * 100
		return ([[%d%% of your healing and life regen now recovers Psi instead of life.  You now use %d%% of your physical save value and %d%% of your mental save value for physical saving throws.
		Increases your solipsism threshold by 10%% (first point only), reducing global speed if your Psi falls below the threshold (currently %d%%).
		Each talent point invested will also increase your max Psi by 10.]]):format(ratio, ratio, ratio, self.solipsism_threshold * 100)
	end,
}

newTalent{
	name = "Clarity",
	type = {"psionic/solipsism", 3},
	points = 5,
	require = psi_wil_req3,
	mode = "passive",
	getClarityThreshold = function(self, t) return math.max(0.5, 1 - self:getTalentLevelRaw(t) / 10) end,
	on_learn = function(self, t)
		self:incMaxPsi(10)
		self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.1
		if self:getTalentLevelRaw(t) == 1 then
			self.clarity_threshold = t.getClarityThreshold(self, t)
		end
		return true
	end,
	on_unlearn = function(self, t)
		self:incMaxPsi(-10)
		if not self:knowTalent(t) then
			self.solipsism_threshold = self.solipsism_threshold - 0.1
			self.clarity_threshold = nil
		else
			self.clarity_threshold = t.getClarityThreshold(self, t)
		end
		return true
	end,
	info = function(self, t)
		local threshold = t.getClarityThreshold(self, t)
		return ([[For every percent that your Psi pool exceeds %d%% you gain 1%% global speed.
		Increases your solipsism threshold by 10%% (first point only), reducing global speed if your Psi falls below the threshold (currently %d%%).
		Each talent point invested will also increase your max Psi by 10.]]):format(threshold * 100, self.solipsism_threshold * 100)
	end,
}

newTalent{
	name = "Dismissal",
	type = {"psionic/solipsism", 4},
	points = 5,
	require = psi_wil_req4,
	cooldown = 12,
	psi = 20,
	tactical = { DEFEND = 2},
	getDuration = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)) end,
	on_learn = function(self, t)
		self:incMaxPsi(10)
		if self:getTalentLevelRaw(t) == 1 then
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.1
		end
		return true
	end,
	on_unlearn = function(self, t)
		self:incMaxPsi(-10)
		if not self:knowTalent(t) then
			self.solipsism_threshold = self.solipsism_threshold - 0.1
		end
		return true
	end,
	action = function(self, t)
		self:setEffect(self.EFF_DISMISSAL, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[You dismiss 'reality' as merely a figment of your mind.  For the next %d turns you are immune to all damage and ignore new status effects.  Performing any action other then movement will reaffirm your belief in 'reality' and end the effect.
		Increases your solipsism threshold by 10%% (first point only), reducing global speed if your Psi falls below the threshold (currently %d%%).
		Each talent point invested will also increase your max Psi by 10.]]):format(duration, self.solipsism_threshold * 100)
	end,
}
