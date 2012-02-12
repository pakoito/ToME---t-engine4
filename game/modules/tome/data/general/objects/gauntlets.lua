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
	define_as = "BASE_GAUNTLETS",
	slot = "HANDS",
	type = "armor", subtype="hands",
	add_name = " (#GLOVES#)",
	display = "[", color=colors.SLATE,
	image = resolvers.image_material("hgloves", "metal"),
	moddable_tile = resolvers.moddable_tile("gauntlets"),
	require = { talent = { Talents.T_ARMOUR_TRAINING }, },
	encumber = 1.5,
	rarity = 9,
	metallic = true,
	wielder = {combat = {physspeed = -0.2}},
	desc = [[Metal gloves protecting the hands up to the middle of the lower arm.]],
	randart_able = { attack=10, physical=10, spell=10, def=40, misc=30 },
	egos = "/data/general/objects/egos/gloves.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_GAUNTLETS",
	name = "iron gauntlets", short_name = "iron",
	level_range = {1, 20},
	cost = 5,
	material_level = 1,
	wielder = {
		combat_armor = 1,
		combat = {
			dam = resolvers.cbonus(4, 10, 1, 2),
			max_acc = resolvers.cbonus(10, 25, 1, 3),
			critical_power = resolvers.cbonus(4, 14, 0.1, 3),
			dammod = {dex=0.1, str=0, cun=0.1 },
		},
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	name = "dwarven-steel gauntlets", short_name = "d.steel",
	level_range = {20, 40},
	cost = 25,
	material_level = 3,
	wielder = {
		combat_armor = 2,
		combat = {
			dam = resolvers.cbonus(16),
			max_acc = resolvers.cbonus(10, 25, 1, 4),
			critical_power = resolvers.cbonus(4, 14, 0.1, 4),
			dammod = {dex=0.2, str=0.1, cun=0.2 },
		},
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	name = "voratun gauntlets", short_name = "voratun",
	level_range = {40, 50},
	cost = 35,
	material_level = 5,
	wielder = {
		combat_armor = 3,
		combat = {
			dam = resolvers.cbonus(40),
			max_acc = resolvers.cbonus(10, 25, 1, 5),
			critical_power = resolvers.cbonus(4, 14, 0.1, 5),
			dammod = {dex=0.4, str=0.3, cun=0.4 },
		},
	},
}
