-- ToME - Tales of Maj'Eyal
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

newEntity{
	define_as = "SAND",
	type = "floor", subtype = "sand",
	name = "sand", image = "terrain/sandfloor.png",
	display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	nice_tiler = { method="grassSand",
		grass8={"SAND_GRASS_8", 100, 1, 1}, grass2={"SAND_GRASS_2", 100, 1, 1}, grass4={"SAND_GRASS_4", 100, 1, 1}, grass6={"SAND_GRASS_6", 100, 1, 1}, grass1={"SAND_GRASS_1", 100, 1, 1}, grass3={"SAND_GRASS_3", 100, 1, 1}, grass7={"SAND_GRASS_7", 100, 1, 1}, grass9={"SAND_GRASS_9", 100, 1, 1}, inner_grass1="SAND_GRASS_1I", inner_grass3="SAND_GRASS_3I", inner_grass7="SAND_GRASS_7I", inner_grass9="SAND_GRASS_9I",
	},
}

newEntity{
	define_as = "UNDERGROUND_SAND",
	type = "floor", subtype = "sand",
	name = "sand", image = "terrain/sand.png",
	display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	grow = "SANDWALL_STABLE",
	nice_tiler = { method="replace", base={"UNDERGROUND_SAND", 10, 1, 11}},
}
for i = 1, 11 do newEntity{ base = "UNDERGROUND_SAND", define_as = "UNDERGROUND_SAND"..i, image = "terrain/sand_"..i..".png"} end

newEntity{
	define_as = "SANDWALL",
	type = "wall", subtype = "sand",
	name = "sandwall", image = "terrain/sandwall.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	-- Dig only makes unstable tunnels
	dig = function(src, x, y, old)
		local sand = require("engine.Object").new{
			name = "unstable sand tunnel", image = "terrain/sand.png",
			display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
			canAct = false,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					game.logSeen(self, "The unstable sand tunnel collapses!")

					local a = game.level.map(self.x, self.y, engine.Map.ACTOR)
					if a then
						game.logPlayer(a, "You are crushed by the collapsing tunnel! You suffocate!")
						a:suffocate(30, self)
						engine.DamageType:get(engine.DamageType.PHYSICAL).projector(self, self.x, self.y, engine.DamageType.PHYSICAL, a.life / 2)
					end
				end
			end,
			dig = function(src, x, y, old)
				old.temporary = 20
				return nil, old, true
			end,
		}
		sand.summoner_gain_exp = true
		sand.summoner = src
		sand.old_feat = old
		sand.temporary = 20
		sand.x = x
		sand.y = y
		game.level:addEntity(sand)
		return nil, sand, true
	end,
-- [[
	nice_tiler = { method="roundwall3d",
		inner={"SANDWALL", 10, 1, 6},
		wall8={"SANDWALL_8", 100, 1, 6},
		wall2={"SANDWALL_2", 100, 1, 3},
		wall4={"SANDWALL_4", 100, 1, 1},
		wall6={"SANDWALL_6", 100, 1, 1},
		wall1={"SANDWALL_1", 100, 1, 2},
		wall3={"SANDWALL_3", 100, 1, 3},
		wall7={"SANDWALL_7", 100, 1, 3},
		wall9={"SANDWALL_9", 100, 1, 3},
		inner_wall1={"SANDWALL_1_INNER", 100, 1, 1},
		inner_wall3={"SANDWALL_3_INNER", 100, 1, 1},
		inner_wall7={"SANDWALL_7_INNER", 100, 1, 1},
		inner_wall9={"SANDWALL_9_INNER", 100, 1, 1},
--		north_south="SANDWALL_NORTH_SOUTH",
	},
--]]
}

for i = 1, 6 do
	newEntity{ base = "SANDWALL", define_as = "SANDWALL"..i, image = "terrain/sandwall_5_"..i..".png", nice_tiler = false}
	newEntity{ base = "SANDWALL", define_as = "SANDWALL_8"..i, image = "terrain/sandwall_5_"..i..".png", add_displays = {class.new{image="terrain/sandwall_8_1.png", z=18, display_y=-1}}, nice_tiler = false}
