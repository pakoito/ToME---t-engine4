-- ToME - Tales of Middle-Earth
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

newEntity{
	define_as = "BASE_WAND",
	type = "wand", subtype="wand",
	unided_name = "wand", id_by_type = true,
	display = "-", color=colors.WHITE,
	encumber = 2,
	rarity = 18,
	use_sound = "talents/spell_generic",
	elec_destroy = {{20,1}, {30,2}, {60,5}, {90,10}, {170,20}},
	desc = [[Magical wands are made by powerful alchemists and archmages to store spells. Anybody can use them to release the spells.]],
	egos = "/data/general/objects/egos/wands.lua", egos_chance = { prefix=resolvers.mbonus(20, 5), suffix=100 },
}

newEntity{ base = "BASE_WAND",
	name = "elm wand",
	color = colors.UMBER,
	level_range = {1, 10},
	cost = 10,
	material_level = 1,
	resolvers.charges(10, 30),
}

newEntity{ base = "BASE_WAND",
	name = "ash wand",
	color = colors.UMBER,
	level_range = {10, 20},
	cost = 20,
	material_level = 2,
	resolvers.charges(25, 45),
}

newEntity{ base = "BASE_WAND",
	name = "yew wand",
	color = colors.UMBER,
	level_range = {20, 30},
	cost = 30,
	material_level = 3,
	resolvers.charges(40, 60),
}

newEntity{ base = "BASE_WAND",
	name = "elven-wood wand",
	color = colors.UMBER,
	level_range = {30, 40},
	cost = 40,
	material_level = 4,
	resolvers.charges(55, 75),
}

newEntity{ base = "BASE_WAND",
	name = "dragonbone wand",
	color = colors.UMBER,
	level_range = {40, 50},
	cost = 50,
	material_level = 5,
	resolvers.charges(70, 90),
}
