require "engine.class"
local Map = require "engine.Map"
local Grid = require "engine.Grid"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.grid_list = zone.grid_list
	self.subgen = {}
	self.data = data

	if data.adjust_level then
		self.adjust_level = {base=zone.base_level, lev = self.level.level, min=data.adjust_level[1], max=data.adjust_level[2]}
	else
		self.adjust_level = {base=zone.base_level, lev = self.level.level, min=0, max=0}
	end

	self:loadMap(data.map)
end

function _M:loadMap(file)
	local t = {}

	print("Static generator using file", "/data/maps/"..file..".lua")
	local f, err = loadfile("/data/maps/"..file..".lua")
	if not f and err then error(err) end
	local g = {
		Map = require("engine.Map"),
		subGenerator = function(g)
			self.subgen[#self.subgen+1] = g
		end,
		defineTile = function(char, grid, obj, actor, trap)
			t[char] = {grid=grid, obj=obj, actor=actor, trap=trap}
		end,
		quickEntity = function(char, e)
			local e = Grid.new(e)
			e:resolve()
			e:resolve(nil, true)
			t[char] = {grid=e}
		end,
	}
	setfenv(f, setmetatable(g, {__index=_G}))
	local ret, err = f()
	if not ret and err then error(err) end

	local m = { w=ret[1]:len(), h=#ret }

	-- Read the map
	for j, line in ipairs(ret) do
		local i = 1
		for c in line:gmatch(".") do
			m[i] = m[i] or {}
			m[i][j] = c
			i = i + 1
		end
	end

	m.startx = g.startx or math.floor(m.w / 2)
	m.starty = g.starty or math.floor(m.h / 2)

	self.gen_map = m
	self.tiles = t

	self.map.w = m.w
	self.map.h = m.h
end

function _M:resolve(typ, c)
	if not self.tiles[c] or not self.tiles[c][typ] then return end
	local res = self.tiles[c][typ]
	if type(res) == "function" then
		return self.grid_list[res()]
	elseif type(res) == "table" and res.__CLASSNAME then
		return res
	elseif type(res) == "table" then
		return self.grid_list[res[rng.range(1, #res)]]
	else
		return self.grid_list[res]
	end
end

function _M:generate(lev, old_lev)
	for i = 1, self.gen_map.w do for j = 1, self.gen_map.h do
		local c = self.gen_map[i][j]
		self.map(i-1, j-1, Map.TERRAIN, self:resolve("grid", c))

		local actor = self.tiles[c] and self.tiles[c].actor

		if actor then
			local m = self.zone:makeEntityByName(self.level, "actor", actor)
			if m then
				m:move(i-1, j-1, true)
				self.level:addEntity(m)
				m:added()
				if self.adjust_level then
					local newlevel = self.adjust_level.base + self.adjust_level.lev + rng.avg(self.adjust_level.min, self.adjust_level.max)
					m:forceLevelup(newlevel)
				end
			end
		end
	end end

	for i = 1, #self.subgen do
		local g = self.subgen[i]
		local data = g.data
		if type(data) == "string" and data == "pass" then data = self.data end

		local map = self.zone.map_class.new(g.w, g.h)
		local generator = require(g.generator).new(
			self.zone,
			map,
			self.level,
			data
		)
		generator:generate(lev, old_lev)

		self.map:import(map, g.x, g.y)
		map:close()
	end

	return self.gen_map.startx, self.gen_map.starty, self.gen_map.startx, self.gen_map.starty
end
