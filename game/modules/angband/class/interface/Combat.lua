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
local Target = require "engine.Target"
local Talents = require "engine.interface.ActorTalents"

--- Interface to add ToME combat system
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
	print("[TEST HIT]", chance, ac, vis)

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

--- Makes the death happen!
local BTH_PLUS_ADJ = 3
function _M:attackTarget(target)
	if self:attr("afraid") then game.logPlayer(self, "You are too afraid to attack.") return end

	local weapon = self:getInven("WEAPON")[1]
	local bonus = (self.to_h or 0) + (weapon and weapon.to_h or 0)
	local chance = self:getSkill("thn") + BTH_PLUS_ADJ * bonus

	local nb_blows = self:calcBlows(weapon)
	print("[ATTACK] blows", nb_blows)
	for i = 1, nb_blows do
		if self:testHit(chance, target.ac, game.level.map.seens(target.x, target.y)) then
			local dam = 1
			local verb = "punch"
			if weapon and weapon.damage then
				local mult = 1
				verb = "hit"
				dam = rng.dice(weapon.damage[1], weapon.damage[2])
				dam = dam * mult
				dam = dam + (weapon.to_d or 0)
			end

			dam = dam + (self.to_d or 0)
			if dam < 0 then k = 0 verb = "fail to harm" end

			game.logPlayer(self, "You %s %s.", verb, target.name)
			print("[ATTACK] damage", dam)
			DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, dam)
		else
			game.logPlayer(self, "You miss %s.", target.name)
		end
	end

	-- We use up our own energy
	self:useEnergy(game.energy_to_act)
end

function _M:getSkill(s)
	local base = (self["skill_"..s] or 0) + (self["xskill_"..s] or 0) * math.floor(self.level / 10)
	return base
end

-- This table is used to help calculate the number of blows the player can
-- make in a single round of attacks (one player turn) with a normal weapon.
--
-- This number ranges from a single blow/round for weak players to up to six
-- blows/round for powerful warriors.
--
-- Note that certain artifacts and ego-items give "bonus" blows/round.
--
-- First, from the player class, we extract some values:
--
--    Warrior --> num = 6; mul = 5; div = MAX(30, weapon_weight);
--    Mage    --> num = 4; mul = 2; div = MAX(40, weapon_weight);
--    Priest  --> num = 4; mul = 3; div = MAX(35, weapon_weight);
--    Rogue   --> num = 5; mul = 4; div = MAX(30, weapon_weight);
--    Ranger  --> num = 5; mul = 4; div = MAX(35, weapon_weight);
--    Paladin --> num = 5; mul = 5; div = MAX(30, weapon_weight);
-- (all specified in p_class.txt now)
--
-- To get "P", we look up the relevant "adj_str_blow[]" (see above),
-- multiply it by "mul", and then divide it by "div", rounding down.
--
-- To get "D", we look up the relevant "adj_dex_blow[]" (see above).
--
-- Then we look up the energy cost of each blow using "blows_table[P][D]".
-- The player gets blows/round equal to 100/this number, up to a maximum of
-- "num" blows/round, plus any "bonus" blows/round.
local blows_table =
{
	-- P
   -- D:   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,   10,  11+
   -- DEX: 3,   10,  17,  /20, /40, /60, /80, /100,/120,/150,/180,/200

	-- 0
	{  100, 100, 95,  85,  75,  60,  50,  42,  35,  30,  25,  23 },

	-- 1
	{  100, 95,  85,  75,  60,  50,  42,  35,  30,  25,  23,  21 },

	-- 2
	{  95,  85,  75,  60,  50,  42,  35,  30,  26,  23,  21,  20 },

	-- 3
	{  85,  75,  60,  50,  42,  36,  32,  28,  25,  22,  20,  19 },

	-- 4
	{  75,  60,  50,  42,  36,  33,  28,  25,  23,  21,  19,  18 },

	-- 5
	{  60,  50,  42,  36,  33,  30,  27,  24,  22,  21,  19,  17 },

	-- 6
	{  50,  42,  36,  33,  30,  27,  25,  23,  21,  20,  18,  17 },

	-- 7
	{  42,  36,  33,  30,  28,  26,  24,  22,  20,  19,  18,  17 },

	-- 8
	{  36,  33,  30,  28,  26,  24,  22,  21,  20,  19,  17,  16 },

	-- 9
	{  35,  32,  29,  26,  24,  22,  21,  20,  19,  18,  17,  16 },

	-- 10
	{  34,  30,  27,  25,  23,  22,  21,  20,  19,  18,  17,  16 },

	-- 11+
	{  33,  29,  26,  24,  22,  21,  20,  19,  18,  17,  16,  15 },
   -- DEX: 3,   10,  17,  /20, /40, /60, /80, /100,/120,/150,/180,/200
}

-- Stat Table (STR) -- help index into the "blow" table
local adj_str_blow =
{
	3	,
	4	,
	5	,
	6	,
	7	,
	8	,
	9	,
	10	,
	11	,
	12	,
	13	,
	14	,
	15	,
	16	,
	17	,
	20 ,
	30 ,
	40 ,
	50 ,
	60 ,
	70 ,
	80 ,
	90 ,
	100 ,
	110 ,
	120 ,
	130 ,
	140 ,
	150 ,
	160 ,
	170 ,
	180 ,
	190 ,
	200 ,
	210 ,
	220 ,
	230 ,
	240 -- 18/220+
}

-- Stat Table (DEX) -- index into the "blow" table
local adj_dex_blow =
{
	0	,
	0	,
	0	,
	0	,
	0	,
	0	,
	0	,
	1	,
	1	,
	1	,
	1	,
	1	,
	1	,
	1	,
	1	,
	1	,
	2	,
	2	,
	2	,
	2	,
	3	,
	3	,
	4	,
	4	,
	5	,
	6	,
	7	,
	8	,
	9	,
	10	,
	11	,
	12	,
	14	,
	16	,
	18	,
	20	,
	20	,
	20
}


function _M:calcBlows(weapon)
	if not weapon then return 1 end

	local blows
	local str_index, dex_index
	local div
	local blow_energy

	-- Enforce a minimum "weight" (tenth pounds)
	div = (weapon.weight < self.min_weight) and self.min_weight or weapon.weight

	-- Get the strength vs weight
	str_index = adj_str_blow[self:getStr() - 2] * math.floor(self.att_multiply / div)

	-- Maximal value
	str_index = math.min(11, str_index)

	-- Index by dexterity
	dex_index = math.min(adj_dex_blow[self:getDex() - 2], 11)

	-- Use the blows table to get energy per blow
	blow_energy = blows_table[str_index+1][dex_index+1]

	blows = math.min(math.floor(100 / blow_energy), self.max_attacks)

	-- Require at least one blow
	return math.max(blows, 1)
end
