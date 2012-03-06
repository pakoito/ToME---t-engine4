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
load("/data/general/grids/sand.lua")
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

newEntity{ define_as = "LAVA",
	name='lava pit',
	display='~', color=colors.LIGHT_RED, back_color=colors.RED,
	always_remember = true, does_block_move = true,
	image="terrain/lava_floor.png",
}

newEntity{ base = "GRASS", define_as = "FIELDS",
	name="cultivated fields",
	display=';', image="terrain/cultivation.png",
	nice_tiler = { method="replace", base={"FIELDS", 100, 1, 4}},
}
for i = 1, 4 do newEntity{ base = "FIELDS", define_as = "FIELDS"..i, image="terrain/grass.png", add_mos={{image="terrain/cultivation0"..i..".png"}} } end

newEntity{ base = "FLOOR", define_as = "COBBLESTONE",
	name="cobblestone road",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}

newEntity{ base = "HARDWALL", define_as = "ROCK",
	name="giant rock",
	image="terrain/oldstone_floor.png", z=1, add_displays = {class.new{z=2, image="terrain/huge_rock.png"}},
	nice_tiler = false,
}

newEntity{
	define_as = "CLOSED_GATE",
	name = "closed gate", image = "terrain/sealed_door.png",
	display = '+', color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
}

newEntity{
	define_as = "OPEN_GATE",
	type = "wall", subtype = "floor",
	name = "open gate", image = "terrain/sealed_door_cracked.png",
	display = "'", color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
}

