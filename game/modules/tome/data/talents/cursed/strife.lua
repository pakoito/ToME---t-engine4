-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

local function getHateMultiplier(self, min, max)
	return (min + ((max - min) * math.min(self.hate, 10) / 10))
end

newTalent{
	name = "Ruined Cut",
	type = {"cursed/strife", 1},
	require = cursed_str_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 0.4,
	tactical = { ATTACK = 2 },
	requires_target = true,
	getDamagePercent = function(self, t)
		return 100 - (40 / self:getTalentLevel(t))
	end,
	getPoisonDamage = function(self, t)
		return self:combatTalentStatDamage(t, "wil", 30, 500)
	end,
	getDuration = function(self, t)
		return math.max(3, 18 - math.floor(self:getTalentLevel(t) * 1.2))
	end,
	action = function(self, t)
		if not self:hasAxeWeapon() and not self:hasCursedWeapon() then
			game.logPlayer(self, "You cannot use %s without an axe or a cursed weapon!", t.name)
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		local damagePercent = t.getDamagePercent(self, t)
		local poisonDamage = t.getPoisonDamage(self, t)
		local duration = t.getDuration(self, t)
		
		local hit = self:attackTarget(target, nil, damagePercent / 100, true)
		if hit and target:canBe("poison") then
			target:setEffect(target.EFF_POISONED, duration, {src=self, power=poisonDamage / duration})
		end

		return true
	end,
	info = function(self, t)
		local damagePercent = t.getDamagePercent(self, t)
		local poisonDamage = t.getPoisonDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Poison your foe for with the essence of your curse inflicting %d%% damage and %d poison damage over %d turns.
		Poison damage increases with the Willpower stat.
		Requires a one or two handed axe or a cursed weapon.]]):format(damagePercent, poisonDamage, duration)
	end,
}

newTalent{
	name = "Bait",
	type = {"cursed/strife", 2},
	require = cursed_str_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 0.4,
	tactical = { ATTACK = 2 },
	requires_target = true,
	getDamagePercent = function(self, t)
		return 100 - (40 / self:getTalentLevel(t))
	end,
	getDistance = function(self, t)
		return math.max(1, math.floor(self:getTalentLevel(t)))
	end,
	action = function(self, t)
		if not self:hasAxeWeapon() and not self:hasCursedWeapon() then
			game.logPlayer(self, "You cannot use %s without an axe or a cursed weapon!", t.name)
			return nil
		end
		
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		local damagePercent = t.getDamagePercent(self, t)
		local distance = t.getDistance(self, t)
		
		local hit = self:attackTarget(target, nil, damagePercent / 100, true)
		self:knockback(target.x, target.y, distance)
		
		return true
	end,
	info = function(self, t)
		local damagePercent = t.getDamagePercent(self, t)
		local distance = t.getDistance(self, t)
		return ([[Swing your weapon for %d%% damage as you leap backwards %d spaces from your target.
		Requires a one or two handed axe or a cursed weapon.]]):format(damagePercent, distance)
	end,
}

newTalent{
	name = "Smash",
	type = {"cursed/strife", 3},
	require = cursed_str_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 0.4,
	tactical = { ATTACK = 2 },
	requires_target = true,
	getDamagePercent = function(self, t)
		return 100 - (40 / math.max(1, self:getTalentLevel(t)))
	end,
	getDuration = function(self, t)
		return 2 + math.floor(self:getTalentLevel(t))
	end,
	action = function(self, t)
		if not self:hasAxeWeapon() and not self:hasCursedWeapon() then
			game.logPlayer(self, "You cannot use %s without an axe or a cursed weapon!", t.name)
			return nil
		end
		
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		local damagePercent = t.getDamagePercent(self, t)
		local duration = t.getDuration(self, t)
		
		local hit = self:attackTarget(target, nil, damagePercent / 100, true)
		if hit and target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, duration, {})
		end
		
		return true
	end,
	info = function(self, t)
		local damagePercent = t.getDamagePercent(self, t)
		local duration = t.getDuration(self, t)
		return ([[Smash you foe with your weapon doing %d%% damage and stunning them for %d turns.
		Requires a one or two handed axe or a cursed weapon.]]):format(damagePercent, duration)
	end,
}

