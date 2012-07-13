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
	cooldown = 8,
	psi = 5,
	tactical = { DISABLE = 2},
	direct_hit = true,
	requires_target = true,
	range = function(self, t) return 5 + math.min(5, self:getTalentLevelRaw(t)) end,
	radius = function(self, t) return 1 + math.floor(self:getTalentLevel(t)/4) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)/2) end,
	getInsomniaDuration = function(self, t)
		local t = self:getTalentFromId(self.T_SANDMAN)
		local reduction = t.getInsomniaReduction(self, t)
		return 10 - reduction
	end,
	getSleepPower = function(self, t) 
		local power = self:combatTalentMindDamage(t, 10, 50)
		if self:knowTalent(self.T_SANDMAN) then
			local t = self:getTalentFromId(self.T_SANDMAN)
			power = power + t.getSleepPowerBonus(self, t)
		end
		return power
	end,
	doContagiousSlumber = function(self, target, p, t)
		local tg = {type="ball", radius=self:getTalentRadius(t), talent=t}
		self:project(tg, target.x, target.y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target and self:reactionToward(target) < 0 and rng.percent(p.contagious) and target:canBe("sleep") and not target:attr("sleep") then
				target:setEffect(target.EFF_SLEEP, math.floor(p.dur/2), {src=self, power=p.power, contagious=p.contagious/2, insomnia=math.ceil(p.insomnia/2), no_ct_effect=true, apply_power=self:combatMindpower()})
			end
		end)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		--Contagious?
		local is_contagious = 0
		if self:getTalentLevel(self.T_SANDMAN) > 5 then
			is_contagious = 25
		end
		--Sandman?
		local power = self:mindCrit(t.getSleepPower(self, t))
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target and not target:attr("sleep") then
				if target:canBe("sleep") then
					target:setEffect(target.EFF_SLEEP, t.getDuration(self, t), {src=self, power=power, contagious=is_contagious, insomnia=t.getInsomniaDuration(self, t), no_ct_effect=true, apply_power=self:combatMindpower()})
				else
					game.logSeen(self, "%s resists the sleep!", target.name:capitalize())
				end
			end
		end)
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		local power = t.getSleepPower(self, t)
		local insomnia = t.getInsomniaDuration(self, t)
		return([[Puts targets in a radius of %d to sleep for %d turns, rendering them unable to act.  Every %d points of damage the target suffers will reduce the effect duration by one turn.
		When Sleep ends the target will suffer from Insomnia for %d turns, rendering them resistant to Sleep effects.
		The damage threshold will scale with your mindpower.]]):format(radius, duration, power, insomnia)
	end,
}

newTalent{
	name = "Sandman",
	type = {"psionic/slumber", 2},
	points = 5, 
	require = psi_wil_req2,
	mode = "passive",
	getSleepPowerBonus = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getInsomniaReduction = function(self, t) return math.min(8, math.floor(self:getTalentLevel(self.T_SANDMAN))) end,
	info = function(self, t)
		local power_bonus = t.getSleepPowerBonus(self, t)
		local reduction = t.getInsomniaReduction(self, t)
		return([[Increases the amount of damage you can deal to sleeping targets before rousing them by %d and reduces the duration of the Insomnia effect by %d turns.
		At talent level 5 the Sleep will become contagious and has a 25%% chance to spread to nearby targets each turn.
		These effects will be directly reflected in the Sleep talent description.
		The damage threshold bonus will scale with your mindpower.]]):format(power_bonus, reduction)
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
	name = "Sleep4",
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