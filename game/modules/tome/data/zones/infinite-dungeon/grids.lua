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
load("/data/general/grids/water.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/sand.lua")

for id, i in ipairs{1, 10, 20, 30, 40} do
newEntity{
	define_as = "ID_HISTORY"..i,
	name = "The Hunter and the Hunted", lore="infinite-dungeon-history-"..id,
	desc = [[The infinite hunt.]],
	image = "terrain/marble_floor.png",
	display = '_', color=colors.GREEN, back_color=colors.DARK_GREY,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	on_move = function(self, x, y, who)
		if who.player then who:learnLore(self.lore) end
	end,
}
end
