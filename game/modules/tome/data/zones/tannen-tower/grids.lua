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
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/mountain.lua")

newEntity{
	define_as = "PORTAL_BACK",
	name = "Portal to Last Hope",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/marble_floor.png", add_mos = {{image="terrain/demon_portal.png"}},
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[This portal seems to be connected with Last Hope, you could probably use it to go back.]],

	on_move = function(self, x, y, who)
		if who == game.player then
			require("engine.ui.Dialog"):yesnoPopup("Back and there again", "Enter the portal back to Last Hope?", function(ret)
				if not ret then
					game.player:hasQuest("east-portal"):back_to_last_hope()
				end
			end, "Stay", "Enter")
		end
	end,
}

-- Reversed!
newEntity{ base = "UP",
	define_as = "TUP",
	change_level = 1,
}
newEntity{ base = "DOWN",
	define_as = "TDOWN",
	change_level = -1,
}
