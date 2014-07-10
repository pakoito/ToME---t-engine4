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

-- EDGE TODO: Icons, Particles, Timed Effect Particles

newTalent{
	name = "Weapon Folding",
	type = {"chronomancy/blade-threading", 1},
	mode = "sustained",
	require = chrono_req1,
	sustain_paradox = 12,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 40, getParadoxSpellpower(self)) end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Folds a single dimension of your weapons (or ammo) upon itself, increasing your armour penetration by %d and adding %0.2f temporal damage to your strikes.
		The armour penetration and damage will increase with your Spellpower.]]):format(damage/2, damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Warp Blade",
	type = {"chronomancy/blade-threading", 2},
	require = chrono_req2,
	points = 5,
	cooldown = 6,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { ATTACK = {weapon = 2}, DISABLE = 3 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "dual") then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	action = function(self, t)
		local dam = doWardenWeaponSwap(self, t, t.getDamage(self, t))
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hitted = self:attackTarget(target, DamageType.MATTER, dam, true)

		if hitted then
			local chance = rng.range(1, 4)
			if chance == 1 then
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=getParadoxSpellpower(self)})
				else
					game.logSeen(target, "%s resists the stun!", target.name:capitalize())
				end
			elseif chance == 2 then
				if target:canBe("blind") then
					target:setEffect(target.EFF_BLINDED, t.getDuration(self, t), {apply_power=getParadoxSpellpower(self)})
				else
					game.logSeen(target, "%s resists the blindness!", target.name:capitalize())
				end
			elseif chance == 3 then
				if target:canBe("pin") then
					target:setEffect(target.EFF_PINNED, t.getDuration(self, t), {apply_power=getParadoxSpellpower(self)})
				else
					game.logSeen(target, "%s resists the pin!", target.name:capitalize())
				end
			elseif chance == 4 then
				if target:canBe("confusion") then
					target:setEffect(target.EFF_CONFUSED, t.getDuration(self, t), {power=50, apply_power=getParadoxSpellpower(self)})
				else
					game.logSeen(target, "%s resists the confusion!", target.name:capitalize())
				end
			end
			game.level.map:particleEmitter(target.x, target.y, 1, "generic_discharge", {rm=64, rM=64, gm=134, gM=134, bm=170, bM=170, am=35, aM=90})
			game:playSoundNear(self, "talents/arcane")
		end				

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local duration = t.getDuration(self, t)
		return ([[Attack the target with your melee weapons for %d%%.  Half of this damage will be temporal and half physical.
		If the attack hits the target may be stunned, blinded, pinned, or confused for %d turns.
		Chance of applying a random effect improves with your Spellpower.]])
		:format(damage, duration)
	end
}

newTalent{
	name = "Braided Blade",
	type = {"chronomancy/blade-threading", 3},
	require = chrono_req3,
	points = 5,
	cooldown = 8,
	paradox = function (self, t) return getParadoxCost(self, t, 15) end,
	tactical = { ATTACKAREA = {weapon = 2}, DISABLE = 3 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 50, 150, getParadoxSpellpower(self)) end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "dual") then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	action = function(self, t)
		local dam = doWardenWeaponSwap(self, t, t.getDamage(self, t))
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		local hit1 = false
		local hit2 = false
		local hit3 = false

		-- do the braid
		if core.fov.distance(self.x, self.y, x, y) == 1 then
			-- get left and right side
			local dir = util.getDir(x, y, self.x, self.y)
			local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
			local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
			local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

			-- target hit
			hit1 = self:attackTarget(target, nil, damage, true)
			
			--left hit
			if lt then
				hit2 = self:attackTarget(lt, nil, damage, true)
			end
			--right hit
			if rt then
				hit3 = self:attackTarget(rt, nil, damage, true)
			end
			
			-- Braid them; no save
			if hit1 then
				if hit2 or hit3 then
					target:setEffect(target.EFF_BRAIDED, t.getDuration(self, t), {power=t.getPower(self, t), src=self, braid_one=lt or nil, braid_two=rt or nil})
				end
			end
			if hit2 then
				if hit1 or hit3 then
					lt:setEffect(lt.EFF_BRAIDED, t.getDuration(self, t), {power=t.getPower(self, t), src=self, braid_one=target or nil, braid_two=rt or nil})
				end
			end
			if hit3 then
				if hit1 or hit2 then
					rt:setEffect(rt.EFF_BRAIDED, t.getDuration(self, t), {power=t.getPower(self, t), src=self, braid_one=target or nil, braid_two=lt or nil})
				end
			end
			
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return ([[Attack your foes in a frontal arc, doing %d%% weapon damage.  If two or more targets are hit you'll braid their lifelines for %d turns.
		Braided targets take %d%% of all damage dealt to other braided targets.
		The damage transfered by the braid effect scales with your Spellpower.]])
		:format(damage, duration, power)
	end
}

newTalent{
	name = "Temporal Assault",
	type = {"chronomancy/blade-threading", 4},
	require = chrono_req4,
	points = 5,
	cooldown = 12,
	paradox = function (self, t) return getParadoxCost(self, t, 15) end,
	tactical = { ATTACKAREA = {weapon = 2}, ATTACK = {weapon = 2},  },
	requires_target = true,
	is_teleport = true,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.6, 1.2) end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "dual") then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	action = function(self, t)
		local dam = doWardenWeaponSwap(self, t, t.getDamage(self, t))
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
			
		-- Hit the target
		if core.fov.distance(self.x, self.y, target.x, target.y) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, dam, true)

		if hitted then
			-- Get available targets
			local tgts = {}
			local grids = core.fov.circle_grids(self.x, self.y, 10, true)
			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local target_type = Map.ACTOR
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
					tgts[#tgts+1] = a
				end
			end end
			
			-- Randomly take targets
			local teleports = 2
			local attempts = 10
			while teleports > 0 and #tgts > 0 and attempts > 0 do
				local a, id = rng.table(tgts)
				-- since we're using a precise teleport we'll look for a free grid first
				local tx2, ty2 = util.findFreeGrid(a.x, a.y, 5, true, {[Map.ACTOR]=true})
				if tx2 and ty2 then
					game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
					if not self:teleportRandom(tx2, ty2, 0) then
						attempts = attempts - 1
					else
						game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
						if core.fov.distance(self.x, self.y, a.x, a.y) <= 1 then
							self:attackTarget(a, nil, dam, true)
							teleports = teleports - 1
						end
					end
				else
					attempts = attempts - 1
				end
			end
		end
		
		game:playSoundNear(self, "talents/teleport")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Attack the target with your melee weapons for %d%% damage.  If the attack hits you'll teleport next to up to two random enemies, attacking each for %d%% damage.
		Temporal Assault can hit the same target multiple times.]])
		:format(damage, damage)
	end
}
