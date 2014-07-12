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
	name = "Impact",
	type = {"chronomancy/bow-threading", 1},
	mode = "sustained",
	require = chrono_req1,
	sustain_paradox = 12,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	getDamage = function(self, t) return 7 + self:combatSpellpower(0.092) * self:combatTalentScale(t, 1, 7) end,
	getApplyPower = function(self, t) return getParadoxSpellpower(self) end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Your weapons and ammo hit with greater force, dealing an additional %0.2f physical damage and having a %d%% chance to daze on hit.
		The daze chance and damage will increase with your Spellpower.]]):format(damDesc(self, DamageType.PHYSICAL, damage), damage/2)
	end,
}

newTalent{
	name = "Threaded Arrow",
	type = {"chronomancy/bow-threading", 2},
	require = chrono_req2,
	points = 5,
	cooldown = 4,
	tactical = { ATTACK = {weapon = 2} },
	requires_target = true,
	range = archery_range,
	no_energy = "fake",
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 2.2) end,
	getParadoxReduction = function(self, t) return math.floor(self:combatTalentScale(t, 10, 20)) end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "bow") then if not silent then game.logPlayer(self, "You require a bow to use this talent.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		self:incParadox(-t.getParadoxReduction(self, t))
	end,
	action = function(self, t)
		local dam, swap = doWardenWeaponSwap(self, t, t.getDamage(self, t))

		local targets = self:archeryAcquireTargets(nil, {one_shot=true, infinite=true})
		if not targets then if swap then doWardenWeaponSwap(self, t, nil, "blade") end return end
		self:archeryShoot(targets, t, nil, {mult=dam, damtype=DamageType.TEMPORAL})

		return true
	end,
	info = function(self, t)
		local paradox = t.getParadoxReduction(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Fire a shot doing %d%% temporal damage.  If the arrow hits you recover %d Paradox.
		This attack does not consume ammo.]])
		:format(damage, paradox)
	end
}

newTalent{
	name = "Singularity Arrow",
	type = {"chronomancy/bow-threading", 3},
	require = chrono_req3,
	points = 5,
	cooldown = 10,
	paradox = function (self, t) return getParadoxCost(self, t, 15) end,
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = 2 },
	requires_target = true,
	range = archery_range,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.7)) end,
	no_energy = "fake",
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getDamageAoE = function(self, t) return self:combatTalentSpellDamage(t, 10, 170, getParadoxSpellpower(self)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "bow") then if not silent then game.logPlayer(self, "You require a bow to use this talent.") end return false end return true end,
	archery_onreach = function(self, t, x, y)
		game:onTickEnd(function() -- Let the arrow hit first
			local tg = self:getTalentTarget(t)
			if not x or not y then return nil end
			local _ _, _, _, x, y = self:canProject(tg, x, y)
			
			local dam = self:spellCrit(t.getDamageAoE(self, t))
			local grids = self:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
				if tx and ty and target:canBe("knockback") then
					target:move(tx, ty, true)
					game.logSeen(target, "%s is drawn in by the singularity!", target.name:capitalize())
				end
			end)
			self:project(tg, x, y, DamageType.GRAVITY, self:spellCrit(dam))
			game.level.map:particleEmitter(x, y, tg.radius, "gravity_spike", {radius=tg.radius, allow=core.shader.allow("distort")})

			game:playSoundNear(self, "talents/earth")
		end)
	end,
	action = function(self, t)
		local dam, swap = doWardenWeaponSwap(self, t, t.getDamage(self, t))
		
		-- Pull x, y from getTarget and pass it so we can show the player the area of effect
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then if swap == true then doWardenWeaponSwap(self, t, nil, "blade") end return nil end
		
		tg.type = "bolt" -- switch our targeting back to a bolt

		local targets = self:archeryAcquireTargets(self:getTalentTarget(t), {one_shot=true, x=x, y=y})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=dam})

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local radius = self:getTalentRadius(t)
		local aoe = t.getDamageAoE(self, t)
		return ([[Fire a shot doing %d%% damage.  When the arrow reaches its destination it will draw in creatures in a radius of %d and inflict %0.2f additional physical damage.
		The additional damage scales with your Spellpower and inflicts 50%% extra damage to pinned targets.]])
		:format(damage, radius, damDesc(self, DamageType.PHYSICAL, aoe))
	end
}

newTalent{
	name = "Arrow Stitching",
	type = {"chronomancy/bow-threading", 4},
	require = chrono_req4,
	points = 5,
	cooldown = 12,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { ATTACK = {weapon = 4} },
	requires_target = true,
	range = archery_range,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.7)) end,
	no_energy = "fake",
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getClones = function(self, t) return self:getTalentLevel(t) >= 5 and 3 or self:getTalentLevel(t) >= 3 and 2 or 1 end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, friendlyblock=false}
	end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "bow") then if not silent then game.logPlayer(self, "You require a bow to use this talent.") end return false end return true end,
	action = function(self, t)
		local dam, swap = doWardenWeaponSwap(self, t, t.getDamage(self, t))
		
		-- Grab our target so we can spawn clones
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then if swap == true then doWardenWeaponSwap(self, t, nil, "blade") end return nil end
		local __, x, y = self:canProject(tg, x, y)
		
		-- Don't cheese arrow stitching through walls
		if not self:hasLOS(x, y) then
			game.logSeen(self, "You do not have line of sight.")
			return nil
		end
				
		local targets = self:archeryAcquireTargets(self:getTalentTarget(t), {one_shot=true, x=x, y=y})
		if not targets then return end
		self:archeryShoot(targets, t, {type="bolt", friendlyfire=false, friendlyblock=false}, {mult=dam})
		
		-- Summon our clones
		if not self.arrow_stitched_clone then
			for i = 1, t.getClones(self, t) do
				local m = makeParadoxClone(self, self, 2)
				local poss = {}
				local range = self:getTalentRange(t)
				for i = x - range, x + range do
					for j = y - range, y + range do
						if game.level.map:isBound(i, j) and
							core.fov.distance(x, y, i, j) <= range and -- make sure they're within arrow range
							core.fov.distance(i, j, self.x, self.y) <= range/2 and -- try to place them close to the caster so enemies dodge less
							self:canMove(i, j) and target:hasLOS(i, j) then
							poss[#poss+1] = {i,j}
						end
					end
				end
				if #poss == 0 then break  end
				local pos = poss[rng.range(1, #poss)]
				x, y = pos[1], pos[2]
				game.zone:addEntity(game.level, m, "actor", x, y)
				m.shoot_target = target
				m.arrow_stitched_clone = true
				m.generic_damage_penalty = 50
				m.energy.value = 1000
				m.on_act = function(self)
					if not self.shoot_target.dead then
						self:forceUseTalent(self.T_ARROW_STITCHING, {force_level=t.leve, ignore_cd=true, ignore_energy=true, force_target=self.shoot_target, ignore_ressources=true, silent=true})
					end
					self:die()
					game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
				end
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local clones = t.getClones(self, t)
		return ([[Fire upon the target for %d%% damage and summon up to %d temporal clones (depending on available space).
		These clones are out of phase with normal reality and deal 50%% damage but shoot through friendly targets.
		At talent level three and five you can summon an additional clone.]])
		:format(damage, clones)
	end
}