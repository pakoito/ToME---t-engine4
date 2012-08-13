-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

load("/data/general/grids/basic.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/jungle.lua")
load("/data/general/grids/water.lua")

newEntity{
	define_as = "DREAM_END",
	type = "floor", subtype = "grass",
	name = "Dream Portal", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/demon_portal.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	on_move = function(self, x, y, who)
		if who and who.summoner then
			who.success = true
			who:die(who)
		end
	end,
}

newEntity{
	define_as = "DREAM2_END",
	type = "floor", subtype = "grass",
	name = "Dream Portal", image = "invis.png", add_mos = {{image="terrain/demon_portal.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	on_move = function(self, x, y, who)
		if who and who.summoner then
			who.success = true
			who:die(who)
		end
	end,
}

newEntity{
	define_as = "DREAM_MOUSE_HOLE",
	type = "wall", subtype = "grass",
	name = "mouse hole",
	desc = "A hole small enough that only you can go through.",
	color_r=0, color_g=0, color_b=0, notice = true,
	image = "terrain/jungle/jungle_grass_floor_01.png",
	add_displays = class:makeTrees("terrain/jungle/jungle_tree_", 17, 7),
	block_move = function(self, x, y, who, act)
		if not act or not who or not who.size_category or who.size_category > 1 then return true end
		return false
	end,
	on_move = function(self, x, y, who)
		if not who or not who.size_category or who.size_category > 1 then return end
		if who.mouse_turn >= game.turn then return end
		who.mouse_turn = game.turn
		who:move(self.mouse_hole.x, self.mouse_hole.y, true)
		if config.settings.tome.smooth_move > 0 then who:resetMoveAnim() who:setMoveAnim(x, y, 8, 5) end
	end,
}

newEntity{
	define_as = "DREAM_STONE",
	type = "floor", subtype = "grass",
	name = "Dreamstone", image = "invis.png", add_displays = {class.new{z=15, display_h=2, display_y=-1, image="terrain/darkgreen_moonstone_06.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	block_move = function(self, x, y, who, act)
		if who and who.summoner and act then
			local g = game.zone.grid_list.BAMBOO_HUT_FLOOR:clone()
			game.zone:addEntity(game.level, g, "terrain", x, y)
			who:heal(100)
			who:removeEffectsFilter{status="detrimental"}
			game.logPlayer(who, "You touch the dreamstone and it disappears. You feel better.")
		end
		return true
	end,
}


-----------------------------------------
-- Basic floors
-----------------------------------------
newEntity{
	define_as = "BAMBOO_HUT_FLOOR",
	type = "floor", subtype = "bamboo hut",
	name = "weird floor", image = "invis.png",
	display = ' ', color=colors.UMBER, back_color=colors.DARK_UMBER,
	grow = "BAMBOO_HUT_WALL",
}

-----------------------------------------
-- Walls
-----------------------------------------
newEntity{
	define_as = "BAMBOO_HUT_WALL",
	type = "wall", subtype = "bamboo hut",
	name = "bamboo wall", image = "invis.png",
	display = '#', color=colors.LIGHT_UMBER, back_color=colors.DARK_UMBER,
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -5,
	dig = "BAMBOO_HUT_FLOOR",
	nice_tiler = { method="singleWall", type="wall",
		v_full={"BHW_V_FULL", 100, 1, 1},
		h_full={"BHW_H_FULL", 20, 1, 8},
		n_cross={"BHW_N_CROSS", 100, 1, 1},
		s_cross={"BHW_S_CROSS", 100, 1, 1},
		e_cross={"BHW_E_CROSS", 100, 1, 1},
		w_cross={"BHW_W_CROSS", 100, 1, 1},
		cross={"BHW_CROSS", 100, 1, 1},
		ne={"BHW_NE", 100, 1, 1},
		nw={"BHW_NW", 100, 1, 1},
		se={"BHW_SE", 100, 1, 1},
		sw={"BHW_SW", 100, 1, 1},
	},
}

newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_V_FULL1", add_displays={class.new{z=16, image="terrain/bamboo/hut_wall_full_hor_01.png"}}}

newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_H_FULL", add_displays={class.new{z=16, image="terrain/bamboo/hut_wall_bottom_hor_01.png"}, class.new{image="terrain/bamboo/hut_wall_top_hor_01.png", display_y=-1, z=17}}}
local decors = {"wall_decor_skin_b_01","wall_decor_skin_a_01","wall_decor_spears_01","wall_decor_sticks_01","wall_decor_mask_c_01","wall_decor_mask_b_01","wall_decor_mask_a_01","wall_decor_3_masks_01"}
for i = 1, 8 do
	newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_H_FULL"..i, add_displays={class.new{z=16, image="terrain/bamboo/hut_wall_bottom_hor_01.png", add_mos={{image="terrain/bamboo/"..decors[i]..".png"}}}, class.new{image="terrain/bamboo/hut_wall_top_hor_01.png", display_y=-1, z=17}}}
end

newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_N_CROSS1", add_displays={class.new{z=16, image="terrain/bamboo/hut_wall_bottom_hor_01.png"}, class.new{z=17, image="terrain/bamboo/hut_corner_vert_south_4_1_2_top_01.png", display_y=-1, add_mos={{image="terrain/bamboo/hut_wall_top_hor_01.png", display_y=-1}}}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_S_CROSS1", add_displays={class.new{z=16, image="terrain/bamboo/hut_wall_bottom_hor_01.png"}, class.new{z=17, image="terrain/bamboo/hut_wall_full_hor_01.png", add_mos={{image="terrain/bamboo/hut_wall_top_hor_01.png", display_y=-1},{image="terrain/bamboo/hut_corner_vert_4_7_8_top_01.png", display_y=-1}}}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_E_CROSS1", add_displays={class.new{z=17, image="terrain/bamboo/hut_wall_full_hor_01.png"}, class.new{image="terrain/bamboo/wall_hor_divider_left_bottom_01.png", z=16, add_mos={{image="terrain/bamboo/wall_hor_divider_left_top_01.png", display_y=-1}}}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_W_CROSS1", add_displays={class.new{z=17, image="terrain/bamboo/hut_wall_full_hor_01.png"}, class.new{image="terrain/bamboo/wall_hor_divider_right_bottom_01.png", z=16, add_mos={{image="terrain/bamboo/wall_hor_divider_right_top_01.png", display_y=-1}}}}}

newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_CROSS1", add_displays={class.new{z=17, image="terrain/bamboo/hut_wall_bottom_hor_01.png"}, class.new{image="terrain/bamboo/hut_wall_top_hor_01.png", z=16, display_y=-1, add_mos={{image="terrain/bamboo/hut_wall_full_hor_01.png"},{image="terrain/bamboo/hut_corner_vert_4_7_8_top_01.png", display_y=-1}}}}}

newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_NE1", add_displays={class.new{z=17, image="terrain/bamboo/hut_corner_4_1_2_bottom_01.png"}, class.new{image="terrain/bamboo/hut_corner_4_1_2_top_01.png", display_y=-1, z=16}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_NW1", add_displays={class.new{z=17, image="terrain/bamboo/hut_corner_6_3_2_bottom_01.png"}, class.new{image="terrain/bamboo/hut_corner_6_3_2_top_01.png", display_y=-1, z=16}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_SE1", add_displays={class.new{z=17, image="terrain/bamboo/hut_corner_4_7_8_bottom_01.png"}, class.new{image="terrain/bamboo/hut_corner_4_7_8_top_01.png", display_y=-1, z=16}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_SW1", add_displays={class.new{z=17, image="terrain/bamboo/hut_corner_8_9_6_bottom_01.png"}, class.new{image="terrain/bamboo/hut_corner_8_9_6_top_01.png", display_y=-1, z=16}}}

-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "BAMBOO_HUT_DOOR",
	type = "wall", subtype = "floor",
	name = "door", image = "invis.png",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="BAMBOO_HUT_DOOR_VERT", west_east="BAMBOO_HUT_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "BAMBOO_HUT_DOOR_OPEN",
	dig = "FLOOR",
}
newEntity{
	define_as = "BAMBOO_HUT_DOOR_OPEN",
	type = "wall", subtype = "floor",
	name = "open door", image = "invis.png",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.DARK_UMBER,
	always_remember = true,
	is_door = true,
	door_closed = "BAMBOO_HUT_DOOR",
}
newEntity{ base = "BAMBOO_HUT_DOOR", define_as = "BAMBOO_HUT_DOOR_HORIZ", add_displays = {class.new{image="terrain/bamboo/hut_wall_door_closed_hor_01.png", z=17}, class.new{image="terrain/bamboo/hut_wall_top_hor_01.png", z=18, display_y=-1}}, door_opened = "BAMBOO_HUT_DOOR_HORIZ_OPEN"}
newEntity{ base = "BAMBOO_HUT_DOOR_OPEN", define_as = "BAMBOO_HUT_DOOR_HORIZ_OPEN", add_displays = {class.new{image="terrain/bamboo/hut_door_hor_open_door_palm_leaves_01.png"}, class.new{image="terrain/bamboo/hut_door_hor_open_door_01.png", z=17}, class.new{image="terrain/bamboo/hut_wall_top_hor_01.png", z=18, display_y=-1}}, door_closed = "BAMBOO_HUT_DOOR_HORIZ"}
newEntity{ base = "BAMBOO_HUT_DOOR", define_as = "BAMBOO_HUT_DOOR_VERT", add_displays = {class.new{image="terrain/bamboo/palm_door_closed_ver_01.png"}, class.new{image="terrain/bamboo/hut_wall_full_hor_01.png", z=18}}, door_opened = "BAMBOO_HUT_DOOR_OPEN_VERT", dig = "BAMBOO_HUT_DOOR_OPEN_VERT"}
newEntity{ base = "BAMBOO_HUT_DOOR_OPEN", define_as = "BAMBOO_HUT_DOOR_OPEN_VERT", add_displays = {class.new{image="terrain/bamboo/palm_door_open_bottom_ver_01.png"}, class.new{image="terrain/bamboo/palm_door_open_top_ver_01.png", z=18, display_y=-1, add_mos={{image="terrain/bamboo/hut_wall_full_hor_01.png"}, {image="terrain/bamboo/palm_door_open_bottom_ver_door_01.png"}}}}, door_closed = "BAMBOO_HUT_DOOR_VERT"}
