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

local Object = require "engine.Object"

newTalent{
	name = "Lightning Speed",
	type = {"wild-gift/storm-drake", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 26,
	range = 10,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 1 end,
	action = function(self, t)
		self:setEffect(self.EFF_LIGHTNING_SPEED, math.ceil(self:mindCrit(1 + self:getTalentLevel(t) * 0.3)), {power=400 + self:getTalentLevel(t) * 70})
		return true
	end,
	info = function(self, t)
		return ([[You transform into pure lightning, moving %d%% faster for %d game turns.
		Also provides 30%% physical damage resistance and 100%% lightning resistance.
		Any actions other than moving will stop this effect.
		Note: since you will be moving very fast, game turns will pass very slowly.
		Each point in storm drake talents also increases your lightning resistance by 1%%.]]):format(400 + self:getTalentLevel(t) * 70, math.ceil(1 + self:getTalentLevel(t) * 0.3))
	end,
}

newTalent{
	name = "Static Field",
	type = {"wild-gift/storm-drake", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 20,
	cooldown = 20,
	range = 0,
	radius = 1,
	tactical = { ATTACKAREA = { instakill = 5 } },
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 1 end,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getPercent = function(self, t)
		return self:combatTalentMindDamage(t, 10, 45)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if not target:checkHit(self:combatMindpower(), target:combatPhysicalResist(), 10) then
				game.logSeen(target, "%s resists the static field!", target.name:capitalize())
				return
			end
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatMindpower())
			game.logSeen(target, "%s is caught in the static field!", target.name:capitalize())

			local perc = t.getPercent(self, t)
			if target.rank >= 5 then perc = perc / 3
			elseif target.rank >= 3.5 then perc = perc / 2
			elseif target.rank >= 3 then perc = perc / 1.5
			end

			local dam = target.life * perc / 100
			if target.life - dam < 0 then dam = target.life end
			target:takeHit(dam, self)

			game:delayedLogDamage(self, target, dam, ("#PURPLE#%d pure damage#LAST#"):format(math.ceil(dam)))
		end, nil, {type="lightning_explosion"})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t)
		return ([[Generate an electrical field around you in a radius of 1. Any creature caught inside will lose %d%% of its current life (effect decreased for higher creature ranks).
		This effect can not kill creatures.
		Life loss will increase with your Mindpower.
		Each point in storm drake talents also increases your lightning resistance by 1%%.]]):format(percent)
	end,
}

newTalent{
	name = "Tornado",
	type = {"wild-gift/storm-drake", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 14,
	cooldown = 15,
	proj_speed = 2, -- This is purely indicative
	tactical = { ATTACK = { LIGHTNING = 2 }, DISABLE = { stun = 2 } },
	range = function(self, t) return 4 + math.floor(self:getTalentLevel(t)) end,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 1 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		local movedam = self:mindCrit(self:combatTalentMindDamage(t, 10, 110))
		local dam = self:mindCrit(self:combatTalentMindDamage(t, 15, 190))

		local proj = require("engine.Projectile"):makeHoming(
			self,
			{particle="bolt_lightning", trail="lightningtrail"},
			{speed=2, name="Tornado", dam=dam, movedam=movedam},
			target,
			self:getTalentRange(t),
			function(self, src)
				local DT = require("engine.DamageType")
				DT:get(DT.LIGHTNING).projector(src, self.x, self.y, DT.LIGHTNING, self.def.movedam)
			end,
			function(self, src, target)
				local DT = require("engine.DamageType")
				src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DT.LIGHTNING, self.def.dam)
				src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DT.MINDKNOCKBACK, self.def.dam)
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, 4, {apply_power=src:combatMindpower()})
				else
					game.logSeen(target, "%s resists the tornado!", target.name:capitalize())
				end

				-- Lightning ball gets a special treatment to make it look neat
				local sradius = (1 + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
				local nb_forks = 16
				local angle_diff = 360 / nb_forks
				for i = 0, nb_forks - 1 do
					local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
					local tx = self.x + math.floor(math.cos(a) * 1)
					local ty = self.y + math.floor(math.sin(a) * 1)
					game.level.map:particleEmitter(self.x, self.y, 1, "lightning", {radius=1, tx=tx-self.x, ty=ty-self.y, nb_particles=25, life=8})
				end
				game:playSoundNear(self, "talents/lightning")
			end
		)
		game.zone:addEntity(game.level, proj, "projectile", self.x, self.y)
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		return ([[Summons a tornado that moves slowly toward its target, following it if it changes position.
		Any foe caught in its path take %0.2f lightning damage.
		When it reaches its target it explodes in a radius of 1 for %0.2f lightning damage, %0.2f physical damage. All affected creatures will be knocked back and the targeted creature will be stunned for 4 turns.
		The tornado will last for %d turns or until it reaches its target.
		Damage will increase with your Mindpower.
		Each point in storm drake talents also increases your lightning resistance by 1%%.]]):format(
			damDesc(self, DamageType.LIGHTNING, self:combatTalentMindDamage(t, 10, 110)),
			damDesc(self, DamageType.LIGHTNING, self:combatTalentMindDamage(t, 15, 190)),
			damDesc(self, DamageType.PHYSICAL, self:combatTalentMindDamage(t, 15, 190)),
			6 + math.ceil(self:getTalentLevel(t) * 2)
		)
	end,
}

newTalent{
	name = "Lightning Breath",
	type = {"wild-gift/storm-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes lightning!",
	tactical = { ATTACKAREA = {LIGHTNING = 2}, DISABLE = { stun = 1 } },
	range = 0,
	radius = function(self, t) return 4 + self:getTalentLevelRaw(t) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 1 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t)
		return self:combatTalentStatDamage(t, "str", 30, 500)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.LIGHTNING_DAZE, rng.avg(dam / 3, dam, 3))

		local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
		local nb_forks = 24
		local angle_diff = 55 / nb_forks
		local base_a = math.deg(math.atan2(y-self.y, x-self.x)) - 27.5
		for i = 0, nb_forks - 1 do
			local a = math.rad(rng.range(base_a+i*angle_diff,base_a+angle_diff+i*angle_diff))
			local tx = x + math.floor(math.cos(a) * tg.radius)
			local ty = y + math.floor(math.sin(a) * tg.radius)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "lightning", {radius=tg.radius, grids=grids, tx=tx-x, ty=ty-y, nb_particles=25, life=12})
		end

		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You breathe lightning in a frontal cone of radius %d. Any target caught in the area will take %0.2f to %0.2f lightning damage and can be dazed for 3 turns.
		The damage will increase with the Strength stat.
		Each point in storm drake talents also increases your lightning resistance by 1%%.]]):format(
			self:getTalentRadius(t),
			damDesc(self, DamageType.LIGHTNING, damage / 3),
			damDesc(self, DamageType.LIGHTNING, damage)
		)
	end,
}
