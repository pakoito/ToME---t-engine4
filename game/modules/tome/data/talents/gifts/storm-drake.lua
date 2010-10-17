-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	range = 20,
	tactical = {
		ATTACK = 10,
	},
	requires_target = true,
	action = function(self, t)
		self:setEffect(self.EFF_LIGHTNING_SPEED, math.ceil(6 + self:getTalentLevel(t) * 1.2), {power=400 + self:getTalentLevel(t) * 70})
		return true
	end,
	info = function(self, t)
		return ([[You transform into pure lightning, moving %d%% faster for %d turns.
		Any actions other than moving will stop this effect.]]):format(400 + self:getTalentLevel(t) * 70, math.ceil(6 + self:getTalentLevel(t) * 1.2))
	end,
}

newTalent{
	name = "???",
	type = {"wild-gift/storm-drake", 2},
	require = gifts_req2,
	mode = "sustained",
	points = 5,
	sustain_equilibrium = 30,
	cooldown = 10,
	range = 20,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.COLD]=5 * self:getTalentLevel(t)}),
			armor = self:addTemporaryValue("combat_armor", 4 * self:getTalentLevel(t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("combat_armor", p.armor)
		return true
	end,
	info = function(self, t)
		return ([[Your skin forms icy scales, damaging all that hit you for %d cold damage and increasing your armor by %d.]]):format(damDesc(self, DamageType.C, 5 * self:getTalentLevel(t)), 4 * self:getTalentLevel(t))
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
	range = function(self, t) return 6 + math.ceil(self:getTalentLevel(t) * 2) end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		local movedam = self:combatTalentMindDamage(t, 10, 60)
		local dam = self:combatTalentMindDamage(t, 15, 130)

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
				src:project({type="ball", radius=1}, self.x, self.y, DT.LIGHTNING, self.def.dam)
				src:project({type="ball", radius=1}, self.x, self.y, DT.MINDKNOCKBACK, self.def.dam)
				if target:checkHit(src:combatMindpower(), target:combatPhysicalResist(), 10) and target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, 4, {})
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
		Damage will increase with your Willpower.]]):format(
			damDesc(self, DamageType.LIGHTNING, self:combatTalentMindDamage(t, 10, 60)),
			damDesc(self, DamageType.LIGHTNING, self:combatTalentMindDamage(t, 15, 130)),
			damDesc(self, DamageType.PHYSICAL, self:combatTalentMindDamage(t, 15, 130)),
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
	tactical = {
		ATTACKAREA = 10,
	},
	range = function(self, t) return 4 + self:getTalentLevelRaw(t) end,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=self:getTalentRange(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = 40 + self:getStr(80) * self:getTalentLevel(t)
		self:project(tg, x, y, DamageType.LIGHTNING_DAZE, rng.avg(dam / 3, dam, 3), {type="lightning_explosion"})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[You breathe lightning in a frontal cone. Any target caught in the area will take %0.2f to %0.2f lightning damage and can be dazed for a few turns.
		The damage will increase with the Strength stat]]):format(
			damDesc(self, DamageType.LIGHTNING, 40 + self:getStr(80) * self:getTalentLevel(t)),
			damDesc(self, DamageType.LIGHTNING, 40 + self:getStr(80) * self:getTalentLevel(t))
		)
	end,
}
