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

local grass_editer = { method="borders", type="grass",
	default8={add_mos={{image="terrain/grass/grass_2_%02d.png", display_y=-1}}, min=1, max=5},
	default2={add_mos={{image="terrain/grass/grass_8_%02d.png", display_y=1}}, min=1, max=5},
	default4={add_mos={{image="terrain/grass/grass_6_%02d.png", display_x=-1}}, min=1, max=5},
	default6={add_mos={{image="terrain/grass/grass_4_%02d.png", display_x=1}}, min=1, max=4},

	default1={add_mos={{image="terrain/grass/grass_9_%02d.png", display_x=-1, display_y=1}}, min=1, max=3},
	default3={add_mos={{image="terrain/grass/grass_7_%02d.png", display_x=1, display_y=1}}, min=1, max=3},
	default7={add_mos={{image="terrain/grass/grass_3_%02d.png", display_x=-1, display_y=-1}}, min=1, max=3},
	default9={add_mos={{image="terrain/grass/grass_1_%02d.png", display_x=1, display_y=-1}}, min=1, max=3},

	default1i={add_mos={{image="terrain/grass/grass_inner_1_%02d.png", display_x=-1, display_y=1}}, min=1, max=3},
	default3i={add_mos={{image="terrain/grass/grass_inner_3_%02d.png", display_x=1, display_y=1}}, min=1, max=3},
	default7i={add_mos={{image="terrain/grass/grass_inner_7_%02d.png", display_x=-1, display_y=-1}}, min=1, max=3},
	default9i={add_mos={{image="terrain/grass/grass_inner_9_%02d.png", display_x=1, display_y=-1}}, min=1, max=3},

	water8={add_mos={{image="terrain/grass/grass_2_%02d.png", display_y=-1}}, min=1, max=1},
	water2={add_mos={{image="terrain/grass/grass_8_%02d.png", display_y=1}}, min=1, max=1},
	water4={add_mos={{image="terrain/grass/grass_6_%02d.png", display_x=-1}}, min=1, max=1},
	water6={add_mos={{image="terrain/grass/grass_4_%02d.png", display_x=1}}, min=1, max=1},

	water1={add_mos={{image="terrain/grass/grass_9_%02d.png", display_x=-1, display_y=1}}, min=1, max=1},
	water3={add_mos={{image="terrain/grass/grass_7_%02d.png", display_x=1, display_y=1}}, min=1, max=1},
	water7={add_mos={{image="terrain/grass/grass_3_%02d.png", display_x=-1, display_y=-1}}, min=1, max=1},
	water9={add_mos={{image="terrain/grass/grass_1_%02d.png", display_x=1, display_y=-1}}, min=1, max=1},

	water1i={add_mos={{image="terrain/grass/grass_inner_1_%02d.png", display_x=-1, display_y=1}}, min=1, max=1},
	water3i={add_mos={{image="terrain/grass/grass_inner_3_%02d.png", display_x=1, display_y=1}}, min=1, max=1},
	water7i={add_mos={{image="terrain/grass/grass_inner_7_%02d.png", display_x=-1, display_y=-1}}, min=1, max=1},
	water9i={add_mos={{image="terrain/grass/grass_inner_9_%02d.png", display_x=1, display_y=-1}}, min=1, max=1},
}

