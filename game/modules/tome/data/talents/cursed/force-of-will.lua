-- ToME - Tales of Middle-Earth
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


-- damage: initial physical damage and used for fractional knockback damage
-- knockback: distance to knockback
-- knockbackDamage: when knockback strikes something, both parties take damage - percent of damage * remaining knockback
-- power: used to determine the initial radius of particles
local function forceHit(self, target, sourceX, sourceY, damage, knockback, knockbackDamage, power, max)
	-- apply initial damage
	if damage > 0 then
		damage = self:mindCrit(damage)
		self:project(target, target.x, target.y, DamageType.PHYSICAL, damage)
		game.level.map:particleEmitter(target.x, target.y, 1, "force_hit", {power=power, dx=target.x - sourceX, dy=target.y - sourceY})
	end

	-- knockback?
	if not target.dead and knockback and knockback > 0 and target:canBe("knockback") and (target.never_move or 0) < 1 then
		-- give direct hit a direction?
		if sourceX == target.x and sourceY == target.y then
			local newDirection = rng.table(util.adjacentDirs())
			local dx, dy = util.dirToCoord(newDirection, sourceX, sourceY)
			sourceX = sourceX + dx
			sourceY = sourceY + dy
		end

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", target) end
		local lineFunction = core.fov.line(sourceX, sourceY, target.x, target.y, block_actor, true)
		local finalX, finalY = target.x, target.y
		local knockbackCount = 0
		local blocked = false
		while knockback > 0 do
			blocked = true
			local x, y, is_corner_blocked = lineFunction:step(true)

			if not game.level.map:isBound(x, y) or is_corner_blocked or game.level.map:checkAllEntities(x, y, "block_move", target) then
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
				local blockDamage = damage * util.bound(knockback * (knockbackDamage / 100), 0, 1.5)
				self:project(target, target.x, target.y, DamageType.PHYSICAL, blockDamage)

				if nextTarget then
					-- start a new force hit with the knockback damage and current knockback
					if max > 0 then
						forceHit(self, nextTarget, sourceX, sourceY, blockDamage, knockback, knockbackDamage, power / 2, max - 1)
					end
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
			local ox, oy = target.x, target.y
			target:move(finalX, finalY, true)
			if config.settings.tome.smooth_move > 0 then
				target:resetMoveAnim()
				target:setMoveAnim(ox, oy, 9, 5)
			end
		end
	end
end

newTalent{
	name = "Willful Strike",
	type = {"cursed/force-of-will", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 5,
	hate = 5,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	direct_hit = true,
	requires_target = true,
	range = 3,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 280)
	end,
	getKnockback = function(self, t)
		return 2
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > range then return nil end

		--local distance = math.max(1, core.fov.distance(self.x, self.y, x, y))
		local power = 1 --(1 - ((distance - 1) / range))
		local damage = t.getDamage(self, t) * power
		local knockback = t.getKnockback(self, t)
		forceHit(self, target, self.x, self.y, damage, knockback, 7, power, 10)
		return true
	end,
	on_learn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) + 3
	end,
	on_unlearn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) - 3
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)
		return ([[Focusing your hate, you strike your foe with unseen force for %d damage and %d knockback.
		Your ability to channel force increases all critical damage by 3%% per point (current: %d%%)
		Damage increases with your Mindpower.]]):format(damDesc(self, DamageType.PHYSICAL, damage), knockback, self.combat_critical_power or 0)
	end,
}

newTalent{
	name = "Deflection",
	type = {"cursed/force-of-will", 2},
	mode = "sustained",
	no_energy = true,
	require = cursed_wil_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	tactical = { DEFEND = 2 },
	no_sustain_autoreset = true,
	getMaxDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 240)
	end,
	getDisplayName = function(self, t, p)
		return ("Deflection (%d)"):format(p.value)
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
		if p.value < maxDamage and self.hate >= 0.2 then
			self:incHate(-0.2)

			p.value = math.min(p.value + maxDamage / 35, maxDamage)

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
	on_learn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) + 3
	end,
	on_unlearn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) - 3
	end,
	info = function(self, t)
		local maxDamage = t.getMaxDamage(self, t)
		return ([[Deflect 50%% of incoming damage with the force of your will. You may deflect up to %d damage, but first your hate must slowly feed your strength (-0.2 hate regeneration while building strength).
		Your ability to channel force increases all critical damage by 3%% per point (current: %d%%)
		The maximum damage deflected increases with your Mindpower.]]):format(maxDamage, self.combat_critical_power or 0)
	end,
}

