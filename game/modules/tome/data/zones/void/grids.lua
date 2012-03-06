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
load("/data/general/grids/mountain.lua")
load("/data/general/grids/sand.lua")
load("/data/general/grids/void.lua")

-- Override exits
newEntity { base = "GRASS", define_as = "GRASS_UP_WILDERNESS" }
newEntity { base = "DEEP_OCEAN_WATER", define_as = "WATER_DOWN" }
newEntity { base = "GRASS", define_as = "OLD_FOREST" }

newEntity{
	define_as = "RIFT",
	name = "Temporal Rift", image="terrain/demon_portal2.png",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[The rift leads somewhere ..]],
	change_level = 1,
	change_level_check = function()
		if game.level.level > 1 then return end
		local p = game.party:findMember{main=true}
		local Chat = require "engine.Chat"
		local chat = Chat.new("temporal-rift-start", {name="Temporal Warden"}, p)
		chat:invoke()
		return true
	end,
}
