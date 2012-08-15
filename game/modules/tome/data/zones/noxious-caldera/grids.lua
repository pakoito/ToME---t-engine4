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
	define_as = "ALTAR",
	type = "wall", subtype = "grass",
	name = "altar of dreams", image = "terrain/jungle/jungle_grass_floor_01.png", add_displays = {class.new{z=18, image="terrain/pedestal_orb_04.png", display_h=2, display_y=-1}},
	display = '&', color_r=0, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_move = function(self, x, y, who, act)
		if who == game.player and act then
			require("engine.ui.Dialog"):yesnoLongPopup("Altar of Dreams", "Looking into the altar will let you experience a dream. But should you die in it your real body might die too. Do you wish to look?", 400, function(ret)
				if ret then
					game.level.data.run_dream(true)
				end
			end)
		end
		return true
	end,
}
