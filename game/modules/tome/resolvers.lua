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

--- Resolves equipment creation for an actor
function resolvers.equip(t)
	return {__resolver="equip", __resolve_last=true, t}
end
--- Actually resolve the equipment creation
function resolvers.calc.equip(t, e)
	print("Equipment resolver for", e.name)
	-- Iterate of object requests, try to create them and equip them
	for i, filter in ipairs(t[1]) do
		print("Equipment resolver", e.name, filter.type, filter.subtype)
		local o
		if not filter.defined then
			o = game.zone:makeEntity(game.level, "object", filter, nil, true)
		else
			o = game.zone:makeEntityByName(game.level, "object", filter.defined)
		end
		if o then
			print("Zone made us an equipment according to filter!", o:getName())

			-- Auto alloc some stats to be able to wear it
			if filter.autoreq and rawget(o, "require") and rawget(o, "require").stat then
				print("Autorequire stats")
				for s, v in pairs(rawget(o, "require").stat) do
					print(s,v)
					if e:getStat(s) < v then
						e.unused_stats = e.unused_stats - (v - e:getStat(s))
						e:incStat(s, v - e:getStat(s))
					end
				end
			end

			e:wearObject(o, true, false)

			-- Do not drop it unless it is an ego or better
			if not o.egoed and not o.unique then o.no_drop = true print(" * "..o.name.." => no drop") end
			if filter.force_drop then o.no_drop = nil end
			game.zone:addEntity(game.level, o, "object")

			if t[1].id then o:identify(t[1].id) end
		end
	end
	-- Delete the origin field
	return nil
end

--- Resolves inventory creation for an actor
function resolvers.inventory(t)
	return {__resolver="inventory", __resolve_last=true, t}
end
--- Actually resolve the inventory creation
function resolvers.calc.inventory(t, e)
	-- Iterate of object requests, try to create them and equip them
	for i, filter in ipairs(t[1]) do
		print("Inventory resolver", e.name, filter.type, filter.subtype)
		local o
		if not filter.defined then
			o = game.zone:makeEntity(game.level, "object", filter, nil, true)
		else
			o = game.zone:makeEntityByName(game.level, "object", filter.defined)
		end
		if o then
			print("Zone made us an inventory according to filter!", o:getName())
			e:addObject(e.INVEN_INVEN, o)
			game.zone:addEntity(game.level, o, "object")

			if t[1].id then o:identify(t[1].id) end
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

	-- Iterate of object requests, try to create them and drops them
	for i = 1, (t.nb or 1) do
		local filter = t[rng.range(1, #t)]
		print("Drops resolver", e.name, filter.type, filter.subtype, filter.defined)
		local o
		if not filter.defined then
			o = game.zone:makeEntity(game.level, "object", filter, nil, true)
		else
			o = game.zone:makeEntityByName(game.level, "object", filter.defined)
		end
		if o then
			print("Zone made us a drop according to filter!", o:getName())
			e:addObject(e.INVEN_INVEN, o)
			game.zone:addEntity(game.level, o, "object")

			if t.id then o:identify(t.id) end
		end
	end
	-- Delete the origin field
	return nil
end

--- Resolves drops creation for an actor
function resolvers.store(def)
	return {__resolver="store", def}
end
--- Actually resolve the drops creation
function resolvers.calc.store(t, e)
	t = t[1]

	e.on_move = function(self, x, y, who)
		if who.player then
			self.store:loadup(game.level, game.zone)
			self.store:interact(who)
		end
	end
	e.store = game:getStore(t)
	print("[STORE] created for entity", t, e, e.name)

	-- Delete the origin field
	return nil
end

--- Resolves chat creation for an actor
function resolvers.chatfeature(def)
	return {__resolver="chatfeature", def}
end
--- Actually resolve the drops creation
function resolvers.calc.chatfeature(t, e)
	t = t[1]

	e.on_move = function(self, x, y, who)
		if who.player then
			local Chat = require("engine.Chat")
			local chat = Chat.new(self.chat, self, who)
			chat:invoke()
		end
	end
	e.chat = t

	-- Delete the origin field
	return nil
end

--- Random bonus based on level (sets the mbonus max level, we use 60 instead of 50 to get some forced randomness at high level)
resolvers.mbonus_max_level = 60

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

	return v
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

--- Charges resolver
function resolvers.charges(min, max, cost)
	return {__resolver="charges", __resolve_last=true, min, max, cost}
end
function resolvers.calc.charges(tt, e)
	e.max_power = rng.range(tt[1], tt[2])
	e.power = e.max_power
	print("creatin wand", e.name, e.egoed, e.max_power, e.cost_per_charge)
	e.recharge_cost = (e.cost_per_charge or 0) * 4
	e.cost = e.cost + (e.cost_per_charge or 0) * e.max_power
	e.show_charges = true
	return
end

--- Image based on material level
function resolvers.image_material(image, values)
	return {__resolver="image_material", image, values}
end
function resolvers.calc.image_material(t, e)
	if not t[2] or (type(t[2]) == "string" and t[2] == "metal") then t[2] = {"iron", "steel", "dsteel", "galvorn", "mithril"} end
	if type(t[2]) == "string" and t[2] == "sea-metal" then t[2] = {"coral", "bluesteel", "deepsteel", "orite", "orichalcum"} end
	if type(t[2]) == "string" and t[2] == "leather" then t[2] = {"rough", "cured", "hardened", "reinforced", "drakeskin"} end
	if type(t[2]) == "string" and t[2] == "wood" then t[2] = {"elm","ash","yew","elvenwood","dragonbone"} end
	if type(t[2]) == "string" and t[2] == "cloth" then t[2] = {"linen","woolen","cashmere","silk","elvensilk"} end
	local ml = e.material_level or 1
	return "object/"..t[1].."_"..t[2][ml]..".png"
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
				self:useTalent(tid)
			end
		end
	end
end
