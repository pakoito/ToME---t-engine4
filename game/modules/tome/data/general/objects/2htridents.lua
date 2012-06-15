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

newEntity{
	define_as = "BASE_TRIDENT",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="trident", image = resolvers.image_material("trident", "sea-metal"),
	moddable_tile = resolvers.moddable_tile("trident"),
	add_name = " (#COMBAT#)",
	display = "|", color=colors.AQUAMARINE,
	encumber = 3,
	trident_rarity = 5, -- Special rarity field, converted to "rarity" when needed
	metallic = true,
	no_rust = true,
	combat = { talented = "trident", damrange = 1.6, physspeed = 1, sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2} },
	desc = [[A two-handed massive trident.
Tridents require the exotic weapons mastery talent to use correctly.]],
	twohanded = true,
	ego_bonus_mult = 0.2,
	randart_able = "/data/general/objects/random-artifacts/melee.lua",
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_TRIDENT",
	name = "coral trident", short_name = "coral",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = resolvers.rngavg(6,10),
		apr = 6,
		physcrit = 1.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_TRIDENT",
	name = "blue-steel trident", short_name = "b.steel",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		dam = resolvers.rngavg(11,19),
		apr = 8,
		physcrit = 2,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_TRIDENT",
	name = "deep-steel trident", short_name = "d.steel",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		dam = resolvers.rngavg(24,31),
		apr = 10,
		physcrit = 2.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_TRIDENT",
	name = "orite trident", short_name = "orite",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		dam = resolvers.rngavg(36,44),
		apr = 13,
		physcrit = 3.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_TRIDENT",
	name = "orichalcum trident", short_name = "orichalcum",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		dam = resolvers.rngavg(50, 56),
		apr = 16,
		physcrit = 4,
		dammod = {str=1.2},
	},
}
