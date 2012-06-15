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
	define_as = "BASE_WARAXE",
	slot = "MAINHAND", dual_wieldable = true,
	type = "weapon", subtype="waraxe",
	add_name = " (#COMBAT#)",
	display = "/", color=colors.SLATE, image = resolvers.image_material("axe", "metal"),
	moddable_tile = resolvers.moddable_tile("axe"),
	encumber = 3,
	rarity = 3,
	metallic = true,
	combat = { talented = "axe", damrange = 1.4, physspeed = 1, sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2}},
	desc = [[One-handed war axes.]],
	randart_able = "/data/general/objects/random-artifacts/melee.lua",
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_WARAXE",
	name = "iron waraxe", short_name = "iron",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = resolvers.rngavg(5,8),
		apr = 2,
		physcrit = 3.5,
		dammod = {str=1},
	},
}

newEntity{ base = "BASE_WARAXE",
	name = "steel waraxe", short_name = "steel",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		dam = resolvers.rngavg(8,14),
		apr = 3,
		physcrit = 4,
		dammod = {str=1},
	},
}

newEntity{ base = "BASE_WARAXE",
	name = "dwarven-steel waraxe", short_name = "d.steel",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		dam = resolvers.rngavg(17,23),
		apr = 4,
		physcrit = 4.5,
		dammod = {str=1},
	},
}

newEntity{ base = "BASE_WARAXE",
	name = "stralite waraxe", short_name = "stralite",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		dam = resolvers.rngavg(28,35),
		apr = 5,
		physcrit = 6.5,
		dammod = {str=1},
	},
}

newEntity{ base = "BASE_WARAXE",
	name = "voratun waraxe", short_name = "voratun",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		dam = resolvers.rngavg(38,42),
		apr = 6,
		physcrit = 7,
		dammod = {str=1},
	},
}
