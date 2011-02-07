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

newEntity{
	define_as = "POST",
	name = "Zigur Postsign", lore="zigur-post",
	desc = [[The laws of the Ziguratnh]],
	image = "terrain/grass.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	on_move = function(self, x, y, who)
		if who.player then who:learnLore(self.lore) end
	end,
}
