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
local DamageType = require "engine.DamageType"
local Talents = require("engine.interface.ActorTalents")

-- common resists/damage
newEntity{
	power_source = {nature=true},
	name = "cinder ", prefix=true, instant_resolve=true,
	keywords = {cinder=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.FIRE] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.FIRE] = resolvers.mbonus_material(5, 5), },
		melee_project= { [DamageType.FIRE] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.FIRE] = resolvers.mbonus_material(10, 5) },
			convert_damage = { [DamageType.FIRE] = resolvers.mbonus_material(25, 25) },
			talent_on_hit = { [Talents.T_FIRE_BREATH] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}
newEntity{
	power_source = {nature=true},
	name = "corrosive ", prefix=true, instant_resolve=true,
	keywords = {corrosive=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.ACID] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.ACID] = resolvers.mbonus_material(5, 5), },
		melee_project= { [DamageType.ACID] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.ACID] = resolvers.mbonus_material(10, 5) },
			convert_damage = { [DamageType.ACID] = resolvers.mbonus_material(25, 25) },
			talent_on_hit = { [Talents.T_ACID_BREATH] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}
newEntity{
	power_source = {nature=true},
	name = "naturalist's ", prefix=true, instant_resolve=true,
	keywords = {natural=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.NATURE] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.NATURE] = resolvers.mbonus_material(5, 5), },
		melee_project= { [DamageType.NATURE] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.NATURE] = resolvers.mbonus_material(10, 5) },
			convert_damage = { [DamageType.NATURE] = resolvers.mbonus_material(25, 25) },
			talent_on_hit = { [Talents.T_POISON_BREATH] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}
newEntity{
	power_source = {nature=true},
	name = "polar ", prefix=true, instant_resolve=true,
	keywords = {polar=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.COLD] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.COLD] = resolvers.mbonus_material(5, 5), },
		melee_project= { [DamageType.COLD] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.COLD] = resolvers.mbonus_material(10, 5) },
			convert_damage = { [DamageType.COLD] = resolvers.mbonus_material(25, 25) },
			talent_on_hit = { [Talents.T_ICE_BREATH] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}
newEntity{
	power_source = {psionic=true},
	name = "psychic's ", prefix=true, instant_resolve=true,
	keywords = {psychic=true},
	level_range = {1, 50},
	rarity = 18, -- much rarer, that proc has a high chance and can confuse
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.MIND] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.MIND] = resolvers.mbonus_material(5, 5), },
		melee_project= { [DamageType.MIND] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.MIND] = resolvers.mbonus_material(10, 5) },
			convert_damage = { [DamageType.MIND] = resolvers.mbonus_material(25, 25) },
			talent_on_hit = { [Talents.T_PSYCHIC_LOBOTOMY] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=20} },
		},
	},
}
newEntity{
	power_source = {nature=true},
	name = "sand ", prefix=true, instant_resolve=true,
	keywords = {sand=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.PHYSICAL] = resolvers.mbonus_material(8, 3), },
		combat_armor = resolvers.mbonus_material(5, 5),
		melee_project= { [DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5) },
			burst_on_hit= { [DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5) },
			talent_on_hit = { [Talents.T_SAND_BREATH] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}
newEntity{
	power_source = {nature=true},
	name = "storm ", prefix=true, instant_resolve=true,
	keywords = {storm=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.LIGHTNING] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.LIGHTNING] = resolvers.mbonus_material(5, 5), },
		melee_project= { [DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5) },
			convert_damage = { [DamageType.LIGHTNING] = resolvers.mbonus_material(25, 25) },
			talent_on_hit = { [Talents.T_LIGHTNING_BREATH] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}
