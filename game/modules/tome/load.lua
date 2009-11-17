local Map = require "engine.Map"
local Entity = require "engine.Entity"
local Actor = require "tome.class.Actor"

local map = Map.new(20, 20)

local floor = Entity.new{display='#', color_r=100, color_g=100, color_b=100}
local e1 = Entity.new{display='#', color_r=255, block_sight=true}
local e2 = Entity.new{display='#', color_g=255, block_sight=true}
local e3 = Entity.new{display='#', color_b=255, block_sight=true}
local e4 = e3:clone{color_r=255}

for i = 0, 19 do for j = 0, 19 do
	map(i, j, 1, floor)
end end

map(8, 6, Map.TERRAIN, e4)
map(8, 7, Map.TERRAIN, e2)
map(8, 8, Map.TERRAIN, e3)
map(9, 6, Map.TERRAIN, e1)
map(9, 7, Map.TERRAIN, e2)
map(9, 8, Map.TERRAIN, e3)
map(10, 6, Map.TERRAIN, e1)
map(10, 7, Map.TERRAIN, e2)
map(10, 8, Map.TERRAIN, e3)

player = Actor.new{name="player!", display='#', color_r=125, color_g=125, color_b=0}
player:move(map, 2, 3)

map:setCurrent()
