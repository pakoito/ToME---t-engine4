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
load("/data/general/grids/fortress.lua")
load("/data/general/grids/void.lua")

newEntity{
	define_as = "COMMAND_ORB",
	name = "Sher'Tul Control Orb", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/shertul_control_orb_blue.png"}},
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		return true
	end,
}

newEntity{
	define_as = "FARPORTAL",
	name = "Exploratory Farportal",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/solidwall/solid_floor1.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They are left over of the powerful Sher'tul race.
This farportal is not connected to any other portal, it is made for exploration, you can not know where it will send you.
It should automatically create a portal back, but it might not be near your arrival zone.]],

	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return true end
		local Dialog = require "engine.ui.Dialog"
		Dialog:simplePopup("Farportal", "The farportal seems to be inactive")
		return true
	end,
}

newEntity{ base = "FARPORTAL", define_as = "CFARPORTAL",
	image = "terrain/solidwall/solid_floor1.png",
	add_displays = {
		class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3},
	},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
	end,
}
