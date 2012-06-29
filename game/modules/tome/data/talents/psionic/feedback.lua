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
	name = "Feedback",
	type = {"psionic/feedback", 1},
	points = 5,
	require = psi_wil_req1,
	cooldown = 10,
	psi = 10,
	tactical = { PSI = 2 },
	on_pre_use = function(self, t, silent) if self.psionic_feedback <= 0 then if not silent then game.logPlayer(self, "You have no feedback to power this talent.") end return false end return not self:hasEffect(self.EFF_REGENERATION) end,
	getConversionRatio = function(self, t) return self:combatTalentMindDamage(t, 50, 150)/100 end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			if not self.psionic_feedback then
				self.psionic_feedback = 0
			end
			self.psionic_feedback_max = (self.psionic_feedback_max or 0) + 50
		end
		return true
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self.psionic_feedback_max = self.psionic_feedback_max - 50
			if self.psionic_feedback_max <= 0 then
				self.psionic_feedback_max = nil
				self.psionic_feedback = nil
			end
		end
		return true
	end,
	action = function(self, t)
		local power = self.psionic_feedback *  t.getConversionRatio(self, t)
		self:setEffect(self.EFF_REGENERATION, 5, {power = self:mindCrit(power/5)})
		self.psionic_feedback = 0
		return true
	end,
	info = function(self, t)
		local conversion = t.getConversionRatio(self, t)
		return ([[You now store damage you take as psionic feedback.  Activating this talent removes all stored feedback, converting %d%% of the stored energy into life regen over the next five turns.
		Learning this talent will increase the amount of feedback you can store by 50 (first talent point only).
		The conversion ratio will scale with your mindpower.]]):format(conversion * 100)
	end,
}

newTalent{
	name = "Discharge",
	type = {"psionic/feedback", 2},
	points = 5, 
	require = psi_wil_req2,
	cooldown = 10,
	psi = 10,
	tactical = { DISABLE = 2},
	range = 0,
	direct_hit = true,
	requires_target = true,
	getConversionRatio = function(self, t) return 100 - math.min(50, self:combatTalentMindDamage(t, 0, 50)) end,
	getDuration = function(self, t)
		local power = (self.psionic_feedback or 0) / t.getConversionRatio(self, t)
		local duration = 1 + math.floor(power)
		return duration
	end,
	radius = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	on_pre_use = function(self, t, silent) if self.psionic_feedback <= 0 then if not silent then game.logPlayer(self, "You have no feedback to power this talent.") end return false end return true end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			if not self.psionic_feedback then
				self.psionic_feedback = 0
			end
			self.psionic_feedback_max = (self.psionic_feedback_max or 0) + 50
		end
		return true
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self.psionic_feedback_max = self.psionic_feedback_max - 50
			if self.psionic_feedback_max <= 0 then
				self.psionic_feedback_max = nil
				self.psionic_feedback = nil
			end
		end
		return true
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)

		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, math.floor(self:mindCrit(t.getDuration(self, t))), {apply_power=self:combatMindpower()})
			else
				game.logSeen(target, "%s resists the daze!", target.name:capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "light")
		end)
		
		self.psionic_feedback = 0
		
		return true
	end,
	info = function(self, t)
		local conversion = t.getConversionRatio(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Activate to discharge all stored feedback, dazing creatures in a radius of %d for 1 turn.  The duration of the effect will be increased by 1 for every %d feedback you have stored.
		Learning this talent will increase the amount of feedback you can store by 50 (first talent point only).
		The conversion ratio will scale with your mindpower.]]):format(radius, conversion)
	end,
}

newTalent{
	name = "Resonance Shield",
	type = {"psionic/feedback", 3},
	points = 5, 
	require = psi_wil_req3,
	cooldown = 15,
	psi = 10,
	tactical = { DEFEND = 2, ATTACK = {MIND = 2}},
	on_pre_use = function(self, t, silent) if self.psionic_feedback <= 0 then if not silent then game.logPlayer(self, "You have no feedback to power this talent.") end return false end return true end,
	getConversionRatio = function(self, t) return self:combatTalentMindDamage(t, 50, 150) / 100 end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			if not self.psionic_feedback then
				self.psionic_feedback = 0
			end
			self.psionic_feedback_max = (self.psionic_feedback_max or 0) + 50
		end
		return true
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self.psionic_feedback_max = self.psionic_feedback_max - 50
			if self.psionic_feedback_max <= 0 then
				self.psionic_feedback_max = nil
				self.psionic_feedback = nil
			end
		end
		return true
	end,
	action = function(self, t)
		local power = (self.psionic_feedback or 0) * t.getConversionRatio(self, t)
		self:setEffect(self.EFF_RESONANCE_SHIELD, 10, {power = self:mindCrit(power), dam = self:mindCrit(t.getDamage(self, t))})
		self.psionic_feedback = 0
		return true
	end,
	info = function(self, t)
		local conversion = t.getConversionRatio(self, t)
		local damage = t.getDamage(self, t)
		return ([[Activate to remove all stored feedback, converting %d%% of the stored energy into a resonance field that will absorb 50%% of all damage you take and inflict %0.2f mind damage to melee attackers.
		Learning this talent will increase the amount of feedback you can store by 50 (first talent point only).
		The conversion ratio will scale with your mindpower and the effect lasts up to ten turns.]]):format(conversion * 100, damDesc(self, DamageType.MIND, damage))
	end,
}

newTalent{
	name = "Feedback Loop",
	type = {"psionic/feedback", 4},
	points = 5, 
	require = psi_wil_req4,
	cooldown = 24,
	psi = 10,
	tactical = { FEEDBACK = 2 },
	getConversionRatio = function(self, t) return math.min(100, self:combatTalentMindDamage(t, 20, 100))/100 end,
	getFeedbackIncrease = function(self, t) return (self.psionic_feedback_max or 0) * t.getConversionRatio(self, t) end,
	no_energy = true,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			if not self.psionic_feedback then
				self.psionic_feedback = 0
			end
			self.psionic_feedback_max = (self.psionic_feedback_max or 0) + 50
		end
		return true
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self.psionic_feedback_max = self.psionic_feedback_max - 50
			if self.psionic_feedback_max <= 0 then
				self.psionic_feedback_max = nil
				self.psionic_feedback = nil
			end
		end
		return true
	end,
	action = function(self, t)
		self.psionic_feedback = math.min(self.psionic_feedback_max or 0, (self.psionic_feedback or 0) + t.getFeedbackIncrease(self, t))
		return true
	end,
	info = function(self, t)
		local conversion = t.getConversionRatio(self, t)
		local feedback = t.getFeedbackIncrease(self, t)
		return ([[Activate to instantly convert psi (the cost of the talent) into %d%% of your maximum feedback (currently %d).
		Learning this talent will increase the amount of feedback you can store by 50 (first talent point only).
		The feedback gain will scale with your mindpower.
		This talent takes no time to use.]]):format(conversion * 100, feedback)
	end,
}