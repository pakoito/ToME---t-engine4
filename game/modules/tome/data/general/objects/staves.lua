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

local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_STAFF",
	flavor_names = {"staff", "magestaff", "starstaff", "vilestaff"},
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="staff",
	twohanded = true,
	add_name = " (#COMBAT_DAMTYPE#)",
	display = "\\", color=colors.LIGHT_RED, image = resolvers.image_material("staff", "wood"),
	moddable_tile = resolvers.moddable_tile("staff"),
	randart_able = "/data/general/objects/random-artifacts/melee.lua",
	encumber = 5,
	rarity = 4,
	combat = {
		talented = "staff",
		physspeed = 1,
		damrange = 1.2,
		sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2},
	},
	desc = [[Staves designed for wielders of magic, by the greats of the art.]],
	egos = "/data/general/objects/egos/staves.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_STAFF",
	name = "elm staff", short_name = "elm",
	level_range = {1, 10},
	require = { stat = { mag=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = 10,
		apr = 2,
		physcrit = 2.5,
		dammod = {mag=1},
	},
	wielder = resolvers.staff_wielder(),
}

newEntity{ base = "BASE_STAFF",
	name = "ash staff", short_name = "ash",
	level_range = {10, 20},
	require = { stat = { mag=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		dam = 15,
		apr = 3,
		physcrit = 3,
		dammod = {mag=1},
	},
	wielder = resolvers.staff_wielder(),
}

newEntity{ base = "BASE_STAFF",
	name = "yew staff", short_name = "yew",
	level_range = {20, 30},
	require = { stat = { mag=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		dam = 20,
		apr = 4,
		physcrit = 3.5,
		dammod = {mag=1},
	},
	wielder = resolvers.staff_wielder(),
}

newEntity{ base = "BASE_STAFF",
	name = "elven-wood staff", short_name = "e.wood",
	level_range = {30, 40},
	require = { stat = { mag=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		dam = 25,
		apr = 5,
		physcrit = 4.5,
		dammod = {mag=1},
	},
	wielder = resolvers.staff_wielder(),
}

newEntity{ base = "BASE_STAFF",
	name = "dragonbone staff", short_name = "dragonbone",
	level_range = {40, 50},
	require = { stat = { mag=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		dam = 30,
		apr = 6,
		physcrit = 5,
		dammod = {mag=1},
	},
	wielder = resolvers.staff_wielder(),
}
