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
		base={"MOUNTAIN_5", 100, 1, 6},
		wall8={"MOUNTAIN_8", 100, 1, 6}, wall87={"MOUNTAIN_8", 100, 1, 6}, wall88={"MOUNTAIN_8", 100, 1, 6}, wall89={"MOUNTAIN_8", 100, 1, 6},
		wall2={"MOUNTAIN_2", 100, 1, 6}, wall21={"MOUNTAIN_2", 100, 1, 6}, wall22={"MOUNTAIN_2", 100, 1, 6}, wall23={"MOUNTAIN_2", 100, 1, 6},
		wall4={"MOUNTAIN_4", 100, 1, 6}, wall47={"MOUNTAIN_4", 100, 1, 6}, wall44={"MOUNTAIN_4", 100, 1, 6}, wall41={"MOUNTAIN_4", 100, 1, 6},
		wall6={"MOUNTAIN_6", 100, 1, 6}, wall69={"MOUNTAIN_6", 100, 1, 6}, wall66={"MOUNTAIN_6", 100, 1, 6}, wall63={"MOUNTAIN_6", 100, 1, 6},
		wall1={"MOUNTAIN_1", 100, 1, 6}, wall3={"MOUNTAIN_3", 100, 1, 6}, wall7={"MOUNTAIN_7", 100, 1, 6}, wall9={"MOUNTAIN_9", 100, 1, 6},
		wall11={"MOUNTAIN_1", 100, 1, 6}, wall33={"MOUNTAIN_3", 100, 1, 6}, wall77={"MOUNTAIN_7", 100, 1, 6}, wall98={"MOUNTAIN_9", 100, 1, 6},
		inner_wall1={"MOUNTAIN_1I", 100, 1, 6}, inner_wall3={"MOUNTAIN_3I", 100, 1, 6}, inner_wall7={"MOUNTAIN_7I", 100, 1, 6}, inner_wall9={"MOUNTAIN_9I", 100, 1, 6},
		pillar={"MOUNTAIN_SINGLE", 100, 1, 6},
		pillar4={"MOUNTAIN_PILLAR4", 100, 1, 6}, pillar6={"MOUNTAIN_PILLAR6", 100, 1, 6}, pillar2={"MOUNTAIN_PILLAR2", 100, 1, 6}, pillar8={"MOUNTAIN_PILLAR8", 100, 1, 6},
		pillar82={"MOUNTAIN_PILLAR82", 100, 1, 6}, pillar46={"MOUNTAIN_PILLAR46", 100, 1, 6},
	},
}