local sand_editer = { method="borders", type="sand", forbid={grass=true},
	default8={add_mos={{image="terrain/sand/sand_2_%02d.png", display_y=-1}}, min=1, max=5},
	default2={add_mos={{image="terrain/sand/sand_8_%02d.png", display_y=1}}, min=1, max=5},
	default4={add_mos={{image="terrain/sand/sand_6_%02d.png", display_x=-1}}, min=1, max=5},
	default6={add_mos={{image="terrain/sand/sand_4_%02d.png", display_x=1}}, min=1, max=4},

	default1={add_mos={{image="terrain/sand/sand_9_%02d.png", display_x=-1, display_y=1}}, min=1, max=3},
	default3={add_mos={{image="terrain/sand/sand_7_%02d.png", display_x=1, display_y=1}}, min=1, max=3},
	default7={add_mos={{image="terrain/sand/sand_3_%02d.png", display_x=-1, display_y=-1}}, min=1, max=3},
	default9={add_mos={{image="terrain/sand/sand_1_%02d.png", display_x=1, display_y=-1}}, min=1, max=3},

	default1i={add_mos={{image="terrain/sand/sand_inner_1_%02d.png", display_x=-1, display_y=1}}, min=1, max=3},
	default3i={add_mos={{image="terrain/sand/sand_inner_3_%02d.png", display_x=1, display_y=1}}, min=1, max=3},
	default7i={add_mos={{image="terrain/sand/sand_inner_7_%02d.png", display_x=-1, display_y=-1}}, min=1, max=3},
	default9i={add_mos={{image="terrain/sand/sand_inner_9_%02d.png", display_x=1, display_y=-1}}, min=1, max=3},
}

--------------------------------------------------------------------------------
-- Grassland
--------------------------------------------------------------------------------

newEntity{
	define_as = "PLAINS",
	type = "floor", subtype = "grass",
	name = "plains", image = "terrain/grass.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	nice_tiler = { method="replace", base={"PLAINS_PATCH", 70, 1, 15}},
	can_encounter=true, equilibrium_level=-10,
	nice_editer = grass_editer,
}
for i = 1, 12 do newEntity{ base = "PLAINS", define_as = "PLAINS_PATCH"..i, image = "terrain/grass"..(i<7 and "" or "2")..".png" } end
newEntity{ base="PLAINS", define_as="CULTIVATION",
	name="cultivated fields",
	display=';', color=colors.GREEN, back_color=colors.DARK_GREEN,
	image="terrain/cultivation.png",
	nice_tiler = { method="replace", base={"CULTIVATION", 100, 1, 4}},
}
for i = 1, 4 do newEntity{ base = "CULTIVATION", define_as = "CULTIVATION"..i, image="terrain/grass.png", add_mos={{image="terrain/cultivation0"..i..".png"}} } end

newEntity{ base="PLAINS", define_as="LOW_HILLS",
	name="low hills",
	display=';', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	nice_tiler = { method="replace", base={"LOW_HILLS", 100, 1, 6}},
}
for i = 1, 6 do newEntity{ base = "LOW_HILLS", define_as = "LOW_HILLS"..i, image="terrain/grass.png", add_mos={{image="terrain/grass_hill_"..i.."_01.png"}} } end

newEntity{
	define_as = "FOREST",
	type = "wall", subtype = "grass",
	name = "forest",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"FOREST", 100, 1, 30}},
	nice_editer = grass_editer,
}
for i = 1, 30 do newEntity{ base="FOREST", define_as = "FOREST"..i, image = "terrain/grass.png", add_displays = class:makeTrees("terrain/tree_alpha", 13, 9)} end

newEntity{
	define_as = "OLD_FOREST",
	type = "wall", subtype = "grass",
	name = "Old forest",
	image = "terrain/tree_dark.png",
	display = '#', color=colors.GREEN, back_color={r=34,g=65,b=33},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"OLD_FOREST", 100, 1, 30}},
	nice_editer = grass_editer,
}
for i = 1, 30 do newEntity{ base="OLD_FOREST", define_as = "OLD_FOREST"..i, image = "terrain/grass.png", add_displays = class:makeTrees("terrain/tree_alpha", 13, 9, colors.GREY)} end

newEntity{
	define_as = "BURNT_FOREST",
	type = "wall", subtype = "burnt",
	name = "burnt tree",
	image = "terrain/burnt_tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"BURNT_FOREST", 100, 1, 20}},
}
for i = 1, 20 do newEntity{ base="BURNT_FOREST", define_as = "BURNT_FOREST"..i, name = "burnt tree", image = "terrain/grass_burnt1.png", add_displays = class:makeTrees("terrain/burnttree_alpha")} end

