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

newTalent{
	name = "Biofeedback",
	type = {"psionic/feedback", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "passive",
	getHealRatio = function(self, t) return 0.5 + self:combatTalentMindDamage(t, 0.1, 1)end,
	info = function(self, t)
		local heal = t.getHealRatio(self, t)
		return ([[Your Feedback decay now heals you for %d%% of the loss.
		The healing effect will scale with your mindpower.]]):format(heal*100)
	end,
}

newTalent{
	name = "Resonance Field",
	type = {"psionic/feedback", 2},
	points = 5,
	feedback = 25,
	require = psi_wil_req2,
	cooldown = 15,
	tactical = { DEFEND = 2},
	no_break_channel = true,
	getShieldPower = function(self, t) return self:combatTalentMindDamage(t, 30, 470) end,
	action = function(self, t)
		self:setEffect(self.EFF_RESONANCE_FIELD, 10, {power = self:mindCrit(t.getShieldPower(self, t))})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local shield_power = t.getShieldPower(self, t)
		return ([[Activate to create a resonance field that will absorb 50%% of all damage you take (%d max absorption).  The field will not interfere with Feedback gain.
		Using this talent will not break psionic channels (such as Mind Storm).
		The max absorption value will scale with your mindpower and the effect lasts up to ten turns.]]):format(shield_power)
	end,
}

newTalent{
	name = "Amplification",
	type = {"psionic/feedback", 3},
	points = 5,
	require = psi_wil_req3,
	mode = "passive",
	getFeedbackGain = function(self, t) return 0.5 + self:combatTalentMindDamage(t, 0.1, 0.5) end,
	getMaxFeedback = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	on_learn = function(self, t)
		self:incMaxFeedback(10)
	end,
	on_unlearn = function(self, t)
		self:incMaxFeedback(-10)
	end,
	info = function(self, t)
		local max_feedback = t.getMaxFeedback(self, t)
		local gain = t.getFeedbackGain(self, t)
		return ([[Increases your maximum Feedback by %d and increases your base Feedback gain ratio to %d%%.
		The Feedback gain will scale with your mindpower.]]):format(max_feedback, gain * 100)
	end,
}

newTalent{
	name = "Conversion",
	type = {"psionic/feedback", 4},
	points = 5,
	feedback = 25,
	require = psi_wil_req4,
	cooldown = 24,
	no_break_channel = true,
	is_heal = true,
	tactical = { MANA = 2, VIM = 2, EQUILIBRIUM = 2, STAMINA = 2, POSITIVE = 2, NEGATIVE = 2, PSI = 2, HATE = 2 },
	getConversion = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getData = function(self, t)
		local base = t.getConversion(self, t)
		return {
			heal = base * 10,
			stamina = base,
			mana = base * 1.8,
			equilibrium = -base * 1.5,
			vim = base,
			positive = base / 2,
			negative = base / 2,
			psi = base * 0.7,
			hate = base / 4,
		}
	end,
	action = function(self, t)
		local data = t.getData(self, t)
		for name, v in pairs(data) do
			local inc = "inc"..name:capitalize()
			if name == "heal" then
				self:heal(self:mindCrit(v))
			elseif
				self[inc] then self[inc](self, v) 
			end
		end
		game.level.map:particleEmitter(self.x, self.y, 1, "generic_charge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local data = t.getData(self, t)
		return ([[Use Feedback to replinish yourself.  Heals you for %d life and restores %d stamina, %d mana, %d equilibrium, %d vim, %d positive and negative energies, %d psi energy, and %d hate.
		Using this talent will not break psionic channels (such as Mind Storm).
		The heal and resource gain will improve with your mindpower.]]):format(data.heal, data.stamina, data.mana, -data.equilibrium, data.vim, data.positive, data.psi, data.hate)
	end,
}
