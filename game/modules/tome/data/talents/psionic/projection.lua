-- ToME - Tales of Maj'Eyal
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

local function combatTalentDamage(self, t, min, max)
	return self:combatTalentSpellDamage(t, min, max, self.level + self:getWil())
end

-- damage: initial physical damage and used for fractional knockback damage
-- knockback: distance to knockback
-- knockbackDamage: when knockback strikes something, both parties take damage - percent of damage * remaining knockback
-- power: used to determine the initial radius of particles
local function forceHit(self, target, sourceX, sourceY, damage, knockback, knockbackDamage, power)
	-- apply initial damage
	if not target then return end
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
	name = "Kinetic Aura",
	type = {"psionic/projection", 1},
	require = psi_wil_req1, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_psi = 30,
	remove_on_zero = true,
	cooldown = function(self, t)
		return 15 - (self:getTalentLevelRaw(self.T_AURA_DISCIPLINE) or 0)
	end,
	tactical = { ATTACKAREA = 2 },
	range = 1,
	direct_hit = true,
	getAuraStrength = function(self, t)
		local add = 0
		if self:knowTalent(self.T_FOCUSED_CHANNELING) then
			add = getGemLevel(self)*(1 + 0.1*(self:getTalentLevel(self.T_FOCUSED_CHANNELING) or 0))
		end
		--return 5 + (1+ self:getWil(5))*self:getTalentLevel(t) + add
		return self:combatTalentIntervalDamage(t, "wil", 6, 50) + add
	end,
	getKnockback = function(self, t)
		return 3 + math.floor(self:getTalentLevel(t))
	end,
	do_kineticaura = function(self, t)

		local mast = 5 + (self:getTalentLevel(self.T_AURA_DISCIPLINE) or 0) + getGemLevel(self)
		local dam = t.getAuraStrength(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 1, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=1, talent=t}
		for i = 1, 10 do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			self:project(tg, a.x, a.y, DamageType.PHYSICAL, dam)
			--game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "lightning", {tx=a.x-self.x, ty=a.y-self.y})
			self:incPsi(-dam/mast)
		end

	end,
	activate = function(self, t)
		return true
	end,
	deactivate = function(self, t, p)
		local dam = 50 + 0.25 * t.getAuraStrength(self, t)*t.getAuraStrength(self, t)
		local cost = t.sustain_psi - 2*getGemLevel(self)
		if self:getPsi() <= cost then
			game.logPlayer(self, "The aura dissipates without producing a spike.")
			return true
		end
		local tg = {type="hit", nolock=true, range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local actor = game.level.map(x, y, Map.ACTOR)
		if not actor then return true end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local knockback = t.getKnockback(self, t)
		forceHit(self, target, self.x, self.y, dam, knockback, 15, 1)
		--self:project(tg, x, y, DamageType.BATTER, dam)
		self:incPsi(-cost)

		return true
	end,

	info = function(self, t)
		local dam = t.getAuraStrength(self, t)
		local spikedam = 50 + 0.25 * dam * dam
		local mast = 5 + (self:getTalentLevel(self.T_AURA_DISCIPLINE) or 0) + getGemLevel(self)
		local spikecost = t.sustain_psi - 2*getGemLevel(self)
		return ([[Fills the air around you with reactive currents of force that do %d physical damage to all who approach. All damage done by the aura will drain one point of energy per %0.2f points of damage dealt.
		When deactivated, if you have at least %d energy, a massive spike of kinetic energy is released, smashing a target for %d physical damage and sending it flying. Telekinetically wielding a gem instead of a weapon will result in improved spike efficiency.
		The damage will increase with the Willpower stat.]]):format(dam, mast, spikecost, spikedam)
	end,
}