--------------------------------------------------------------------------------
-- Iceland
--------------------------------------------------------------------------------

newEntity{
	define_as = "POLAR_CAP",
	type = "floor", subtype = "snow",
	name = "polar cap", image = "terrain/frozen_ground.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.WHITE,
	can_encounter=true, equilibrium_level=-10,
}

newEntity{
	define_as = "COLD_FOREST",
	type = "wall", subtype = "snow",
	name = "cold forest", image = "terrain/tree_dark_snow1.png",
	display = '#', color=colors.WHITE, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"COLD_FOREST", 100, 1, 30} },
}
for i = 1, 30 do
newEntity{ base="COLD_FOREST",
	define_as = "COLD_FOREST"..i,
	image = "terrain/frozen_ground.png",
	add_displays = class:makeTrees("terrain/tree_dark_snow", 13, 10),
	nice_tiler = false,
}
end

--------------------------------------------------------------------------------
-- Water
--------------------------------------------------------------------------------

newEntity{
	define_as = "WATER_BASE",
	type = "floor", subtype = "water",
	name = "deep water", image = "terrain/water_grass_5_1.png",
	display = '~', color=colors.AQUAMARINE, back_color=colors.DARK_BLUE,
	always_remember = true,
	air_level = -5, air_condition="water",
	can_encounter="water", equilibrium_level=-10,
}
newEntity{ base = "WATER_BASE", define_as = "WATER_BASE_DEEP", can_pass = {pass_water=1}, does_block_move = true }

newEntity{ base="WATER_BASE_DEEP", define_as = "SEA_EYAL", name = "sea of Eyal" }
newEntity{ base="WATER_BASE", define_as = "RIVER", name = "river" }
newEntity{ base="WATER_BASE_DEEP", define_as = "LAKE_NUR", name = "lake of Nur" }
newEntity{ base="WATER_BASE_DEEP", define_as = "SEA_SASH", name = "sea of Sash" }
newEntity{ base="WATER_BASE_DEEP", define_as = "LAKE", name = "lake" }
newEntity{ base="WATER_BASE_DEEP", define_as = "LAKE_WESTREACH", name = "Westreach lake" }
newEntity{ base="WATER_BASE_DEEP", define_as = "LAKE_IRONDEEP", name = "Irondeep lake" }
newEntity{ base="WATER_BASE_DEEP", define_as = "LAKE_SPELLMURK", name = "Spellmurk lake" }


--------------------------------------------------------------------------------
-- Mountains
--------------------------------------------------------------------------------

