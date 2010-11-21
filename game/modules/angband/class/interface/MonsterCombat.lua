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

require "engine.class"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"

--- Interface to add angband monster combat system
module(..., package.seeall, class.make)

--- Checks what to do with the target
-- Talk ? attack ? displace ?
function _M:bumpInto(target)
	local reaction = self:reactionToward(target)
	if reaction < 0 then
		return self:attackTarget(target)
	elseif reaction >= 0 then
		if self.move_others then
			-- Displace
			game.level.map:remove(self.x, self.y, Map.ACTOR)
			game.level.map:remove(target.x, target.y, Map.ACTOR)
			game.level.map(self.x, self.y, Map.ACTOR, target)
			game.level.map(target.x, target.y, Map.ACTOR, self)
			self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y
		end
	end
end

function _M:testHit(chance, ac, vis)
	local k

	-- Percentile dice
	k = rng.range(0, 99)

	-- Hack -- Instant miss or hit
	if (k < 10) then return (k < 5) end

	-- Penalize invisible targets
	if (not vis) then chance = chance / 2 end

	-- Power competes against armor
	if ((chance > 0) and (rng.range(0, chance-1) >= (ac * 3 / 4))) then return true end

	-- Assume miss
	return false
end


--- Determine if a monster attack against the player succeeds.
function _M:checkHit(power, level, ac)
	local chance

	-- Calculate the "attack quality"
	chance = (power + (level * 3))

	-- Check if the player was hit
	return self:testHit(chance, ac, true)
end

local methods = {
	HIT = { miss="misses you", hit="hits you.", do_cut=1, do_stun=1 },
	TOUCH = { miss="misses you", hit = "touches you.", },
	PUNCH = { miss="misses you", hit = "punches you.",do_stun = 1, },
	KICK = { miss="misses you", hit = "kicks you.",do_stun = 1, },
	CLAW = { miss="misses you", hit = "claws you.",do_cut = 1,},
	BITE = { miss="misses you", hit = "bites you.",do_cut = 1,},
	STING = { miss="misses you", hit = "stings you.",},
	BUTT = { miss="misses you", hit = "butts you.",do_stun = 1,},
	CRUSH = { miss="misses you", hit = "crushes you.",do_stun = 1,},
	ENGULF = { miss="misses you", hit = "engulfs you.",},
	CRAWL = { miss="misses you", hit = "crawls on you.",},
	DROOL = { miss="misses you", hit = "drools on you.",},
	SPIT = { miss="misses you", hit = "spits on you.",},
	GAZE = { miss="misses you", hit = "gazes at you.",},
	WAIL = { miss="misses you", hit = "wails at you.",},
	SPORE = { miss="misses you", hit = "releases spores at you.",},
	BEG = { miss="misses you", hit = "begs you for money.",},
	INSULT = { miss="misses you", hit = "insults you.",},
	MOAN = { miss="misses you", hit = "moams.", },
}

local effects = {
	HURT = { power=60, act=function(self, target, dam, ac)
		dam = dam - (dam * math.min(ac, 240) / 400)
		DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, dam)
	end },
	POISON = { power=5, act=function(self, target, dam, ac)
		DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, dam)
		if target:canBe("poison") then target:setEffect(target.EFF_POISONED, rng.range(1, self.level) + 5, {src=self}) end
	end },
}

--- Makes the death happen!
function _M:attackTarget(target, mult)
	if self:attr("never_blow") then return end
	if not self.blows then return end

	local ac = (target.ac or 0) + (target.to_a or 0)
	local rlev = math.max(1, self.level)

	for i, blow in ipairs(self.blows) do
		if blow.method and blow.effect then
			local meth = methods[blow.method]
			local eff = effects[blow.effect]

			if not meth then game.log("#LIGHT_RED#Method %s not defined yet!", blow.method) meth = methods.HIT end
			if not eff then game.log("#LIGHT_RED#Effect %s not defined yet!", blow.effect) eff = effects.HURT end

			local power = eff.power
			if self:checkHit(power, rlev, ac) then
				local dam = rng.dice(blow.damage[1], blow.damage[2])
				game.logPlayer(target, "%s %s", self.name, meth.hit)
				eff.act(self, target, dam, ac)
			end
		end
	end

	-- We use up our own energy
	self:useEnergy(game.energy_to_act)
end
