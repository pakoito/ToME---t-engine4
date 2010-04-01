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

local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_HEAVY_BOOTS",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.SLATE,
	require = { talent = { Talents.T_HEAVY_ARMOUR_TRAINING }, },
	encumber = 3,
	rarity = 7,
	desc = [[Heavy boots, with metal strips at the toes, heels and other vulnerable parts, to better protect the wearer's feet from harm.]],
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	name = "pair of iron boots",
	level_range = {1, 20},
	cost = 5,
	wielder = {
		combat_armor = 3,
		fatigue = 2,
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	name = "pair of dwarven-steel boots",
	level_range = {20, 40},
	cost = 7,
	wielder = {
		combat_armor = 4,
		fatigue = 3,
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	name = "pair of mithril boots",
	level_range = {40, 50},
	cost = 10,
	wielder = {
		combat_armor = 5,
		fatigue = 4,
	},
}
