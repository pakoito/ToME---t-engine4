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

-- damage: initial physical damage and used for fractional knockback damage
-- knockback: distance to knockback
-- knockbackDamage: when knockback strikes something, both parties take damage - percent of damage * remaining knockback
-- power: used to determine the initial radius of particles
local function forceHit(self, target, sourceX, sourceY, damage, knockback, knockbackDamage, power)
	-- apply initial damage
	if damage > 0 then
		self:project(target, target.x, target.y, DamageType.PHYSICAL, damage)
		game.level.map:particleEmitter(target.x, target.y, 1, "force_hit", {power=power, dx=target.x - sourceX, dy=target.y - sourceY})
	end
	
	-- knockback?
	if not target.dead and knockback and knockback > 0 and target:canBe("knockback") and (target.never_move or 0) < 1 then
		-- give direct hit a direction?
		if sourceX == target.x and sourceY == target.y then
			local newDirection = rng.range(1, 8)
			sourceX = sourceX + dir_to_coord[newDirection][1]
			sourceY = sourceY + dir_to_coord[newDirection][2]
		end
	
		local lineFunction = line.new(sourceX, sourceY, target.x, target.y, true)
		local finalX, finalY = target.x, target.y
		local knockbackCount = 0
		local blocked = false
		while knockback > 0 do
			blocked = true
			local x, y = lineFunction(true)
			
			if not game.level.map:isBound(x, y) or game.level.map:checkAllEntities(x, y, "block_move", target) then
				-- blocked
				local nextTarget = game.level.map(x, y, Map.ACTOR)
				if nextTarget then
					if knockbackCount > 0 then
						game.logPlayer(self, "%s was blasted %d spaces into %s!", target.name:capitalize(), knockbackCount, nextTarget.name)
					else
						game.logPlayer(self, "%s was blasted into %s!", target.name:capitalize(), nextTarget.name)
					end
				elseif knockbackCount > 0 then
					game.logPlayer(self, "%s was smashed back %d spaces!", target.name:capitalize(), knockbackCount)
				else
					game.logPlayer(self, "%s was smashed!", target.name:capitalize())
				end
				
				-- take partial damage
				local blockDamage = damage * knockback * knockbackDamage / 100
				self:project(target, target.x, target.y, DamageType.PHYSICAL, blockDamage)
				
				if nextTarget then
					-- start a new force hit with the knockback damage and current knockback
					
					forceHit(self, nextTarget, sourceX, sourceY, blockDamage, knockback, knockbackDamage, power / 2)
				end
				
				knockback = 0
			else
				-- allow move
				finalX, finalY = x, y
				knockback = knockback - 1
				knockbackCount = knockbackCount + 1
			end
		end
		
		if not blocked and knockbackCount > 0 then
			game.logPlayer(self, "%s was blasted back %d spaces!", target.name:capitalize())
		end
		
		if not target.dead and (finalX ~= target.x or finalY ~= target.y) then
			target:move(finalX, finalY, true)
		end
	end
end

newTalent{
	name = "Willful Strike",
	type = {"cursed/force-of-will", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 4,
	hate = 0.5,
	range = function(self, t)
		return math.floor(4 + self:getTalentLevel(t))
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 20, 160)
	end,
	getKnockback = function(self, t)
		return math.floor(self:getTalentLevel(t))
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		
		local distance = math.max(1, math.floor(core.fov.distance(self.x, self.y, x, y)))
		
		local power = (1 - ((distance - 1) / range))
		local damage = t.getDamage(self, t) * power
		local knockback = t.getKnockback(self, t)
		forceHit(self, target, self.x, self.y, damage, knockback, 15, power)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)
		return ([[Focusing your hate you strike your foe with unseen force for up to %d damage and %d knockback. Damage increases with willpower but decreases with range.]]):format(damDesc(self, DamageType.PHYSICAL, damage), knockback)
	end,
}

newTalent{
	name = "Deflection",
	type = {"cursed/force-of-will", 2},
	mode = "sustained",
	require = cursed_wil_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	tactical = {
		DEFEND = 10,
	},
	no_sustain_autoreset = true,
	direct_hit = true,
	getMaxDamage = function(self, t)
		return self:getWil(70) * math.sqrt(self:getTalentLevel(t))
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		return {
			value = 0
		}
	end,
	deactivate = function(self, t, p)
		if p.particles then self:removeParticles(p.particles) end
		p.particles = nil
		return true
	end,
	do_act = function(self, t, p)
		local maxDamage = t.getMaxDamage(self, t)
		if p.value < maxDamage and self.hate >= 0.05 then
			self:incHate(-0.05)
			
			p.value = math.min(p.value + maxDamage / 50, maxDamage)
			
			t.updateParticles(self, t, p)
		end
	end,
	do_onTakeHit = function(self, t, p, damage)
		if p.value > 0 then
			-- absorb 50% damage
			local deflectDamage = math.floor(math.min(damage * 0.5, p.value))
			if deflectDamage > 0 then
				damage = damage - deflectDamage
				p.value = math.max(0, p.value - deflectDamage)
				t.updateParticles(self, t, p)
				
				game.logPlayer(self, "You have deflected %d incoming damage!", deflectDamage)
			end
		end
		return damage
	end,
	updateParticles = function(self, t, p)
		local power = 1 + math.floor(p.value / t.getMaxDamage(self, t) * 9)
		if not p.particles or p.power ~= power then
			if p.particles then self:removeParticles(p.particles) end
			p.particles = self:addParticles(Particles.new("force_deflection", 1, { power = power }))
			p.power = power
		end
	end,
	info = function(self, t)
		local maxDamage = t.getMaxDamage(self, t)
		return ([[Deflect 50%% of incoming damage with the force of your will. You may deflect up to %d damage but first your hate must slowly feed your strength.]]):format(maxDamage)
	end,
}

