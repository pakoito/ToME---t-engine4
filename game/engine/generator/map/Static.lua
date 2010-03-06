require "engine.class"
local Map = require "engine.Map"
local Grid = require "engine.Grid"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, grid_list, data)
	engine.Generator.init(self, zone, map)
	self.grid_list = grid_list

	self:loadMap(data.map)
end

function _M:loadMap(file)
	local t = {}

	print("Static generator using file", "/data/maps/"..file..".lua")
	local f, err = loadfile("/data/maps/"..file..".lua")
	if not f and err then error(err) end
	setfenv(f, setmetatable({
		Map = require("engine.Map"),
		defineTile = function(char, grid, obj, actor)
			t[char] = {grid=grid, obj=obj, actor=actor}
		end,
		quickEntity = function(char, e)
			local e = Grid.new(e)
			e:resolve()
			e:resolve(nil, true)
			t[char] = {grid=e}
		end,
	}, {__index=_G}))
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

	m.startx = ret.startx or math.floor(m.w / 2)
	m.starty = ret.starty or math.floor(m.h / 2)

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

function _M:generate()
	for i = 1, self.gen_map.w do for j = 1, self.gen_map.h do
		self.map(i-1, j-1, Map.TERRAIN, self:resolve("grid", self.gen_map[i][j]))
	end end

	return self.gen_map.startx, self.gen_map.starty, self.gen_map.startx, self.gen_map.starty
end