newTalent{ 
	name = "Blast",
	type = {"cursed/force-of-will", 3},
	require = cursed_wil_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { stun = 1 } },
	requires_target = true,
	hate = 12,
	range = 4,
	radius = function(self, t)
		return math.floor(2 + self:getTalentLevel(t) / 3)
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 300)
	end,
	getKnockback = function(self, t)
		return 2
	end,
	target = function(self, t)
		return {type="ball", nolock=true, pass_terrain=false, friendly_fire=false, nowarning=true, range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	getDazeDuration = function(self, t)
		return 3
	end,
	action = function(self, t) --NOTE TO DG, SINCE I CAN'T UNDERSTAND A WORD OF BENLI'S CODE: EDIT SO THAT KNOCKBACK OCCURS AFTER DAMAGE, AND SEPARATELY, TO PREVENT ENEMIES BEING SHOVED INTO A NEW SPACE AND HIT AGAIN.
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)

		local tg = self:getTalentTarget(t)
		local blastX, blastY = self:getTarget(tg)
		if not blastX or not blastY or core.fov.distance(self.x, self.y, blastX, blastY) > range then return nil end

		local grids = self:project(tg, blastX, blastY,
			function(x, y, target, self)
				-- your will ignores friendly targets (except for knockback hits)
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					local distance = core.fov.distance(blastX, blastY, x, y)
					local power = (1 - (distance / radius))
					local localDamage = damage * power
					local dazeDuration = t.getDazeDuration(self, t)

					forceHit(self, target, blastX, blastY, damage, math.max(0, knockback - distance), 7, power, 10)
					if target:canBe("stun") then
						target:setEffect(target.EFF_DAZED, dazeDuration, {src=self})
					end
				end
			end,
			nil, nil)

		local _ _, _, _, x, y = self:canProject(tg, blastX, blastY)
		game.level.map:particleEmitter(x, y, tg.radius, "force_blast", {radius=tg.radius})
		game:playSoundNear(self, "talents/fireflash")

		return true
	end,
	on_learn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) + 3
	end,
	on_unlearn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) - 3
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)
		local dazeDuration = t.getDazeDuration(self, t)
		return ([[You rage coalesces at a single point and then explodes outward blasting enemies within a radius of %d in all directions. The blast causes %d damage and %d knockback at the center that decreases with distance. Anyone caught in the explosion will also be dazed for 3 turns.
		Your ability to channel force increases all critical damage by 3%% per point (current: %d%%)
		Damage increases with your Mindpower.]]):format(radius, damDesc(self, DamageType.PHYSICAL, damage), knockback, self.combat_critical_power or 0)
	end,
}

newTalent{
	name = "Unseen Force",
	type = {"cursed/force-of-will", 4},
	require = cursed_wil_req4,
	points = 5,
	hate = 18,
	cooldown = 30,
	tactical = { ATTACKAREA = { PHYSICAL = 2 } },
	range = 4,
	getDuration = function(self, t)
		return 5 + math.floor(self:getTalentLevel(t))
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 140)
	end,
	getKnockback = function(self, t)
		return 2
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
				forceHit(self, target, target.x, target.y, damage, knockback, 7, 0.6, 10)
			end
		end

		self.unseenForce.duration = self.unseenForce.duration - 1
		if self.unseenForce.duration <= 0 then
			self:removeParticles(self.unseenForce.particles)
			self.unseenForce = nil
			game.logSeen(self, "The unseen force around %s subsides.", self.name)
		end
	end,
	on_learn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) + 3
	end,
	on_unlearn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) - 3
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)
		local secondHitChance = t.getSecondHitChance(self, t)
		return ([[Your fury becomes an unseen force that randomly lashes out at the foes around you. For %d turns you strike one nearby target doing %d damage and %d knockback. At higher levels there is a %d%% chance of a second strike.
		Your ability to channel force increases all critical damage by 3%% per point (current: %d%%)
		Damage increases with your Mindpower.]]):format(duration, damDesc(self, DamageType.PHYSICAL, damage), knockback, secondHitChance, self.combat_critical_power or 0)
	end,
}