newTalent{
	name = "Assail",
	type = {"cursed/strife", 4},
	require = cursed_str_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 20,
	hate = 1.5,
	tactical = { ATTACKAREA = 2 },
	requires_target = false,
	getDamagePercent = function(self, t)
		return 100 - (40 / self:getTalentLevel(t))
	end,
	getAttackCount = function(self, t)
		return 2 + math.floor(self:getTalentLevel(t) / 2)
	end,
	getConfuseDuration = function(self, t)
		return 2 + math.floor(self:getTalentLevel(t) / 1.5)
	end,
	getConfuseEfficiency = function(self, t)
		return 50 + self:getTalentLevelRaw(t) * 10
	end,
	hasLOS = function(startX, startY, x, y)
		local l = line.new(startX, startY, x, y)
		local lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_sight") then break end

			lx, ly = l()
		end
		if not lx and not ly then return true end
		if lx == x and ly == y then return true end
		return false
	end,
	action = function(self, t)
		if not self:hasAxeWeapon() and not self:hasCursedWeapon() then
			game.logPlayer(self, "You cannot use %s without an axe or a cursed weapon!", t.name)
			return nil
		end
		
		local damagePercent = t.getDamagePercent(self, t)
		local attackCount = t.getAttackCount(self, t)
		local confuseDuration = t.getConfuseDuration(self, t)
		local confuseEfficiency = t.getConfuseEfficiency(self, t)
		
		local minDistance = 1
		local maxDistance = 4
		local startX, startY = self.x, self.y
		local positions = {}
		local targets = {}
		
		-- find all positions and targets in range
		for x = startX - maxDistance, startX + maxDistance do
			for y = startY - maxDistance, startY + maxDistance do
				if game.level.map:isBound(x, y)
						and core.fov.distance(startX, startY, x, y) <= maxDistance
						and core.fov.distance(startX, startY, x, y) >= minDistance
						and self:hasLOS(x, y) then
					if self:canMove(x, y) then positions[#positions + 1] = {x, y} end
					
					local target = game.level.map(x, y, Map.ACTOR)
					if target and target ~= self and self:reactionToward(target) < 0 then targets[#targets + 1] = target end
				end
			end
		end
		
		-- perform confusion
		for i = 1, #targets do
			self:project({type="hit",x=targets[i].x,y=targets[i].y}, targets[i].x, targets[i].y, DamageType.CONFUSION, { dur = confuseDuration, dam = confuseEfficiency })
		end
		
		-- perform attacks
		for i = 1, attackCount do
			if #targets == 0 then break end
			
			local target = rng.tableRemove(targets)
			local hit = self:attackTarget(target, nil, damagePercent / 100, true)
		end
		
		-- perform movements
		if #positions > 0 then
			for i = 1, 8 do
				local position = positions[rng.range(1, #positions)]
				if rng.chance(50) then
					game.level.map:particleEmitter(position[1], position[2], 1, "teleport_out")
				else
					game.level.map:particleEmitter(position[1], position[2], 1, "teleport_in")
				end
			end
		end
		
		game.level.map:particleEmitter(currentX, currentY, 1, "teleport_in")
		local position = positions[rng.range(1, #positions)]
		self:move(position[1], position[2], true)
		
		return true
	end,
	info = function(self, t)
		local damagePercent = t.getDamagePercent(self, t)
		local attackCount = t.getAttackCount(self, t)
		local confuseDuration = t.getConfuseDuration(self, t)
		local confuseEfficiency = t.getConfuseEfficiency(self, t)
		
		return ([[With unnatural speed you assail all foes in sight within a range of 4 with wild swings from your axe. You will attack up to %d different targets for %d%% damage. When the assualt finally ends all foes in range will be confused for %d turns and you will find yourself in a nearby location.
		Requires a one or two handed axe or a cursed weapon.]]):format(attackCount, damagePercent, confuseDuration)
	end,
}