newTalent{
	name = "Thermal Aura",
	type = {"psionic/projection", 2},
	require = psi_wil_req2, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_psi = 40,
	remove_on_zero = true,
	cooldown = function(self, t)
		return 15 - (self:getTalentLevelRaw(self.T_AURA_DISCIPLINE) or 0)
	end,
	tactical = { ATTACKAREA = 2 },
	range = function(self, t)
		local r = 6
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	direct_hit = true,
	getAuraStrength = function(self, t)
		local add = 0
		if self:knowTalent(self.T_FOCUSED_CHANNELING) then
			add = getGemLevel(self)*(1 + 0.1*(self:getTalentLevel(self.T_FOCUSED_CHANNELING) or 0))
		end
		--return 5 + (1+ self:getWil(5))*self:getTalentLevel(t) + add
		return self:combatTalentIntervalDamage(t, "wil", 6, 50) + add
	end,
	do_thermalaura = function(self, t)

		local mast = 5 + (self:getTalentLevel(self.T_AURA_DISCIPLINE) or 0) + getGemLevel(self)
		local dam = t.getAuraStrength(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 1, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=1, talent=t}
		for i = 1, 10 do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			self:project(tg, a.x, a.y, DamageType.FIRE, dam)
			--game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "lightning", {tx=a.x-self.x, ty=a.y-self.y})
			self:incPsi(-dam/mast)
		end

	end,
	activate = function(self, t)
		return true
	end,
	deactivate = function(self, t, p)
		local dam = 50 + 0.4 * t.getAuraStrength(self, t)*t.getAuraStrength(self, t)
		local cost = t.sustain_psi - 2*getGemLevel(self)
		--if self:isTalentActive(self.T_CONDUIT) then return true end
		if self:getPsi() <= cost then
			game.logPlayer(self, "The aura dissipates without producing a spike.")
			return true
		end

		local tg = {type="beam", nolock=true, range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local actor = game.level.map(x, y, Map.ACTOR)
		if math.floor(core.fov.distance(self.x, self.y, x, y)) == 1 and not actor then return true end
		self:project(tg, x, y, DamageType.FIREBURN, self:spellCrit(rng.avg(0.8*dam, dam)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})

		game:playSoundNear(self, "talents/fire")
		self:incPsi(-cost)
		return true
	end,

	info = function(self, t)
		local dam = t.getAuraStrength(self, t)
		local spikedam = 50 + 0.4 * dam * dam
		local mast = 5 + (self:getTalentLevel(self.T_PROJECTION_MASTERY) or 0) + getGemLevel(self)
		local spikecost = t.sustain_psi - 2*getGemLevel(self)
		return ([[Fills the air around you with reactive currents of furnace-like heat that do %d fire damage to all who approach. All damage done by the aura will drain one point of energy per %0.2f points of damage dealt.
		When deactivated, if you have at least %d energy, a massive spike of thermal energy is released as a tunnel of superheated air. Anybody caught in it will suffer %d fire damage. Telekinetically wielding a gem instead of a weapon will result in improved spike efficiency.
		The damage will increase with the Willpower stat.]]):format(dam, mast, spikecost, spikedam)
	end,
}


