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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/sand.lua")

newEntity{ base = "FLOOR", define_as = "ROAD",
	name="cobblestone road",
	display='.', image="terrain/stone_road1.png"
}

newEntity{
	define_as = "WEST_PORTAL",
	name = "Farportal: Last Hope",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/marble_floor.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They usually require an external item to use. You have no idea if it is even two-way.
This one seems to go near the town of Last Hope in Maj'Eyal.]],

	orb_portal = {
		change_level = 1,
		change_zone = "wilderness",
		change_wilderness = {
			spot = {type="farportal-end", subtype="last-hope"},
		},
		message = "#VIOLET#You enter the swirling portal and in the blink of an eye you set foot on the outskirts of Last Hope, with no trace of the portal...",
		on_use = function(self, who)
		end,
	},
}
newEntity{ base = "WEST_PORTAL", define_as = "CWEST_PORTAL",
	image = "terrain/marble_floor.png",
	add_displays = {class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3}},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(y, y, 3, "farportal_lightning")
	end,
}

newEntity{
	define_as = "GOLDEN_MOUNTAIN",
	name = "sunwall mountain", image = "terrain/golden_mountain5_1.png",
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
