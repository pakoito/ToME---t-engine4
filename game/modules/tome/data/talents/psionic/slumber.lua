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
	name = "Sleep",
	type = {"psionic/slumber", 1},
	points = 5, 
	require = psi_wil_req1,
	cooldown = 5,
	tactical = { DISABLE = 2},
	range = 0,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 150) end,
	radius = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	on_pre_use = function(self, t, silent) if self.psionic_feedback <= 0 then if not silent then game.logPlayer(self, "You have no feedback to power this talent.") end return false end return true end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			if not self.psionic_feedback then
				self.psionic_feedback = 0
			end
			self.psionic_feedback_max = (self.psionic_feedback_max or 0) + 100
		end
		return true
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self.psionic_feedback_max = self.psionic_feedback_max - 100
			if self.psionic_feedback_max <= 0 then
				self.psionic_feedback_max = nil
				self.psionic_feedback = nil
			end
		end
		return true
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		
		local damage = math.min(self.psionic_feedback, t.getDamage(self, t))
		self:project(tg, x, y, DamageType.MIND, {dam=self:mindCrit(damage), crossTierChance=math.max(100, damage)})
		
		self.psionic_feedback = self.psionic_feedback - damage
							
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[You now store damage you take from outside sources as psionic feedback.  Activate to slumber up to %0.2f feedback in a %d radius cone.  Targets in the area will suffer mind damage and may be brain locked by this attack.
		Learning this talent will increase the amount of feedback you can store by 100 (first talent point only).
		The damage will scale with your mindpower.]]):format(damage, radius)
	end,
}

newTalent{
	name = "Fitful Slumber",
	type = {"psionic/slumber", 2},
	points = 5, 
	require = psi_wil_req2,
	mode = "sustained",
	sustain_psi = 20,
	cooldown = 18,
	tactical = { BUFF = 2 },
	getMaxOverflow = function(self, t) return self.psionic_feedback_max * (self:combatTalentMindDamage(t, 20, 100)/100) end,
	radius = function(self, t) return math.ceil(self:getTalentLevel(t)/2) end,
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
	doOverflowslumber = function(self, t)
		local tg = {type="ball", range=0, radius=self:getTalentRadius(t), selffire=false, friendlyfire=false}
		local damage = self.psionic_overflow
		self:project(tg, self.x, self.y, DamageType.MIND, self:mindCrit(damage))
		-- Lose remaining overflow
		self.psionic_overflow = nil
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/flame")
		return {
			ov = self:addTemporaryValue("psionic_overflow_max", t.getMaxOverflow(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("psionic_overflow_max", p.ov)
		return true
	end,
	info = function(self, t)
		local overflow = t.getMaxOverflow(self, t)
		local radius = self:getTalentRadius(t)
		return ([[While active you store up to %d excess feedback as overflow.  At the start of your turn the overflow will be unleased as mind damage in a radius of %d.
		Learning this talent will increase the amount of feedback you can store by 50 (first talent point only).
		The max excess you can store will improve with your mindpower and max feedback.]]):format(overflow, radius)
	end,
}

newTalent{
	name = "Contagious Slumber",
	type = {"psionic/slumber", 3},
	points = 5,
	require = psi_wil_req3,
	cooldown = 10,
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = { knockback = 2 }, },
	range = 0,
	radius = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 230) end,
	on_pre_use = function(self, t, silent) if self.psionic_feedback <= 0 then if not silent then game.logPlayer(self, "You have no feedback to power this talent.") end return false end return not self:hasEffect(self.EFF_REGENERATION) end,
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
		if not x or not y then return nil end
		
		local damage = math.min(self.psionic_feedback, t.getDamage(self, t))
		self:project(tg, x, y, DamageType.MINDKNOCKBACK, self:mindCrit(damage))
		self.psionic_feedback = self.psionic_feedback - damage
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Activate to convert up to %0.2f of stored feedback into a blast of kinetic energy.  Targets out to a radius of %d will suffer physical damage and may be knocked back.
		Learning this talent will increase the amount of feedback you can store by 50 (first talent point only).
		The damage will scale with your mindpower.]]):format(damDesc(self, DamageType.PHYSICAL, damage), radius)
	end,
}

newTalent{
	name = "Sandman",
	type = {"psionic/slumber", 4},
	points = 5, 
	require = psi_wil_req4,
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
			self.psionic_feedback_max = (self.psionic_feedback_max or 0) + 100
		end
		return true
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self.psionic_feedback_max = self.psionic_feedback_max - 100
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
		return ([[Activate to conver up to %0.2f feedback into a resonance shield that will absorb 50%% of all damage you take and inflict %0.2f mind damage to melee attackers.
		Learning this talent will increase the amount of feedback you can store by 100 (first talent point only).
		The conversion ratio will scale with your mindpower and the effect lasts up to ten turns.]]):format(shield_power, damDesc(self, DamageType.MIND, damage))
	end,
}