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
	name = "Slash",
	type = {"cursed/slaughter", 1},
	require = cursed_str_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 0.1,
	tactical = { ATTACK = 2 },
	requires_target = true,
	action = function(self, t)
		if not self:hasAxeWeapon() and not self:hasCursedWeapon() then
			game.logPlayer(self, "You cannot use %s without an axe or a cursed weapon!", t.name)
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		local multiplier = 1 + (0.17 + .23 * self:getTalentLevel(t)) * getHateMultiplier(self, 0, 1)
		local hit = self:attackTarget(target, nil, multiplier, true)

		return true
	end,
	info = function(self, t)
		local multiplier = (0.17 + .23 * self:getTalentLevel(t))
		return ([[Slashes wildly at your target for 100%% (at 0 Hate) to %d%% (at 10+ Hate) damage.
		Requires a one or two handed axe or a cursed weapon.]]):format(multiplier * 100 + 100)
	end,
}

newTalent{
	name = "Frenzy",
	type = {"cursed/slaughter", 2},
	require = cursed_str_req2,
	points = 5,
	tactical = { ATTACKAREA = 2 },
	random_ego = "attack",
	cooldown = 15,
	hate = 0.2,
	requires_target = true,
	action = function(self, t)
		if not self:hasAxeWeapon() and not self:hasCursedWeapon() then
			game.logPlayer(self, "You cannot use %s without an axe or a cursed weapon!", t.name)
			return nil
		end

		local targets = {}
		for i = -1, 1 do
			for j = -1, 1 do
				local x, y = self.x + i, self.y + j
				if (self.x ~= x or self.y ~= y) and game.level.map:isBound(x, y) and game.level.map(x, y, Map.ACTOR) then
					local target = game.level.map(x, y, Map.ACTOR)
					if target and self:reactionToward(target) < 0 then
						targets[#targets+1] = target
					end
				end
			end
		end

		if #targets <= 0 then return nil end

		local multiplier = self:combatTalentWeaponDamage(t, 0.2, 0.7) * getHateMultiplier(self, 0.5, 1.0)
		for i = 1, 4 do
			local target = rng.table(targets)

			self:attackTarget(target, nil, multiplier, true)
		end

		return true
	end,
	info = function(self, t)
		local multiplier = self:combatTalentWeaponDamage(t, 0.2, 0.7)
		return ([[Assault nearby foes with 4 fast attacks for %d%% (at 0 Hate) to %d%% (at 10+ Hate) damage each.
		Requires a one or two handed axe or a cursed weapon.]]):format(multiplier * 50, multiplier * 100)
	end,
}

newTalent{
	name = "Reckless Charge",
	type = {"cursed/slaughter", 3},
	require = cursed_str_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 20,
	hate = 0.5,
	range = 4,
	tactical = { CLOSEIN = 2 },
	requires_target = true,
	action = function(self, t)
		if not self:hasAxeWeapon() and not self:hasCursedWeapon() then
			game.logPlayer(self, "You cannot use %s without an axe or a cursed weapon!", t.name)
			return nil
		end

		local targeting = {type="bolt", range=self:getTalentRange(t), nolock=true}
		local targetX, targetY, actualTarget = self:getTarget(targeting)
		if not targetX or not targetY then return nil end
		if math.floor(core.fov.distance(self.x, self.y, targetX, targetY)) > self:getTalentRange(t) then return nil end

		local lineFunction = line.new(self.x, self.y, targetX, targetY)
		local nextX, nextY = lineFunction()
		local currentX, currentY = self.x, self.y

		while nextX and nextY do
			local blockingTarget = game.level.map(nextX, nextY, Map.ACTOR)
			if blockingTarget and self:reactionToward(blockingTarget) < 0 then
				-- attempt a knockback
				local level = self:getTalentLevelRaw(t)
				local maxSize = 2
				if level >= 5 then
					maxSize = 4
				elseif level >= 3 then
					maxSize = 3
				end

				local blocked = true
				if blockingTarget.size_category <= maxSize then
					if blockingTarget:checkHit(self:combatAttackStr(), blockingTarget:combatPhysicalResist(), 0, 95, 15) and blockingTarget:canBe("knockback") then
						-- determine where to move the target (any adjacent square that isn't next to the attacker)
						local start = rng.range(0, 8)
						for i = start, start + 8 do
							local x = nextX + (i % 3) - 1
							local y = nextY + math.floor((i % 9) / 3) - 1
							if math.floor(core.fov.distance(currentY, currentX, x, y)) > 1
									and game.level.map:isBound(x, y)
									and not game.level.map:checkAllEntities(x, y, "block_move", self) then
								blockingTarget:move(x, y, true)
								game.logSeen(self, "%s knocks back %s!", self.name:capitalize(), blockingTarget.name)
								blocked = false
								break
							end
						end
					end
				end

				if blocked then
					game.logSeen(self, "%s blocks %s!", blockingTarget.name:capitalize(), self.name)
				end
			end

			-- check that we can move
			if not game.level.map:isBound(nextX, nextY) or game.level.map:checkAllEntities(nextX, nextY, "block_move", self) then break end

			-- allow the move
			currentX, currentY = nextX, nextY
			nextX, nextY = lineFunction()

			-- attack adjacent targets
			for i = 0, 8 do
				local x = currentX + (i % 3) - 1
				local y = currentY + math.floor((i % 9) / 3) - 1
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					local multiplier = self:combatTalentWeaponDamage(t, 0.5, 1.5) * getHateMultiplier(self, 0.3, 1.0)
					self:attackTarget(target, nil, multiplier, true)

					game.level.map:particleEmitter(x, y, 1, "blood", {})
					game:playSoundNear(self, "actions/melee")
				end
			end
		end

		self:move(currentX, currentY, true)

		return true
	end,
	info = function(self, t)
		local multiplier = self:combatTalentWeaponDamage(t, 0.5, 1.5)
		local level = self:getTalentLevelRaw(t)
		local size
		if level >= 5 then
			size = "Big"
		elseif level >= 3 then
			size = "Medium-sized"
		else
			size = "Small"
		end
		return ([[Charge through your opponents, attacking anyone near your path for %d%% (at 0 Hate) to %d%% (at 10+ Hate) damage. %s opponents may be knocked from your path.
		Requires a one or two handed axe or a cursed weapon.]]):format(multiplier * 30, multiplier * 100, size)
	end,
}

newTalent{
	name = "Cleave",
	type = {"cursed/slaughter", 4},
	mode = "passive",
	require = cursed_str_req4,
	points = 5,
	on_attackTarget = function(self, t, target, multiplier)
		if not self:hasAxeWeapon() and not self:hasCursedWeapon() then
			game.logPlayer(self, "You cannot use %s without an axe or a cursed weapon!", t.name)
			return nil
		end

		if inCleave then return end
		inCleave = true

		local chance = 28 + self:getTalentLevel(t) * 7
		if rng.percent(chance) then
			local start = rng.range(0, 8)
			for i = start, start + 8 do
				local x = self.x + (i % 3) - 1
				local y = self.y + math.floor((i % 9) / 3) - 1
				local secondTarget = game.level.map(x, y, Map.ACTOR)
				if secondTarget and secondTarget ~= target and self:reactionToward(secondTarget) < 0 then
					local multiplier = multiplier or 1 * self:combatTalentWeaponDamage(t, 0.2, 0.7) * getHateMultiplier(self, 0.5, 1.0)
					game.logSeen(self, "%s cleaves through another foe!", self.name:capitalize())
					self:attackTarget(secondTarget, nil, multiplier, true)
					inCleave = false
					return
				end
			end
		end
		inCleave = false

	end,
	info = function(self, t)
		local chance = 28 + self:getTalentLevel(t) * 7
		local multiplier = self:combatTalentWeaponDamage(t, 0.2, 0.7)
		return ([[Every swing of your weapon has a %d%% chance of striking a second target for %d%% (at 0 Hate) to %d%% (at 10+ Hate) damage.
		Requires a one or two handed axe or a cursed weapon.]]):format(chance, multiplier * 50, multiplier * 100)
	end,
}
