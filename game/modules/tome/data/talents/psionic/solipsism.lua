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


-- Edge TODO: Sounds, Particles

newTalent{
	name = "Solipsism",
	type = {"psionic/solipsism", 1},
	points = 5,
	require = psi_wil_req1,
	mode = "passive",
	no_unlearn_last = true,
	getConversionRatio = function(self, t) return math.min(self:getTalentLevel(t) * 0.15, 1) end,
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
		local conversion_ratio = t.getConversionRatio(self, t)
		return ([[You believe that your mind is the center of everything.  Permanently increases the amount of psi you gain per level by 10 and reduces your life rating (affects life at level up) to 0 (one time only adjustment).
		You also have learned to overcome damage with your mind alone and convert %d%% of all damage into psi damage and %d%% of your healing and life regen now recovers Psi instead of life. 
		Increases your solipsism threshold by 20%% (first point only), reducing global speed if your Psi falls below the threshold (currently %d%%).
		Each talent point invested will also increase your max Psi by 10.]]):format(conversion_ratio * 100, conversion_ratio * 100, self.solipsism_threshold * 100)
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
		return ([[You now substitute %d%% of your mental save for %d%% of your physical and spell saves throws (so at 100%% you would effectively use mental save for all saving throw rolls).
		Increases your solipsism threshold by 10%% (first point only), reducing global speed if your Psi falls below the threshold (currently %d%%).
		Each talent point invested will also increase your max Psi by 10.]]):format(ratio, ratio, self.solipsism_threshold * 100)
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
		self.clarity_threshold = t.getClarityThreshold(self, t)
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
		return ([[For every percent that your Psi pool exceeds %d%% you gain 1%% global speed (up to a maximum of 50%%).
		Increases your solipsism threshold by 10%% (first point only), reducing global speed if your Psi falls below the threshold (currently %d%%).
		Each talent point invested will also increase your max Psi by 10.]]):format(threshold * 100, self.solipsism_threshold * 100)
	end,
}

newTalent{
	name = "Dismissal",
	type = {"psionic/solipsism", 4},
	points = 5,
	require = psi_wil_req4,
	mode = "passive",
	getSavePercentage = function(self, t) return math.min(2, 0.3  + self:getTalentLevel(t)/5) end,
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
	doDismissalOnHit = function(self, value, src, t)
		local saving_throw = self:combatMindCrit(t.getSavePercentage(self, t))
		print("[Dismissal] ", self.name:capitalize(), " attempting to ignore ", value, "damage from ", src.name:capitalize(), "using", saving_throw,  "mental save.")
		if self:checkHit(math.floor(saving_throw), value) then
			game.logSeen(self, "%s dismisses %s's attack!", self.name:capitalize(), src.name:capitalize())
			return 0
		else
			return value
		end
	end,
	info = function(self, t)
		local save_percentage = t.getSavePercentage(self, t)
		return ([[Each time you take damage you roll %d%% of your mental save against it.  If the saving throw succeeds the damage will be reduced to 0.
		Increases your solipsism threshold by 10%% (first point only), reducing global speed if your Psi falls below the threshold (currently %d%%).
		Each talent point invested will also increase your max Psi by 10.]]):format(save_percentage * 100, self.solipsism_threshold * 100)
	end,
}
