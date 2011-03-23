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
	define_as = "ROCKY_GROUND",
	type = "floor", subtype = "rock",
	name = "rocky ground", image = "terrain/rocky_ground.png",
	display = '.', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	grow = "MOUNTAIN_WALL",
}

newEntity{
	define_as = "MOUNTAIN_WALL",
	type = "rockwall", subtype = "rock",
	name = "rocky mountain", image = "terrain/rocky_mountain.png",
	display = '#', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20,
	dig = "ROCKY_GROUND",
	nice_tiler = { method="mountain3d",
		base="MOUNTAIN_5",
		wall8="MOUNTAIN_8", wall87="MOUNTAIN_8", wall88="MOUNTAIN_8", wall89="MOUNTAIN_8",
		wall2="MOUNTAIN_2", wall21="MOUNTAIN_2", wall22="MOUNTAIN_2", wall23="MOUNTAIN_2",
		wall4="MOUNTAIN_4", wall47="MOUNTAIN_4", wall44="MOUNTAIN_4", wall41="MOUNTAIN_4",
		wall6="MOUNTAIN_6", wall69="MOUNTAIN_6", wall66="MOUNTAIN_6", wall63="MOUNTAIN_6",
		wall1="MOUNTAIN_1", wall3="MOUNTAIN_3", wall7="MOUNTAIN_7", wall9="MOUNTAIN_9",
		wall11="MOUNTAIN_1", wall33="MOUNTAIN_3", wall77="MOUNTAIN_7", wall98="MOUNTAIN_9",
		inner_wall1="MOUNTAIN_1I", inner_wall3="MOUNTAIN_3I", inner_wall7="MOUNTAIN_7I", inner_wall9="MOUNTAIN_9I",
		pillar = "MOUNTAIN_SINGLE",
		pillar4 = "MOUNTAIN_PILLAR4", pillar6 = "MOUNTAIN_PILLAR6", pillar2 = "MOUNTAIN_PILLAR2", pillar8 = "MOUNTAIN_PILLAR8",
		pillar82 = "MOUNTAIN_PILLAR82", pillar46 = "MOUNTAIN_PILLAR46",
	},
}

newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_5", image="terrain/mountain5.png"}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_8", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=-1, image="terrain/mountain8.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_2", image="terrain/mountain5.png", add_displays = {class.new{display_y=1, image="terrain/mountain2.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_4", image="terrain/mountain5.png", add_displays = {class.new{display_x=-1, image="terrain/mountain4.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_6", image="terrain/mountain5.png", add_displays = {class.new{display_x=1, image="terrain/mountain6.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_7", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_9", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain9.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_1", image="terrain/mountain5.png", add_displays = {class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_3", image="terrain/mountain5.png", add_displays = {class.new{display_y=1, display_x=1, image="terrain/mountain3.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_1I", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain1i.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_3I", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain3i.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_7I", image="terrain/mountain5.png", add_displays = {class.new{display_y=1, display_x=1, image="terrain/mountain7i.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_9I", image="terrain/mountain5.png", add_displays = {class.new{display_y=1, display_x=-1, image="terrain/mountain9i.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_SINGLE", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, display_y=-1, image="terrain/mountain9.png"}}}, class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, display_y=1, image="terrain/mountain3.png"}, {display_x=-1, image="terrain/mountain4.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR4", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}}}, class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR6", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain9.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}}}, class.new{display_y=1, display_x=1, image="terrain/mountain3.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR46", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=-1, image="terrain/mountain8.png"}, class.new{display_y=1, image="terrain/mountain2.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR8", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, display_y=-1, image="terrain/mountain9.png"}}}, class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR2", image="terrain/mountain5.png", add_displays = {class.new{z=18, display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, display_y=1, image="terrain/mountain3.png"}}}, class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR82", image="terrain/mountain5.png", add_displays = {class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}

newEntity{
	define_as = "ROCKY_SNOWY_TREE",
	type = "wall", subtype = "rock",
	name = "snowy tree", image = "terrain/rocky_snowy_tree.png",
	display = '#', color=colors.WHITE, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "ROCKY_GROUND",
	nice_tiler = { method="replace", base={"ROCKY_SNOWY_TREE", 100, 1, 20} },
}
for i = 1, 20 do
newEntity{ base="ROCKY_SNOWY_TREE",
	define_as = "ROCKY_SNOWY_TREE"..i,
	image = "terrain/rocky_ground.png",
	add_displays = class:makeTrees("terrain/tree_dark_snow"),
	nice_tiler = false,
}
end

newEntity{
	define_as = "HARDMOUNTAIN_WALL",
	name = "hard rocky mountain", image = "terrain/rocky_mountain.png",
	display = '#', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
}

-----------------------------------------
-- Rocky exits
-----------------------------------------
newEntity{
	define_as = "ROCKY_UP_WILDERNESS",
	name = "exit to the worldmap", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "ROCKY_UP8",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "ROCKY_UP2",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "ROCKY_UP4",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "ROCKY_UP6",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "ROCKY_DOWN8",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "ROCKY_DOWN2",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "ROCKY_DOWN4",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "ROCKY_DOWN6",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
