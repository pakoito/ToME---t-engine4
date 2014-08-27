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

local Talents = require "engine.interface.ActorTalents"

--- Resolves equipment creation for an actor
function resolvers.equip(t)
	return {__resolver="equip", __resolve_last=true, t}
end
function resolvers.equipbirth(t)
	for i, filter in ipairs(t) do
		filter.ignore_material_restriction = true
	end
	return {__resolver="equip", __resolve_last=true, t}
end
--- Actually resolve the equipment creation
function resolvers.calc.equip(t, e)
--	print("Equipment resolver for", e.name)
	-- Iterate over object requests, try to create them and equip them
	for i, filter in ipairs(t[1]) do
--		print("Equipment resolver", e.name, filter.type, filter.subtype, filter.defined, filter.random_art_replace)
		local o
		local tries = 0
		repeat
			local ok = true
			tries = tries + 1
			if not filter.defined then
				o = game.zone:makeEntity(game.level, "object", filter, nil, true)
			else
				local forced
				o, forced = game.zone:makeEntityByName(game.level, "object", filter.defined, filter.random_art_replace and true or false)
				-- If we forced the generation this means it was already found
				if forced then
--					print("Serving unique "..o.name.." but forcing replacement drop")
					filter.random_art_replace.chance = 100
				end
			end
			if o and o.power_source and (o.power_source.antimagic and e:attr("has_arcane_knowledge") or o.power_source.arcane and e:attr("forbid_arcane")) then -- check antimagic restrictions
--			if o and not filter.no_power_restrictions and not game.state:checkPowers(e, o) then -- Check power restrictions
				ok = false
				print("  Equipment resolver for ", e.name ," -- incompatible equipment ", o.name, "retrying", tries, "forbid ps:", filter.forbid_power_source and table.concat(table.keys(filter.forbid_power_source, ",")), "vs ps", o.power_source and table.concat(table.keys(o.power_source), ","))
			end
		until ok or tries > 4
		if o then
---		print("Zone made us an equipment according to filter!", o:getName())
			-- curse (done here to ensure object attributes get applied correctly)
			if e:knowTalent(e.T_DEFILING_TOUCH) then
				local t = e:getTalentFromId(e.T_DEFILING_TOUCH)
				t.curseItem(e, t, o)
			end

			-- Auto alloc some stats to be able to wear it
			if filter.autoreq and rawget(o, "require") and rawget(o, "require").stat then
--				print("Autorequire stats")
				for s, v in pairs(rawget(o, "require").stat) do
					if e:getStat(s) < v then
						e.unused_stats = e.unused_stats - (v - e:getStat(s))
						e:incStat(s, v - e:getStat(s))
					end
				end
			end

			if e:wearObject(o, true, false) == false then
				e:addObject(e.INVEN_INVEN, o)
			end

			-- Do not drop it unless it is an ego or better
			if not o.unique then o.no_drop = true --[[print(" * "..o.name.." => no drop")]] end
			if filter.force_drop then o.no_drop = nil end
			if filter.never_drop then o.no_drop = true end
			game.zone:addEntity(game.level, o, "object")

			if t[1].id then o:identify(t[1].id) end

			if filter.random_art_replace then
				o.__special_boss_drop = filter.random_art_replace
			end
		end
	end
	-- Delete the origin field
	return nil
end


--- Resolves equipment creation for an actor
function resolvers.attachtinker(t)
	return {__resolver="attachtinker", __resolve_last=true, t}
end
function resolvers.attachtinkerbirth(t)
	for i, filter in ipairs(t) do
		filter.ignore_material_restriction = true
	end
	return {__resolver="attachtinker", __resolve_last=true, t}
end
--- Actually resolve the equipment creation
function resolvers.calc.attachtinker(t, e)
	print("Tinker resolver for", e.name)
	-- Iterate of object requests, try to create them and equip them
	for i, filter in ipairs(t[1]) do
		print("Tinker resolver", e.name, filter.type, filter.subtype, filter.defined)
		local o
		if not filter.defined then
			o = game.zone:makeEntity(game.level, "object", filter, nil, true)
		else
			local forced
			o, forced = game.zone:makeEntityByName(game.level, "object", filter.defined, filter.random_art_replace and true or false)
			-- If we forced the generation this means it was already found
			if forced then
--				print("Serving unique "..o.name.." but forcing replacement drop")
				filter.random_art_replace.chance = 100
			end
		end
		if o then
			print("Zone made us an Tinker according to filter!", o:getName())
			-- Auto alloc some stats to be able to wear it
			if filter.autoreq and rawget(o, "require") and rawget(o, "require").stat then
