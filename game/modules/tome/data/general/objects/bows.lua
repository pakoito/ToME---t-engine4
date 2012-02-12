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
	define_as = "BASE_LONGBOW",
	flavor_names = {"shortbow", "longbow", "warbow", "warbow"},
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="longbow",
	add_name = " (#COMBAT_RANGED#)",
	display = "}", color=colors.UMBER, image = resolvers.image_material("longbow", "wood"),
	moddable_tile = resolvers.moddable_tile("bow"),
	encumber = 4,
	rarity = 5,
	combat = { talented = "bow", sound = "actions/arrow", sound_miss = "actions/arrow", physspeed = 0.8,},
	require = { talent = { Talents.T_SHOOT }, },
	archery = "bow",
	proj_image = resolvers.image_material("arrow", "wood"),
	desc = [[Longbows are used to shoot arrows at your foes.]],
	randart_able = { attack=40, physical=80, spell=20, def=10, misc=10 },
	egos = "/data/general/objects/egos/bow.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_LONGBOW",
	name = "elm longbow", short_name = "elm",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = resolvers.cbonus(3, 6, 1, 1),
		critical_power = resolvers.cbonus(18, 30, 0.1, 3),
		range = 6,
		dammod = {dex=0.1},
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "ash longbow", short_name = "ash",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 30,
	material_level = 2,
	combat = {
		dam = resolvers.cbonus(6),
		critical_power = resolvers.cbonus(18, 30, 0.1, 3.5),
		range = 7,
		dammod = {dex=0.2},
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "yew longbow", short_name = "yew",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 80,
	material_level = 3,
	combat = {
		dam = resolvers.cbonus(12),
		critical_power = resolvers.cbonus(18, 30, 0.1, 4),
		range = 8,
		dammod = {dex=0.3},
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "elven-wood longbow", short_name = "e.wood",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 120,
	material_level = 4,
	combat = {
		dam = resolvers.cbonus(21),
		critical_power = resolvers.cbonus(18, 30, 0.1, 4.5),
		range = 9,
		dammod = {dex=0.4},
	},
}

newEntity{ base = "BASE_LONGBOW",
	name = "dragonbone longbow", short_name = "dragonbone",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 170,
	material_level = 5,
	combat = {
		dam = resolvers.cbonus(30),
		critical_power = resolvers.cbonus(18, 30, 0.1, 5),
		range = 10,
		dammod = {dex=0.5},
	},
}
------------------ QUIVERS -------------------

newEntity{
	define_as = "BASE_QUIVER",
	slot = "QUIVER",
	type = "ammo", subtype="arrow",
	add_name = " (#COMBAT_QUIVER#)",
	display = "{", color=colors.UMBER, image = resolvers.image_material("arrow", "wood"),
	encumber = 3,
	rarity = 11,
	combat = { talented = "bow", damrange = 1},
	proj_image = resolvers.image_material("arrow", "wood"),
	archery_ammo = "bow",
	desc = [[Arrows are used with bows to pierce your foes.]],
	egos = "/data/general/objects/egos/ammo.lua",
	egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_QUIVER", define_as = "TEST_ELM_QUIVER",
	name = "quiver of elm arrows", short_name = "elm",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		capacity = resolvers.cbonus(10),
		dam = resolvers.cbonus(3, 6, 1, 1),
		max_acc = resolvers.cbonus(85, 100, 1, 3),
		dammod = {dex=0.1},
		shots_left = 20,
	},
	--wielder = {learn_talent = {[Talents.T_RELOAD] = 1}},
}

newEntity{ base = "BASE_QUIVER",
	name = "quiver of ash arrows", short_name = "ash",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 30,
	material_level = 2,
	combat = {
		capacity = resolvers.cbonus(10, nil, nil, 3),
		dam = resolvers.cbonus(6),
		max_acc = resolvers.cbonus(85, 100, 1, 3.5),
		dammod = {dex=0.2},
		shots_left = 20,
	},
}

newEntity{ base = "BASE_QUIVER",
	name = "quiver of yew arrows", short_name = "yew",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 80,
	material_level = 3,
	combat = {
		capacity = resolvers.cbonus(10, nil, nil, 3.5),
		dam = resolvers.cbonus(12),
		max_acc = resolvers.cbonus(85, 100, 1, 4),
		dammod = {dex=0.3},
		shots_left = 20,
	},
}

newEntity{ base = "BASE_QUIVER",
	name = "quiver of elven-wood arrows", short_name = "e.wood",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 120,
	material_level = 4,
	combat = {
		capacity = resolvers.cbonus(10, nil, nil, 4),
		dam = resolvers.cbonus(21),
		max_acc = resolvers.cbonus(85, 100, 1, 4.5),
		dammod = {dex=0.4},
		shots_left = 20,
	},
}

newEntity{ base = "BASE_QUIVER",
	name = "quiver of dragonbone arrows", short_name = "dragonbone",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 170,
	material_level = 5,
	combat = {
		capacity = resolvers.cbonus(10, nil, nil, 4.5),
		dam = resolvers.cbonus(30),
		max_acc = resolvers.cbonus(85, 100, 1, 5),
		dammod = {dex=0.5},
		shots_left = 20,
	},
}

