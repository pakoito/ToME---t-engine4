-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	define_as = "BASE_MINDSTAR",
	slot = "MAINHAND", offslot = "OFFHAND",
	type = "weapon", subtype="mindstar",
	add_name = " (#COMBAT_DAMTYPE#)",
	display = "!", color=colors.LIGHT_RED, image = resolvers.image_material("mindstar", "wood"),
	moddable_tile = resolvers.moddable_tile("mindstar"),
	randart_able = { attack=10, physical=40, spell=1, def=10, misc=10 },
	encumber = 5,
	rarity = 4,
	power_source = {nature=true},
	combat = {
		talented = "mindstar",
		physspeed = 1,
		damrange = 1.1,
		sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2},
		damtype = resolvers.rngtable{DamageType.NATURE, DamageType.MIND},
	},
	desc = [[Mindstars are natural products. Natural gems covered in living matter, they are used to focus the mental powers of all nature defenders.]],
	egos = "/data/general/objects/egos/mindstars.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_MINDSTAR",
	name = "mossy mindstar", short_name = "mossy",
	level_range = {1, 10},
	require = { stat = { wil=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = resolvers.rngavg(2,3),
		apr = 2,
		physcrit = 2.5,
		dammod = {wil=1},
	},
	wielder = {
		combat_mindpower = 1,
		combat_mindcrit = 1,
	},
}

newEntity{ base = "BASE_MINDSTAR",
	name = "vined mindstar", short_name = "vined",
	level_range = {10, 20},
	require = { stat = { wil=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		dam = resolvers.rngavg(4,6),
		apr = 3,
		physcrit = 3,
		dammod = {wil=1},
	},
	wielder = {
		combat_mindpower = 1,
		combat_mindcrit = 2,
	},
}

newEntity{ base = "BASE_MINDSTAR",
	name = "thorny mnidstar", short_name = "thorny",
	level_range = {20, 30},
	require = { stat = { wil=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		dam = resolvers.rngavg(7,10),
		apr = 4,
		physcrit = 3.5,
		dammod = {wil=1},
	},
	wielder = {
		combat_mindpower = 2,
		combat_mindcrit = 3,
	},
}

newEntity{ base = "BASE_MINDSTAR",
	name = "pulsing mindstar", short_name = "pusling",
	level_range = {30, 40},
	require = { stat = { wil=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		dam = resolvers.rngavg(12,14),
		apr = 5,
		physcrit = 4.5,
		dammod = {wil=1},
	},
	wielder = {
		combat_mindpower = 4,
		combat_mindcrit = 4,
	},
}

newEntity{ base = "BASE_MINDSTAR",
	name = "living mindstar", short_name = "living",
	level_range = {40, 50},
	require = { stat = { wil=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		dam = resolvers.rngavg(15,18),
		apr = 6,
		physcrit = 5,
		dammod = {wil=1},
	},
	wielder = {
		combat_mindpower = 5,
		combat_mindcrit = 5,
	},
}