newTalent{
	name = "Blast",
	type = {"cursed/force-of-will", 3},
	require = cursed_wil_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	hate = 1.5,
	range = function(self, t)
		return math.floor(8 + self:getTalentLevel(t))
	end,
	getRadius = function(self, t)
		return math.floor(2 + self:getTalentLevel(t))
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 20, 160)
	end,
	getKnockback = function(self, t)
		return 3 + math.floor(self:getTalentLevel(t))
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local radius = t.getRadius(self, t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)
		
		local tg = {type="ball", nolock=true, pass_terrain=false, friendly_fire=false, nowarning=true, range=range, radius=radius, talent=t}
		local blastX, blastY = self:getTarget(tg)
		if not blastX or not blastY then return nil end
		
		local grids = self:project(tg, blastX, blastY,
			function(x, y, target, self)
				-- your will ignores friendly targets (except for knockback hits)
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					local distance = math.floor(core.fov.distance(blastX, blastY, x, y))
					local power = (1 - (distance / radius))
					local localDamage = damage * power
					forceHit(self, target, blastX, blastY, damage, math.max(0, knockback - distance), 15, power)
				end
			end,
			nil, nil)

		local _ _, x, y = self:canProject(tg, blastX, blastY)
		game.level.map:particleEmitter(x, y, tg.radius, "force_blast", {radius=tg.radius})
		game:playSoundNear(self, "talents/fireflash")
		
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)
		return ([[You rage coalesces at a single point and then explodes outward blasting enemies within a radius of %d in all directions. The blast causes %d damage and %d knockback at the center that decreases with distance. Damage increases with willpower.]]):format(radius, damDesc(self, DamageType.PHYSICAL, damage), knockback)
	end,
}

newTalent{
	name = "Unseen Force",
	type = {"cursed/force-of-will", 4},
	require = cursed_wil_req4,
	points = 5,
	hate = 2,
	cooldown = 50,
	tactical = {
		ATTACKAREA = 10,
	},
	direct_hit = true,
	range = function(self, t)
		return math.floor(5 + self:getTalentLevel(t))
	end,
	getDuration = function(self, t)
		return 5 + math.floor(self:getTalentLevel(t))
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 20, 160)
	end,
	getKnockback = function(self, t)
		return math.floor(self:getTalentLevel(t))
	end,
	getSecondHitChance = function(self, t)
		local level = self:getTalentLevel(t)
		if level < 4 then return 0 end
		
		return 5 + (level - 4) * 10
	end,
	action = function(self, t)
		game.logSeen(self, "An unseen force begin to swirl around %s!", self.name)
		local duration = t.getDuration(self, t)
		local particles = self:addParticles(Particles.new("force_area", 1, { radius = self:getTalentRange(t) }))
		
		self.unseenForce = { duration = duration, particles = particles }
		return true
	end,
	do_unseenForce = function(self, t)
		local targets = {}
		local grids = core.fov.circle_grids(self.x, self.y, 5, true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
					targets[#targets+1] = a
				end
			end
		end
		
		if #targets > 0 then
			local damage = t.getDamage(self, t)
			local knockback = t.getKnockback(self, t)
		
			local hitCount = 1
			if rng.percent(t.getSecondHitChance(self, t)) then hitCount = hitCount + 1 end
		
			-- Randomly take targets
			for i = 1, hitCount do
				local target, index = rng.table(targets)
				forceHit(self, target, target.x, target.y, damage, knockback, 15, 0.6)
			end
		end
		
		self.unseenForce.duration = self.unseenForce.duration - 1
		if self.unseenForce.duration <= 0 then
			self:removeParticles(self.unseenForce.particles)
			self.unseenForce = nil
			game.logSeen(self, "The unseen force around %s subsides.", self.name)
		end
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)
		local secondHitChance = t.getSecondHitChance(self, t)
		if secondHitChance > 0 then
			return ([[Your fury becomes an unseen force that randomly lashes out at the foes around you. For %d turns you strike one nearby target doing %d damage and %d knockback. There is a %d%% chance of a second strike. Damage increases with willpower.]]):format(duration, damDesc(self, DamageType.PHYSICAL, damage), knockback, secondHitChance)
		else
			return ([[Your fury becomes an unseen force that randomly lashes out at the foes around you. For %d turns you strike one nearby target doing %d damage and %d knockback. At higher levels there is a chance of a second strike. Damage increases with willpower.]]):format(duration, damDesc(self, DamageType.PHYSICAL, damage), knockback, secondHitChance)
		end
	end,
}