for id, name in pairs{['']='mountain chain', DAIKARA_='daikara', IRONTHRONE_='Iron Throne', VOLCANIC_='volcanic mountains'} do
newEntity{
	define_as = id.."MOUNTAIN",
	type = "rockwall", subtype = "grass",
	name = name, image = "terrain/rocky_mountain.png",
	display = '#', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20,
	nice_tiler = { method="mountain3d",
		base={id.."MOUNTAIN_5", 100, 1, 6},
		wall8={id.."MOUNTAIN_8", 100, 1, 6}, wall87={id.."MOUNTAIN_8", 100, 1, 6}, wall88={id.."MOUNTAIN_8", 100, 1, 6}, wall89={id.."MOUNTAIN_8", 100, 1, 6},
		wall2={id.."MOUNTAIN_2", 100, 1, 6}, wall21={id.."MOUNTAIN_2", 100, 1, 6}, wall22={id.."MOUNTAIN_2", 100, 1, 6}, wall23={id.."MOUNTAIN_2", 100, 1, 6},
		wall4={id.."MOUNTAIN_4", 100, 1, 6}, wall47={id.."MOUNTAIN_4", 100, 1, 6}, wall44={id.."MOUNTAIN_4", 100, 1, 6}, wall41={id.."MOUNTAIN_4", 100, 1, 6},
		wall6={id.."MOUNTAIN_6", 100, 1, 6}, wall69={id.."MOUNTAIN_6", 100, 1, 6}, wall66={id.."MOUNTAIN_6", 100, 1, 6}, wall63={id.."MOUNTAIN_6", 100, 1, 6},
		wall1={id.."MOUNTAIN_1", 100, 1, 6}, wall3={id.."MOUNTAIN_3", 100, 1, 6}, wall7={id.."MOUNTAIN_7", 100, 1, 6}, wall9={id.."MOUNTAIN_9", 100, 1, 6},
		wall11={id.."MOUNTAIN_1", 100, 1, 6}, wall33={id.."MOUNTAIN_3", 100, 1, 6}, wall77={id.."MOUNTAIN_7", 100, 1, 6}, wall98={id.."MOUNTAIN_9", 100, 1, 6},
		inner_wall1={id.."MOUNTAIN_1I", 100, 1, 6}, inner_wall3={id.."MOUNTAIN_3I", 100, 1, 6}, inner_wall7={id.."MOUNTAIN_7I", 100, 1, 6}, inner_wall9={id.."MOUNTAIN_9I", 100, 1, 6},
		pillar={id.."MOUNTAIN_SINGLE", 100, 1, 6},
		pillar4={id.."MOUNTAIN_PILLAR4", 100, 1, 6}, pillar6={id.."MOUNTAIN_PILLAR6", 100, 1, 6}, pillar2={id.."MOUNTAIN_PILLAR2", 100, 1, 6}, pillar8={id.."MOUNTAIN_PILLAR8", 100, 1, 6},
		pillar82={id.."MOUNTAIN_PILLAR82", 100, 1, 6}, pillar46={id.."MOUNTAIN_PILLAR46", 100, 1, 6},
	},
}

for i = 1, 6 do
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_5"..i, image="terrain/mountain5_"..i..".png", z=2}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_8"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=-1, image="terrain/mountain8.png"}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_2"..i, image="terrain/mountain5_"..i..".png", z=2, add_mos = {{display_y=1, image="terrain/mountain2.png"}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_4"..i, image="terrain/mountain5_"..i..".png", z=2, add_mos = {{display_x=-1, image="terrain/mountain4.png"}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_6"..i, image="terrain/mountain5_"..i..".png", z=2, add_mos = {{display_x=1, image="terrain/mountain6.png"}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_7"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_9"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain9.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_1"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{display_y=1, z=3, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_3"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{display_y=1, z=3, display_x=1, image="terrain/mountain3.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_1I"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain1i.png"}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_3I"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain3i.png"}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_7I"..i, image="terrain/mountain5_"..i..".png", z=2, add_mos = {{display_y=1, display_x=1, image="terrain/mountain7i.png"}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_9I"..i, image="terrain/mountain5_"..i..".png", z=2, add_mos = {{display_y=1, display_x=-1, image="terrain/mountain9i.png"}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_SINGLE"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, display_y=-1, image="terrain/mountain9.png"}}}, class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, display_y=1, image="terrain/mountain3.png"}, {display_x=-1, image="terrain/mountain4.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_PILLAR4"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}}}, class.new{display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=-1, image="terrain/mountain4.png"}}}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_PILLAR6"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/mountain9.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}}}, class.new{display_y=1, display_x=1, image="terrain/mountain3.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_PILLAR46"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=-1, image="terrain/mountain8.png"}, class.new{display_y=1, image="terrain/mountain2.png"}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_PILLAR8"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/mountain7.png", add_mos = {{display_y=-1, image="terrain/mountain8.png"}, {display_x=1, display_y=-1, image="terrain/mountain9.png"}}}, class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_PILLAR2"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{z=18, display_y=1, display_x=-1, image="terrain/mountain1.png", add_mos = {{display_y=1, image="terrain/mountain2.png"}, {display_x=1, display_y=1, image="terrain/mountain3.png"}}}, class.new{display_x=-1, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
newEntity{base=id.."MOUNTAIN", define_as = id.."MOUNTAIN_PILLAR82"..i, image="terrain/mountain5_"..i..".png", z=2, add_displays = {class.new{display_x=-1, z=3, image="terrain/mountain4.png", add_mos = {{display_x=1, image="terrain/mountain6.png"}}}}}
end
end

