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
	define_as = "LAVA_FLOOR",
	name = "lava floor", image = "terrain/lava_floor.png",
	display = '.', color=colors.RED, back_color=colors.DARK_GREY,
	shader = "lava",
}

newEntity{
	define_as = "LAVA_WALL",
	name = "lava wall", image = "terrain/granite_wall1.png",
	display = '#', color=colors.RED, back_color=colors.DARK_GREY, tint=colors.LIGHT_RED,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
	dig = "LAVA_FLOOR",
}

newEntity{
	define_as = "LAVA",
	name = "molten lava", image = "terrain/lava.png",
	display = '%', color=colors.LIGHT_RED, back_color=colors.RED,
	does_block_move = true,
	shader = "lava",
}

newEntity{
	define_as = "PORTAL_BACK",
	name = "Demonic Portal", image = "terrain/lava_floor.png", add_displays = {class.new{image="terrain/demon_portal.png"}},
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[This portal seems to be connected with Maj'Eyal, you could probably use it to go back.]],

	on_move = function(self, x, y, who)
		if who == game.player then
			require("engine.ui.Dialog"):yesnoPopup("Back and there again", "Enter the portal back to Maj'Eyal? (Warning loot Draebor first)", function(ret)
				if not ret then
					local level = game.memory_levels["wilderness-1"]
					local spot = level:pickSpot{type="farportal-end", subtype="demon-plane-arrival"}
					who.wild_x, who.wild_y = spot.x, spot.y
					game:changeLevel(1, "wilderness")
					game.logPlayer(who, "#VIOLET#You enter the swirling portal and in the blink of an eye you are back to Maj'Eyal, near the Daikara.")
				end
			end, "Stay", "Enter")
		end
	end,
}
