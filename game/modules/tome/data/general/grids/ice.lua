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

local ice_editer = {method="borders_def", def="ice"}

newEntity{
	define_as = "ICY_FLOOR",
	type = "floor", subtype = "ice",
	name = "icy floor", image = "terrain/frozen_ground.png",
	display = '.', color=colors.LIGHT_BLUE, back_color=colors.WHITE,
	nice_editer = ice_editer,
	on_stand = function(self, x, y, who)
		who:setEffect(who.EFF_ICY_FLOOR, 1, {})
	end,
}
newEntity{
	define_as = "FROZEN_WATER",
	type = "floor", subtype = "ice",
	name = "frozen water", image = "terrain/water_grass_5_1.png",
	display = ';', color=colors.LIGHT_BLUE, back_color=colors.WHITE,
	nice_editer = ice_editer,
	nice_tiler = { method="replace", base={"FROZEN_WATER", 100, 1, 4}},
	special_minimap = colors.BLUE,
}
for i = 1, 4 do newEntity{ base="FROZEN_WATER", define_as = "FROZEN_WATER"..i, add_mos = {{image = "terrain/ice/frozen_ground_5_0"..i..".png"}}} end