newEntity{
	define_as = "GOLDEN_MOUNTAIN",
	type = "rockwall", subtype = "grass",
	name = "Sunwall mountain", image = "terrain/golden_mountain5_1.png",
	display = '#', color=colors.GOLD, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
	nice_tiler = { method="mountain3d",
		base={"GOLDENMOUNTAIN_5", 100, 1, 6},
		wall8={"GOLDENMOUNTAIN_8", 100, 1, 6}, wall87={"GOLDENMOUNTAIN_8", 100, 1, 6}, wall88={"GOLDENMOUNTAIN_8", 100, 1, 6}, wall89={"GOLDENMOUNTAIN_8", 100, 1, 6},
		wall2={"GOLDENMOUNTAIN_2", 100, 1, 6}, wall21={"GOLDENMOUNTAIN_2", 100, 1, 6}, wall22={"GOLDENMOUNTAIN_2", 100, 1, 6}, wall23={"GOLDENMOUNTAIN_2", 100, 1, 6},
		wall4={"GOLDENMOUNTAIN_4", 100, 1, 6}, wall47={"GOLDENMOUNTAIN_4", 100, 1, 6}, wall44={"GOLDENMOUNTAIN_4", 100, 1, 6}, wall41={"GOLDENMOUNTAIN_4", 100, 1, 6},
		wall6={"GOLDENMOUNTAIN_6", 100, 1, 6}, wall69={"GOLDENMOUNTAIN_6", 100, 1, 6}, wall66={"GOLDENMOUNTAIN_6", 100, 1, 6}, wall63={"GOLDENMOUNTAIN_6", 100, 1, 6},
		wall1={"GOLDENMOUNTAIN_1", 100, 1, 6}, wall3={"GOLDENMOUNTAIN_3", 100, 1, 6}, wall7={"GOLDENMOUNTAIN_7", 100, 1, 6}, wall9={"GOLDENMOUNTAIN_9", 100, 1, 6},
		wall11={"GOLDENMOUNTAIN_1", 100, 1, 6}, wall33={"GOLDENMOUNTAIN_3", 100, 1, 6}, wall77={"GOLDENMOUNTAIN_7", 100, 1, 6}, wall98={"GOLDENMOUNTAIN_9", 100, 1, 6},
		inner_wall1={"GOLDENMOUNTAIN_1I", 100, 1, 6}, inner_wall3={"GOLDENMOUNTAIN_3I", 100, 1, 6}, inner_wall7={"GOLDENMOUNTAIN_7I", 100, 1, 6}, inner_wall9={"GOLDENMOUNTAIN_9I", 100, 1, 6},
		pillar={"GOLDENMOUNTAIN_SINGLE", 100, 1, 6},
		pillar4={"GOLDENMOUNTAIN_PILLAR4", 100, 1, 6}, pillar6={"GOLDENMOUNTAIN_PILLAR6", 100, 1, 6}, pillar2={"GOLDENMOUNTAIN_PILLAR2", 100, 1, 6}, pillar8={"GOLDENMOUNTAIN_PILLAR8", 100, 1, 6},
		pillar82={"GOLDENMOUNTAIN_PILLAR82", 100, 1, 6}, pillar46={"GOLDENMOUNTAIN_PILLAR46", 100, 1, 6},
	},
}

