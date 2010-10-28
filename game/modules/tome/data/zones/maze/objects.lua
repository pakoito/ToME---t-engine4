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

load("/data/general/objects/objects.lua")

local Stats = require"engine.interface.ActorStats"

-- Artifact, droped (and used!) by the Minautaur
newEntity{ base = "BASE_HELM",
	define_as = "HELM_OF_HAMMERHAND",
	name = "Steel Helm of Hammerhand", unique=true,
	desc = [[A great helm as steady as the heroes of the Westdike. Mighty were the blows of Helm, the Hammerhand!]],
	require = { stat = { str=16 }, },
	cost = 20,

	wielder = {
		combat_armor = 4,
		fatigue = 8,
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_CON] = 3, [Stats.STAT_WIL] = 4 },
		combat_physresist = 7,
		combat_mentalresist = 7,
		combat_spellresist = 7,
	},
}

newEntity{ base = "BASE_SHIELD",
	define_as = "LUNAR_SHIELD",
	unique = true,
	name = "Lunar Shield",
	unided_name = "chitinous shield",
	desc = [[A large section of chitin removed from Nimisil. It continues to give off a strange white glow.]],
	color = colors.YELLOW,
	metallic = false,
	require = { stat = { str=35 }, },
	cost = 350,
	material_level = 5,
	special_combat = {
		dam = 45,
		physcrit = 10,
		dammod = {str=1},
		damtype = DamageType.ARCANE,
	},
	wielder = {
		resists={[DamageType.DARKNESS] = 25},
		inc_damage={[DamageType.DARKNESS] = 15},

		combat_armor = 7,
		combat_def = 12,
		combat_def_ranged = 5,
		fatigue = 12,

		lite = 1,
		talents_types_mastery = {["divine/star-fury"]=0.2,["divine/twilight"]=0.1,},
	},
}
