-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	define_as = "QUICK_EXIT",
	name = "teleporting circle to the surface", image = "terrain/maze_floor.png", add_displays = {class.new{image="terrain/maze_teleport.png"}},
	display = '>', color_r=255, color_g=0, color_b=255,
	notice = true, show_tooltip = true,
	change_level = 1, change_zone = "wilderness",
}

local cracks_editer = {method="borders_def", def="blackcracks"}

newEntity{
	define_as = "CRACKS",
	type = "wall", subtype = "cracks",
	name = "huge crack in the floor", image = "terrain/cracks/ground_9_01.png",
	display = '.', color=colors.BLACK, back_color=colors.BLACK,
	nice_editer = cracks_editer,
	pass_projectile = true,
	block_move = function(self, x, y, who, act)
		if not who or not act or not who.player then return true end
		require("engine.ui.Dialog"):yesnoLongPopup("Crack in the floor", "This area appears to have been hit by a huge tremor, breaking the floor in a huge crack.\nYou think you can jump to the level below.", 400, function(ret) if ret then
			game:changeLevel(game.level.level + 1)
		end end, "Jump", "Stay")
		return true
	end,
}
