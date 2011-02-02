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

load("/data/general/grids/basic.lua")
load("/data/general/grids/sand.lua")
newEntity{
	define_as = "WALL_SEE",
	name = "wall", image = "terrain/granite_wall1.png",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	nice_tiler = { method="wall3d", inner={"WALL_SEE", 100, 1, 5}, north={"WALL_SEE_NORTH", 100, 1, 5}, south={"WALL_SEE_SOUTH", 10, 1, 17}, north_south="WALL_SEE_NORTH_SOUTH", small_pillar="WALL_SEE_SMALL_PILLAR", pillar_2="WALL_SEE_PILLAR_2", pillar_8={"WALL_SEE_PILLAR_8", 100, 1, 5}, pillar_4="WALL_SEE_PILLAR_4", pillar_6="WALL_SEE_PILLAR_6" },
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = false,
	air_level = -20,
	dig = "WALL_SEE",
}
for i = 1, 5 do
	newEntity{ base = "WALL_SEE", define_as = "WALL_SEE"..i, image = "terrain/granite_wall1_"..i..".png"}
	newEntity{ base = "WALL_SEE", define_as = "WALL_SEE_NORTH"..i, image = "terrain/granite_wall1_"..i..".png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
	newEntity{ base = "WALL_SEE", define_as = "WALL_SEE_PILLAR_8"..i, image = "terrain/granite_wall1_"..i..".png", add_displays = {class.new{image="terrain/granite_wall_pillar_8.png", z=18, display_y=-1}}}
end
newEntity{ base = "WALL_SEE", define_as = "WALL_SEE_NORTH_SOUTH", image = "terrain/granite_wall2.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
newEntity{ base = "WALL_SEE", define_as = "WALL_SEE_SOUTH", image = "terrain/granite_wall2.png"}
for i = 1, 17 do newEntity{ base = "WALL_SEE", define_as = "WALL_SEE_SOUTH"..i, image = "terrain/granite_wall2_"..i..".png"} end
newEntity{ base = "WALL_SEE", define_as = "WALL_SEE_SMALL_PILLAR", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_small.png"}, class.new{image="terrain/granite_wall_pillar_small_top.png", z=18, display_y=-1}}}
newEntity{ base = "WALL_SEE", define_as = "WALL_SEE_PILLAR_6", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_3.png"}, class.new{image="terrain/granite_wall_pillar_9.png", z=18, display_y=-1}}}
newEntity{ base = "WALL_SEE", define_as = "WALL_SEE_PILLAR_4", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_1.png"}, class.new{image="terrain/granite_wall_pillar_7.png", z=18, display_y=-1}}}
newEntity{ base = "WALL_SEE", define_as = "WALL_SEE_PILLAR_2", image = "terrain/sandfloor.png", add_displays = {class.new{image="terrain/granite_wall_pillar_2.png"}}}

newEntity{
	define_as = "LOCK",
	name = "closed gate", image = "terrain/sealed_door.png",
	display = '+', color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
	air_level = -40,
	on_stand = function(self, x, y, who)
		local DT = engine.DamageType
		local dam = DT:get(DT.PHYSICAL).projector(self, x, y, DT.PHYSICAL, 200)
	end,
}
