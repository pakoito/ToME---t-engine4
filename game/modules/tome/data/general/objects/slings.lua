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
	define_as = "BASE_SLING",
	slot = "MAINHAND",
	type = "weapon", subtype="sling",
	add_name = " (#COMBAT_RANGED#)",
	display = "}", color=colors.UMBER, image = resolvers.image_material("sling", "leather"),
	moddable_tile = resolvers.moddable_tile("sling"),
	encumber = 4,
	rarity = 5,
	combat = { talented = "sling", sound = "actions/sling", sound_miss = "actions/sling", },
	archery = "sling",
	require = { talent = { Talents.T_SHOOT }, },
	proj_image = resolvers.image_material("shot_s", "metal"),
	desc = [[Slings are used to hurl stones or metal shots at your foes.]],
	randart_able = { attack=40, physical=80, spell=20, def=10, misc=10 },
	egos = "/data/general/objects/egos/sling.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_SLING",
	name = "rough leather sling", short_name = "rough",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 1,
	material_level = 1,
	combat = {
		dam = resolvers.cbonus(2, 4, 1, 1),
		critical_power = resolvers.cbonus(15, 27, 0.1, 3),
		range = 6,
		dammod = {dex=0.1, cun=0.1},
	},
}

newEntity{ base = "BASE_SLING",
	name = "cured leather sling", short_name = "cured",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		dam = resolvers.cbonus(4, 8, 1, 1),
		critical_power = resolvers.cbonus(15, 27, 0.1, 3.5),
		range = 7,
		dammod = {dex=0.2, cun=0.2},
	},
}

newEntity{ base = "BASE_SLING",
	name = "hardened leather sling", short_name = "hardened",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		dam = resolvers.cbonus(8),
		critical_power = resolvers.cbonus(15, 27, 0.1, 4),
		range = 8,
		dammod = {dex=0.3, cun=0.3},
	},
}

newEntity{ base = "BASE_SLING",
	name = "reinforced leather sling", short_name = "reinforced",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		dam = resolvers.cbonus(14),
		critical_power = resolvers.cbonus(15, 27, 0.1, 4.5),
		range = 9,
		dammod = {dex=0.4, cun=0.4},
	},
}

newEntity{ base = "BASE_SLING",
	name = "drakeskin leather sling", short_name = "drakeskin",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		dam = resolvers.cbonus(20),
		critical_power = resolvers.cbonus(15, 27, 0.1, 5),
		range = 10,
		dammod = {dex=0.5, cun=0.5},
	},
}

------------------ AMMO -------------------

newEntity{
	define_as = "BASE_SHOT_POUCH",
	slot = "QUIVER",
	type = "ammo", subtype="shot",
	add_name = " (#COMBAT_QUIVER#)",
	display = "{", color=colors.UMBER, image = resolvers.image_material("shot", "metal"),
	encumber = 3,
	rarity = 11,
	combat = { talented = "sling", damrange = 1},
	proj_image = resolvers.image_material("shot_s", "metal"),
	archery_ammo = "sling",
	desc = [[Shots are used with slings to pummel your foes.]],
	egos = "/data/general/objects/egos/ammo.lua",
	egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_SHOT_POUCH",
	name = "pouch of iron shot", short_name = "iron",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 1,
	material_level = 1,
	combat = {
		capacity = resolvers.cbonus(40),
		dam = resolvers.cbonus(2, 4, 1, 1),
		max_acc = resolvers.cbonus(80, 100, 1, 3),
		dammod = {dex=0.1},
		shots_left = 40,
	},
	wielder = {},
	--learn_talent = {[Talents.T_RELOAD] = 1},
}

newEntity{ base = "BASE_SHOT_POUCH",
	name = "pouch of steel shot", short_name = "steel",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		capacity = resolvers.cbonus(40),
		dam = resolvers.cbonus(4, 8, 1, 1),
		max_acc = resolvers.cbonus(80, 100, 1, 3.5),
		dammod = {dex=0.2},
		shots_left = 40,
	},
	wielder = {},
	learn_talent = {[Talents.T_RELOAD] = 1},
}

newEntity{ base = "BASE_SHOT_POUCH",
	name = "pouch of dwarven-steel shot", short_name = "d.steel",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		capacity = resolvers.cbonus(40),
		dam = resolvers.cbonus(8),
		max_acc = resolvers.cbonus(80, 100, 1, 4),
		dammod = {dex=0.3},
		shots_left = 40,
	},
	wielder = {},
	learn_talent = {[Talents.T_RELOAD] = 1},
}

newEntity{ base = "BASE_SHOT_POUCH",
	name = "pouch of stralite shot", short_name = "stralite",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		capacity = resolvers.cbonus(40),
		dam = resolvers.cbonus(14),
		max_acc = resolvers.cbonus(80, 100, 1, 4.5),
		dammod = {dex=0.4},
		shots_left = 40,
	},
	wielder = {},
	learn_talent = {[Talents.T_RELOAD] = 2},
}

newEntity{ base = "BASE_SHOT_POUCH",
	name = "pouch of voratun shot", short_name = "voratun",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		capacity = resolvers.cbonus(40),
		dam = resolvers.cbonus(20),
		max_acc = resolvers.cbonus(80, 100, 1, 5),
		dammod = {dex=0.5},
		shots_left = 40,
	},
	wielder = {},
	learn_talent = {[Talents.T_RELOAD] = 2},
}
