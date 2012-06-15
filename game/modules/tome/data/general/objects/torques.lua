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
	define_as = "BASE_TORQUE",
	slot = "TOOL",
	type = "charm", subtype="torque",
	unided_name = "torque", id_by_type = true,
	display = "-", color=colors.WHITE, image = resolvers.image_material("torque", "metal"),
	encumber = 2,
	rarity = 12,
	add_name = "#CHARM# #CHARGES#",
	use_sound = "talents/spell_generic",
	desc = [[Torques are made by powerful psionics to store psionic powers.]],
	egos = "/data/general/objects/egos/torques.lua", egos_chance = { prefix=resolvers.mbonus(20, 5), suffix=resolvers.mbonus(20, 5) },
	addons = "/data/general/objects/egos/torques-powers.lua",
	power_source = {psionic=true},
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	talent_cooldown = "T_GLOBAL_CD",
}

newEntity{ base = "BASE_TORQUE",
	name = "iron torque", short_name = "iron",
	color = colors.UMBER,
	level_range = {1, 10},
	cost = 1,
	material_level = 1,
	charm_power = resolvers.mbonus_material(15, 10),
}

newEntity{ base = "BASE_TORQUE",
	name = "steel torque", short_name = "steel",
	color = colors.UMBER,
	level_range = {10, 20},
	cost = 2,
	material_level = 2,
	charm_power = resolvers.mbonus_material(20, 20),
}

newEntity{ base = "BASE_TORQUE",
	name = "dwarven-steel torque", short_name = "d.steel",
	color = colors.UMBER,
	level_range = {20, 30},
	cost = 3,
	material_level = 3,
	charm_power = resolvers.mbonus_material(25, 30),
}

newEntity{ base = "BASE_TORQUE",
	name = "stralite torque", short_name = "stralite",
	color = colors.UMBER,
	level_range = {30, 40},
	cost = 4,
	material_level = 4,
	charm_power = resolvers.mbonus_material(30, 40),
}

newEntity{ base = "BASE_TORQUE",
	name = "voratun torque", short_name = "voratun",
	color = colors.UMBER,
	level_range = {40, 50},
	cost = 5,
	material_level = 5,
	charm_power = resolvers.mbonus_material(35, 50),
}
