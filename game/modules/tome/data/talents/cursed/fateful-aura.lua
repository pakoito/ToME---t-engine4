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

local curses_detrimental
local curses_beneficial
local curses_weapon
local curses_staff
local curses_armor

local function getEffect(list, item)
	-- filters on item.type and uses random weighting
	local weightTotal = 0
	for i, effect in pairs(list) do
		if not effect.item_type or effect.item_type == item.type then
			weightTotal = weightTotal + (effect.weighting or 1)
		end
	end

	local weight = rng.range(1, weightTotal)
	weightTotal = 0
	for i, effect in pairs(list) do
		if not effect.item_type or effect.item_type == item.type then
			weightTotal = weightTotal + (effect.weighting or 1)
			if weight <= weightTotal then return effect end
		end
	end
	return
end

local function addEffects(list, item, percent1, percent2, percent3)
	local effectCount
	local percent = rng.range(1, 100)
	if percent <= percent3 then
		effectCount = 3
	elseif percent <= percent3 + percent2 then
		effectCount = 2
	elseif percent <= percent3 + percent2 + percent1 then
		effectCount = 1
	else
		effectCount = 0
	end

	if effectCount > 0 then
		for i = 1, effectCount do
			local effect = getEffect(list, item)

			print(("* curse %s with [%s]"):format(item.name, effect.name))
			table.mergeAddAppendArray(item, effect.copy, true)
			item:resolve()
			item:resolve(nil, true)
		end
	end
	return effectCount
end

newTalent{
	name = "Cursed Touch",
	type = {"cursed/fateful-aura", 1},
	mode = "passive",
	require = cursed_wil_req1,
	points = 5,
	getAffectedPercent = function(self, t)
		return math.floor(math.max(0, 100 - (math.sqrt(self:getTalentLevel(t)) - 0.5) * 25))
	end,
	curseItem = function(self, t, item)
		if item.cursed_touch then return end
		if item.unique then return end
		if item.quest then return end
		if not item:wornInven() then return end
		if item.type == "ammo" then return end

		item.cursed_touch = true
		item.name = "cursed " .. item.name
		item.encumber = item.encumber + 1

		local affectedPercent
		local affected = 0

		-- cursed touch
		affectedPercent = t.getAffectedPercent(self, t)
		if not curses_detrimental then curses_detrimental = mod.class.Object:loadList("/data/general/objects/egos/curses-detrimental.lua") end
		affected = affected + addEffects(curses_detrimental, item, affectedPercent * 0.7, affectedPercent * 0.2, affectedPercent * 0.1)

		-- dark gifts
		local tDarkGifts = self:getTalentFromId(self.T_DARK_GIFTS)
		if tDarkGifts and self:getTalentLevelRaw(tDarkGifts) > 0 then
			affectedPercent = t.getAffectedPercent(self, t)
			if not curses_beneficial then curses_beneficial = mod.class.Object:loadList("/data/general/objects/egos/curses-beneficial.lua") end
			affected = affected + addEffects(curses_beneficial, item, affectedPercent * 0.7, affectedPercent * 0.2, affectedPercent * 0.1)
		end

		-- vengeful blessings
		if item.type == "weapon" then
			local tVengefulBlessings = self:getTalentFromId(self.T_VENGEFUL_BLESSINGS)
			if tVengefulBlessings and self:getTalentLevelRaw(tVengefulBlessings) > 0 then
				local list
				if item.subtype == "staff" then
					if not curses_staff then curses_staff = mod.class.Object:loadList("/data/general/objects/egos/curses-staff.lua") end
					list = curses_staff
				else
					if not curses_weapon then curses_weapon = mod.class.Object:loadList("/data/general/objects/egos/curses-weapon.lua") end
					list = curses_weapon
				end
				affectedPercent = t.getAffectedPercent(self, t)
				affected = affected + addEffects(list, item, affectedPercent * 0.65, affectedPercent * 0.25, affectedPercent * 0.1)
			end
		end

		-- grim craft
		if item.type == "armor" then
			local tGrimCraft = self:getTalentFromId(self.T_GRIM_CRAFT)
			if tGrimCraft and self:getTalentLevelRaw(tGrimCraft) > 0 then
				if not curses_armor then curses_armor = mod.class.Object:loadList("/data/general/objects/egos/curses-armor.lua") end
				affectedPercent = t.getAffectedPercent(self, t)
				affected = affected + addEffects(curses_armor, item, affectedPercent * 0.65, affectedPercent * 0.25, affectedPercent * 0.1)
			end
		end

		if affected > 0 then item.name = "cursed ".. item.name end
	end,
	curseFloor = function(self, t, x, y)
		local i = 1
		local item = game.level.map:getObject(x, y, i)
		while item do
			t.curseItem(self, t, item)

			i = i + 1
			item = game.level.map:getObject(x, y, i)
		end
	end,
	activate = function(self, t)
		return { }
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local affectedPercent = t.getAffectedPercent(self, t)

		return ([[Your cursed touch permeates everything around you. Any non-unique equipment you find gains 1 extra weight and has a %d%% chance of receiving 1 curse, %d%% chance of 2 curses or a %d%% chance of 3 curses.]]):format(affectedPercent * 0.7, affectedPercent * 0.2, affectedPercent * 0.1)
	end,
}

newTalent{
	name = "Dark Gifts",
	type = {"cursed/fateful-aura", 2},
	mode = "passive",
	require = cursed_wil_req2,
	points = 5,
	getAffectedPercent = function(self, t)
		return math.floor(math.min(100, 20 + (math.sqrt(self:getTalentLevel(t)) - 0.5) * 30))
	end,
	info = function(self, t)
		local affectedPercent = t.getAffectedPercent(self, t)

		return ([[Your curses can also bring dark gifts. All cursed items have a %d%% chance of receiving 1 beneficial effect, %d%% chance of 2 beneficial effects or a %d%% chance of 3 beneficial effects.]]):format(affectedPercent * 0.7, affectedPercent * 0.2, affectedPercent * 0.1)
	end,
}

newTalent{
	name = "Vengeful Blessings",
	type = {"cursed/fateful-aura", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	getAffectedPercent = function(self, t)
		return math.floor(math.min(100, 20 + (math.sqrt(self:getTalentLevel(t)) - 0.5) * 30))
	end,
	info = function(self, t)
		local affectedPercent = t.getAffectedPercent(self, t)

		return ([[Bestow vengeful blessings on your tools of death. Cursed weapons or staves have a %d%% chance of receiving 1 beneficial effect, %d%% chance of 2 beneficial effects or a %d%% chance of 3 beneficial effects.]]):format(affectedPercent * 0.65, affectedPercent * 0.25, affectedPercent * 0.1)
	end,
}

newTalent{
	name = "Grim Craft",
	type = {"cursed/fateful-aura", 4},
	mode = "passive",
	require = cursed_wil_req4,
	points = 5,
	getAffectedPercent = function(self, t)
		return math.floor(math.min(100, 20 + (math.sqrt(self:getTalentLevel(t)) - 0.5) * 30))
	end,
	info = function(self, t)
		local affectedPercent = t.getAffectedPercent(self, t)

		return ([[Craft to your defenses for the slaughter that lies ahead. Cursed body armor has a %d%% chance of receiving 1 beneficial effect, %d%% chance of 2 beneficial effects or a %d%% chance of 3 beneficial effects.]]):format(affectedPercent * 0.65, affectedPercent * 0.25, affectedPercent * 0.1)
	end,
}