for i = 1, 6 do
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_5"..i, image="terrain/golden_mountain5_"..i..".png"}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_8"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, image="terrain/golden_mountain8.png"}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_2"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{display_y=1, image="terrain/golden_mountain2.png"}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_4"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{display_x=-1, image="terrain/golden_mountain4.png"}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_6"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{display_x=1, image="terrain/golden_mountain6.png"}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_7"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/golden_mountain7.png", add_mos = {{display_y=-1, image="terrain/golden_mountain8.png"}, {display_x=-1, image="terrain/golden_mountain4.png"}}}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_9"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/golden_mountain9.png", add_mos = {{display_y=-1, image="terrain/golden_mountain8.png"}, {display_x=1, image="terrain/golden_mountain6.png"}}}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_1"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=-1, image="terrain/golden_mountain1.png", add_mos = {{display_y=1, image="terrain/golden_mountain2.png"}, {display_x=-1, image="terrain/golden_mountain4.png"}}}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_3"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=1, image="terrain/golden_mountain3.png", add_mos = {{display_y=1, image="terrain/golden_mountain2.png"}, {display_x=1, image="terrain/golden_mountain6.png"}}}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_1I"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/golden_mountain1i.png"}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_3I"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/golden_mountain3i.png"}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_7I"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=1, image="terrain/golden_mountain7i.png"}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_9I"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{display_y=1, display_x=-1, image="terrain/golden_mountain9i.png"}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_SINGLE"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/golden_mountain7.png", add_mos = {{display_y=-1, image="terrain/golden_mountain8.png"}, {display_x=1, display_y=-1, image="terrain/golden_mountain9.png"}}}, class.new{display_y=1, display_x=-1, image="terrain/golden_mountain1.png", add_mos = {{display_y=1, image="terrain/golden_mountain2.png"}, {display_x=1, display_y=1, image="terrain/golden_mountain3.png"}, {display_x=-1, image="terrain/golden_mountain4.png"}, {display_x=1, image="terrain/golden_mountain6.png"}}}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_PILLAR4"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/golden_mountain7.png", add_mos = {{display_y=-1, image="terrain/golden_mountain8.png"}}}, class.new{display_y=1, display_x=-1, image="terrain/golden_mountain1.png", add_mos = {{display_y=1, image="terrain/golden_mountain2.png"}, {display_x=-1, image="terrain/golden_mountain4.png"}}}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_PILLAR6"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=1, image="terrain/golden_mountain9.png", add_mos = {{display_y=-1, image="terrain/golden_mountain8.png"}}}, class.new{display_y=1, display_x=1, image="terrain/golden_mountain3.png", add_mos = {{display_y=1, image="terrain/golden_mountain2.png"}, {display_x=1, image="terrain/golden_mountain6.png"}}}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_PILLAR46"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, image="terrain/golden_mountain8.png"}, class.new{display_y=1, image="terrain/golden_mountain2.png"}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_PILLAR8"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=-1, display_x=-1, image="terrain/golden_mountain7.png", add_mos = {{display_y=-1, image="terrain/golden_mountain8.png"}, {display_x=1, display_y=-1, image="terrain/golden_mountain9.png"}}}, class.new{display_x=-1, image="terrain/golden_mountain4.png", add_mos = {{display_x=1, image="terrain/golden_mountain6.png"}}}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_PILLAR2"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{z=18, display_y=1, display_x=-1, image="terrain/golden_mountain1.png", add_mos = {{display_y=1, image="terrain/golden_mountain2.png"}, {display_x=1, display_y=1, image="terrain/golden_mountain3.png"}}}, class.new{display_x=-1, image="terrain/golden_mountain4.png", add_mos = {{display_x=1, image="terrain/golden_mountain6.png"}}}}}
newEntity{base="GOLDEN_MOUNTAIN", define_as = "GOLDENMOUNTAIN_PILLAR82"..i, image="terrain/golden_mountain5_"..i..".png", add_displays = {class.new{display_x=-1, image="terrain/golden_mountain4.png", add_mos = {{display_x=1, image="terrain/golden_mountain6.png"}}}}}
end


