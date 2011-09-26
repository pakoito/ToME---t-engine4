-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

------------------------------------------------------------
-- For inside the sea
------------------------------------------------------------

newEntity{
	define_as = "WATER_FLOOR",
	type = "floor", subtype = "underwater",
	name = "underwater", image = "terrain/underwater/subsea_floor_02.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	air_level = -5, air_condition="water",
	nice_tiler = { method="replace", base={"WATER_FLOOR", 10, 1, 5}},
}
for i = 1, 5 do newEntity{ base="WATER_FLOOR", define_as = "WATER_FLOOR"..i, image = "terrain/underwater/subsea_floor_02"..string.char(string.byte('a')+i-1)..".png" } end

newEntity{
	define_as = "WATER_WALL",
	type = "wall", subtype = "underwater",
	name = "coral wall", image = "terrain/underwater/subsea_granite_wall1.png",
	display = '#', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -5,
	z = 3,
	nice_tiler = { method="wall3d", inner={"WATER_WALL", 100, 1, 5}, north={"WATER_WALL_NORTH", 100, 1, 5}, south={"WATER_WALL_SOUTH", 10, 1, 14}, north_south="WATER_WALL_NORTH_SOUTH", small_pillar="WATER_WALL_SMALL_PILLAR", pillar_2="WATER_WALL_PILLAR_2", pillar_8={"WATER_WALL_PILLAR_8", 100, 1, 5}, pillar_4="WATER_WALL_PILLAR_4", pillar_6="WATER_WALL_PILLAR_6" },
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	dig = "WATER_FLOOR",
}

for i = 1, 5 do
	newEntity{ base = "WATER_WALL", define_as = "WATER_WALL"..i, image = "terrain/underwater/subsea_granite_wall1_"..i..".png", z = 3}
	newEntity{ base = "WATER_WALL", define_as = "WATER_WALL_NORTH"..i, image = "terrain/underwater/subsea_granite_wall1_"..i..".png", z = 3, add_displays = {class.new{image="terrain/underwater/subsea_granite_wall3.png", z=18, display_y=-1}}}
	newEntity{ base = "WATER_WALL", define_as = "WATER_WALL_PILLAR_8"..i, image = "terrain/underwater/subsea_granite_wall1_"..i..".png", z = 3, add_displays = {class.new{image="terrain/underwater/subsea_granite_wall_pillar_8.png", z=18, display_y=-1}}}
end
newEntity{ base = "WATER_WALL", define_as = "WATER_WALL_NORTH_SOUTH", image = "terrain/underwater/subsea_granite_wall2.png", z = 3, add_displays = {class.new{image="terrain/underwater/subsea_granite_wall3.png", z=18, display_y=-1}}}
newEntity{ base = "WATER_WALL", define_as = "WATER_WALL_SOUTH", image = "terrain/underwater/subsea_granite_wall2.png", z = 3}
for i = 1, 14 do newEntity{ base = "WATER_WALL", define_as = "WATER_WALL_SOUTH"..i, image = "terrain/underwater/subsea_granite_wall2_"..i..".png", z = 3} end
newEntity{ base = "WATER_WALL", define_as = "WATER_WALL_SMALL_PILLAR", image = "terrain/underwater/subsea_floor_02.png", z=1, add_displays = {class.new{image="terrain/underwater/subsea_granite_wall_pillar_small.png",z=3}, class.new{image="terrain/underwater/subsea_granite_wall_pillar_small_top.png", z=18, display_y=-1}}}
newEntity{ base = "WATER_WALL", define_as = "WATER_WALL_PILLAR_6", image = "terrain/underwater/subsea_floor_02.png", z=1, add_displays = {class.new{image="terrain/underwater/subsea_granite_wall_pillar_3.png",z=3}, class.new{image="terrain/underwater/subsea_granite_wall_pillar_9.png", z=18, display_y=-1}}}
newEntity{ base = "WATER_WALL", define_as = "WATER_WALL_PILLAR_4", image = "terrain/underwater/subsea_floor_02.png", z=1, add_displays = {class.new{image="terrain/underwater/subsea_granite_wall_pillar_1.png",z=3}, class.new{image="terrain/underwater/subsea_granite_wall_pillar_7.png", z=18, display_y=-1}}}
newEntity{ base = "WATER_WALL", define_as = "WATER_WALL_PILLAR_2", image = "terrain/underwater/subsea_floor_02.png", z=1, add_displays = {class.new{image="terrain/underwater/subsea_granite_wall_pillar_2.png",z=3}}}


