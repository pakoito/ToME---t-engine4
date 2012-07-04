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

-- Edge TODO: Sounds, Particles, Talent Icons; All Talents

newTalent{
	name = "Feedback",
	type = {"psionic/feedback", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "passive",
	dont_provide_pool = true,
	getConversionRatio = function(self, t) return (50 + self:combatTalentMindDamage(t, 10, 100)) / 100 end,
	on_learn = function(self, t)
		self:incMaxFeedback(10)
		return true
	end,
	on_unlearn = function(self, t)
		self:incMaxFeedback(-10)
		return true
	end,
	info = function(self, t)
		local conversion = t.getConversionRatio(self, t)
		return ([[You channel your pain, gaining %d%% of all damage you take from outside sources as Psionic Feedback.  When using powers that require Psi you'll spend Feedback first if you have any.
		Each talent point invested will increase the amount of feedback you can store by 10 and Feedback will decay at the rate of 10%% or 1 per turn, whichever is greater.
		The conversion ratio will scale with your mindpower.]]):format(conversion * 100)
	end,
}

newTalent{
	name = "Resonance Shield",
	type = {"psionic/feedback", 3},
	points = 5,
	feedback = 10,
	require = psi_wil_req3,
	cooldown = 15,
	tactical = { DEFEND = 2, ATTACK = {MIND = 2}},
	on_pre_use = function(self, t, silent) if self.psionic_feedback <= 0 then if not silent then game.logPlayer(self, "You have no feedback to power this talent.") end return false end return true end,
	getShieldPower = function(self, t) return self:combatTalentMindDamage(t, 20, 300) end,
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
		local power = math.min(self.psionic_feedback, t.getShieldPower(self, t))
		self:setEffect(self.EFF_RESONANCE_SHIELD, 10, {power = self:mindCrit(power), dam = t.getDamage(self, t)})
		self.psionic_feedback = self.psionic_feedback - power
		return true
	end,
	info = function(self, t)
		local shield_power = t.getShieldPower(self, t)
		local damage = t.getDamage(self, t)
		return ([[Activate to convert up to %0.2f feedback into a resonance shield that will absorb 50%% of all damage you take and inflict %0.2f mind damage to melee attackers.
		Learning this talent will increase the amount of feedback you can store by 50 (first talent point only).
		The conversion ratio will scale with your mindpower and the effect lasts up to ten turns.]]):format(shield_power, damDesc(self, DamageType.MIND, damage))
	end,
}

