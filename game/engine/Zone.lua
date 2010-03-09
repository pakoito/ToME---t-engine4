require "engine.class"
local Savefile = require "engine.Savefile"

--- Defines a zone: a set of levels, with depth, nps, objects, level generator, ...
module(..., package.seeall, class.make)

--- Setup classes to use for level generation
-- Static method
-- @param t table that contains the name of the classes to use
-- @usage Required fields:
-- npc_class (default engine.Actor)
-- grid_class (default engine.Grid)
-- object_class (default engine.Object)
function _M:setup(t)
	self.map_class = require(t.map_class or "engine.Map")
	self.level_class = require(t.level_class or "engine.Level")
	self.npc_class = require(t.npc_class or "engine.Actor")
	self.grid_class = require(t.grid_class or "engine.Grid")
	self.trap_class = require(t.trap_class or "engine.Trap")
	self.object_class = require(t.object_class or "engine.Object")
end

--- Loads a zone definition
-- @param short_name the short name of the zone to load, if should correspond to a directory in your module data/zones/short_name/ with a zone.lua, npcs.lua, grids.lua and objects.lua files inside
function _M:init(short_name)
	self.short_name = short_name
	self:load()
	self.level_range = self.level_range or {1,1}
	if type(self.level_range) == "number" then self.level_range = {self.level_range, self.level_range} end
	self.level_scheme = self.level_scheme or "fixed"
	assert(self.max_level, "no zone max level")
	self.levels = self.levels or {}
	self.npc_list = self.npc_class:loadList("/data/zones/"..self.short_name.."/npcs.lua")
	self.grid_list = self.grid_class:loadList("/data/zones/"..self.short_name.."/grids.lua")
	self.object_list = self.object_class:loadList("/data/zones/"..self.short_name.."/objects.lua")
	self.trap_list = self.trap_class:loadList("/data/zones/"..self.short_name.."/traps.lua")

	-- Determine a zone base level
	self.base_level = self.level_range[1]
	if self.level_scheme == "player" then
		local plev = game:getPlayer().level
		self.base_level = util.bound(plev, self.level_range[1], self.level_range[2])
	end
	print("Initiated zone", self.name, "with base_level", self.base_level)
end

--- Parses the npc/objects list and compute rarities for random generation
-- ONLY entities with a rarity properties will be considered.<br/>
-- This means that to get a never-random entity you simply do not put a rarity property on it.
function _M:computeRarities(type, list, level, filter)
	local r = { total=0 }
	print("******************", level.level)
	for i, e in ipairs(list) do
		if e.rarity and e.level_range and (not filter or filter(e)) then
