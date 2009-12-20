require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, grid_list, data)
	engine.Generator.init(self, zone, map)
	self.grid_list = grid_list

	self:loadMap(data.map)
end

function _M:loadMap(file)
	local t = {}

	local f = loadfile("/data/maps/"..file..".lua")
	setfenv(f, setmetatable({
		Map = require("engine.Map"),
		defineTile = function(char, grid, obj, actor)
			t[char] = {grid=grid, obj=obj, actor=actor}
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

	self.gen_map = m
	self.tiles = t
end

function _M:resolve(typ, c)
	local res = self.tiles[c][typ]
	if type(res) == "function" then
		return res()
	elseif type(res) == "table" then
		return res[rng.range(1, #res)]
	else
		return res
	end
end

function _M:generate()
	for i = 1, self.gen_map.w do for j = 1, self.gen_map.h do
		self.map(i-1, j-1, Map.TERRAIN, self.grid_list[self:resolve("grid", self.gen_map[i][j])])
--		self.map(i-1, j-1, Map.OBJECT, self.gen_map[i][j].obj)
--		self.map(i-1, j-1, Map.ACTOR, self.gen_map[i][j].actor)
	end end

	-- Always starts at 1, 1
	return 1, 1
end
