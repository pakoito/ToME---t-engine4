-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
local Map = require "engine.Map"

--- Define a level
module(..., package.seeall, class.make)

--- Initializes the level with a "level" and a map
function _M:init(level, map)
	self.level = level
	self.map = map
	self.e_array = {}
	self.entities = {}
	self.entities_list = {}
	self.perm_entities_list = {}
	self.sublevels = {}
	self.sublevel_id = "__main__"
	self.data = {}
end

function _M:onSaving()
	self.last_iteration = nil
end

--- Adds a sublevel
function _M:addSublevel(name, level)
	if self.sublevels[name] then error("Sublevel already exists: "..name) end
	self.sublevels[name] = level
	level.sublevel_id = name
	print("[LEVEL] new sublevel", name)
end

--- Removes a sublevel
function _M:removeSublevel(name)
	self.sublevels[name] = nil
	print("[LEVEL] del sublevel", name)
end

--- Activate the given sublevel to become the new main one
function _M:selectSublevel(name)
	if not self.sublevels[name] then error("Sublevel does not exist, cant switch: "..name) end
	if game.level ~= self then error("Switching sublevel on a level that is not active") end
	local level = self.sublevels[name]
	game.level = level

	level.sublevels = self.sublevels
	self.sublevels = {}

	level.sublevels[level.sublevel_id] = nil
	level.sublevels[self.sublevel_id] = self

	print("[LEVEL] switch to sublevel", level.sublevel_id, "from", self.sublevel_id)
end

--- Adds an entity to the level
-- Only entities that need to act need to be added. Terrain features do not need this usually
function _M:addEntity(e, after, no_error)
	if e._fake_level_entity then
		e._fake_level_entity(self, "add", after)
		return
	end

	if self.entities[e.uid] and self.entities[e.uid] == e then return end
	if self.entities[e.uid] then 
		if self.remove_old_entity_on_duplicate then self:removeEntity(self.entities[e.uid], true) end
		if no_error then return else error("Entity "..e.uid.."("..(e.name or "???")..") already present on the level") end 
	end
	self.entities[e.uid] = e
	if e.addEntityOrder then after = e:addEntityOrder(level) end
	if not after or not self:hasEntity(after) then
		table.insert(self.e_array, e)
	else
		print("Adding entity", e.uid, "after", after.uid)
		local pos = nil
		for i = 1, #self.e_array do
			if self.e_array[i] == after then
				pos = i
				break
			end
		end
		if pos then
			table.insert(self.e_array, pos+1, e)
		else
			table.insert(self.e_array, e)
		end
	end
	game:addEntity(e)
end

--- Removes an entity from the level
function _M:removeEntity(e, force)
	if e._fake_level_entity then
		-- Tells it to delete itself if needed
		if e.deleteFromMap then e:deleteFromMap(self.map) end

		e._fake_level_entity(self, "remove")
		return
	end

	if not self.entities[e.uid] and not force then error("Entity "..e.uid.."("..(e.name or "???")..") not present on the level") end
	self.entities[e.uid] = nil
	for i = 1, #self.e_array do
		if self.e_array[i] == e then
			table.remove(self.e_array, i)
			break
		end
	end
	game:removeEntity(e)

	-- Tells it to delete itself if needed
	if e.deleteFromMap then e:deleteFromMap(self.map) end
end

--- Is the entity on the level?
function _M:hasEntity(e)
	if e._fake_level_entity then return e._fake_level_entity(self, "has") end
	return self.entities[e.uid]
end

--- Serialization
function _M:save()
	return class.save(self, {entities_list=true})
end
function _M:loaded()
	-- Loading the game has defined new uids for entities, yet we hard referenced the old ones
	-- So we fix it
	local nes = {}
	for uid, e in pairs(self.entities) do
		nes[e.uid] = e
	end
	self.entities = nes
	self.entities_list = {}
end

--- Setup an entity list for the level, this allows the Zone to pick objects/actors/...
function _M:setEntitiesList(type, list, permanent)
	if permanent then
		self.perm_entities_list[type] = list
	else
		self.entities_list[type] = list
	end
	print("Stored entities list", type, list)
end

--- Gets an entity list for the level, this allows the Zone to pick objects/actors/...
function _M:getEntitiesList(type)
	return self.entities_list[type] or self.perm_entities_list[type]
end

--- Removed, so we remove all entities
function _M:removed()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		local z = i + j * self.map.w
		if self.map.map[z] then
			for _, e in pairs(self.map.map[z]) do
				e:removed()
			end
		end
	end end
end

--- Decay the level
-- Decaying means we look on the map for the given type of entities and if we are allowed to we delete them
-- @param what what Map feature to decay (ACTOR, OBJECT, ...)
-- @param check either a boolean or a function, if true the given entity will be decayed
-- @return the number of decayed entities and the total number of such entities remaining
function _M:decay(what, check)
	local total, nb = 0, 0
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		if not self.map.attrs(i, j, "no_decay") then
			if what == self.map.OBJECT then
				for z = self.map:getObjectTotal(i, j), 1, -1 do
					local e = self.map:getObject(i, j, z)
					if e and not e.no_decay and util.getval(check, e, i, j) then
						print("[DECAY] decaying", e.uid, e.name)
						self.map:removeObject(i, j, z)
						e:removed()
						nb = nb + 1
					elseif e then
						total = total + 1
					end
				end
			else
				local e = self.map(i, j, what)
				if e and not e.no_decay and util.getval(check, e, i, j) then
					print("[DECAY] decaying", e.uid, e.name)
					if self:hasEntity(e) then
						self:removeEntity(e)
					else
						self.map:remove(i, j, what)
					end
					e:removed()
					nb = nb + 1
				elseif e then
					total = total + 1
				end
			end
		end
	end end
	return nb, total
end

--- Pick a random spot matching the given filter
function _M:pickSpot(filter)
	local list = {}
	for i, spot in ipairs(self.spots) do
		if not filter or game.zone:checkFilter(spot, filter) then list[#list+1] = spot end
	end
	return rng.table(list), list
end

--- Pick a random spot matching the given filter and remove it
function _M:pickSpotRemove(filter)
	local list = {}
	for i, spot in ipairs(self.spots) do
		if not filter or game.zone:checkFilter(spot, filter) then list[#list+1] = {spot=spot, idx=i} end
	end
	local s = rng.table(list)
	if not s then return end
	table.remove(self.spots, s.idx)
	return s.spot
end
