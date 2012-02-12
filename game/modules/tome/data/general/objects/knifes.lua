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

local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_KNIFE",
	flavor_names = {"dagger", "dirk", "stiletto", "baselard"},
	slot = "MAINHAND", offslot = "OFFHAND",
	type = "weapon", subtype="dagger",
	add_name = " (#COMBAT#)",
	display = "/", color=colors.WHITE, image = resolvers.image_material("knife", "metal"),
	moddable_tile = resolvers.moddable_tile("dagger"),
	encumber = 1,
	rarity = 5,
	metallic = true,
	combat = { talented = "knife", damrange = 1, physspeed = 0.666, sound = {"actions/melee", pitch=1.2, vol=1.2}, sound_miss = {"actions/melee", pitch=1.2, vol=1.2} },
	desc = [[Sharp, short and deadly.]],
	randart_able = { attack=40, physical=80, spell=20, def=10, misc=10 },
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_KNIFE",
	name = "iron dagger", short_name = "iron",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = resolvers.cbonus(3, 5, 1, 1.5),
		max_acc = resolvers.cbonus(95, 100, 1, 1.5),
		critical_power = resolvers.cbonus(16, 25, 0.1),
		dammod = {dex=0.1, str=0.1},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "steel dagger", short_name = "steel",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 30,
	material_level = 2,
	combat = {
		dam = resolvers.cbonus(6, 10, 1, 2),
		max_acc = resolvers.cbonus(95, 100, 1, 2),
		critical_power = resolvers.cbonus(16, 25, 0.1, 2.5),
		dammod = {dex=0.2, str=0.2},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "dwarven-steel dagger", short_name = "d.steel",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 80,
	material_level = 3,
	combat = {
		dam = resolvers.cbonus(12),
		max_acc = resolvers.cbonus(95, 100, 1, 2.5),
		critical_power = resolvers.cbonus(16, 25, 0.1, 3),
		dammod = {dex=0.3, str=0.3},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "stralite dagger", short_name = "stralite",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 120,
	material_level = 4,
	combat = {
		dam = resolvers.cbonus(21),
		max_acc = resolvers.cbonus(95, 100, 1, 3),
		critical_power = resolvers.cbonus(16, 25, 0.1, 3.5),
		dammod = {dex=0.4, str=0.4},
	},
}

newEntity{ base = "BASE_KNIFE",
	name = "voratun dagger", short_name = "voratun",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 170,
	material_level = 5,
	combat = {
		dam = resolvers.cbonus(30),
		max_acc = resolvers.cbonus(95, 100, 1, 3.5),
		critical_power = resolvers.cbonus(16, 25, 0.1, 4),
		dammod = {dex=0.5, str=0.5},
	},
}
