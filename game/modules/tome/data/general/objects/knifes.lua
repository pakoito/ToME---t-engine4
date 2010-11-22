-- ToME - Tales of Maj'Eyal
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
	define_as = "BASE_KNIFE",
	slot = "MAINHAND", offslot = "OFFHAND",
	type = "weapon", subtype="dagger",
	add_name = " (#COMBAT#)",
	display = "/", color=colors.WHITE, image = resolvers.image_material("knife", "metal"),
	encumber = 1,
	rarity = 5,
	metallic = true,
	combat = { talented = "knife", damrange = 1.3, sound = "actions/melee", sound_miss = "actions/melee_miss", },
	desc = [[Sharp, long and deadly.]],
	randart_able = { attack=40, physical=80, spell=20, def=10, misc=10 },
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_KNIFE",
	name = "iron dagger",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = resolvers.rngavg(4,6),
		apr = 5,
		physcrit = 4,
		dammod = {dex=0.45,str=0.45},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "steel dagger",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		dam = resolvers.rngavg(8,12),
		apr = 6,
		physcrit = 5,
		dammod = {dex=0.45,str=0.45},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "dwarven-steel dagger",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		dam = resolvers.rngavg(14,22),
		apr = 7,
		physcrit = 6,
		dammod = {dex=0.45,str=0.45},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "stralite dagger",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		dam = resolvers.rngavg(25,32),
		apr = 9,
		physcrit = 8,
		dammod = {dex=0.45,str=0.45},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "voratun dagger",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		dam = resolvers.rngavg(36,40),
		apr = 9,
		physcrit = 10,
		dammod = {dex=0.45,str=0.45},
	},
}