for i = 1, 6 do
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_5"..i, image="terrain/mountain5_"..i..".png"}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_8"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, image="terrain/mountain8.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_2"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_y=1, image="terrain/mountain2.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_4"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_x=-1, image="terrain/mountain4.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_6"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_x=1, image="terrain/mountain6.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_7"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_9"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain9.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_1"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_3"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=1, image="terrain/mountain3.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_1I"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain1i.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_3I"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain3i.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_7I"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=1, image="terrain/mountain7i.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_9I"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=-1, image="terrain/mountain9i.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_SINGLE"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, display_y=-1, image="terrain/mountain9.png"}}}, class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, display_y=1, image="terrain/mountain3.png"}, {display_x=-1, image="terrain/mountain4.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR4"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}}}, class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR6"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain9.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}}}, class.new{display_y=1, display_x=1, image="terrain/mountain3.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR46"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, image="terrain/mountain8.png"}, class.new{display_y=1, image="terrain/mountain2.png"}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR8"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, display_y=-1, image="terrain/mountain9.png"}}}, class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR2"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, display_y=1, image="terrain/mountain3.png"}}}, class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="MOUNTAIN_WALL", define_as = "MOUNTAIN_PILLAR82"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
end

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
	nice_tiler = { method="replace", base={"ROCKY_SNOWY_TREE", 100, 1, 30} },
}
for i = 1, 30 do
newEntity{ base="ROCKY_SNOWY_TREE",
	define_as = "ROCKY_SNOWY_TREE"..i,
	image = "terrain/rocky_ground.png",
	add_displays = class:makeTrees("terrain/tree_dark_snow", 13, 10),
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
	nice_tiler = { method="mountain3d",
		base={"HARDMOUNTAIN_5", 100, 1, 6},
		wall8={"HARDMOUNTAIN_8", 100, 1, 6}, wall87={"HARDMOUNTAIN_8", 100, 1, 6}, wall88={"HARDMOUNTAIN_8", 100, 1, 6}, wall89={"HARDMOUNTAIN_8", 100, 1, 6},
		wall2={"HARDMOUNTAIN_2", 100, 1, 6}, wall21={"HARDMOUNTAIN_2", 100, 1, 6}, wall22={"HARDMOUNTAIN_2", 100, 1, 6}, wall23={"HARDMOUNTAIN_2", 100, 1, 6},
		wall4={"HARDMOUNTAIN_4", 100, 1, 6}, wall47={"HARDMOUNTAIN_4", 100, 1, 6}, wall44={"HARDMOUNTAIN_4", 100, 1, 6}, wall41={"HARDMOUNTAIN_4", 100, 1, 6},
		wall6={"HARDMOUNTAIN_6", 100, 1, 6}, wall69={"HARDMOUNTAIN_6", 100, 1, 6}, wall66={"HARDMOUNTAIN_6", 100, 1, 6}, wall63={"HARDMOUNTAIN_6", 100, 1, 6},
		wall1={"HARDMOUNTAIN_1", 100, 1, 6}, wall3={"HARDMOUNTAIN_3", 100, 1, 6}, wall7={"HARDMOUNTAIN_7", 100, 1, 6}, wall9={"HARDMOUNTAIN_9", 100, 1, 6},
		wall11={"HARDMOUNTAIN_1", 100, 1, 6}, wall33={"HARDMOUNTAIN_3", 100, 1, 6}, wall77={"HARDMOUNTAIN_7", 100, 1, 6}, wall98={"HARDMOUNTAIN_9", 100, 1, 6},
		inner_wall1={"HARDMOUNTAIN_1I", 100, 1, 6}, inner_wall3={"HARDMOUNTAIN_3I", 100, 1, 6}, inner_wall7={"HARDMOUNTAIN_7I", 100, 1, 6}, inner_wall9={"HARDMOUNTAIN_9I", 100, 1, 6},
		pillar={"HARDMOUNTAIN_SINGLE", 100, 1, 6},
		pillar4={"HARDMOUNTAIN_PILLAR4", 100, 1, 6}, pillar6={"HARDMOUNTAIN_PILLAR6", 100, 1, 6}, pillar2={"HARDMOUNTAIN_PILLAR2", 100, 1, 6}, pillar8={"HARDMOUNTAIN_PILLAR8", 100, 1, 6},
		pillar82={"HARDMOUNTAIN_PILLAR82", 100, 1, 6}, pillar46={"HARDMOUNTAIN_PILLAR46", 100, 1, 6},
	},
}

for i = 1, 6 do
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_5"..i, image="terrain/mountain5_"..i..".png"}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_8"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, image="terrain/mountain8.png"}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_2"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_y=1, image="terrain/mountain2.png"}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_4"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_x=-1, image="terrain/mountain4.png"}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_6"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_x=1, image="terrain/mountain6.png"}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_7"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_9"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain9.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_1"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_3"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=1, image="terrain/mountain3.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_1I"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain1i.png"}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_3I"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain3i.png"}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_7I"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=1, image="terrain/mountain7i.png"}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_9I"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=-1, image="terrain/mountain9i.png"}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_SINGLE"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, display_y=-1, image="terrain/mountain9.png"}}}, class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, display_y=1, image="terrain/mountain3.png"}, {display_x=-1, image="terrain/mountain4.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_PILLAR4"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}}}, class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_PILLAR6"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain9.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}}}, class.new{display_y=1, display_x=1, image="terrain/mountain3.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_PILLAR46"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, image="terrain/mountain8.png"}, class.new{display_y=1, image="terrain/mountain2.png"}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_PILLAR8"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, display_y=-1, image="terrain/mountain9.png"}}}, class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_PILLAR2"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, display_y=1, image="terrain/mountain3.png"}}}, class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_PILLAR82"..i, image="terrain/mountain5_"..i..".png", add_displays = {class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
end


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