--				print("Autorequire stats")
				for s, v in pairs(rawget(o, "require").stat) do
					if e:getStat(s) < v then
						e.unused_stats = e.unused_stats - (v - e:getStat(s))
						e:incStat(s, v - e:getStat(s))
					end
				end
			end

			local base_inven, base_item = e:findTinkerSpot(o)
			if base_inven and base_item then
				local base_o = base_inven[base_item]
				e:doWearTinker(nil, nil, o, base_inven, base_item, base_o, true)
				if t[1].id then o:identify(t[1].id) end
			end
		end
	end
	-- Delete the origin field
	return nil
end

--- Resolves inventory creation for an actor
function resolvers.inventory(t)
	return {__resolver="inventory", __resolve_last=true, t}
end
function resolvers.inventorybirth(t)
	for i, filter in ipairs(t) do
		filter.ignore_material_restriction = true
	end
	return {__resolver="inventory", __resolve_last=true, t}
end
--- Actually resolve the inventory creation
function resolvers.calc.inventory(t, e)
	-- Iterate of object requests, try to create them and equip them
	for i, filter in ipairs(t[1]) do
		print("Inventory resolver", e.name, e.filter, filter.type, filter.subtype)
		local o
		if not filter.defined then
			o = game.zone:makeEntity(game.level, "object", filter, nil, true)
		else
			if filter.base_list then
				local _, _, class, file = filter.base_list:find("(.*):(.*)")
				if class and file then
					local base_list = require(class):loadList(file)
					base_list.__real_type = "object"
					o = game.zone:makeEntityByName(game.level, base_list, filter.defined)
				end
			else
				o = game.zone:makeEntityByName(game.level, "object", filter.defined)
			end
		end
		if o then
--			print("Zone made us an inventory according to filter!", o:getName())
			e:addObject(t[1].inven and e:getInven(t[1].inven) or e.INVEN_INVEN, o)
			game.zone:addEntity(game.level, o, "object")

			if t[1].id then o:identify(t[1].id) end
			if t[1].transmo then o.__transmo = true end
		end
	end
	e:sortInven()
	-- Delete the origin field
	return nil
end

--- Resolves drops creation for an actor
function resolvers.drops(t)
	return {__resolver="drops", __resolve_last=true, t}
