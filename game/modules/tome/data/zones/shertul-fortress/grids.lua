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

newEntity{
	define_as = "LAKE_NUR",
	name = "stair back to the lake of Nur",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 3, change_zone = "lake-nur", force_down = true,
}

newEntity{
	define_as = "SEALED_DOOR",
	name = "sealed door", image = "terrain/stone_wall_door.png",
	display = '+', color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
}

newEntity{ base = "BIGWALL",
	define_as = "HARD_BIGWALL",
	block_sense = true,
	block_esp = true,
	dig = false,
}

newEntity{
	define_as = "TELEPORT_OUT",
	name = "teleportation circle to the surface", image = "terrain/maze_teleport.png",
	display = '>', color_r=255, color_g=0, color_b=255,
	notice = true, show_tooltip = true,
	change_level = 1, change_zone = "wilderness",
}

newEntity{
	define_as = "COMMAND_ORB",
	name = "Sher'Tul Control Orb", image = "terrain/maze_floor.png", add_displays = {class.new{image="terrain/worldmap.png"}},
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local chat = require("engine.Chat").new("shertul-fortress-command-orb", self, e)
			chat:invoke()
		end
		return true
	end,
}

newEntity{ base = "HARD_BIGWALL",
	define_as = "GREEN_DRAPPING",
	add_displays = {class.new{image="terrain/green_drapping.png"}},
}
newEntity{ base = "HARD_BIGWALL",
	define_as = "PURPLE_DRAPPING",
	add_displays = {class.new{image="terrain/purple_drapping.png"}},
}
