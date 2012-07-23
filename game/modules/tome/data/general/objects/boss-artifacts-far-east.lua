-- ToME - Tales of Middle-Earth
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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- This file describes artifacts associated with a boss of the game, they have a high chance of dropping their respective ones, but they can still be found elsewhere

newEntity{ base = "BASE_KNIFE", define_as = "LIFE_DRINKER",
	power_source = {technique=true},
	unique = true,
	name = "Life Drinker", image = "object/artifact/dagger_life_drinker.png",
	unided_name = "blood coated dagger",
	desc = [[Black blood for foul deads. This dagger serves evil.]],
	level_range = {40, 50},
	rarity = 300,
	require = { stat = { mag=44 }, },
	cost = 450,
	material_level = 5,
	combat = {
		dam = 42,
		apr = 11,
		physcrit = 18,
		dammod = {mag=0.55,str=0.35},
	},
	wielder = {
		inc_damage={
			[DamageType.BLIGHT] = 15,
			[DamageType.DARKNESS] = 15,
			[DamageType.ACID] = 15,
		},
		combat_spellpower = 25,
		combat_spellcrit = 10,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_CUN] = 6, },
		infravision = 2,
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_WORM_ROT, level = 2, power = 40 },
	talent_on_spell = {
		{chance=15, talent=Talents.T_BLOOD_GRASP, level=2},
	},
}

newEntity{ base = "BASE_TRIDENT",
	power_source = {nature=true},
	define_as = "TRIDENT_TIDES",
	unided_name = "ever-dripping trident",
	name = "Trident of the Tides", unique=true, image = "object/artifact/trident_of_the_tides.png",
	desc = [[The power of the tides rushing through this trident.
Tridents require the exotic weapons mastery talent to use correctly.]],
	require = { stat = { str=35 }, },
	level_range = {30, 40},
	rarity = 230,
	cost = 300,
	material_level = 4,
	combat = {
		dam = 80,
		apr = 20,
		physcrit = 15,
		dammod = {str=1.4},
		damrange = 1.4,
		melee_project={
			[DamageType.COLD] = 15,
			[DamageType.NATURE] = 20,
		},
		talent_on_hit = { T_WATER_BOLT = {level=3, chance=40} }
	},

	wielder = {
		combat_atk = 10,
		combat_spellresist = 18,
		see_invisible = 2,
		resists={[DamageType.COLD] = 25},
		inc_damage = { [DamageType.COLD] = 20 },
	},

	talent_on_spell = { {chance=20, talent="T_WATER_BOLT", level=3} },

	max_power = 150, power_regen = 1,
	use_talent = { id = Talents.T_FREEZE, level=3, power = 60 },
}
