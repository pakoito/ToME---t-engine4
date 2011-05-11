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
load("/data/general/grids/sand.lua")
load("/data/general/grids/water.lua")

newEntity{
	define_as = "LEVER_DOOR",
	type = "wall", subtype = "floor",
	name = "sealed door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="LEVER_DOOR_VERT", west_east="LEVER_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	levers = 0,
	force_clone = true,
	door_player_stop = "This door seems to have been sealed off, you need to find a way to open it.",
	door_opened = "DOOR_OPEN",
}
newEntity{ base = "LEVER_DOOR", define_as = "LEVER_DOOR_HORIZ", image = "terrain/granite_door1.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, door_opened = "DOOR_HORIZ_OPEN"}
newEntity{ base = "LEVER_DOOR", define_as = "LEVER_DOOR_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_vert.png", z=17}, class.new{image="terrain/granite_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "DOOR_OPEN_VERT"}

newEntity{
	define_as = "LEVER",
	type = "lever", subtype = "floor",
	name = "huge lever",
	display = '&', color=colors.UMBER, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	lever = true,
	force_clone = true,
	block_move = function(self, x, y, e, act)
		if act and e.player and self.lever then
			self.lever = false
			local spot = game.level:pickSpot{type="lever", subtype="door"}
			if not spot then return true end
			local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN)
			g.levers = (g.levers or 0) + 1
			if g.levers >= 2 then
				game.level.map(spot.x, spot.y, engine.Map.TERRAIN, game.zone.grid_list[g.door_opened])
				game.log("#VIOLET#You hear a door openning.")
			else
				game.log("#VIOLET#You hear a mechanism clicking.")
			end
		end
		return true
	end,
}