--			print("computing rarity of", e.name)
			local lev = self.base_level + (level.level - 1)

			local max = 10000
			if lev < e.level_range[1] then max = 10000 / (3 * (e.level_range[1] - lev))
			elseif lev > e.level_range[2] then max = 10000 / (lev - e.level_range[2])
			end
			local genprob = math.ceil(max / e.rarity)
			print(("Entity(%30s) got %3d (=%3d / %3d) chance to generate. Level range(%2d-%2d), current %2d"):format(e.name, math.floor(genprob), math.floor(max), e.rarity, e.level_range[1], e.level_range[2], lev))

			-- Generate and store egos list if needed
			if e.egos and not level:getEntitiesList(type.."/"..e.egos) then
				local egos = self:getEgosList(level, type, e.egos, e.__CLASSNAME)
				if egos then
					egos = self:computeRarities(type, egos, level, filter)
					level:setEntitiesList(type.."/"..e.egos, egos)
				end
			end

			if genprob > 0 then
				r.total = r.total + genprob
				r[#r+1] = { e=e, genprob=r.total, level_diff = lev - level.level }
			end
		end
	end
	table.sort(r, function(a, b) return a.genprob < b.genprob end)

	print("*DONE", r.total)
	for i, ee in ipairs(r) do
		print(("entity chance %2d : chance(%4d): %s"):format(i, ee.genprob, ee.e.name))
	end

	return r
end

--- Checks an entity against a filter
function _M:checkFilter(e, filter)
	if e.unique and game.uniques[e.unique] then print("refused unique", e.name, e.unique) return false end

	if not filter then return true end
	print("Filtering", filter.type, filter.subtype)

	if filter.type and filter.type ~= e.type then return false end
	if filter.subtype and filter.subtype ~= e.subtype then return false end
	if filter.name and filter.name ~= e.name then return false end

	if e.unique then print("accepted unique", e.name, e.unique) end

	return true
end

--- Picks an entity from a computed probability list
function _M:pickEntity(list)
	if #list == 0 then return nil end
	local r = rng.range(1, list.total)
	for i = 1, #list do
--		print("test", r, ":=:", list[i].genprob)
		if r < list[i].genprob then
--			print(" * select", list[i].e.name)
			return list[i].e
		end
	end
	return nil
end

--- Gets the possible egos
function _M:getEgosList(level, type, group, class)
	-- Already loaded ? use it
	local list = level:getEntitiesList(type.."/"..group)
	if list then return list end

	-- otehrwise loads it and store it
	list = require(class):loadList(group, true)
	level:setEntitiesList(type.."/"..group, list)

	return list
end

--- Picks and resolve an entity
-- @return the fully resolved entity, ready to be used on a level. Or nil if a filter was given an nothing found
function _M:makeEntity(level, type, filter)
	resolvers.current_level = self.base_level + level.level - 1

	local list = level:getEntitiesList(type)
	local e
	local tries = 500
	-- CRUDE ! Brute force ! Make me smarter !
	while tries > 0 do
		e = self:pickEntity(list)
		if e and self:checkFilter(e, filter) then break end
		tries = tries - 1
	end
	if tries == 0 then return nil end

	e = self:finishEntity(level, type, e, filter and filter.ego_chance)

	return e
end

--- Find a given entity and resolve it
-- @return the fully resolved entity, ready to be used on a level. Or nil if a filter was given an nothing found
function _M:makeEntityByName(level, type, name)
	resolvers.current_level = self.base_level + level.level - 1

	local e
	if type == "actor" then e = self.npc_list[name]
	elseif type == "object" then e = self.object_list[name]
	elseif type == "grid" then e = self.grid_list[name]
	elseif type == "trap" then e = self.trap_list[name]
	end
	if not e then return nil end

	if e.unique and game.uniques[e.unique] then print("refused unique", e.name, e.unique) return nil end

	e = self:finishEntity(level, type, e)

	return e
end

--- Finishes generating an entity
function _M:finishEntity(level, type, e, ego_chance)
	e = e:clone()
	e:resolve()

	-- Add "ego" properties, sometimes
	if not e.unique and e.egos and e.egos_chance and rng.percent(util.bound(e.egos_chance + (ego_chance or 0), 0, 100)) then
		local egos = self:getEgosList(level, type, e.egos, e.__CLASSNAME)
		local ego = self:pickEntity(egos)
		if ego then
			print("ego", ego.__CLASSNAME, ego.name, getmetatable(ego))
			ego = ego:clone()
			ego:resolve()
			ego:resolve(nil, true)
			local newname
			if ego.prefix then
				newname = ego.name .. e.name
			else
				newname = e.name .. ego.name
			end
			print("applying ego", ego.name, "to ", e.name, "::", newname)
			ego.unided_name = nil
			table.mergeAdd(e, ego, true)
			e.name = newname
			e.egoed = true
		end
	end

	-- Generate a stack ?
	if e.generate_stack then
		local s = {}
		while e.generate_stack > 0 do
			s[#s+1] = e:clone()
			e.generate_stack = e.generate_stack - 1
		end
		for i = 1, #s do e:stack(s[i]) end
	end

	e:resolve(nil, true)

	return e
end

function _M:load()
	local f, err = loadfile("/data/zones/"..self.short_name.."/zone.lua")
	if err then error(err) end
	local data = f()
	for k, e in pairs(data) do self[k] = e end
end

local recurs = function(t)
	local nt = {}
	for k, e in pairs(nt) do if k ~= "__CLASSNAME" then nt[k] = e end end
	return nt
end
function _M:getLevelData(lev)
	local res = table.clone(self, true)
	if self.levels[lev] then
		table.merge(res, self.levels[lev], true)
	end
	-- Make sure it is not considered a class
	res.__CLASSNAME = nil
	return res
end

--- Leave the level, forgetting uniques and such
function _M:leaveLevel(no_close, lev, old_lev)
	-- Before doing anything else, close the current level
	if not no_close and game.level and game.level.map then
		game:leaveLevel(game.level, lev, old_lev)

		if game.level.data.persistant then
			local save = Savefile.new(game.save_name)
			save:saveLevel(game.level)
			save:close()
		else
			game.level:removed()
		end

		game.level.map:close()
	end
end

--- Asks the zone to generate a level of level "lev"
-- @param lev the level (from 1 to zone.max_level)
-- @return a Level object
function _M:getLevel(game, lev, old_lev, no_close)
	self:leaveLevel(no_close, lev, old_lev)

	local level_data = self:getLevelData(lev)

	local level
	-- Load persistant level?
	if level_data.persistant == true then
		local save = Savefile.new(game.save_name)
		level = save:loadLevel(self.short_name, lev)
		save:close()

		if level then
			-- Setup the level in the game
			game:setLevel(level)
		end
	end

	-- In any cases, make one if none was found
	if not level then
		level = self:newLevel(level_data, lev, old_lev, game)
	end

	-- Clean up things
	collectgarbage("collect")

	return level
end

function _M:newLevel(level_data, lev, old_lev, game)
	local map = self.map_class.new(level_data.width, level_data.height)
	if level_data.all_lited then map:liteAll(0, 0, map.w, map.h) end
	if level_data.all_remembered then map:rememberAll(0, 0, map.w, map.h) end

	-- Setup the entities list
	local level = self.level_class.new(lev, map)
	level:setEntitiesList("actor", self:computeRarities("actor", self.npc_list, level, nil))
	level:setEntitiesList("object", self:computeRarities("object", self.object_list, level, nil))
	level:setEntitiesList("trap", self:computeRarities("trap", self.trap_list, level, nil))

	-- Save level data
	level.data = level_data

	-- Setup the level in the game
	game:setLevel(level)

	-- Generate the map
	local generator = require(level_data.generator.map.class).new(
		self,
		map,
		level,
		level_data.generator.map
	)
	local ux, uy, dx, dy, spots = generator:generate(lev, old_lev)
	spots = spots or {}

	level.ups = {{x=ux, y=uy}}
	level.downs = {{x=dx, y=dy}}
	level.spots = spots

	-- Generate objects
	if level_data.generator.object then
		local generator = require(level_data.generator.object.class).new(
			self,
			map,
			level,
			spots
		)
		generator:generate()
	end

	-- Generate traps
	if level_data.generator.trap then
		local generator = require(level_data.generator.trap.class).new(
			self,
			map,
			level,
			spots
		)
		generator:generate()
	end

	-- Generate actors
	if level_data.generator.actor then
		local generator = require(level_data.generator.actor.class).new(
			self,
			map,
			level,
			spots
		)
		generator:generate()
	end

	-- Delete the room_map, now useless
	map.room_map = nil

	return level
end
