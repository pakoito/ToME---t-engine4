require "engine.class"
require "engine.Map"
require "engine.Entity"

map = engine.Map.new(20, 20)

local floor = engine.Entity.new{color_r=50, color_g=50, color_b=50}
local e1 = engine.Entity.new{color_r=255, block_sight=true}
local e2 = engine.Entity.new{color_g=255, block_sight=true}
local e3 = engine.Entity.new{color_b=255}
local e4 = e3:clone()
e4.color_r=255

for i = 0, 19 do for j = 0, 19 do
	map(i, j, 1, floor)
end end

map(8, 6, 1, e4)
map(8, 7, 1, e2)
map(8, 8, 1, e3)
map(9, 6, 1, e1)
map(9, 7, 1, e2)
map(9, 8, 1, e3)
map(10, 6, 1, e1)
map(10, 7, 1, e2)
map(10, 8, 1, e3)

print(map(8, 8, 1))

map:setCurrent()

--dofile("/game/modules/tome/")
