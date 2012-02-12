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
	define_as = "BASE_GREATMAUL",
	flavor_names = {"greatmaul", "sledge", "warhammer", "bonegrinder"},
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="greatmaul",
	add_name = " (#COMBAT#)",
	display = "\\", color=colors.SLATE, image = resolvers.image_material("2hmace", "metal"),
	moddable_tile = resolvers.moddable_tile("mace"),
	encumber = 5,
	rarity = 5,
	metallic = true,
	combat = { talented = "mace", damrange = 1, physspeed = 1, sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2} },
	desc = [[Massive two-handed maul.]],
	twohanded = true,
	randart_able = { attack=40, physical=80, spell=20, def=10, misc=10 },
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_GREATMAUL",
	name = "iron greatmaul", short_name = "iron",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = resolvers.cbonus(12),
		max_acc = resolvers.cbonus(80, 100, 1, 3),
		critical_power = resolvers.cbonus(15, 27, 0.1, 3),
		dammod = {str=0.25},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	name = "steel greatmaul", short_name = "steel",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 30,
	material_level = 2,
	combat = {
		dam = resolvers.cbonus(24),
		max_acc = resolvers.cbonus(80, 100, 1, 3.5),
		critical_power = resolvers.cbonus(15, 27, 0.1, 3.5),
		dammod = {str=0.5},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	name = "dwarven-steel greatmaul", short_name = "d.steel",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 80,
	material_level = 3,
	combat = {
		dam = resolvers.cbonus(48),
		max_acc = resolvers.cbonus(80, 100, 1, 4),
		critical_power = resolvers.cbonus(15, 27, 0.1, 4),
		dammod = {str=0.75},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	name = "stralite greatmaul", short_name = "stralite",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 120,
	material_level = 4,
	combat = {
		dam = resolvers.cbonus(84),
		max_acc = resolvers.cbonus(80, 100, 1, 4.5),
		critical_power = resolvers.cbonus(15, 27, 0.1, 4.5),
		dammod = {str=1},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	name = "voratun greatmaul", short_name = "voratun",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 170,
	material_level = 5,
	combat = {
		dam = resolvers.cbonus(120),
		max_acc = resolvers.cbonus(80, 100, 1, 5),
		critical_power = resolvers.cbonus(15, 27, 0.1, 5),
		dammod = {str=1.25},
	},
}
