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

local Object = require "engine.Object"

local curses_detrimental
local curses_beneficial
local curses_weapon

local function getEffect(list, item, who, level, effectName)
	-- filters on item.type, etc. and uses random weighting
	local weightTotal = 0
	local effects = {}
	for i, effect in pairs(list) do
		if (not effect.level or effect.level == level)
				and (not effect.item_type or effect.item_type == item.type)
				and (not effect.item_subtype or effect.item_subtype == item.subtype)
				and (not effect.subclass or effect.subclass == (who.descriptor and who.descriptor.subclass or who.subtype))
				and (not item.uses_special_on_hit or not item.combat or not item.combat.special_on_hit)then
			if effectName and effect.name == effectName then return effect end

			weightTotal = weightTotal + (effect.weighting or 1)
			effects[#effects + 1] = effect
		end
	end

	local weight = rng.range(1, weightTotal)
	weightTotal = 0
	for i, effect in pairs(effects) do
		weightTotal = weightTotal + (effect.weighting or 1)
		if weight <= weightTotal then return effect end
	end
	print("* fateful-aura getEffect failed. count:", #list, "found:", #effects, "weightTotal:", weightTotal, "weight:", weight, "item:", item.name, "type:", item.type, "subtype:", item.subtype, "level:", level, "subclass:", (who.descriptor and who.descriptor.subclass or who.subtype))
	return
end

local function addEffect(item, effect, who, power)
	if effect.copy then
		table.mergeAddAppendArray(item, effect.copy, true)
		item:resolve()
		item:resolve(nil, true)
	end
	if effect.apply then
		effect.apply(item, who, power)
	end

	if item.extra_description then
		item.extra_description = item.extra_description..", #F53CBE#"..effect.name.."#LAST#"
	else
		item.extra_description = "#F53CBE#"..effect.name.."#LAST#"
	end
end

newTalent{
	name = "Cursed Touch",
	type = {"cursed/fateful-aura", 1},
	mode = "passive",
	require = cursed_wil_req1,
	points = 5,
	getCurseChance = function(self, t)
		return math.floor(math.min(100, 30 + (math.sqrt(self:getTalentLevel(t)) - 1) * 50))
	end,
	getMajorChance = function(self, t)
		return math.floor(math.max(0, 30 - (math.sqrt(self:getTalentLevel(t)) - 1) * 25))
	end,
	curseItem = function(self, t, item)
		if item.cursed_touch then return end
		if item.unique then return end
		if item.quest then return end
		if not item:wornInven() then return end
		if item.type == "ammo" or item.type == "alchemist-gem" or item.type == "gem" then return end

		--[[ test to run all code
		if not curses_detrimental then curses_detrimental = mod.class.Object:loadList("/data/general/objects/egos/curses-detrimental.lua") end
		if not curses_weapon then curses_weapon = mod.class.Object:loadList("/data/general/objects/egos/curses-weapon.lua") end
		if not curses_beneficial then curses_beneficial = mod.class.Object:loadList("/data/general/objects/egos/curses-beneficial.lua") end
		local tal = t
		local lis
		if item.type == "weapon" then
			lis = curses_weapon
		elseif item.type == "lite" then
			lis = curses_beneficial
		else
			lis = curses_detrimental
		end
		if lis then
			for i, effect in pairs(lis) do
				addEffect(item, effect, self, 1)
			end
			item.cursed = true
			item.name = "cursed ".. item.name
			if false then return nil end
		end
		-- end test]]

		-- prevent re-cursion
		item.cursed_touch = true

		-- add a curse?
		if not rng.percent(t.getCurseChance(self, t)) then return end

		-- effect power
		local power = 0.3 + (item.material_level or 3) * 0.1

		local level

		-- beneficial
		local beneficialEffect
		local tDarkGifts = self:getTalentFromId(self.T_DARK_GIFTS)
		if tDarkGifts and self:getTalentLevelRaw(tDarkGifts) > 0 then
			local tVengefulBlessings = self:getTalentFromId(self.T_VENGEFUL_BLESSINGS)

			local list
			if item.type == "weapon" and tVengefulBlessings and self:getTalentLevelRaw(tVengefulBlessings) > 0 and rng.percent(tVengefulBlessings.getChance(self, tVengefulBlessings)) then
				if not curses_weapon then curses_weapon = mod.class.Object:loadList("/data/general/objects/egos/curses-weapon.lua") end
				list = curses_weapon
				if rng.percent(tVengefulBlessings.getMajorChance(self, t)) then level = 2 else level = 1 end
				power = power * (1 + tVengefulBlessings.getPowerPercent(self, tVengefulBlessings) / 100)
			else
				if not curses_beneficial then curses_beneficial = mod.class.Object:loadList("/data/general/objects/egos/curses-beneficial.lua") end
				list = curses_beneficial
				if rng.percent(tDarkGifts.getMajorChance(self, t)) then level = 2 else level = 1 end
				power = power * (1 + tDarkGifts.getPowerPercent(self, tDarkGifts) / 100)
			end

			beneficialEffect = getEffect(list, item, self, level)
		end

		-- detrimental
		local detrimentalEffect
		local effectName
		if rng.percent(t.getMajorChance(self, t)) then level = 2 else level = 1 end
		if beneficialEffect and beneficialEffect.detrimental then effectName = rng.table(beneficialEffect.detrimental) end -- select a recommended curse
		if not curses_detrimental then curses_detrimental = mod.class.Object:loadList("/data/general/objects/egos/curses-detrimental.lua") end
		detrimentalEffect = getEffect(curses_detrimental, item, self, level, effectName)

		-- apply the curse
		item.cursed = true
		item.name = "cursed ".. item.name
		item.encumber = item.encumber + 1

		addEffect(item, detrimentalEffect, self, power)
		if beneficialEffect then
			addEffect(item, beneficialEffect, self, power)
		end

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
		local curseChance = t.getCurseChance(self, t)
		local majorChance = t.getMajorChance(self, t)

		return ([[Your cursed touch permeates everything around you. Any non-unique equipment you find has a %d%% chance of becoming cursed. Cursed objects gain 1 extra weight and receive a harmful effect. There is a %d%% chance of a major effect.]]):format(curseChance, majorChance)
	end,
}

newTalent{
	name = "Dark Gifts",
	type = {"cursed/fateful-aura", 2},
	mode = "passive",
	require = cursed_wil_req2,
	points = 5,
	getMajorChance = function(self, t)
		return math.floor(math.min(100, 10 + (math.sqrt(self:getTalentLevel(t)) - 1) * 20))
	end,
	getPowerPercent = function(self, t)
		return math.floor((math.sqrt(self:getTalentLevel(t)) - 1) * 20)
	end,
	info = function(self, t)
		local majorChance = t.getMajorChance(self, t)
		local powerPercent = t.getPowerPercent(self, t)

		return ([[Your curses will also bring dark gifts. All cursed items receive a beneficial effect with a %d%% chance of a major effect. Your gifts gain %d%% more power.]]):format(majorChance, powerPercent)
	end,
}

newTalent{
	name = "Vengeful Blessings",
	type = {"cursed/fateful-aura", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	getChance = function(self, t)
		return math.floor(math.min(100, 35 + (math.sqrt(self:getTalentLevel(t)) - 1) * 30))
	end,
	getMajorChance = function(self, t)
		return math.floor(math.min(100, 10 + (math.sqrt(self:getTalentLevel(t)) - 1) * 15))
	end,
	getPowerPercent = function(self, t)
		return math.floor((math.sqrt(self:getTalentLevel(t)) - 1) * 20)
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local majorChance = t.getMajorChance(self, t)
		local powerPercent = t.getPowerPercent(self, t)

		return ([[Bestow vengeful blessings on your tools of death. Cursed weapons or staves have a %d%% chance of being blessed with a powerful beneficial effect that replaces your dark gift. There is a %d%% chance of a major effect. Your blessings gain %d%% more power.]]):format(chance, majorChance, powerPercent)
	end,
}

newTalent{
	name = "Cursed Sentry",
	type = {"cursed/fateful-aura", 4},
	require = cursed_wil_req4,
	points = 5,
	cooldown = 40,
	range = 5,
	no_npc_use = true,
	getDuration = function(self, t)
		return math.floor(8 + (math.sqrt(self:getTalentLevel(t)) - 1) * 8)
	end,
	getAttackSpeed = function(self, t)
		return math.floor(60 + (math.sqrt(self:getTalentLevel(t)) - 1) * 60)
	end,
	action = function(self, t)
		local inven = self:getInven("INVEN")
		local found = false
		for i, obj in pairs(inven) do
			if type(obj) == "table" and obj.cursed and obj.type == "weapon" then
				found = true
			break
			end
		end
		if not found then
			game.logPlayer(self, "You cannot use %s without a cursed weapon in your inventory!", t.name)
			return false
		end

		-- select the location
		local range = self:getTalentRange(t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, x, y = self:canProject(tg, tx, ty)
		if game.level.map(x, y, Map.ACTOR) or game.level.map:checkEntity(x, y, game.level.map.TERRAIN, "block_move") then return nil end

		-- select the item
		local d = self:showInventory("Which weapon will be your sentry?", inven,
			function(o)
				return o.cursed and o.type == "weapon"
			end, nil)
		d.action = function(o, item)
				d.used_talent = true
				d.selected_object = o
				d.selected_item = item

				return false
			end

		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent, self.selected_object, d.selected_item) end
		local used_talent, o, item = coroutine.yield()
		if not used_talent then return nil end

		local result = self:removeObject(inven, item)

		local NPC = require "mod.class.NPC"
		local sentry = NPC.new {
			type = "construct", subtype = "weapon",
			display = o.display, color=o.color, image = o.image, blood_color = colors.GREY,
			name = "animated "..o.name, faction = self.faction,
			desc = "A weapon imbued with a living curse. It seems to be searching for its next victim.",
			faction = self.faction,
			body = { INVEN = 10, MAINHAND=1, QUIVER=1 },
			rank = 2,
			size_category = 1,

			autolevel = "warrior",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },

			max_life = 50, life_rating = 3,
			stats = { str=20, dex=20, mag=10, con=10 },
			combat = { dam=1, atk=1, apr=1 },
			combat_armor = 100, combat_def = 50,
			combat_physspeed = 100 / t.getAttackSpeed(self, t),
			infravision = 10,

			resists = { all = 75, },
			cut_immune = 1,
			blind_immune = 1,
			fear_immune = 1,
			poison_immune = 1,
			disease_immune = 1,
			stone_immune = 1,
			see_invisible = 30,
			no_breath = 1,
			disarm_immune = 1,
			never_move = 1,
			no_drops = true, -- remove to drop the weapon

			resolvers.talents{
				[Talents.T_WEAPON_COMBAT]={base=1, every=5, max=10},
				[Talents.T_WEAPONS_MASTERY]={base=1, every=5, max=10},
				[Talents.T_BOW_MASTERY]={base=1, every=5, max=10},
				[Talents.T_SHOOT]=1,
			},

			summoner = self,
			summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			summon_quiet = true,

			on_die = function(self, who)
				game.logSeen(self, "#F53CBE#%s crumbles to dust.", self.name:capitalize())
			end,
		}
		result = sentry:wearObject(o, true, false)

		sentry:resolve()
		sentry:resolve(nil, true)
		sentry:forceLevelup(self.level)
		game.zone:addEntity(game.level, sentry, "actor", x, y)

		sentry.no_party_ai = true
		sentry.unused_stats = 0
		sentry.unused_talents = 0
		sentry.unused_generics = 0
		sentry.unused_talents_types = 0
		sentry.no_points_on_levelup = true
		if game.party:hasMember(self) then
			sentry.remove_from_party_on_death = true
			game.party:addMember(sentry, { control="no", type="summon", title="Summon"})
		end

		game:playSoundNear(self, "talents/spell_generic")

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local attackSpeed = t.getAttackSpeed(self, t)

		return ([[Instill a part of your living curse into a weapon in your inventory and toss it nearby. This nearly impervious sentry will attack all nearby enemies for %d turns. When the curse ends the weapon will crumble to dust. Attack Speed: %d%%]]):format(duration, attackSpeed)
	end,
}