--------------------------------------------------------------------------------
-- Sand & beaches
--------------------------------------------------------------------------------

newEntity{
	define_as = "DESERT",
	type = "floor", subtype = "sand",
	name = "desert", image = "terrain/sandfloor.png",
	display = '.', color={r=203,g=189,b=72}, back_color={r=93,g=79,b=22},
	can_encounter="desert", equilibrium_level=-10,
	nice_editer = sand_editer,
}

newEntity{
	define_as = "OASIS",
	type = "wall", subtype = "sand",
	name = "oasis", image = "terrain/palmtree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=93,g=79,b=22},
	add_displays = class:makeTrees("terrain/palmtree_alpha", 4),
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"OASIS", 100, 1, 30} },
	nice_editer = sand_editer,
}
for i = 1, 30 do
newEntity{ base="OASIS",
	define_as = "OASIS"..i,
	image = "terrain/sandfloor.png",
	add_displays = class:makeTrees("terrain/palmtree_alpha", 4),
	nice_tiler = false,
}
end

--------------------------------------------------------------------------------
-- Towns
--------------------------------------------------------------------------------
newEntity{ base="PLAINS", define_as = "TOWN", change_level=1, display='*', color={r=255, g=255, b=255}, back_color=colors.DARK_GREEN }

newEntity{ base="TOWN", define_as = "TOWN_DERTH",
	name = "Derth (Town)", add_mos = {{image="terrain/town1.png"}},
	desc = "A quiet town at the crossroads of the north",
	change_zone="town-derth",
}
newEntity{ base="TOWN", define_as = "TOWN_LAST_HOPE",
	name = "Last Hope (Town)", add_mos = {{image="terrain/town1.png"}},
	desc = "Capital city of the Allied Kingdoms ruled by King Tolak",
	change_zone="town-last-hope",
}
newEntity{ base="TOWN", define_as = "TOWN_ANGOLWEN",
	name = "Angolwen, the hidden city of magic", add_mos = {{image="terrain/town1.png"}},
	desc = "Secret place of magic, set apart from the world to protect it.\nLead by the Supreme Archmage Linaniil.",
	change_zone="town-angolwen",
}
newEntity{ base="TOWN", define_as = "TOWN_SHATUR",
	name = "Shatur (Town)", add_mos = {{image="terrain/town1.png"}},
	desc = "Capital city of Thaloren lands, ruled by Nessilla Tantaelen",
	change_zone="town-shatur",
}
newEntity{ base="TOWN", define_as = "TOWN_ELVALA",
	name = "Elvala (Town)", add_mos = {{image="terrain/town1.png"}},
	desc = "Capital city of Shaloren lands, ruled by Aranion Gayaeil",
	change_zone="town-elvala",
}
newEntity{ base="TOWN", define_as = "TOWN_GATES_OF_MORNING",
	name = "Gates of Morning (Town)", add_mos = {{image="terrain/town1.png"}},
	desc = "A massive hole in the Sunwall.",
	change_zone="town-gates-of-morning",
}
newEntity{ base="TOWN", define_as = "TOWN_IRKKK",
	name = "Irkkk (Town)", add_mos = {{image="terrain/town1.png"}},
	desc = "Yeek Wayist capital",
	change_zone="town-irrk",
}
newEntity{ base="TOWN", define_as = "TOWN_ZIGUR",
	name = "Zigur (Town)", add_mos = {{image="terrain/town1.png"}},
	desc = "Ziguranth main training ground",
	change_zone="town-zigur",
}
newEntity{ base="TOWN", define_as = "TOWN_IRON_COUNCIL",
	name = "Iron Council (Town)", add_mos = {{image="terrain/town1.png"}},
	desc = "Heart of the dwarven Empire",
	change_zone="town-iron-council",
}
