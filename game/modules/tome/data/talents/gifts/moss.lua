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

local function activate_moss(self, btid)
	for tid, lev in pairs(self.talents) do
		if tid ~= btid and self.talents_def[tid].type[1] == "wild-gift/moss" and (not self.talents_cd[tid] or self.talents_cd[tid] < 3) then
			self.talents_cd[tid] = 3
		end
	end
end

newTalent{
	name = "Grasping Moss",
	type = {"wild-gift/moss", 1},
	require = gifts_req1,
	points = 5,
	cooldown = 16,
	equilibrium = 5,
	no_energy = true,
	tactical = { ATTACKAREA = {NATURE=1}, DISABLE = {pin = 1} },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 6, 40) end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 4, 8)) end, 
	getSlow = function(self, t) return math.ceil(self:combatTalentLimit(t, 100, 36, 60)) end, -- Limit < 100%
	getPin = function(self, t) return math.ceil(self:combatTalentLimit(t, 100, 25, 45)) end, -- Limit < 100%
	range = 0,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t,2.5, 4.5, nil, 0, 0, true)) --uses raw talent level
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.GRASPING_MOSS, {dam=self:mindCrit(t.getDamage(self, t)), pin=t.getPin(self, t), slow=t.getSlow(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
		activate_moss(self, t.id)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local slow = t.getSlow(self, t)
		local pin = t.getPin(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Instantly grow a moss circle of radius %d at your feet.
		Each turn the moss deals %0.2f nature damage to each foe within its radius.
		This moss is very thick and sticky causing all foes passing through it have their movement speed reduced by %d%% and have a %d%% chance to be pinned to the ground for 4 turns.
		The moss lasts %d turns.
		Moss talents are instant but place all other moss talents on cooldown for 3 turns.
		The damage will increase with your Mindpower.]]):
		format(radius, damDesc(self, DamageType.NATURE, damage), slow, pin, duration)
	end,
}

newTalent{
	name = "Nourishing Moss",
	type = {"wild-gift/moss", 2},
	require = gifts_req2,
	points = 5,
	cooldown = 16,
	equilibrium = 5,
	no_energy = true,
	tactical = { ATTACKAREA = {NATURE=1}, HEAL = 1 },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 6, 40) end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t,4,8)) end,
	getHeal = function(self, t) return math.floor(self:combatTalentLimit(t, 200, 62, 110)) end, -- Limit < 200%	
	range = 0,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t,2.5, 4.5, nil, 0, 0, true))
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.NOURISHING_MOSS, {dam=self:mindCrit(t.getDamage(self, t)), factor=t.getHeal(self, t)/100},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
		activate_moss(self, t.id)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local heal = t.getHeal(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Instantly grow a moss circle of radius %d at your feet.
		Each turn the moss deals %0.2f nature damage to each foe within its radius.
		This moss has vampiric properties and heals the user for %d%% of the damage done.
		The moss lasts %d turns.
		Moss talents are instant but place all other moss talents on cooldown for 3 turns.
		The damage will increase with your Mindpower.]]):
		format(radius, damDesc(self, DamageType.NATURE, damage), heal, duration)
	end,
}

newTalent{
	name = "Slippery Moss",
	type = {"wild-gift/moss", 3},
	require = gifts_req3,
	points = 5,
	cooldown = 16,
	equilibrium = 5,
	no_energy = true,
	tactical = { ATTACKAREA = {NATURE=1}, DISABLE = {pin = 1} },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 6, 40) end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 4, 8)) end,
	getFail = function(self, t) return math.min(50, 15 + math.ceil(self:getTalentLevel(t) * 4)) end,
	range = 0,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t,2.5, 4.5, nil, 0, 0, true)) 
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.SLIPPERY_MOSS, {dam=self:mindCrit(t.getDamage(self, t)), fail=t.getFail(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
		activate_moss(self, t.id)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local fail = t.getFail(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Instantly grow a moss circle of radius %d at your feet.
		Each turn the moss deals %0.2f nature damage to each foe within its radius.
		This moss is very slippery and causes affected foes to have a %d%% chance of failing to perform complex actions.
		The moss lasts %d turns.
		Moss talents are instant but place all other moss talents on cooldown for 3 turns.
		The damage will increase with your Mindpower.]]):
		format(radius, damDesc(self, DamageType.NATURE, damage), fail, duration)
	end,
}

newTalent{
	name = "Hallucinogenic Moss",
	type = {"wild-gift/moss", 4},
	require = gifts_req4,
	points = 5,
	cooldown = 16,
	equilibrium = 5,
	no_energy = true,
	tactical = { ATTACKAREA = {NATURE=1}, DISABLE = {pin = 1} },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 6, 40) end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 4, 8)) end,
	getChance = function(self, t) return math.ceil(self:combatTalentLimit(t, 100, 25.5, 47.5)) end, -- Limit < 100%
	getPower = function(self, t) return math.max(0,self:combatTalentLimit(t, 50, 20, 40)) end, -- Limit < 50%
	range = 0,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t,2.5, 4.5, nil, 0, 0, true))
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.HALLUCINOGENIC_MOSS, {dam=self:mindCrit(t.getDamage(self, t)), chance=t.getChance(self, t), power=t.getPower(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
		activate_moss(self, t.id)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local power = t.getPower(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Instantly grow a moss circle of radius %d at your feet.
		Each turn the moss deals %0.2f nature damage to each foe within its radius.
		This moss is coated with strange fluids and has a %d%% chance to confuse (power %d%%) foes passing through it for 2 turns.
		The moss lasts %d turns.
		Moss talents are instant but place all other moss talents on cooldown for 3 turns.
		The damage will increase with your Mindpower.]]):
		format(radius, damDesc(self, DamageType.NATURE, damage), chance, power, duration)
	end,
}
