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
			o = game.zone:makeEntity(game.level, "object", filter)
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
			if not o.egoed and not o.unique then o.no_drop = true end
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
			o = game.zone:makeEntity(game.level, "object", filter)
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
			o = game.zone:makeEntity(game.level, "object", filter)
		else
			o = game.zone:makeEntityByName(game.level, "object", filter.defined)
		end
		if o then
			print("Zone made us an drop according to filter!", o:getName())
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
		self.store:loadup(game.level, game.zone)
		self.store:interact(who)
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
		local Chat = require("engine.Chat")
		local chat = Chat.new(self.chat, self, who)
		chat:invoke()
	end
	e.chat = t

	-- Delete the origin field
	return nil
end