end
--- Actually resolve the drops creation
function resolvers.calc.drops(t, e)
	t = t[1]
	if not rng.percent(t.chance or 100) then return nil end
	if t.check and not t.check(e) then return nil end

	-- Iterate of object requests, try to create them and drops them
	for i = 1, (t.nb or 1) do
		local filter = t[rng.range(1, #t)]
		filter = table.clone(filter)

		-- Make sure if we request uniques we do not get lore, it would be kinda deceptive
		if filter.unique then
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "lore"
		end

--		print("Drops resolver", e.name, filter.type, filter.subtype, filter.defined)
		local o
		if not filter.defined then
			o = game.zone:makeEntity(game.level, "object", filter, nil, true)
		else
			local forced
			o, forced = game.zone:makeEntityByName(game.level, "object", filter.defined, filter.random_art_replace and true or false)
			-- If we forced the generation this means it was already found
			if forced then
--				print("Serving unique "..o.name.." but forcing replacement drop")
				filter.random_art_replace.chance = 100
			end
		end
		if o then
--			print("Zone made us a drop according to filter!", o:getName())
			e:addObject(e.INVEN_INVEN, o)
			game.zone:addEntity(game.level, o, "object")

			if t.id then o:identify(t.id) end

			if filter.random_art_replace then
				o.__special_boss_drop = filter.random_art_replace
			end
		end
	end
	-- Delete the origin field
	return nil
end

-- Resolves material level based on actor level
-- @param base = base value at level = base_level (scales as sqrt)
-- @param spread = number of std deviations (1 usually) in material level
-- @param min, max = material level limits
function resolvers.matlevel(base, base_level, spread, mn, mx)
	return {__resolver="matlevel", base, base_level, spread, mn, mx}
end
function resolvers.calc.matlevel(t, e)
	local mean = math.min(e.level/10+1,t[1] * (e.level/t[2])^.5) -- I5 material level scales up with sqrt of actor level or level/10
	local spread = math.max(t[3],mean/5) -- spread out probabilities at high level
	local mn = t[4] or 1
	local mx = t[5] or 5
	
	local rand = math.floor(rng.normalFloat(mean,spread))
	return util.bound(rand,mn,mx)
end

-- Estimate actor final level for drop calculations (.__resolve_last does not work)
local function actor_final_level(e)
	local finlevel = math.max(math.max(e.level,e.start_level),1)
	if game.zone.actor_adjust_level and e.forceLevelup then
		return math.max(finlevel, game.zone:actor_adjust_level(game.level, e) + e:getRankLevelAdjust())
	else
		return math.max(finlevel, game.zone.base_level + e:getRankLevelAdjust())
	end
end

--- Resolves drops creation for an actor; drops a created on the fly randart
function resolvers.drop_randart(t)
	return {__resolver="drop_randart", __resolve_last=true, t}
end
--- Actually resolve the drops creation
function resolvers.calc.drop_randart(t, e)
	t = t[1]
	local filter = t.filter

 	local matresolver = resolvers.matlevel(5,50,1,2) -- Min material level 2
   
--	game.log("#LIGHT_BLUE#Calculating randart drop for %s (uid %d, est level %d)",e.name,e.uid,actor_final_level(e))
	if not filter then
		filter = {ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}, special=function(eq)
			local matlevel = resolvers.calc.matlevel(matresolver,{level = actor_final_level(e)})
--			game.log("Checking equipment %s against material level %d for %s (final level %d)",eq.name,matlevel,e.name, actor_final_level(e))
			return (not eq.unique and eq.randart_able) and eq.material_level == matlevel and true or false
		end}
	end

--	print("Randart Drops resolver")
	local base = nil
	if filter then
		if not filter.defined then
			base = game.zone:makeEntity(game.level, "object", filter, nil, true)
		else
			base = game.zone:makeEntityByName(game.level, "object", filter.defined)
		end
	end

	local o = game.state:generateRandart{base=base, lev=resolvers.current_level}
	if o then
--		print("Zone made us a randart drop according to filter!", o:getName{force_id=true})
		e:addObject(e.INVEN_INVEN, o)
		game.zone:addEntity(game.level, o, "object")

		if t.id then o:identify(t.id) end
	end
	-- Delete the origin field
	return nil
end

--- Resolves drops creation for an actor
function resolvers.store(def, faction, door, sign)
	return {__resolver="store", def, faction, door, sign}
end
--- Actually resolve the drops creation
function resolvers.calc.store(t, e)
	if t[3] then
		e.image = t[3]
		if t[4] then e.add_mos = {{display_x=0.6, image=t[4]}} end
	end

	e.store_faction = t[2]
	t = t[1]

	e.block_move = function(self, x, y, who, act, couldpass)
		if who and who.player and act then
			if self.store_faction and who:reactionToward({faction=self.store_faction}) < 0 then return true end
			self.store:loadup(game.level, game.zone)
			self.store:interact(who, self.name)
		end
		return true
	end
	e.store = game:getStore(t)
	e.store.faction = e.store_faction
--	print("[STORE] created for entity", t, e, e.name)

	-- Delete the origin field
	return nil
end

--- Resolves chat creation for an actor
function resolvers.chatfeature(def, faction)
	return {__resolver="chatfeature", def, faction}
end
--- Actually resolve the drops creation
function resolvers.calc.chatfeature(t, e)
	e.chat_faction = t[2]
	t = t[1]

	if e.chat_faction then
		e.chat_display_entity = engine.Entity.new{image="faction/"..e.chat_faction..".png"}
	end

	e.block_move = function(self, x, y, who, act, couldpass)
		if who and who.player and act then
			if self.chat_faction and who:reactionToward({faction=self.chat_faction}) < 0 then return true end
			local Chat = require("engine.Chat")
			local chat = Chat.new(self.chat, self, who, {npc=self, player=who})
			chat:invoke()
		end
		return true
	end
	e.chat = t

	-- Delete the origin field
	return nil
end

--- Random bonus based on level (sets the mbonus max level, we use 60 instead of 50 to get some forced randomness at high level)
resolvers.mbonus_max_level = 90

--- Random bonus based on level and material quality
resolvers.current_level = 1
function resolvers.mbonus_material(max, add, pricefct)
	return {__resolver="mbonus_material", max, add, pricefct}
end
function resolvers.calc.mbonus_material(t, e)
	local ml = e.material_level or 1
	local v = math.ceil(rng.mbonus(t[1], resolvers.current_level, resolvers.mbonus_max_level) * ml / 5) + (t[2] or 0)

	if e.cost and t[3] then
		local ap, nv = t[3](e, v)
		e.cost = e.cost + ap
		v = nv or v
	end

	if e.ego_bonus_mult then
		if v >= 1 then
			v = math.ceil(v * (1 + e.ego_bonus_mult))
		else
			v = v * (1 + e.ego_bonus_mult)
		end
	end

	return v
end

--- Random bonus based on level, more strict
resolvers.current_level = 1
function resolvers.mbonus_level(max, add, pricefct, step)
	return {__resolver="mbonus_level", max, add, step or 10, pricefct}
end
function resolvers.calc.mbonus_level(t, e)
	local max = resolvers.mbonus_max_level

	local ml = 1 + math.floor((resolvers.current_level - 1) / t[3])
	ml = util.bound(rng.float(ml, ml * 1.6), 1, 6)

	local maxl = 1 + math.floor((max - 1) / t[3])
	local power = 1 + math.log10(ml / maxl)

	local v = math.ceil(rng.mbonus(t[1], resolvers.current_level, max) * power) + (t[2] or 0)

	if e.cost and t[4] then
		local ap, nv = t[4](e, v)
		e.cost = e.cost + ap
		v = nv or v
	end

	return v
end

--- Random bonus based on level
resolvers.current_level = 1
function resolvers.mbonus(max, add, pricefct)
	return {__resolver="mbonus", max, add, pricefct}
end
function resolvers.calc.mbonus(t, e)
	local v = rng.mbonus(t[1], resolvers.current_level, resolvers.mbonus_max_level) + (t[2] or 0)

	if e.cost and t[3] then
		local ap, nv = t[3](e, v)
		e.cost = e.cost + ap
		v = nv or v
	end

	return v
end

-- bonus scaled up or down with current level (default 0.75 power) with minimum and random factor
-- base = base value at level = base_level
-- spread = random deviation from calculated value
-- result is (base +/- spread)*(current_level/base_level)^power
-- min = optional minimum value
function resolvers.clscale(base, base_level, spread, power, min)
	return {__resolver="clscale", base, base_level, spread, power or 0.75, min}
end
function resolvers.calc.clscale(t, e)
	return math.max(math.ceil((t[1] + (t[3] and rng.range(-t[3],t[3]) or 0))*(resolvers.current_level/t[2])^t[4]),t[5] or t[1])
end

--- Generic resolver, takes a function, executes at the end
function resolvers.genericlast(fct)
	return {__resolver="genericlast", __resolve_last=true, fct}
end
function resolvers.calc.genericlast(t, e)
	return t[1](e)
end

--- Charges resolver, gives a random use talent
function resolvers.random_use_talent(types, power)
	types = table.reverse(types)
	return {__resolver="random_use_talent", __resolve_last=true, types, power}
end
function resolvers.calc.random_use_talent(tt, e)
	local ml = e.material_level or 1
	local ts = {}
	for i, t in ipairs(engine.interface.ActorTalents.talents_def) do
		if t.random_ego and tt[1][t.random_ego] and t.type[2] < ml then ts[#ts+1]=t.id end
	end
	local tid = rng.table(ts) or engine.interface.ActorTalents.T_SENSE
	local t = engine.interface.ActorTalents.talents_def[tid]
	local level = util.bound(math.ceil(rng.mbonus(5, resolvers.current_level, resolvers.mbonus_max_level) * ml / 5), 1, 5)
	e.cost = e.cost + t.type[2] * 3 * level
	e.recharge_cost = t.type[2] * 3 * level
	return { id=tid, level=level, power=tt[2] }
end

--- Charms resolver
function resolvers.charm(desc, cd, fct, tcd)
	return {__resolver="charm", desc, cd, fct, tcd}
end
function resolvers.calc.charm(tt, e)
	local cd = tt[2]
	e.max_power = cd
	e.power = e.max_power
	e.use_power = {name=tt[1], power=cd, use=tt[3], __no_merge_add=true}
	if e.talent_cooldown == nil then e.talent_cooldown = tt[4] or "T_GLOBAL_CD" end
	return
end

--- Charms talent resolver
function resolvers.charmt(tid, tlvl, cd, tcd)
	return {__resolver="charmt", tid, tlvl, cd, tcd}
end
function resolvers.calc.charmt(tt, e)
	local cd = tt[3]
	e.max_power = cd
	e.power = e.max_power
	local lvl = util.getval(tt[2], e)
	e.use_talent = {id=tt[1], power=cd, level=lvl, __no_merge_add=true}
	if e.talent_cooldown == nil then e.talent_cooldown = tt[4] or "T_GLOBAL_CD" end
	return
end

--- Image based on material level
function resolvers.image_material(image, values)
	return {__resolver="image_material", image, values}
end
function resolvers.calc.image_material(t, e)
	if not t[2] or (type(t[2]) == "string" and t[2] == "metal") then t[2] = {"iron", "steel", "dsteel", "stralite", "voratun"} end
	if type(t[2]) == "string" and t[2] == "sea-metal" then t[2] = {"coral", "bluesteel", "deepsteel", "orite", "orichalcum"} end
	if type(t[2]) == "string" and t[2] == "leather" then t[2] = {"rough", "cured", "hardened", "reinforced", "drakeskin"} end
	if type(t[2]) == "string" and t[2] == "wood" then t[2] = {"elm","ash","yew","elvenwood","dragonbone"} end
	if type(t[2]) == "string" and t[2] == "nature" then t[2] = {"mossy","vined","thorned","pulsing","living"} end
	if type(t[2]) == "string" and t[2] == "cloth" then t[2] = {"linen","woollen","cashmere","silk","elvensilk"} end
	local ml = e.material_level or 1
	return "object/"..t[1].."_"..t[2][ml]..".png"
end

--- Moddable Image based on material level
function resolvers.moddable_tile(image, values)
	return {__resolver="moddable_tile", image}
end
function resolvers.calc.moddable_tile(t, e)
	local slot = t[1]
	local r, r2
	if slot == "cloak" then r = {"cloak_%s_01","cloak_%s_02","cloak_%s_03","cloak_%s_04","cloak_%s_05"}
	elseif slot == "massive" then
		r = {"upper_body_20","upper_body_21","upper_body_22","upper_body_24","upper_body_23",}
		r2 = {"lower_body_09","lower_body_10","lower_body_11","lower_body_13","lower_body_12",}
	elseif slot == "heavy" then
		r = {"upper_body_25","upper_body_11","upper_body_26","upper_body_28","upper_body_27",}
		r2 = {"lower_body_08","lower_body_08","lower_body_08","lower_body_08","lower_body_08",}
	elseif slot == "light" then
		r = {"upper_body_05","upper_body_06","upper_body_07","upper_body_08","upper_body_19",}
		r2 = {"lower_body_03","lower_body_04","lower_body_05","lower_body_06","lower_body_06",}
	elseif slot == "robe" then r = {"upper_body_18","upper_body_16","upper_body_13","upper_body_15","upper_body_17",}
	elseif slot == "shield" then r = {"%s_hand_10","%s_hand_11","%s_hand_11","%s_hand_12","%s_hand_12",}
	elseif slot == "staff" then r = {{"%s_hand_08",true}}
	elseif slot == "leather_boots" then r = {"feet_03","feet_04","feet_04","feet_05","feet_05",}
	elseif slot == "heavy_boots" then r = {"feet_06","feet_06","feet_07","feet_09","feet_08",}
	elseif slot == "gauntlets" then r = {"hands_03","hands_04","hands_05","hands_07","hands_06",}
	elseif slot == "gloves" then r = {"hands_02",}
	elseif slot == "sword" then r = {"%s_hand_04",}
	elseif slot == "2hsword" then r = {"%s_2hsword",}
	elseif slot == "wizard_hat" then r = {{"head_11",true},{"head_13",true},{"head_17",true},{"head_12",true},{"head_15",true},}
	elseif slot == "trident" then r = {{"%s_hand_13",true}}
	elseif slot == "whip" then r = {"%s_hand_09"}
	elseif slot == "mace" then r = {"%s_hand_05"}
	elseif slot == "2hmace" then r = {"%s_2hmace"}
	elseif slot == "axe" then r = {"%s_hand_06"}
	elseif slot == "2haxe" then r = {"%s_2haxe"}
	elseif slot == "bow" then r = {"%s_hand_01"}
	elseif slot == "sling" then r = {"%s_hand_02"}
	elseif slot == "dagger" then r = {"%s_hand_03"}
	elseif slot == "mindstar" then r = {{"mindstar_mossy_%s_01",true},{"mindstar_vines_%s_01",true},{"mindstar_thorn_%s_01",true},{"mindstar_pulsing_%s_01",true},{"mindstar_living_%s_01",true},}
	elseif slot == "helm" then r = {"head_05","head_06","head_08","head_10","head_09",}
	elseif slot == "leather_cap" then r = {"head_03"}
	elseif slot == "mummy_wrapping" then r = {{"special/mummy_wrappings",true}}
	end
	local ml = e.material_level or 1
	r = r[util.bound(ml, 1, #r)]
	if r2 then
		r2 = r2[util.bound(ml, 1, #r2)]
		e.moddable_tile2 = r2
	end
	if type(r) == "string" then return r else e.moddable_tile_big = true return r[1] end
end

--- Activates all sustains at birth
function resolvers.sustains_at_birth()
	return {__resolver="sustains_at_birth", __resolve_last=true}
end
function resolvers.calc.sustains_at_birth(_, e)
	e.on_added = function(self)
		for tid, _ in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and t.mode == "sustained" then
				self.energy.value = game.energy_to_act
--				print("===== activating sustain", self.name, tid)
				self:useTalent(tid)
			end
		end
	end
end

--- Help creating randarts
function resolvers.randartmax(v, max)
	return {__resolver="randartmax", v=v, max=max}
end
function resolvers.calc.randartmax(t, e)
	return t.v
end

--- Inscription resolver
function resolvers.inscription(name, data)
	return {__resolver="inscription", name, data}
end
function resolvers.calc.inscription(t, e)
	e:setInscription(nil, t[1], t[2], false, false, nil, true, true)
	return nil
end

--- Random inscription resolver
local inscriptions_max = {
	heal = 1,
	protect = 1,
	attack = 4,
	movement = 1,
	utility = 6,
	teleport = 0, -- Annoying
}

function resolvers.inscriptions(nb, list, kind, ignore_limits)
	return {__resolver="inscriptions", nb, list, kind, ignore_limits}
end
function resolvers.calc.inscriptions(t, e)
	local kind = nil
	if not t[4] then
		if t[3] then
			kind = function(o)
				if 	o.inscription_kind == t[3] and
					(e.__npc_inscription_kinds[o.inscription_kind] or 0) < (inscriptions_max[o.inscription_kind] or 0)
					then return true
				end return false
			end
		else
			kind = function(o)
				if 	(e.__npc_inscription_kinds[o.inscription_kind] or 0) < (inscriptions_max[o.inscription_kind] or 0)
					then return true
				end return false
			end
		end
	end

	e.__npc_inscription_kinds = e.__npc_inscription_kinds or {}
	for i = 1, t[1] do
		local o
		if type(t[2]) == "table" then
			if #t[2] > 0 then
				local name = rng.tableRemove(t[2])
				if not name then return nil end
				o = game.zone:makeEntity(game.level, "object", {special=kind, name=name}, nil, true)
			else
				o = game.zone:makeEntity(game.level, "object", {special=kind, type="scroll"}, nil, true)
			end
		else
			o = game.zone:makeEntity(game.level, "object", {special=kind, type="scroll", subtype=t[2]}, nil, true)
		end
		if o and o.inscription_talent and o.inscription_data then
			o.inscription_data.use_any_stat = 0.5 -- Cheat a bit to scale inscriptions nicely
			o.inscription_data.cooldown = math.ceil(o.inscription_data.cooldown * 1.6)
			e:setInscription(nil, o.inscription_talent, o.inscription_data, false, false, nil, true, true)
			e.__npc_inscription_kinds[o.inscription_kind] = (e.__npc_inscription_kinds[o.inscription_kind] or 0) + 1
		end
	end
	return nil
end

--- Tactical settings made easy
function resolvers.tactic(name)
	return {__resolver="tactic", name}
end
function resolvers.calc.tactic(t, e)
	if t[1] == "default" then return {type="default", }
	elseif t[1] == "standby" then return {type="standby", standby=1}
	elseif t[1] == "melee" then return {type="melee", attack=2, attackarea=2, disable=2, escape=0, closein=2, go_melee=1}
	elseif t[1] == "ranged" then return {type="ranged", disable=1.5, escape=3, closein=0, defend=2, heal=2, safe_range=4}
	elseif t[1] == "tank" then return {type="tank", disable=3, escape=0, closein=2, defend=2, protect=2, heal=3, go_melee=1}
	elseif t[1] == "survivor" then return {type="survivor", disable=2, escape=5, closein=0, defend=3, protect=0, heal=6, safe_range=8}
	end
	return {}
end

--- Resolve tactical ai weights based on talents known
--	mostly to make sure randbosses have sensible ai_tactic tables
--	this tends to make npc's slightly more aggressive/defensive depending on their talents
--	@param method = function to be applied to generating the ai_tactic table <not implemented>
-- 	@param tactic_total = total tactical weights desired <10>
--	@param weight_power = smoothing factor to balance out weights <0.5>
--	applied with "on_added_to_level"
function resolvers.talented_ai_tactic(method, tactic_total, weight_power)
	local method = method or "simple_recursive"
	return {__resolver="talented_ai_tactic", method, tactic_total, weight_power, __resolve_last=true,
	}
end

-- Extra recursive methods not handled yet
function resolvers.calc.talented_ai_tactic(t, e)
	local old_on_added_to_level = e.on_added_to_level
	e.__ai_compute = t
	e.on_added_to_level = function(e, level, x, y)
		local t = e.__ai_compute
		if old_on_added_to_level then old_on_added_to_level(e, level, x, y) end
		print("  # talented_ai_tactic resolver function for", e.name, "level=", e.level, e.uid)
		local tactic_total = t[2] or t.tactic_total or 10 --want tactic weights to total 10
		local weight_power = t[3] or t.weight_power or 0.5 --smooth out tactical weights
		local tacs_offense = {attack=1, attackarea=1}
		local tacs_close = {closein=1, go_melee=1}
		local tacs_defense = {escape=1, defend=1, heal=1, protect=1, disable = 1}
--		local tac_types = {type="melee",type = "ranged", type="tank", type="survivor"}
		local tactic, tactical = {}, {total = 0} 
--		local count = {talents = 0, atk_count = 0, atk_value = 0, total_range = 0,
--			atk_melee = 0, melee_value = 0, range_value = 0, atk_range = 0, 
--			escape = 0, close = 0, def_count = 0, def_value = 0, disable=0}
		local do_count, counted, count_talent, val
		local tac_count = #table.keys(tacs_offense) + #table.keys(tacs_close) + #table.keys(tacs_defense)
		local count = {tal_count = 0, atk_count = 0, total_range = 0,
			atk_melee = 0, melee_value = 0, range_value = 0, atk_range = 0, 
			escape = 0, close = 0, tac_count = tac_count}
		-- go through all talents, adding up all the tactical weights from the tactical tables
		local tal
		local function get_weight(wt)
			local val = 0
			if type(wt) == "function" then
				wt = wt(e, tal, e) -- try to target self for effectiveness
			end
			if type(wt) == "number" then return wt
			elseif type(wt) == "table" then
				for _, n in pairs(wt) do
					val = math.max(val, get_weight(n))
				end
				if val == 0 then val = 2 end
			end
			return tonumber(val) or 0
		end
		
		for tid, tl in pairs(e.talents) do
			tal = e:getTalentFromId(tid)
			local range, radius = e:getTalentRange(tal), e:getTalentRadius(tal)
--			if range > 0 then range = range + radius*2/3 end
			count_talent = false, false
			if tal and tal.tactical then
	print("   #- tactical table for talent", tal.name, "range", range, "radius", radius)
--	table.print(tal.tactical)
				do_count = false
				for tt, wt in pairs(tal.tactical) do
					val = get_weight(wt, e)
	print("   --- ", tt, "wt=", val)
					tactical[tt] = (tactical[tt] or 0) + val -- sum up all the input weights
					if tacs_offense[tt] then
						do_count = true
						count.atk_count = count.atk_count + 1
						val = val * tacs_offense[tt]
--						count.atk_value = count.atk_value + val
						if range >= 2 or radius > 2 then
							count.atk_range = count.atk_range + 1
							count.range_value = count.range_value + val
						else
							count.atk_melee = count.atk_melee + 1
							count.melee_value = count.melee_value + val
						end
						count.total_range = count.total_range + range + radius*2/3
					end
					if tacs_defense[tt] then
						do_count = true
						if tt == "escape" then count.escape = count.escape + 1 end
						if tt == "disable" then -- for range average only
							count.atk_count = count.atk_count + 1
							count.total_range = count.total_range + range + radius*2/3
						end
					end
					if tacs_close[tt] then
						do_count = true
						count.close = count.close + 1
					end
					if do_count then -- sum up only relevant weights
						count_talent = true
--						tactical.total = tactical.total + val
						tactic[tt] = (tactic[tt] or 0) + val
					end
				end
				if count_talent then
					count.tal_count = count.tal_count + 1
--					table.print(count, "--")
				end
			end
		end

		-- normalize weights
		count.avg_attack_range = count.total_range/count.atk_count
		local norm_total = 0
		for tt, wt in pairs(tactic) do
			local ave_weight = (tactic[tt]+count.tal_count)/count.tal_count
			local ave_xweight = ave_weight^weight_power - 1
			if ave_xweight > 1/tac_count then
				tactic[tt] = ave_weight
				norm_total = norm_total + ave_weight
			else
				tactic[tt] = nil -- defaults to a weight of 1 in the tactical ai
			end
		end
		for tt, _ in pairs(tactic) do
			tactic[tt] = tactic[tt]*tactic_total/norm_total
			if tactic[tt] < 1 then tactic[tt] = nil end -- defaults to a weight of 1 in the tactical ai
		end
		
		-- NPC's with predominantly ranged attacks will want to stay at range.
		if count.atk_range + count.escape > count.atk_melee + count.close and count.range_value /(count.melee_value + 1) > 1.5 then
			tactic.safe_range = math.max(2, math.ceil(count.avg_attack_range/2))
		end
		
		tactic.tactical_sum=tactical
		tactic.count = count
		tactic.level = e.level
		tactic.type = "computed"
print("  ### ai_tactic table:")
for tac, wt in pairs(tactic) do print("    ##", tac, wt) end
		e.ai_tactic = tactic
		e.__ai_compute = nil
		return tactic
	end
end

--- Racial Talents resolver

local racials = {
	halfling = {
		T_HALFLING_LUCK = {last=10, base=0, every=4, max=5},
		T_DUCK_AND_DODGE = {base=0, every=4, max=5},
		T_INDOMITABLE = {last=20, base=0, every=4, max=5},
	},
	human = {
		T_HIGHER_HEAL = {last=20, base=0, every=4, max=5},
		T_BORN_INTO_MAGIC = {base=0, every=4, max=5},
		T_HIGHBORN_S_BLOOM = {last=10, base=0, every=4, max=5},
	},
	shalore = {
		T_SHALOREN_SPEED = {last=30, base=0, every=4, max=5},
		T_MAGIC_OF_THE_ETERNALS = {base=0, every=4, max=5},
		T_SECRETS_OF_THE_ETERNALS = {last=20, base=0, every=4, max=5},
		T_TIMELESS = {last=10, base=0, every=4, max=5},
	},
	thalore = {
		T_THALOREN_WRATH = {last=10, base=0, every=4, max=5},
		T_UNSHACKLED = {base=0, every=4, max=5},
		T_GUARDIAN_OF_THE_WOOD = {last=20, base=0, every=4, max=5},
		T_NATURE_S_PRIDE = {last=30, base=0, every=4, max=5},
	},
	yeek = {
		T_UNITY = {base=0, every=4, max=5},
		T_QUICKENED = {last=10, base=0, every=4, max=5},
		T_WAYIST = {last=20, base=0, every=4, max=5},
	},
	dwarf = {
		T_POWER_IS_MONEY = {last=20, base=0, every=4, max=5},
		T_STONESKIN = {base=0, every=4, max=5},
		T_DWARF_RESILIENCE = {last=10, base=0, every=4, max=5},
	},
	orc = {
		T_ORC_FURY = {last=20, base=0, every=4, max=5},
		T_HOLD_THE_GROUND = {base=0, every=4, max=5},
		T_SKIRMISHER = {last=10, base=0, every=4, max=5},
		T_PRIDE_OF_THE_ORCS = {last=30, base=0, every=4, max=5},
	},
	skeleton = {
		T_BONE_ARMOUR = {last=30, base=0, every=4, max=5},
		T_SKELETON_REASSEMBLE = {last=40, base=0, every=4, max=5},
		T_RESILIENT_BONES = {last=20, base=0, every=4, max=5},
		T_SKELETON = {last=10, base=0, every=4, max=5},
	},
	ghoul = {
		T_GHOUL = {last=10, base=0, every=4, max=5},
		T_GHOULISH_LEAP = {last=20, base=0, every=4, max=5},
		T_GNAW = {last=40, base=0, every=4, max=5},
		T_RETCH = {last=30, base=0, every=4, max=5},
	},
}
resolvers.racials_defs = racials

function resolvers.racial(race)
	return {__resolver="racial", race}
end
function resolvers.calc.racial(t, e)
	if e.type ~= "humanoid" and e.type ~= "giant" and e.type ~= "undead" then return end
	local race = t[1] or e.subtype
	if not racials[race] then return end

	local levelup_talents = e._levelup_talents or {}
	for tid, level in pairs(racials[race]) do
		levelup_talents[tid] = table.clone(level)
	end
	e._levelup_talents = levelup_talents
	return nil
end


function resolvers.emote_random(def)
	return {__resolver="emote_random", def}
end
function resolvers.calc.emote_random(t, e)
	local def = t[1]
	def.chance = def.chance or 0.1
	if def.allow_backup_guardian then
		def[#def+1] = function()
			local t = game.state:getBackupGuardianEmotes{}
			return #t > 0 and rng.table(t) or nil
		end
	end
	return def
end

function resolvers.nice_tile(def)
	return {__resolver="nice_tile", def}
end
function resolvers.calc.nice_tile(t, e)
	if engine.Map.tiles.nicer_tiles then
		if t[1].tall then t[1] = {image="invis.png", add_mos = {{image="=BASE=TILE=", display_h=2, display_y=-1}}} end
		if t[1].add_mos and t[1].add_mos[1] and t[1].add_mos[1].image == "=BASE=TILE=" then t[1].add_mos[1].image = e.image end
		if t[1].add_mos and t[1].add_mos[1] and t[1].add_mos[1].image then t[1].attachement_spots = t[1].add_mos[1].image end
		table.merge(e, t[1])
	end
	return nil
end

function resolvers.shooter_capacity()
	return {__resolver="shooter_capacity", __resolve_last=true}
end
function resolvers.calc.shooter_capacity(t, e)
	e.combat.capacity = math.floor(e.combat.capacity)
	e.combat.shots_left = e.combat.capacity
	return nil
end

--- Give staves a flavor, appropriate damage type, spellpower, spellcrit, and the ability to teach the command staff talent
function resolvers.staff_wielder(name)
	return {__resolver="staff_wielder", name}
end
function resolvers.calc.staff_wielder(t, e)
	local staff_type = rng.table{2, 2, 2, 2, 3, 3, 3, 4, 4, 4}
	e.flavor_name = e["flavor_names"][staff_type]
	if staff_type == 2 then
		e.combat.element = rng.table{engine.DamageType.FIRE, engine.DamageType.COLD, engine.DamageType.LIGHTNING, engine.DamageType.ARCANE }
		e.modes = {"fire", "cold", "lightning", "arcane"}
		e.name = e.name:gsub(" staff", " magestaff")
	elseif staff_type == 3 then
		e.combat.element = rng.table{engine.DamageType.LIGHT, engine.DamageType.DARKNESS, engine.DamageType.TEMPORAL,  engine.DamageType.PHYSICAL }
		e.modes = {"light", "darkness", "temporal", "physical"}
		e.name = e.name:gsub(" staff", " starstaff")
	elseif staff_type == 4 then
		e.combat.element = rng.table{engine.DamageType.DARKNESS, engine.DamageType.BLIGHT, engine.DamageType.ACID, engine.DamageType.FIRE,}
		e.modes = {"darkness", "blight", "acid", "fire"}
		e.name = e.name:gsub(" staff", " vilestaff")
	end
	e.combat.damtype = engine.DamageType.PHYSICAL
	return 	{ inc_damage = {[e.combat.element] = e.combat.dam}, combat_spellpower = e.material_level * 3, combat_spellcrit = e.material_level, learn_talent = {[Talents.T_COMMAND_STAFF] = 1}, }
end