end
for i = 1, 3 do newEntity{ base = "SANDWALL", define_as = "SANDWALL_2"..i, image = "terrain/sand.png", add_displays = {class.new{image = "terrain/sandwall_2_"..i..".png"}}, nice_tiler = false} end
newEntity{ base = "SANDWALL", define_as = "SANDWALL_41", image = "terrain/sand.png", add_displays = {class.new{image = "terrain/sandwall_4_1.png"}}, nice_tiler = false}
newEntity{ base = "SANDWALL", define_as = "SANDWALL_61", image = "terrain/sand.png", add_displays = {class.new{image = "terrain/sandwall_6_1.png"}}, nice_tiler = false}
for i = 1, 3 do newEntity{ base = "SANDWALL", define_as = "SANDWALL_3"..i, image = "terrain/sand.png", add_displays = {class.new{image = "terrain/sandwall_3_"..i..".png"}}, nice_tiler = false} end
for i = 1, 2 do newEntity{ base = "SANDWALL", define_as = "SANDWALL_1"..i, image = "terrain/sand.png", add_displays = {class.new{image = "terrain/sandwall_1_"..i..".png"}}, nice_tiler = false} end
for i = 1, 3 do newEntity{ base = "SANDWALL", define_as = "SANDWALL_7"..i, image = "terrain/sandwall_5_"..i..".png", add_displays = {class.new{image="terrain/sandwall_7_1.png", z=18, display_y=-1}}, nice_tiler = false} end
for i = 1, 3 do newEntity{ base = "SANDWALL", define_as = "SANDWALL_9"..i, image = "terrain/sandwall_5_"..i..".png", add_displays = {class.new{image="terrain/sandwall_9_1.png", z=18, display_y=-1}}, nice_tiler = false} end
newEntity{ base = "SANDWALL", define_as = "SANDWALL_7_INNER1", image = "terrain/sand.png", add_displays = {class.new{image = "terrain/sandwall_7i_1.png"}}, nice_tiler = false}
newEntity{ base = "SANDWALL", define_as = "SANDWALL_9_INNER1", image = "terrain/sand.png", add_displays = {class.new{image = "terrain/sandwall_9i_1.png"}}, nice_tiler = false}
newEntity{ base = "SANDWALL", define_as = "SANDWALL_1_INNER1", image = "terrain/sand.png", add_displays = {class.new{image = "terrain/sandwall_1i_1.png"}}, nice_tiler = false}
newEntity{ base = "SANDWALL", define_as = "SANDWALL_3_INNER1", image = "terrain/sand.png", add_displays = {class.new{image = "terrain/sandwall_3i_1.png"}}, nice_tiler = false}


newEntity{
	define_as = "SANDWALL_STABLE",
	type = "wall", subtype = "sand",
	name = "sandwall", image = "terrain/sandwall.png",
	display = '#', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	dig = "SAND",
}

newEntity{
	define_as = "PALMTREE",
	type = "wall", subtype = "sand",
	name = "tree", image = "terrain/sand.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=93,g=79,b=22},
--	add_displays = class:makeTrees("terrain/palmtree_alpha", 1),
	add_displays = {class.new{image="terrain/palmtree_alpha1.png"}},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "SAND",
}

-----------------------------------------
-- Sandy exits
-----------------------------------------
newEntity{
	define_as = "SAND_UP_WILDERNESS",
	type = "floor", subtype = "sand",
	name = "exit to the worldmap", image = "terrain/sand.png", add_displays = {class.new{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "SAND_UP8",
	type = "floor", subtype = "sand",
	name = "way to the previous level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "SAND_UP2",
	type = "floor", subtype = "sand",
	name = "way to the previous level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "SAND_UP4",
	type = "floor", subtype = "sand",
	name = "way to the previous level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "SAND_UP6",
	type = "floor", subtype = "sand",
	name = "way to the previous level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "SAND_DOWN8",
	type = "floor", subtype = "sand",
	name = "way to the next level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "SAND_DOWN2",
	type = "floor", subtype = "sand",
	name = "way to the next level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "SAND_DOWN4",
	type = "floor", subtype = "sand",
	name = "way to the next level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "SAND_DOWN6",
	type = "floor", subtype = "sand",
	name = "way to the next level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "SAND_LADDER_DOWN",
	type = "floor", subtype = "sand",
	name = "ladder to the next level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/ladder_down.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "SAND_LADDER_UP",
	type = "floor", subtype = "sand",
	name = "ladder to the previous level", image = "terrain/sand.png", add_displays = {class.new{image="terrain/ladder_up.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "SAND_LADDER_UP_WILDERNESS",
	type = "floor", subtype = "sand",
	name = "ladder to worldmap", image = "terrain/sand.png", add_displays = {class.new{image="terrain/ladder_up_wild.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

-----------------------------------------
-- Grass/sand
-----------------------------------------

for i = 1, 9 do for j = 1, 1 do
	if i ~= 5 then newEntity{base="SAND", define_as = "SAND_GRASS_"..i..j, image="terrain/sand_grass_"..i.."_"..j..".png"} end
end end
newEntity{base="SAND", define_as = "SAND_GRASS_1I", image="terrain/sand_grass_1i_1.png"}
newEntity{base="SAND", define_as = "SAND_GRASS_3I", image="terrain/sand_grass_3i_1.png"}
newEntity{base="SAND", define_as = "SAND_GRASS_7I", image="terrain/sand_grass_7i_1.png"}
newEntity{base="SAND", define_as = "SAND_GRASS_9I", image="terrain/sand_grass_9i_1.png"}
