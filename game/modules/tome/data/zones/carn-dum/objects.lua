-- ToME - Tales of Middle-Earth
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

load("/data/general/objects/objects.lua")

local Stats = require "engine.interface.ActorStats"

-- Artifact, droped by Rantha
newEntity{ base = "BASE_LEATHER_BOOT",
	define_as = "FROST_TREADS",
	name = "Frost Treads", unique=true,
	desc = [[A pair of leather boots. Cold to the touch, they radiate a cold blue light.]],
	require = { stat = { dex=16 }, },
	cost = 40,

	wielder = {
		lite = 1,
		combat_armor = 2,
		combat_def = 1,
		fatigue = 14,
		inc_damage = {
			[DamageType.COLD] = 5,
		},
		resists = {
			[DamageType.COLD] = 20,
			[DamageType.NATURE] = 10,
		},
		inc_stats = { [Stats.STAT_STR] = 4, [Stats.STAT_DEX] = 4, [Stats.STAT_CUN] = 4, },
	},
}

newEntity{ base = "BASE_HELM",
	define_as = "RUNED_SKULL",
	name = "Dragonskull Helm", unique=true, unided_name="skull helm",
	desc = [[Traces of a dragon's power still remain in this bleached and cracked skull.]],
	require = { stat = { mag=24 }, },
	cost = 200,

	wielder = {
		resists = {
			[DamageType.FIRE] = 15,
			[DamageType.COLD] = 15,
			[DamageType.LIGHTNING] = 15,
		},
		esp = {dragon=1},
		combat_armor = 2,
		fatigue = 12,
		combat_physresist = 12,
		combat_mentalresist = 12,
		combat_spellresist = 12,
	},
}
