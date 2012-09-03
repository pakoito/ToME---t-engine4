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
	name = "Mind Storm",
	type = {"psionic/discharge", 1},
	points = 5, 
	require = psi_wil_high1,
	sustain_feedback = 0,
	mode = "sustained",
	cooldown = 12,
	tactical = { ATTACKAREA = {MIND = 2}},
	requires_target = true,
	proj_speed = 10,
	range = 7,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, friendlyblock=false, display={particle="discharge_bolt", trail="lighttrail"}}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	getTargetCount = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	getOverchargeRatio = function(self, t) return 20 - math.ceil(self:getTalentLevel(t)) end,
	doMindStorm = function(self, t, p)
		local tgts = {}
		local tgts_oc = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
				tgts_oc[#tgts_oc+1] = a
			end
		end end	
		
		local wrath = self:hasEffect(self.EFF_FOCUSED_WRATH)
		
		-- Randomly take targets
		local tg = self:getTalentTarget(t)
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 or self:getFeedback() < 5 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			-- Divert the Bolt?
			if wrath then
				self:projectile(tg, wrath.target.x, wrath.target.y, DamageType.MIND, self:mindCrit(t.getDamage(self, t), nil, wrath.power))
			else
				self:projectile(tg, a.x, a.y, DamageType.MIND, self:mindCrit(t.getDamage(self, t)))
			end
			self:incFeedback(-5)
		end
		
		-- Randomly take overcharge targets
		local tg = self:getTalentTarget(t)
		if p.overcharge >= 1 then
			for i = 1, math.min(p.overcharge, t.getTargetCount(self, t)) do
				if #tgts_oc <= 0 then break end
				local a, id = rng.table(tgts_oc)
				table.remove(tgts_oc, id)
				-- Divert the Bolt?
				if wrath then
					self:projectile(tg, wrath.target.x, wrath.target.y, DamageType.MIND, self:mindCrit(t.getDamage(self, t), nil, wrath.power))
				else
					self:projectile(tg, a.x, a.y, DamageType.MIND, self:mindCrit(t.getDamage(self, t)))
				end
			end
		end
			
		p.overcharge = 0
		
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/thunderstorm")
		local ret = {
			overcharge = 0,
			particles = self:addParticles(Particles.new("ultrashield", 1, {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90, radius=0.2, density=15, life=28, instop=10}))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particles)
		return true
	end,
	info = function(self, t)
		local targets = t.getTargetCount(self, t)
		local damage = t.getDamage(self, t)
		local charge_ratio = t.getOverchargeRatio(self, t)
		return ([[Unleash your subconscious on the world around you.  While active you fire up to %d bolts each turn (one per hostile target) that deal %0.2f mind damage.  Each bolt consumes 1 Feedback.
		Feedback gains beyond your maximum allowed amount may generate extra bolts (one bolt per %d excess Feedback per target), but no more then %d extra bolts per turn.
		This effect is a psionic channel and will break if you move, use a talent that consumes a turn, or activate an item.
		The damage will scale with your mindpower.]]):format(targets, damDesc(self, DamageType.MIND, damage), charge_ratio, targets)
	end,
}

newTalent{
	name = "Feedback Loop",
	type = {"psionic/discharge", 2},
	points = 5, 
	require = psi_wil_high2,
	cooldown = 24,
	tactical = { FEEDBACK = 2 },
	no_break_channel = true,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t) * 1.5) end,
	on_pre_use = function(self, t, silent) if self:getFeedback() <= 0 then if not silent then game.logPlayer(self, "You have no feedback to start a feedback loop!") end return false end return true end,
	action = function(self, t)
		local wrath = self:hasEffect(self.EFF_FOCUSED_WRATH)
		self:setEffect(self.EFF_FEEDBACK_LOOP, self:mindCrit(t.getDuration(self, t), nil, wrath and wrath.power or 0), {})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Activate to invert your Feedback decay for %d turns.  This effect can be a critical hit, increasing the duration even further.
		Using this talent will not break psionic channels (such as Mind Storm).  You must have some Feedback in order to start the loop.
		The maximum Feedback gain will scale with your mindpower.]]):format(duration)
	end,
}

newTalent{
	name = "Backlash",
	type = {"psionic/discharge", 3},
	points = 5, 
	require = psi_wil_high3,
	mode = "passive",
	range = 7,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 75) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	doBacklash = function(self, target, value, t)
		self.no_backlash_loops = true
		if core.fov.distance(self.x, self.y,target.x, target.y) > self:getTalentRange(t) then return nil end
		local tg = self:getTalentTarget(t)
		local a = game.level.map(target.x, target.y, Map.ACTOR)
		if not a or self:reactionToward(a) >= 0 then return nil end
		local damage = math.min(value, t.getDamage(self, t))
		-- Divert the Backlash?
		local wrath = self:hasEffect(self.EFF_FOCUSED_WRATH)
		if damage > 0 then
			if wrath then
				self:project(tg, wrath.target.x, wrath.target.y, DamageType.MIND, self:mindCrit(damage, nil, wrath.power), nil, true) -- No Martyr loops
				game.level.map:particleEmitter(wrath.target.x, wrath.target.y, 1, "generic_discharge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
			else
				self:project(tg, a.x, a.y, DamageType.MIND, self:mindCrit(damage), nil, true) -- No Martyr loops
				game.level.map:particleEmitter(a.x, a.y, 1, "generic_discharge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
			end
		end
		self.no_backlash_loops = nil
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local damage = t.getDamage(self, t)
		return ([[Your subconscious now retaliates when you take damage.  If the attacker is within range (%d) you'll inflict mind damage equal to the Feedback gained from the attack or %0.2f, whichever is lower.
		The damage will scale with your mindpower.]]):format(range, damDesc(self, DamageType.MIND, damage))
	end,
}

newTalent{
	name = "Focused Wrath",   
	type = {"psionic/discharge", 4},
	points = 5, 
	require = psi_wil_high4,
	feedback = 25,
	cooldown = 12,
	tactical = { ATTACK = {MIND = 2}},
	range = 7,
	getCritBonus = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t)}
	end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)) end,
	direct_hit = true,
	requires_target = true,
	no_break_channel = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		_, x, y = self:canProject(tg, x, y)
		local target = x and game.level.map(x, y, engine.Map.ACTOR) or nil
		if not target or target == self then return nil end
		
		self:setEffect(self.EFF_FOCUSED_WRATH, t.getDuration(self, t), {target=target, power=t.getCritBonus(self, t)/100})

		game.level.map:particleEmitter(self.x, self.y, 1, "generic_charge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local crit_bonus = t.getCritBonus(self, t)
		return ([[Focus your mind on a single target, diverting all offensive Discharge talent effects to it for %d turns.  While this effect is active all Discharge talents gain %d%% critical power.
		Using this talent will not break psionic channels (such as Mind Storm).  If the target is killed the effect will end early.
		The damage bonus will scale with your mindpower.]]):format(duration, damDesc(self, DamageType.MIND, crit_bonus))
	end,
}