-- arcane/pure single target talent procs/higher chance
newEntity{
	power_source = {arcane=true},
	name = "blighted ", prefix=true, instant_resolve=true,
	keywords = {blighed=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.BLIGHT] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.BLIGHT] = resolvers.mbonus_material(5, 5), },
		melee_project= { [DamageType.BLIGHT] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.BLIGHT] = resolvers.mbonus_material(10, 5) },
			convert_damage = { [DamageType.BLIGHT] = resolvers.mbonus_material(25, 25) },
			talent_on_hit = { [Talents.T_SOUL_ROT] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=20} },
		},
	},
}
newEntity{
	power_source = {arcane=true},
	name = "umbral ", prefix=true, instant_resolve=true,
	keywords = {umbral=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.DARKNESS] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.DARKNESS] = resolvers.mbonus_material(5, 5), },
		melee_project= { [DamageType.DARKNESS] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.DARKNESS] = resolvers.mbonus_material(10, 5) },
			convert_damage = { [DamageType.DARKNESS] = resolvers.mbonus_material(25, 25) },
			talent_on_hit = { [Talents.T_MOONLIGHT_RAY] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=20} },
		},
	},
}
newEntity{
	power_source = {arcane=true},
	name = "radiant ", prefix=true, instant_resolve=true,
	keywords = {radiant=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.LIGHT] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.LIGHT] = resolvers.mbonus_material(5, 5), },
		melee_project= { [DamageType.LIGHT] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.LIGHT] = resolvers.mbonus_material(10, 5) },
			convert_damage = { [DamageType.LIGHT] = resolvers.mbonus_material(25, 25) },
			talent_on_hit = { [Talents.T_SEARING_LIGHT] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=20} },
		},
	},
}
newEntity{
	power_source = {arcane=true},
	name = "temporal ", prefix=true, instant_resolve=true,
	keywords = {temporal=true},
	level_range = {1, 50},
	rarity = 18, -- much rarer, that proc is very high damage so lets not kill the player with it to much
	cost = 5,
	wielder = {
		inc_damage= { [DamageType.TEMPORAL] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.TEMPORAL] = resolvers.mbonus_material(5, 5), },
		melee_project= { [DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5) },
		combat = {
			burst_on_crit= { [DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5) },
			convert_damage = { [DamageType.TEMPORAL] = resolvers.mbonus_material(25, 25) },
			talent_on_hit = { [Talents.T_QUANTUM_SPIKE] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=20} },
		},
	},
}
-- stats
newEntity{
	power_source = {technique=true},
	name = " of dexterity (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {dex=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(4, 2) },
		combat_atk = resolvers.mbonus_material(15, 10),
		combat = {
			physcrit = resolvers.mbonus_material(8, 4),
			atk = resolvers.mbonus_material(8, 4),
		},
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of magic (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {magic=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(4, 2) },
		inc_damage= { [DamageType.ARCANE] = resolvers.mbonus_material(8, 3), },
		combat = {
			melee_project={ [DamageType.ARCANE] = resolvers.mbonus_material(15, 4) },
			burst_on_crit= { [DamageType.ARCANE] = resolvers.mbonus_material(10, 5) },
		},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of strength (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {strength=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(4, 2) },
		combat_dam = resolvers.mbonus_material(15, 5),
		combat = {
			dam = resolvers.mbonus_material(7, 3),
		},
	},
}

-- the rest
newEntity{
	power_source = {psionic=true},
	name = "restful ", prefix=true, instant_resolve=true,
	keywords = {restful=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		max_stamina = resolvers.mbonus_material(30, 10),
		life_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/10 return 0, v end),
		stamina_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
		combat = {
			talent_on_hit = { [Talents.T_SLUMBER] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = "steady ", prefix=true, instant_resolve=true,
	keywords = {steady=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		combat_atk = resolvers.mbonus_material(5, 5),
		combat_physresist = resolvers.mbonus_material(5, 5),
		combat_mentalresist = resolvers.mbonus_material(5, 5),
		combat = {
			atk = resolvers.mbonus_material(5, 5),
			talent_on_hit = { [Talents.T_PERFECT_CONTROL] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of war-making", suffix=true, instant_resolve=true,
	keywords = {war=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 20,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(15, 5),
		combat_mindcrit = resolvers.mbonus_material(15, 5),
		combat_physcrit = resolvers.mbonus_material(15, 5),
		combat_critical_power = resolvers.mbonus_material(35, 5),
		combat = {
			physcrit = resolvers.mbonus_material(10, 4),
			dam = resolvers.mbonus_material(7, 3),
			talent_on_crit = { [Talents.T_CRIPPLE] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=20} },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the iron hand", suffix=true, instant_resolve=true,
	keywords = {iron=true},
	level_range = {30, 50},
	rarity = 30,
	cost = 25,
	wielder = {
		talents_types_mastery = { ["technique/grappling"] = 0.2},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_CON] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 2),
		},
		disarm_bonus = resolvers.mbonus_material(25, 5),
		combat = {
			talent_on_hit = { [Talents.T_MAIM] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=20} },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "alchemist's ", prefix=true, instant_resolve=true,
	keywords = {alchemist=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 35,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 2),
		},
		melee_project = {
			[DamageType.ACID] = resolvers.mbonus_material(7, 3),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(7, 3),
			[DamageType.FIRE] = resolvers.mbonus_material(7, 3),
			[DamageType.COLD] = resolvers.mbonus_material(7, 3),
		},
		combat = {
			melee_project={
				[DamageType.FIRE] = resolvers.mbonus_material(25, 4),
				[DamageType.ICE] = resolvers.mbonus_material(15, 4),
				[DamageType.ACID] = resolvers.mbonus_material(25, 4),
				[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4),
			},
		},
	},

}

newEntity{
	power_source = {technique=true},
	name = "brawler's ", prefix=true, instant_resolve=true,
	keywords = {brawler=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 75,
	wielder = {
		talent_cd_reduction={ [Talents.T_DOUBLE_STRIKE]=1,},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 2),
		},
		combat_physresist = resolvers.mbonus_material(10, 5),
		combat = {
			physcrit = resolvers.mbonus_material(10, 4),
			atk = resolvers.mbonus_material(10, 2),
			physspeed = -0.1,
			talent_on_hit = { [Talents.T_SET_UP] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}

newEntity{
	power_source = {antimagic=true},
	name = " of butchering", suffix=true, instant_resolve=true,
	keywords = {butchering=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
		},
		combat_spellresist = resolvers.mbonus_material(15, 8),
		combat_atk = resolvers.mbonus_material(10, 4),
		combat_dam = resolvers.mbonus_material(10, 4),
		combat = {
			apr = resolvers.mbonus_material(10, 5),
			melee_project={
				[DamageType.SLIME] = resolvers.mbonus_material(15, 3),
				[DamageType.ACID] = resolvers.mbonus_material(24, 4),
			},
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of the nighthunter", suffix=true, instant_resolve=true,
	keywords = {nighthunter=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 80,
	resolvers.charmt(Talents.T_TRACK, 2, 30),
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
		},
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		infravision = resolvers.mbonus_material(3, 1),
		combat_atk = resolvers.mbonus_material(10, 5),
		combat = {
			talent_on_crit = { [Talents.T_DOMINATE] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
			physcrit = resolvers.mbonus_material(10, 3),
			atk = resolvers.mbonus_material(10, 3),
			melee_project={
				[DamageType.DARKNESS] = resolvers.mbonus_material(25, 4),
			},
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "stone warden's ", prefix=true, instant_resolve=true,
	keywords = {stone=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 90,
	wielder = {
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 4),
		},
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_armor = resolvers.mbonus_material(10, 5),
		combat_armor_hardiness = resolvers.mbonus_material(5, 5),
		combat = {
			talent_on_hit = { [Talents.T_STONE_TOUCH] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=5} },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the starseeker", suffix=true, instant_resolve=true,
	keywords = {starseeker=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 90,
	resolvers.charmt(Talents.T_STARFALL, 1, 20),
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
		},
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(5, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(5, 5),
		},
		infravision = resolvers.mbonus_material(1, 1),
		combat = {
			talent_on_hit = { [Talents.T_CIRCLE_OF_BLAZING_LIGHT] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
			melee_project={
				[DamageType.LIGHT] = resolvers.mbonus_material(10, 2),
				[DamageType.DARKNESS] = resolvers.mbonus_material(10, 2),
			},
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of dispersion", suffix=true, instant_resolve=true,
	keywords = {dispersion=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 70,
	resolvers.charmt(Talents.T_DISPERSE_MAGIC, 3, 20),
	wielder = {
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material(7, 3),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(7, 3),
			[Stats.STAT_WIL] = resolvers.mbonus_material(7, 3),
		},
		melee_project = {
			[DamageType.ARCANE] = resolvers.mbonus_material(15, 4),
		},
		combat = {
			melee_project={  [DamageType.ARCANE] = resolvers.mbonus_material(15, 4), },
			talent_on_hit = { [Talents.T_MANATHRUST] = {level=3, chance=10} },
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of regeneration", suffix=true, instant_resolve=true,
	keywords = {regen=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 25,
	wielder = {
		life_regen = resolvers.mbonus_material(45, 15, function(e, v) v=v/10 return 0, v end),
		psi_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
		stamina_regen = resolvers.mbonus_material(10, 3, function(e, v) v=v/10 return 0, v end),
		combat = {
			talent_on_hit = { [Talents.T_SECOND_WIND] = {level=1, chance=10} },
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of sorrow", suffix=true, instant_resolve=true,
	keywords = {sorrow=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 80,
	resolvers.charmt(Talents.T_RUINED_EARTH, 3, 20),
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(10, -15),
		combat_mindpower = resolvers.mbonus_material(7, 3),
		melee_project = {
			[DamageType.MIND] = resolvers.mbonus_material(30, 10),
			[DamageType.DARKNESS] = resolvers.mbonus_material(30, 10),
		},
		combat = {
             burst_on_crit = { [DamageType.RANDOM_GLOOM] = resolvers.mbonus_material(10, 10), },
			 talent_on_hit = { [Talents.T_REPROACH] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the juggernaut", suffix=true, instant_resolve=true,
	keywords = {juggernaut=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.charmt(Talents.T_JUGGERNAUT, {2,3,4}, 30),
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_mentalresist = resolvers.mbonus_material(7, 3),
		combat_physresist = resolvers.mbonus_material(20, 10),
		combat_spellresist = resolvers.mbonus_material(7, 3),
		combat = {
			melee_project={ [DamageType.PHYSICAL] = resolvers.mbonus_material(25, 4), },
			talent_on_hit = { [Talents.T_JUGGERNAUT] = {level=1, chance=10} },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "spellstreaming ", prefix=true, instant_resolve=true,
	keywords = {spellstream=true},
	level_range = {	30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 60,
	wielder = {
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
		combat_spellpower = resolvers.mbonus_material(12, 4),
		combat_spellcrit = resolvers.mbonus_material(7, 3),
		combat = {
			melee_project={  [DamageType.ARCANE] = resolvers.mbonus_material(15, 4), },
			talent_on_hit = { [Talents.T_ELEMENTAL_BOLT] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "heroic ", prefix=true, instant_resolve=true,
	keywords = {heroic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 75,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		max_life=resolvers.mbonus_material(40, 40),
		combat_armor = resolvers.mbonus_material(3, 3),
		combat = {
			dam = resolvers.mbonus_material(7, 3),
			atk = resolvers.mbonus_material(10, 2),
			talent_on_hit = { [Talents.T_BATTLE_SHOUT] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "archer's ", prefix=true, instant_resolve=true,
	keywords = {archer=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 35,
	resolvers.charmt(Talents.T_STEADY_SHOT, 3, 20),
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 2),
		},
		combat_atk = resolvers.mbonus_material(5, 5),
		combat_apr = resolvers.mbonus_material(5, 5),
		combat = {
			apr = resolvers.mbonus_material(5, 5),
			atk = resolvers.mbonus_material(5, 5),
			talent_on_hit = { [Talents.T_PERFECT_STRIKE] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=15} }, -- this is more for brawlers actually
		},
	},
}