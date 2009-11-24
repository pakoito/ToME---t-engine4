require "engine.class"

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

function _M:load()
	local f, err = loadfile("/data/zones/"..self.short_name.."/zone.lua")
	if err then error(err) end
	local data = f()
	for k, e in pairs(data) do self[k] = e end
end

function _M:getLevelData(lev)
	if not self.levels[lev] then return self end

	local res = {}
	for k, e in pairs(self) do res[k] = e end
	for k, e in pairs(self.levels[lev]) do res[k] = e end
	return res
end

--- Asks the zone to generate a level of level "lev"
-- @param lev the level (from 1 to zone.max_level)
-- @return a Level object
function _M:getLevel(game, lev, no_close)
	-- Before doing anything else, close the current level
	if not no_close and game.level and game.level.map then
		game.level.map:close()
	end

	local level_data = self:getLevelData(lev)

	local map = self.map_class.new(level_data.width, level_data.height)
	if level_data.all_lited then map:liteAll(0, 0, map.w, map.h) end
	if level_data.all_remembered then map:rememberAll(0, 0, map.w, map.h) end

	-- Generate the map
	local generator = require(level_data.generator.map.class).new(
		map,
		self.grid_list,
		level_data.generator.map
	)
	local startx, starty = generator:generate()

	local level = self.level_class.new(lev, map)
	level.start = {x=startx, y=starty}

	-- Setup the level in the game
	game:setLevel(level)

	-- Generate actors
	if level_data.generator.actor then
		local generator = require(level_data.generator.actor.class).new(
			map,
			level,
			self.npc_list,
			level_data.generator.actor
		)
		generator:generate()
	end

	-- Setup the level in the game
	game:setLevel(level)

	-- Clean up things
	collectgarbage("collect")

	return level
end
