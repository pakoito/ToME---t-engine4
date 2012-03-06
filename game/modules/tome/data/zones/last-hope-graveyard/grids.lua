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

local grass_editer = { method="borders_def", def="grass"}

newEntity{
	define_as = "SWAMPTREE",
	type = "wall", subtype = "grass",
	name = "tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS",
	nice_tiler = { method="replace", base={"SWAMPTREE", 100, 1, 20}},
	nice_editer = grass_editer,
}
for i = 1, 20 do newEntity{ base="SWAMPTREE", define_as = "SWAMPTREE"..i, image = "terrain/grass.png", add_displays = class:makeTrees("terrain/swamptree", 3, 3)} end

newEntity{ base = "FLOOR", define_as = "ROAD",
	type = "floor", subtype = "road",
	name="cobblestone road",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}

newEntity{ base = "FLOOR", define_as = "GRAVE",
	type = "wall", subtype = "grass",
	name="grave",
	display='&', image="terrain/grass.png",
	does_block_move = true,
	pass_projectile = true,
	nice_editer = grass_editer,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return true end
		if self.lore then who:learnLore(self.lore) end
		return true
	end,
}
for i = 1, 44 do newEntity{ base = "GRAVE", define_as = "GRAVE"..i, lore="last-hope-graveyard-"..i, add_displays={class.new{z=18,image="terrain/grave_unopened_0"..rng.range(1,3).."_64.png", display_y=-1, display_h=2}},} end

newEntity{ base = "FLOOR", define_as = "COFFIN",
	name="coffin",
	display='&', image="terrain/marble_floor.png", add_mos={{image="terrain/coffin_unopened_01_64.png", display_h=2, display_y=-1}},
	does_block_move = true,
	pass_projectile = true,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return true end
		game.zone.open_coffin(x, y, who)
		return true
	end,
}

newEntity{ base = "FLOOR", define_as = "COFFIN_OPEN",
	name="open coffin",
	display='/', image="terrain/marble_floor.png", add_mos={{image="terrain/coffin_opened_01_64.png", display_h=2, display_y=-1}},
	does_block_move = true,
	pass_projectile = true,
}

newEntity{ define_as = "MAUSOLEUM",
	name = "open mausoleum",
	image = "terrain/stone_road1.png", add_displays = {class.new{z=5, image="terrain/dungeon_entrance01.png"}},
	type = "floor", subtype = "floor",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "ALTAR",
	name = "ritualistic symbol",
	image = "terrain/marble_floor.png", add_mos = {{image="terrain/floor_pentagram.png"}},
	display = ';', color=colors.RED, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
}
