-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	define_as = "BASE_LONGBOW",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="longbow",
	display = "}", color=colors.UMBER, image = resolvers.image_material("longbow", "wood"),
	moddable_tile = resolvers.moddable_tile("bow"),
	encumber = 4,
	rarity = 7,
	combat = { talented = "bow", accuracy_effect = "axe", sound = "actions/arrow", sound_miss = "actions/arrow",},
	require = { talent = { Talents.T_SHOOT }, },
	archery_kind = "bow",
	archery = "bow",
	proj_image = resolvers.image_material("arrow", "wood"),
	desc = [[Longbows are used to shoot arrows at your foes.]],
	randart_able = "/data/general/objects/random-artifacts/ranged.lua",
	egos = "/data/general/objects/egos/bow.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_LONGBOW",
	name = "elm longbow", short_name = "elm",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		range = 6,
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "ash longbow", short_name = "ash",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		range = 7,
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "yew longbow", short_name = "yew",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		range = 8,
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "elven-wood longbow", short_name = "e.wood",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		range = 9,
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "dragonbone longbow", short_name = "dragonbone",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		range = 10,
		physspeed = 0.8,
	},
}

------------------ AMMO -------------------

newEntity{
	define_as = "BASE_ARROW",
	slot = "QUIVER",
	type = "ammo", subtype="arrow",
	add_name = " (#COMBAT_AMMO#)",
	display = "{", color=colors.UMBER, image = resolvers.image_material("arrow", "wood"),
	encumber = 3,
	rarity = 7,
	combat = {
		talented = "bow", accuracy_effect = "axe",
		damrange = 1.4,
	},
	proj_image = resolvers.image_material("arrow", "wood"),
	archery_ammo = "bow",
	desc = [[Arrows are used with bows to pierce your foes to death.]],
	randart_able = "/data/general/objects/random-artifacts/ammo.lua",
	egos = "/data/general/objects/egos/ammo.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
	resolvers.shooter_capacity(),
}

newEntity{ base = "BASE_ARROW",
	name = "quiver of elm arrows", short_name = "elm",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 2,
	material_level = 1,
	combat = {
		capacity = resolvers.rngavg(5, 15),
		dam = resolvers.rngavg(7,12),
		apr = 5,
		physcrit = 1,
		dammod = {dex=0.7, str=0.5},
	},
}

newEntity{ base = "BASE_ARROW",
	name = "quiver of ash arrows", short_name = "ash",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 5,
	material_level = 2,
	combat = {
		capacity = resolvers.rngavg(7, 15),
		dam = resolvers.rngavg(15,22),
		apr = 7,
		physcrit = 1.5,
		dammod = {dex=0.7, str=0.5},
	},
}

newEntity{ base = "BASE_ARROW",
	name = "quiver of yew arrows", short_name = "yew",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 10,
	material_level = 3,
	combat = {
		capacity = resolvers.rngavg(9, 15),
		dam = resolvers.rngavg(28,37),
		apr = 10,
		physcrit = 2,
		dammod = {dex=0.7, str=0.5},
	},
}

newEntity{ base = "BASE_ARROW",
	name = "quiver of elven-wood arrows", short_name = "e.wood",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 15,
	material_level = 4,
	combat = {
		capacity = resolvers.rngavg(11, 15),
		dam = resolvers.rngavg(40,47),
		apr = 14,
		physcrit = 2.5,
		dammod = {dex=0.7, str=0.5},
	},
}

newEntity{ base = "BASE_ARROW",
	name = "quiver of dragonbone arrows", short_name = "dragonbone",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 25,
	material_level = 5,
	combat = {
		capacity = resolvers.rngavg(13, 15),
		dam = resolvers.rngavg(50, 57),
		apr = 18,
		physcrit = 3,
		dammod = {dex=0.7, str=0.5},
	},
}
