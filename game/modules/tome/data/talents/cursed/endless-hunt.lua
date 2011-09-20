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

local function checkWillFailure(self, target, minChance, maxChance, attackStrength)
	-- attack power is analogous to mental resist except all willpower and no cunning
	local attack = self:getWil() * 0.5 * attackStrength
	local defense = target:combatMentalResist()

	-- used this instead of checkHit to get a curve that is a little more ratio dependent than difference dependent.
	-- + 10 prevents large changes for low attack/defense values
	-- 2 * log adjusts falloff to roughly get 0% break near attack = 0.5 * defense and 100% break near attack = 2 * defense
	local chance = minChance + (1 + 2 * math.log((attack + 10) / (defense + 10))) * (maxChance - minChance) * 0.5

	local result = rng.avg(1, 100)
	print("checkWillFailure", self.name, self.level, target.name, target.level, minChance, chance, maxChance)

	if result <= minChance then return true end
	if result >= maxChance then return false end
	return result <= chance
end

newTalent{
	name = "Dominate",
	type = {"cursed/endless-hunt", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 0.1,
	tactical = { ATTACK = 3 },
	requires_target = true,
	action = function(self, t)
		local target = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(target)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- attempt domination
		local damMult = 1 + self:combatTalentWeaponDamage(t, 0.1, 0.5)
		local customMindpower = self:getWil() * 0.5 * 1
		target:setEffect(target.EFF_DOMINATED, 4, { dominatedSource = self, dominatedDamMult = damMult, apply_power=customMindpower})
		
		-- just a regular attack (but maybe..with domination!)
		self:attackTarget(target, nil, 1, true)

		return true
	end,
	info = function(self, t)
		local damMult = 1 + self:combatTalentWeaponDamage(t, 0.1, 0.5)
		return ([[Combine strength and will to overpower your opponent with a vicious attack. If your opponent fails to save versus willpower then all of your melee hits will do %d%% damage against them for for 4 turns. There is a 50%% chance of guaranteed success.]]):format(damMult * 100)
	end,
}

newTalent{
	name = "Preternatural Senses",
	type = {"cursed/endless-hunt", 2},
	mode = "passive",
	require = cursed_wil_req2,
	points = 5,
	range = function(self, t)
		return 2 + getHateMultiplier(self, 0, self:getTalentLevel(t) * 1.5)
	end,
	info = function(self, t)
		local maxRange = 2 + math.floor(self:getTalentLevel(t) * 1.5)
		return ([[Your preternatural senses aid you in your hunt for the next victim. You sense foes in a radius of %d (at 0 Hate) to %d (at 10+ Hate).]]):format(2, maxRange)
	end,
}

newTalent{
	name = "Blindside",
	type = {"cursed/endless-hunt", 3},
	require = cursed_wil_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	hate = 0.3,
	range = 6,
	tactical = { CLOSEIN = 2, ATTACK = 1 },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", pass_terrain = true, range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local start = rng.range(0, 8)
		for i = start, start + 8 do
			local x = target.x + (i % 3) - 1
			local y = target.y + math.floor((i % 9) / 3) - 1
			if game.level.map:isBound(x, y)
					and self:canMove(x, y)
					and not game.level.map.attrs(x, y, "no_teleport") then
				self:move(x, y, true)
				game:playSoundNear(self, "talents/teleport")
				local multiplier = self:combatTalentWeaponDamage(t, 0.7, 1.9) * getHateMultiplier(self, 0.3, 1.0)
				self:attackTarget(target, nil, multiplier, true)
				return true
			end
		end

		return true
	end,
	info = function(self, t)
		local multiplier = self:combatTalentWeaponDamage(t, 0.7, 1.9)
		return ([[With blinding speed you suddenly appear next to a target up to %d spaces away and attack for %d%% (at 0 Hate) to %d%% (at 10+ Hate) damage.]]):format(self:getTalentRange(t), multiplier * 30, multiplier * 100)
	end,
}

newTalent{
	name = "Stalk",
	type = {"cursed/endless-hunt", 4},
	require = cursed_wil_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	hate = 0.1,
	range = 6,
	no_npc_use = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target or target == self then return nil end

		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then
			game.logPlayer(self, "You are too far to begin stalking that prey!")
			return nil
		end

		if self:hasLOS(x, y) and target:canSee(self) then
			game.logPlayer(self, "You cannot begin stalking prey that can see you!")
			return nil
		end

		local duration = 4 + math.floor(self:getTalentLevel(t) * 2)
		self:setEffect(self.EFF_STALKER, duration, {target=target})
		target:setEffect(self.EFF_STALKED, duration, {target=self})

		return true
	end,
	info = function(self, t)
		local duration = 4 + math.floor(self:getTalentLevel(t) * 2)
		local critical = math.min(100, 40 + self:getTalentLevel(t) * 12)
		return ([[Stalk a single opponent starting from a position that is out of sight.
		You will be invisible to your target for %d turns or until you attack (%d%% chance of a critical strike).
		Your gloom will not affect the stalked prey.]]):format(duration, critical)
	end,
}

--newTalent{
--	name = "Spite",
--	type = {"cursed/endless-hunt", 4},
--	require = cursed_wil_req4,
--	points = 5,
--	random_ego = "attack",
--	cooldown = 4,
--	hate = 0.1,
--	range = 3,
--	action = function(self, t)
--		local tg = {type="hit", range=self:getTalentRange(t)}
--		local x, y, target = self:getTarget(tg)
--		if not x or not y or not target then return nil end
--
--		local damage = self:getWil() * self:getTalentLevel(t)
--		self:project(tg, x, y, DamageType.BLIGHT, damage)
--
--		game.level.map:particleEmitter(target.x, target.y, 1, "ball_fire", {radius=1})
--		game:playSoundNear(self, "talents/devouringflame")
--		return true
--	end,
--	info = function(self, t)
--		local damage = self:getWil() * self:getTalentLevel(t)
--		return ([[Focusing your hate you blast your target for %d blight damage. Damage increases with willpower.]]):format(damage)
--	end,
--}

