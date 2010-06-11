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
	define_as = "BASE_HELM",
	slot = "HEAD",
	type = "armor", subtype="head",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.SLATE,
	require = { talent = { Talents.T_HEAVY_ARMOUR_TRAINING }, },
	encumber = 3,
	rarity = 7,
	desc = [[A large helmet that can protect the entire head. Ventilation and bad vision can be a problem, however.]],
}

newEntity{ base = "BASE_HELM",
	name = "iron helm",
	level_range = {1, 20},
	cost = 5,
	material_level = 1,
	wielder = {
		combat_armor = 3,
		fatigue = 5,
	},
}

newEntity{ base = "BASE_HELM",
	name = "dwarven-steel helm",
	level_range = {20, 40},
	cost = 7,
	material_level = 3,
	wielder = {
		combat_armor = 4,
		fatigue = 4,
	},
}

newEntity{ base = "BASE_HELM",
	name = "mithril helm",
	level_range = {40, 50},
	cost = 10,
	material_level = 5,
	wielder = {
		combat_armor = 5,
		fatigue = 5,
	},
}
