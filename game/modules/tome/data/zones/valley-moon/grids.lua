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
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/mountain.lua")

newEntity{
	define_as = "MOONSTONE",
	name = "moonstone",
	image = "terrain/moonstone.png",
	display = '&', color=colors.GREY, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
}

newEntity{
	define_as = "PORTAL_DEMON",
	name = "Infernal Portal",
	display = '&', color=colors.RED, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[An invocation portal, perpetualy summoning beings through it.]],
}