newEntity{
	define_as = "WATER_DOOR",
	type = "wall", subtype = "floor",
	name = "door", image = "terrain/underwater/subsea_stone_wall_door_closed.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="WATER_DOOR_VERT", west_east="WATER_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	air_level = -5, air_condition="water",
	is_door = true,
	door_opened = "WATER_DOOR_OPEN",
	dig = "WATER_FLOOR",
}
newEntity{
	define_as = "WATER_DOOR_OPEN",
	type = "wall", subtype = "floor",
	name = "open door", image="terrain/underwater/subsea_granite_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	always_remember = true,
	air_level = -5, air_condition="water",
	is_door = true,
	door_closed = "WATER_DOOR",
}
newEntity{ base = "WATER_DOOR", define_as = "WATER_DOOR_HORIZ", image = "terrain/underwater/subsea_stone_wall_door_closed.png", add_displays = {class.new{image="terrain/underwater/subsea_granite_wall3.png", z=18, display_y=-1}}, door_opened = "WATER_DOOR_HORIZ_OPEN"}
newEntity{ base = "WATER_DOOR_OPEN", define_as = "WATER_DOOR_HORIZ_OPEN", image = "terrain/underwater/subsea_floor_02.png", add_displays = {class.new{image="terrain/underwater/subsea_stone_store_open.png", z=17}, class.new{image="terrain/underwater/subsea_granite_wall3.png", z=18, display_y=-1}}, door_closed = "WATER_DOOR_HORIZ"}
newEntity{ base = "WATER_DOOR", define_as = "WATER_DOOR_VERT", image = "terrain/underwater/subsea_floor_02.png", add_displays = {class.new{image="terrain/underwater/subsea_granite_door1_vert.png", z=17}, class.new{image="terrain/underwater/subsea_granite_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "WATER_DOOR_OPEN_VERT", dig = "WATER_DOOR_OPEN_VERT"}
newEntity{ base = "WATER_DOOR_OPEN", define_as = "WATER_DOOR_OPEN_VERT", image = "terrain/underwater/subsea_floor_02.png", add_displays = {class.new{image="terrain/underwater/subsea_granite_door1_open_vert.png", z=17}, class.new{image="terrain/underwater/subsea_granite_door1_open_vert_north.png", z=18, display_y=-1}}, door_closed = "WATER_DOOR_VERT"}


newEntity{
	define_as = "WATER_FLOOR_BUBBLE",
	name = "underwater air bubble", image = "terrain/underwater/subsea_floor_bubbles.png",
	display = ':', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	air_level = 15, nb_charges = resolvers.rngrange(4, 7),
	force_clone = true,
	on_stand = function(self, x, y, who)
		if ((who.can_breath.water and who.can_breath.water <= 0) or not who.can_breath.water) and not who:attr("no_breath") then
			self.nb_charges = self.nb_charges - 1
			if self.nb_charges <= 0 then
				game.logSeen(who, "#AQUAMARINE#The air bubbles are depleted!")
				local g = game.zone:makeEntityByName(game.level, "terrain", "WATER_FLOOR")
				game.zone:addEntity(game.level, g, "terrain", x, y)
			end
		end
	end,
}

------------------------------------------------------------
-- For outside
------------------------------------------------------------

newEntity{
	define_as = "WATER_BASE",
	type = "floor", subtype = "water",
	name = "deep water", image = "terrain/water_floor.png",
	display = '~', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	always_remember = true,
	special_minimap = colors.BLUE,
}

-----------------------------------------
-- Water/grass
-----------------------------------------

newEntity{ base="WATER_BASE",
	define_as = "DEEP_WATER",
	image="terrain/water_grass_5_1.png",
	air_level = -5, air_condition="water",
}

-----------------------------------------
-- Water(ocean)/grass
-----------------------------------------

newEntity{ base="WATER_BASE",
	define_as = "DEEP_OCEAN_WATER",
	image = "terrain/ocean_water_grass_5_1.png",
	air_level = -5, air_condition="water",
}

-----------------------------------------
-- Poison water
-----------------------------------------

newEntity{
	define_as = "POISON_DEEP_WATER",
	type = "floor", subtype = "water",
	name = "poisoned deep water", image = "terrain/poisoned_water_01.png",
	display = '~', color=colors.YELLOW_GREEN, back_color=colors.DARK_GREEN,
--	add_displays = class:makeWater(true, "poison_"),
	always_remember = true,
	air_level = -5, air_condition="water",

	mindam = resolvers.mbonus(10, 25),
	maxdam = resolvers.mbonus(20, 50),
	on_stand = function(self, x, y, who)
		local DT = engine.DamageType
		local dam = DT:get(DT.POISON).projector(self, x, y, DT.POISON, rng.range(self.mindam, self.maxdam))
		if dam > 0 then game.logPlayer(who, "The water poisons you!") end
	end,
	combatAttack = function(self) return rng.range(self.mindam, self.maxdam) end,
	nice_tiler = { method="replace", base={"POISON_DEEP_WATER", 100, 1, 6}},
}
for i = 1, 6 do newEntity{ base="POISON_DEEP_WATER", define_as = "POISON_DEEP_WATER"..i, image = "terrain/poisoned_water_0"..i..".png" } end


-----------------------------------------
-- Dungeony exits
-----------------------------------------
newEntity{
	define_as = "WATER_UP_WILDERNESS",
	name = "exit to the worldmap",
	image = "terrain/underwater/subsea_floor_02.png", add_mos = {{image="terrain/underwater/subsea_stair_up_wild.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	air_level = -5, air_condition="water",
}

newEntity{
	define_as = "WATER_UP",
	image = "terrain/underwater/subsea_floor_02.png", add_mos = {{image="terrain/underwater/subsea_stair_up.png"}},
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	air_level = -5, air_condition="water",
}

newEntity{
	define_as = "WATER_DOWN",
	image = "terrain/underwater/subsea_floor_02.png", add_mos = {{image="terrain/underwater/subsea_stair_down_03_64.png"}},
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	air_level = -5, air_condition="water",
}
