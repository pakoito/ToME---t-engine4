-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_DIGGER",
	slot = "TOOL",
	type = "tool", subtype="digger",
	display = "\\", color=colors.LIGHT_BLUE, image = resolvers.image_material("pickaxe", "metal"),
	encumber = 3,
	rarity = 14,
	desc = [[Allows you to dig a wall, remove a tree, create ways.]],
	add_name = " (#DIGSPEED#)",

	carrier = {
		learn_talent = { [Talents.T_DIG_OBJECT] = 1, },
	},

	egos = "/data/general/objects/egos/digger.lua", egos_chance = resolvers.mbonus(10, 5),
}

newEntity{ base = "BASE_DIGGER",
	name = "iron pickaxe", short_name = "iron",
	level_range = {1, 20},
	cost = 3,
	material_level = 1,
	digspeed = resolvers.rngavg(35,40),
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 1, },
	},
}

newEntity{ base = "BASE_DIGGER",
	name = "dwarven-steel pickaxe", short_name = "d.steel",
	level_range = {20, 40},
	cost = 3,
	material_level = 3,
	digspeed = resolvers.rngavg(27,33),
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 2, },
	},
}

newEntity{ base = "BASE_DIGGER",
	name = "voratun pickaxe", short_name = "voratun",
	level_range = {40, 50},
	cost = 3,
	material_level = 5,
	digspeed = resolvers.rngavg(20,25),
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 3, },
	},
}
