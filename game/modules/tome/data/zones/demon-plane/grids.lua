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
load("/data/general/grids/lava.lua", function(e) if e.define_as == "LAVA_FLOOR" then e.on_stand = nil end end)

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
					game:onLevelLoad("wilderness-1", function(zone, level)
						local spot = level:pickSpot{type="farportal-end", subtype="demon-plane-arrival"}
						who.wild_x, who.wild_y = spot.x, spot.y
					end)
					game:changeLevel(1, "wilderness")
					game.logPlayer(who, "#VIOLET#You enter the swirling portal and in the blink of an eye you are back to Maj'Eyal, near the Daikara.")
				end
			end, "Stay", "Enter")
		end
	end,
}
