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

load("/data/general/objects/objects.lua")

newEntity{ base = "BASE_HEAVY_BOOTS", define_as = "PHYSSAVE_BOOTS",
	power_source = {technique=true},
	unique = true,
	name = "Boots of Physical Save (+10)", image = "object/artifact/scorched_boots.png",
	unided_name = "Dried-up old boots.",
	identified = true,
	no_unique_lore = true,
	level_range = {1, nil},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	desc = [[Fine boots that increse your physical save by 10.]],
	cost = 100,
	wielder = {
		combat_physresist = 10,
	},
}

newEntity{ base = "BASE_AMULET", define_as = "MINDPOWER_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Amulet of Mindpower (+3)", image = "object/artifact/amulet_spellblaze_echoes.png",
	unided_name = "Glittering amulet.",
	identified = true,
	no_unique_lore = true,
	level_range = {1, nil},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	desc = [[A beautiful amulet that increases your mindpower by 3.]],
	cost = 100,
	wielder = {
		combat_mindpower = 3,
	},
}

newEntity{ base = "BASE_HELM", define_as = "ACCURACY_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Helmet of Accuracy (+6)", image = "object/artifact/helm_of_the_dwarven_emperors.png",
	unided_name = "Hard-looking helmet.",
	identified = true,
	no_unique_lore = true,
	level_range = {1, nil},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	desc = [[A finely-wrought helmet that increases your Accuracy by 6.]],
	cost = 100,
	wielder = {
		combat_atk = 6,
	},
}

newEntity{ base = "BASE_RING", define_as = "MENTALSAVE_RING",
	power_source = {technique=true},
	unique = true,
	name = "Ring of Mental Save (+6)", image = "object/artifact/ring_of_war_master.png",
	unided_name = "Smooth ring.",
	identified = true,
	no_unique_lore = true,
	level_range = {1, nil},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	desc = [[A ruby-studded ring.]],
	cost = 100,
	wielder = {
		combat_mentalresist = 6,
	},
}