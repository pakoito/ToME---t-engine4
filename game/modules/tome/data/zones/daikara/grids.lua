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

newEntity{
	define_as = "RIFT",
	name = "Temporal Rift", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/temporal_instability_yellow.png"}},
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[The rift leads somewhere ..]],
	change_level = 1, change_zone = "temporal-rift",
	change_level_check = function() -- Forbid going back
		if not game.player:hasQuest("temporal-rift") then
			require("engine.ui.Dialog"):yesnoPopup("Temporal Rift", "Are you sure you want to enter? There's no telling where you will end up or if you will be able to make it back.", function(ret)
				if ret then game:changeLevel(1, "temporal-rift") end
			end)
			return true
		end
		game.log("The rift is too unstable to cross it.")
		return true
	end
}
