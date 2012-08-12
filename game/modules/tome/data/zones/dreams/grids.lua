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
	define_as = "DREAM_END",
	type = "floor", subtype = "grass",
	name = "Dream Portal", image = "terrain/jungle/jungle_grass_floor_01.png", add_mos = {{image="terrain/demon_portal.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	on_move = function(self, x, y, who)
		if who and who.summoner then
			who.success = true
			who:die(who)
		end
	end,
}
