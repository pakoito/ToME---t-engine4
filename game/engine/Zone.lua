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
	self.object_class = require(t.object_class or "engine.Object")
end

--- Loads a zone definition
-- @param short_name the short name of the zone to load, if should correspond to a directory in your module data/zones/short_name/ with a zone.lua, npcs.lua, grids.lua and objects.lua files inside
function _M:init(short_name)
	self.short_name = short_name
	self:load()
	assert(self.max_level, "no zone max level")
	self.levels = self.levels or {}
	self.npc_list = self.npc_class:loadList("/data/zones/"..self.short_name.."/npcs.lua")
	self.grid_list = self.grid_class:loadList("/data/zones/"..self.short_name.."/grids.lua")
	self.object_list = self.object_class:loadList("/data/zones/"..self.short_name.."/objects.lua")
end

--- Parses the npc/objects list and compute rarities for random generation
-- ONLY entities with a rarity properties will be considered.<br/>
-- This means that to get a never-random entity you simply do not put a rarity property on it.
function _M:computeRarities(list, level, ood, filter)
	local r = { total=0 }
	print("******************", level)
	for i, e in ipairs(list) do
		if e.rarity and e.level_range and (not filter or filter(e)) then
--			print("computing rarity of", e.name)
			local lev = level
			-- Out of Depth chance
--			if ood and rng.percent(ood.chance) then
--				lev = level + rng.range(ood.range[1], ood.range[2])
--				print("OOD Entity !", e.name, ":=:", level, "to", lev)
--			end

			local max = 100
			if lev < e.level_range[1] then max = 100 / (3 * (e.level_range[1] - lev))
			elseif lev > e.level_range[2] then max = 100 / (lev - e.level_range[2])
			end
			local genprob = max / e.rarity
			print("prob", e.name, math.floor(genprob), "max", math.floor(max), e.level_range[1], e.level_range[2], lev)

			r.total = r.total + genprob
			r[#r+1] = { e=e, genprob=r.total + genprob, level_diff = lev - level }
		end
	end
	table.sort(r, function(a, b) return a.genprob < b.genprob end)
	print("*DONE", r.total)
	return r
end

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
	local res = table.clone(self)
	if self.levels[lev] then
		table.merge(res, self.levels[lev], true)
	end
	-- Make sure it is not considered a class
	res.__CLASSNAME = nil
	return res
end

--- Asks the zone to generate a level of level "lev"
-- @param lev the level (from 1 to zone.max_level)
-- @return a Level object
function _M:getLevel(game, lev, old_lev, no_close)
	-- Before doing anything else, close the current level
	if not no_close and game.level and game.level.map then
		if game.level.data.persistant then
			local save = Savefile.new(game.save_name)
			save:saveLevel(game.level)
			save:close()
		end

		game.level.map:close()
	end

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

	-- Generate the map
	local generator = require(level_data.generator.map.class).new(
		self,
		map,
		self.grid_list,
		level_data.generator.map
	)
	local startx, starty = generator:generate(lev, old_lev)

	local level = self.level_class.new(lev, map)
	level.start = {x=startx, y=starty}

	-- Save level data
	level.data = level_data

	-- Setup the level in the game
	game:setLevel(level)

	-- Generate actors
	if level_data.generator.actor then
		local generator = require(level_data.generator.actor.class).new(
			self,
			map,
			level
		)
		generator:generate()
	end
	if level_data.generator.object then
		local generator = require(level_data.generator.object.class).new(
			self,
			map,
			level
		)
		generator:generate()
	end

	return level
end
