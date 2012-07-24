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

local Object = require "mod.class.Object"

newTalent{
	name = "Distortion Bolt",
	type = {"psionic/distortion", 1},
	points = 5, 
	require = psi_wil_req1,
	cooldown = 2,
	psi = 5,
	tactical = { ATTACK = { PHYSICAL = 2} },
	range = 10,
	radius = function(self, t) return 1 + math.floor(self:getTalentLevel(t)/2) end,
	requires_target = true,
	proj_speed = 20,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	getDetonateDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 200) end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_void", trail="dust_trail"}}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.DISTORTION, {dam=self:mindCrit(t.getDamage(self, t)), explosion=t.getDetonateDamage(self, t), penetrate=true, radius=self:getTalentRadius(t)})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local detonate_damage = t.getDetonateDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Fire a bolt of distortion that ignores resistance and inflicts %0.2f physical damage.  This damage will distort affected targets, rendering them vulnerable to distortion effects.
		If the bolt comes in contact with a target that's already distorted a detonation will occur, inflicting %0.2f physical damage and knocking back all targets in a %d radius.
		The damage will scale with your mindpower.]]):format(damDesc(self, DamageType.PHYSICAL, damage), damDesc(self, DamageType.PHYSICAL, detonate_damage), radius)
	end,
}

newTalent{
	name = "Distortion Wave",
	type = {"psionic/distortion", 2},
	points = 5, 
	require = psi_wil_req2,
	cooldown = 6,
	psi = 10,
	tactical = { ATTACK = { PHYSICAL = 2}, DISABLE = 2},
	range = 0,
	radius = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)/2) end,
	requires_target = true,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 150) end,
	getPower = function(self, t) return math.ceil(self:getTalentRadius(t)/2) end,
	target = function(self, t)
		return { type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t }
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.DISTORTION, {dam=self:mindCrit(t.getDamage(self, t)), knockback=t.getPower(self, t), stun=t.getPower(self, t)}, {type="mind"})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local power = t.getPower(self, t)
		return ([[Creates a distortion wave in a radius %d cone that deals %0.2f physical damage and knocks back targets in the blast radius.
		This damage will distort affected targets, rendering them vulnerable to distortion effects.
		If the target is already distorted they'll be stunned for %d turns as well.
		The damage will scale with your mindpower.]]):format(radius, damDesc(self, DamageType.PHYSICAL, damage), power)
	end,
}

newTalent{
	name = "Ravage",
	type = {"psionic/distortion", 3},
	points = 5, 
	require = psi_wil_req3,
	cooldown = 12,
	psi = 20,
	tactical = { ATTACK = { PHYSICAL = 2}, DISABLE = 2},
	range = 10,
	requires_target = true,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		local ravage = false
		if target:hasEffect(target.EFF_DISTORTION) then
			ravage = true
		end
		
		target:setEffect(target.EFF_RAVAGE, t.getDuration(self, t), {dam=self:mindCrit(t.getDamage(self, t)), ravage=ravage, apply_power=self:combatMindpower()})
							
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Ravages the target with distortion, inflicting %0.2f physical damage each turn for %d turns.
		This damage will distort affected targets, rendering them vulnerable to distortion effects.
		If the target is already distorted when ravage is applied the target will also lose one beneficial physical effect or sustain each turn.
		The damage will scale with your mindpower.]]):format(damDesc(self, DamageType.PHYSICAL, damage), duration)
	end,
}

newTalent{
	name = "Maelstrom",
	type = {"psionic/distortion", 4},
	points = 5, 
	require = psi_wil_req4,
	cooldown = 24,
	psi = 30,
	tactical = { ATTACK = { PHYSICAL = 2}, DISABLE = 2},
	range = 10,
	radius = function(self, t) return 3 end,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), nolock=true, talent=t}
	end,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = 1 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end

		local oe = game.level.map(x, y, Map.TERRAIN)
		if not oe or oe.is_maelstrom then return end
		
		local e = Object.new{
			old_feat = oe,
			type = oe.type, subtype = oe.subtype,
			name = "maelstrom", image = oe.image, add_mos = {{image = "terrain/wormhole.png"}},
			display = '&', color_r=255, color_g=255, color_b=255, back_color=colors.STEEL_BLUE,
			always_remember = true,
			temporary = t.getDuration(self, t),
			is_maelstrom = true,
			x = x, y = y,
			canAct = false,
			dam = self:mindCrit(t.getDamage(self, t)),
			radius = self:getTalentRadius(t),
			act = function(self)
				local tgts = {}
				local Map = require "engine.Map"
				local DamageType = require "engine.DamageType"
				local grids = core.fov.circle_grids(self.x, self.y, self.radius, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local Map = require "engine.Map"
					local target = game.level.map(x, y, Map.ACTOR)
					if target then 
						tgts[#tgts+1] = {actor=target, sqdist=core.fov.distance(self.x, self.y, x, y)}
					end
				end end
				table.sort(tgts, "sqdist")
				for i, target in ipairs(tgts) do
					if target.actor:canBe("knocback") then
						target.actor:pull(self.x, self.y, 1)
						game.logSeen(target.actor, "%s is pulled in by the %s!", target.actor.name:capitalize(), self.name)
					end
					DamageType:get(DamageType.PHYSICAL).projector(self.summoner, target.actor.x, target.actor.y, DamageType.PHYSICAL, self.dam)
					target.actor:setEffect(target.actor.EFF_DISTORTION, 1, {})
				end

				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map:removeParticleEmitter(self.particles)	
					game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					game.level.map:updateMap(self.x, self.y)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		
		e.particles = game.level.map:particleEmitter(x, y, 3, "leavestide", {only_one=true}) -- Edge TODO: Make particles for this
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		game.nicer_tiles:updateAround(game.level, x, y)
		game.level.map:updateMap(x, y)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[Create a powerful maelstorm for %d turns.  Each turn the maelstrom will pull in actors within a radius of 3 and inflict %0.2f physical damage.
		This damage will distort affected targets, rendering them vulnerable to distortion effects.
		The damage will scale with your mindpower.]]):format(duration, damDesc(self, DamageType.PHYSICAL, damage))
	end,
}