newTalent{
	name = "Charged Aura",
	type = {"psionic/projection", 3},
	require = psi_wil_req3, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_psi = 50,
	remove_on_zero = true,
	cooldown = function(self, t)
		return 15 - (self:getTalentLevelRaw(self.T_AURA_DISCIPLINE) or 0)
	end,
	tactical = { ATTACKAREA = 2 },
	range = function(self, t)
		local r = 6
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	direct_hit = true,
	getAuraStrength = function(self, t)
		local add = 0
		if self:knowTalent(self.T_FOCUSED_CHANNELING) then
			add = getGemLevel(self)*(1 + 0.1*(self:getTalentLevel(self.T_FOCUSED_CHANNELING) or 0))
		end
		--return 5 + (1+ self:getWil(5))*self:getTalentLevel(t) + add
		return self:combatTalentIntervalDamage(t, "wil", 6, 50) + add
	end,
	do_chargedaura = function(self, t)
		local mast = 5 + (self:getTalentLevel(self.T_AURA_DISCIPLINE) or 0) + getGemLevel(self)
		local dam = t.getAuraStrength(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 1, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=1, talent=t}
		for i = 1, 10 do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			self:project(tg, a.x, a.y, DamageType.LIGHTNING, dam)
			--game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "lightning", {tx=a.x-self.x, ty=a.y-self.y})
			self:incPsi(-dam/mast)
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/thunderstorm")
		return true
	end,
	deactivate = function(self, t, p)
		local dam = 50 + 0.4 * t.getAuraStrength(self, t)*t.getAuraStrength(self, t)
		local cost = t.sustain_psi - 2*getGemLevel(self)
		--if self:isTalentActive(self.T_CONDUIT) then return true end
		if self:getPsi() <= cost then
			game.logPlayer(self, "The aura dissipates without producing a spike.")
			return true
		end

		local tg = {type="bolt", nolock=true, range=self:getTalentRange(t), talent=t}
		local fx, fy = self:getTarget(tg)
		if not fx or not fy then return nil end

		local nb = 1 + math.floor(0.5*self:getTalentLevel(t)) + getGemLevel(self)
		local affected = {}
		local first = nil
		--Here's the part where deactivating the aura fires off a huge chain lightning
		self:project(tg, fx, fy, function(dx, dy)
			print("[Chain lightning] targetting", fx, fy, "from", self.x, self.y)
			local actor = game.level.map(dx, dy, Map.ACTOR)
			if actor and not affected[actor] then
				ignored = false
				affected[actor] = true
				first = actor

				print("[Chain lightning] looking for more targets", nb, " at ", dx, dy, "radius ", 10, "from", actor.name)
				self:project({type="ball", friendlyfire=false, x=dx, y=dy, radius=self:getTalentRange(t), range=0}, dx, dy, function(bx, by)
					local actor = game.level.map(bx, by, Map.ACTOR)
					if actor and not affected[actor] and self:reactionToward(actor) < 0 then
						print("[Chain lightning] found possible actor", actor.name, bx, by, "distance", core.fov.distance(dx, dy, bx, by))
						affected[actor] = true
					end
				end)
				return true
			end
		end)

		if not first then return true end
		local targets = { first }
		affected[first] = nil
		local possible_targets = table.listify(affected)
		print("[Chain lightning] Found targets:", #possible_targets)
		for i = 2, nb do
			if #possible_targets == 0 then break end
			local act = rng.tableRemove(possible_targets)
			targets[#targets+1] = act[1]
		end

		local sx, sy = self.x, self.y
		for i, actor in ipairs(targets) do
			local tgr = {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t, x=sx, y=sy}
			print("[Chain lightning] jumping from", sx, sy, "to", actor.x, actor.y)
			self:project(tgr, actor.x, actor.y, DamageType.LIGHTNING, self:spellCrit(rng.avg(0.8*dam, dam)))
			game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning", {tx=actor.x-sx, ty=actor.y-sy, nb_particles=150, life=6})
			sx, sy = actor.x, actor.y
		end
		game:playSoundNear(self, "talents/lightning")
		self:incPsi(-cost)
		return true
	end,

	info = function(self, t)
		local dam = t.getAuraStrength(self, t)
		local spikedam = 50 + 0.4 * dam * dam
		local mast = 5 + (self:getTalentLevel(self.T_AURA_DISCIPLINE) or 0) + getGemLevel(self)
		local spikecost = t.sustain_psi - 2*getGemLevel(self)
		local nb = 3 + self:getTalentLevelRaw(t)
		return ([[Fills the air around you with crackling energy, doing %d lightning damage to all who stand nearby. All damage done by the aura will drain one point of energy per %0.2f points of damage dealt.
		When deactivated, if you have at least %d energy, a massive spike of electrical energy jumps between up to %d nearby targets, doing %d lightning damage to each. Telekinetically wielding a gem instead of a weapon will result in improved spike efficiency.
		The damage will increase with the Willpower stat.]]):format(dam, mast, spikecost, nb, spikedam)
	end,
}

newTalent{
	name = "Projection Mastery",
	type = {"psionic/projection", 4},
	require = psi_wil_req4,
	cooldown = function(self, t)
		return 120 - self:getTalentLevel(t)*12
	end,
	psi = 15,
	points = 5,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		if self.talents_cd[self.T_KINETIC_AURA] == nil and self.talents_cd[self.T_THERMAL_AURA] == nil and self.talents_cd[self.T_CHARGED_AURA] == nil then
			return
		else
			if self:isTalentActive(self.T_CONDUIT) then
				local auras = self:isTalentActive(self.T_CONDUIT)
				if not auras.k_aura_on then
					self.talents_cd[self.T_KINETIC_AURA] = nil
				end
				if not auras.t_aura_on then
					self.talents_cd[self.T_THERMAL_AURA] = nil
				end
				if not auras.c_aura_on then
					self.talents_cd[self.T_CHARGED_AURA] = nil
				end
			else
				self.talents_cd[self.T_KINETIC_AURA] = nil
				self.talents_cd[self.T_THERMAL_AURA] = nil
				self.talents_cd[self.T_CHARGED_AURA] = nil
			end
			return true
		end
	end,

	info = function(self, t)
		return ([[When activated, brings all auras off cooldown. Additional talent points spent in Projection Mastery allow it to be used more frequently.]])
	end,

}
