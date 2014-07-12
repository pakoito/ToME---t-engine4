-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

-- EDGE TODO: Particles, Timed Effect Particles

newTalent{
	name = "Disentangle",
	type = {"chronomancy/fate-threading", 1},
	require = chrono_req1,
	points = 5,
	cooldown = 12,
	tactical = { PARADOX = 2 },
	getReduction = function(self, t) return self:combatTalentSpellDamage(t, 20, 80, getParadoxSpellpower(self)) end,
	getParadoxMulti = function(self, t) return self:combatTalentLimit(t, 2, 0.10, .75) end,
	anomaly_type = "no-major",
	no_energy = true,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "anomaly_paradox_recovery", t.getParadoxMulti(self, t))
	end,
	action = function(self, t)
		local reduction = self:spellCrit(t.getReduction(self, t))
		self:paradoxDoAnomaly(reduction, t.anomaly_type, "forced")
		return true
	end,
	info = function(self, t)
		local reduction = t.getReduction(self, t)
		local paradox = 100 * t.getParadoxMulti(self, t)
		return ([[Disentangle the timeline, reducing your Paradox by %d and creating an anomaly.  This spell will never produce a major anomaly.
		Additionally you recover %d%% more Paradox from random anomalies (%d%% total).
		The Paradox reduction will increase with your Spellpower.]]):format(reduction, paradox, paradox + 200)
	end,
}

newTalent{
	name = "Trim Threads",
	type = {"chronomancy/fate-threading", 2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 4,
	tactical = { ATTACKAREA = { TEMPORAL = 2 } },
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 300, getParadoxSpellpower(self)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	requires_target = true,
	direct_hit = true,
	doAnomaly = function(self, t, target, eff)
		self:project({type=hit}, target.x, target.y, DamageType.TEMPORAL, eff.power * eff.dur)
		target:removeEffect(target.EFF_TRIM_THREADS)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local damage = self:spellCrit(t.getDamage(self, t))
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_TRIM_THREADS, 3, {power=damage/3, src=self, apply_power=getParadoxSpellpower(self)})
		end)

		game.level.map:particleEmitter(x, y, tg.radius, "temporal_flash", {radius=tg.radius})

		game:playSoundNear(self, "talents/teleport")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Deals %0.2f temporal damage over three turns to all targets in a radius of %d.  If the target is hit by an Anomaly the remaining damage will be done instantly.
		The damage will scale with your Spellpower.]]):format(damDesc(self, DamageType.TEMPORAL, damage), radius)
	end,
}

newTalent{
	name = "Bias Weave",
	type = {"chronomancy/fate-threading", 3},
	require = chrono_req3,
	points = 5,
	cooldown = 10,
	-- Anomaly biases can be set manually for monsters
	-- Use the following format anomaly_bias = { type = "teleport", chance=50}
	on_pre_use = function(self, t, silent) if not self == game.player then return false end	return true end,
	getBiasChance = function(self, t) return self:combatTalentLimit(t, 100, 10, 75) end,
	getTargetChance = function(self, t) return self:combatTalentLimit(t, 100, 10, 75) end,
	getAnomalySpeed = function(self, t) return self:combatTalentLimit(t, 1, 0.10, .75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "anomaly_recovery_speed", t.getAnomalySpeed(self, t))
	end,
	on_learn = function(self, t)
		if self.anomaly_bias and self.anomaly_bias.chance then
			self.anomaly_bias.chance = t.getBiasChance(self, t)
		end
	end,
 	on_unlearn = function(self, t)
		if self:getTalentLevel(t) == 0 then
			self.anomaly_bias = nil
		elseif self.anomaly_bias and self.anomaly_bias.chance then
			self.anomaly_bias.chance = t.getBiasChance(self, t)
		end
 	end,
	action = function(self, t)
		local state = {}
		local Chat = require("engine.Chat")
		local chat = Chat.new("chronomancy-bias-weave", {name="Bias Weave"}, self, {version=self, state=state})
		local d = chat:invoke()
		local co = coroutine.running()
		d.unload = function() coroutine.resume(co, state.set_bias) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local target_chance = t.getTargetChance(self, t)
		local bias_chance = t.getBiasChance(self, t)
		local anomaly_recovery = t.getAnomalySpeed(self, t) * 100
		return ([[You've learned to focus most anomalies when they occur and may choose the target area with %d%% probability.
		You also may bias the type of anomaly effects you produce with %d%% probability.
		Additionally random anomalies only cost you %d%% of a turn rather than a full turn when they occur.
		Major anomalies, those occuring when your modified Paradox is over 600, are not affected by this talent.]]):format(target_chance, bias_chance, anomaly_recovery)
	end,
}

newTalent{
	name = "Preserve Pattern",
	type = {"chronomancy/fate-threading", 4},
	require = chrono_req4,
	points = 5,
	mode = "sustained",
	sustain_paradox = 48,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 15, 45, 25)) end, -- Limit >15
	tactical = { DEFEND = 2 },
	getHeal = function(self, t) return self.max_life * self:combatTalentLimit(t, 1.5, 0.09, 0.4) end, -- Limit < 150% max life (to survive a large string of hits between turns)
	callbackOnHit = function(self, t, cb)
		local p = self:isTalentActive(t.id)
		
		if p and p.rest_count <= 0 and cb.value >= self.life then
			-- Save them from the hit and heal up
			cb.value = 0
			self.life = 1
			self:heal(t.getHeal(self, t))
			
			-- Make them invulnerable so they don't die to anomalies
			game.logSeen(self, "#STEEL_BLUE#%s is rapidly shunted into another timeline!#LAST#", self.name:capitalize())
			local invuln = self.invulnerable
			self.invulnerable = 1
			
			-- Make some anomalies and remove invulnerability
			for i = 1, rng.avg(3, 6, 3) do self:paradoxDoAnomaly(0, nil, "forced", self, true) end
			self.invulnerable = invuln
			
			-- Set the counter on the sustain
			p.rest_count = self:getTalentCooldown(t)
			if self.player then world:gainAchievement("AVOID_DEATH", self) end
		end
		
		return cb.value
	end,
	callbackOnActBase = function(self, t)
		local p = self:isTalentActive(t.id)
		if p.rest_count > 0 then p.rest_count = p.rest_count - 1 end
	end,
	iconOverlay = function(self, t, p)
		local val = p.rest_count or 0
		if val <= 0 then return "" end
		local fnt = "buff_font"
		return tostring(math.ceil(val)), fnt
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = { rest_count = 0 }
	--[[if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.6, rotation=0, radius=2, img="flamesgeneric"}, {type="sunaura", time_factor=6000}))
		else
			ret.particle = self:addParticles(Particles.new("golden_shield", 1))
		end]]
		return ret
	end,
	deactivate = function(self, t, p)
	--	self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		local cooldown = self:getTalentCooldown(t)
		return ([[Any attack that would drop you below 1 hit point instead triggers Preserve Pattern, setting your life to 1, then healing you for %d.
		This effect causes three to six anomalies to occur as you move from timeline to timeline until you find one in which you're still alive.
		These anomalies may not be targeted though they may be biased.  This effect can only occur once every %d turns.]]):format(heal, cooldown)
	end,
}