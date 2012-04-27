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
local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"
local Talents = require("engine.interface.ActorTalents")

newEntity{
	power_source = {technique=true},
	name = " of disarming", suffix=true, instant_resolve=true,
	keywords = {disarm=true},
	level_range = {10, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		disarm_bonus = resolvers.mbonus_material(25, 5),
		combat = {
			talent_on_hit = { [Talents.T_DISARM] = {level=2, chance=10} },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of criticals", suffix=true, instant_resolve=true,
	keywords = {crits=true},
	level_range = {20, 50},
	rarity = 9,
	cost = 15,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(15, 5),
		combat_physcrit = resolvers.mbonus_material(15, 5),
		combat = {
			physcrit = resolvers.mbonus_material(10, 4),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of mighty criticals", suffix=true, instant_resolve=true,
	keywords = {critical=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 25,
	wielder = {
		combat_critical_power = resolvers.mbonus_material(35, 5),
		combat = {
			physcrit = resolvers.mbonus_material(10, 4),
			dam = resolvers.mbonus_material(7, 3),
			talent_on_hit = { [Talents.T_HAYMAKER] = {level=1, chance=10} },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of attack", suffix=true, instant_resolve=true,
	keywords = {attack=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 5,
	wielder = {
		combat_atk = resolvers.mbonus_material(15, 10),
		combat = {
			atk = resolvers.mbonus_material(10, 4),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of damage", suffix=true, instant_resolve=true,
	keywords = {damage=true},
	level_range = {10, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		combat_dam = resolvers.mbonus_material(15, 5),
		combat = {
			dam = resolvers.mbonus_material(7, 3),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "cinder ", prefix=true, instant_resolve=true,
	keywords = {cinder=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.FIRE] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.FIRE] = resolvers.mbonus_material(5, 5), },
		combat = {
			melee_project={[ DamageType.FIRE] = resolvers.mbonus_material(25, 4) },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "polar ", prefix=true, instant_resolve=true,
	keywords = {polar=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.COLD] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.COLD] = resolvers.mbonus_material(5, 5), },
		combat = {
			melee_project={ [DamageType.ICE] = resolvers.mbonus_material(15, 4) },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "corrosive ", prefix=true, instant_resolve=true,
	keywords = {corrosive=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.ACID] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.ACID] = resolvers.mbonus_material(5, 5), },
		combat = {
			melee_project={ [DamageType.ACID] = resolvers.mbonus_material(25, 4) },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "charged ", prefix=true, instant_resolve=true,
	keywords = {charged=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHTNING] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.LIGHTNING] = resolvers.mbonus_material(5, 5), },
		combat = {
			melee_project={ [DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4) },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "temporal ", prefix=true, instant_resolve=true,
	keywords = {temporal=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.TEMPORAL] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.TEMPORAL] = resolvers.mbonus_material(5, 5), },
		combat = {
			melee_project={ [DamageType.TEMPORAL] = resolvers.mbonus_material(15, 4) },
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "naturalist's ", prefix=true, instant_resolve=true,
	keywords = {naturalist=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.NATURE] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.NATURE] = resolvers.mbonus_material(5, 5), },
		combat = {
			melee_project={ [DamageType.SLIME] = resolvers.mbonus_material(25, 4) },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "blighted ", prefix=true, instant_resolve=true,
	keywords = {blighted=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.BLIGHT] = resolvers.mbonus_material(8, 3), },
		resists = { [DamageType.BLIGHT] = resolvers.mbonus_material(5, 5), },
		combat = {
			melee_project={ [DamageType.BLIGHT] = resolvers.mbonus_material(25, 4) },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "powerful ", prefix=true, instant_resolve=true,
	keywords = {powerful=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = resolvers.mbonus_material(8, 3), },
		combat = {
			melee_project={ [DamageType.PHYSICAL] = resolvers.mbonus_material(25, 4) },
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
		combat = {
			dam = resolvers.mbonus_material(5, 1),
			melee_project={ [DamageType.PHYSICAL] = resolvers.mbonus_material(15, 4) },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of dexterity (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {dex=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(4, 2) },
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
		combat = {
			melee_project={ [DamageType.ARCANE] = resolvers.mbonus_material(15, 4) },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of iron grip", suffix=true, instant_resolve=true,
	keywords = {grip=true},
	level_range = {20, 50},
	rarity = 9,
	cost = 15,
	wielder = {
		talents_types_mastery = { ["technique/grappling"] = 0.2},
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(2, 2) },
		disarm_immune = resolvers.mbonus_material(4, 4, function(e, v) v=v/10 return 0, v end),
		combat = {
			talent_on_hit = { [Talents.T_MAIM] = {level=2, chance=10} },
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of protection", suffix=true, instant_resolve=true,
	keywords = {protection=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 25,
	wielder = {
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(5, 5),
		},
		combat_mentalresist = resolvers.mbonus_material(7, 3),
		combat_physresist = resolvers.mbonus_material(7, 3),
		combat_spellresist = resolvers.mbonus_material(7, 3),
		combat = {
			talent_on_hit = { [Talents.T_HEALING_NEXUS] = {level=1, chance=10} },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of warmaking", suffix=true, instant_resolve=true,
	keywords = {warmaking=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 35,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 2),
			},
		combat_apr = resolvers.mbonus_material(4, 4),
		combat = {
			physcrit = resolvers.mbonus_material(10, 4),
			melee_project={ [DamageType.PHYSICAL] = resolvers.mbonus_material(25, 4) },
			talent_on_hit = { [Talents.T_BATTLE_CALL] = {level=1, chance=10} },
		},
	},

}

newEntity{
	power_source = {technique=true},
	name = " of regeneration", suffix=true, instant_resolve=true,
	keywords = {regen=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 25,
	wielder = {
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
		stamina_regen = resolvers.mbonus_material(10, 3, function(e, v) v=v/10 return 0, v end),
		combat = {
			talent_on_hit = { [Talents.T_SECOND_WIND] = {level=1, chance=10} },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "heroic ", prefix=true, instant_resolve=true,
	keywords = {heroic=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 75,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
		max_life=resolvers.mbonus_material(40, 40),
		combat_armor = resolvers.mbonus_material(3, 3),
		combat = {
			dam = resolvers.mbonus_material(7, 3),
			atk = resolvers.mbonus_material(10, 2),
			talent_on_hit = { [Talents.T_BATTLE_SHOUT] = {level=1, chance=10} },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "alchemist's ", prefix=true, instant_resolve=true,
	keywords = {alchemist=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 35,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 2),
			},
		blind_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		confusion_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		combat = {
			melee_project={
				[DamageType.FIRE] = resolvers.mbonus_material(25, 4),
				[DamageType.ICE] = resolvers.mbonus_material(15, 4),
				[DamageType.ACID] = resolvers.mbonus_material(25, 4),
				[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4),
			},
			talent_on_hit = { [Talents.T_STONE_TOUCH] = {level=1, chance=10} },
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
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 2),
		},
		combat_atk = resolvers.mbonus_material(5, 5),
		combat = {
			apr = resolvers.mbonus_material(8, 1),
			atk = resolvers.mbonus_material(10, 2),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "brawler's ", prefix=true, instant_resolve=true,
	keywords = {brawler=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 75,
	wielder = {
		talent_cd_reduction={ [Talents.T_DOUBLE_STRIKE]=1,	},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 2),
		},
		combat = {
			physcrit = resolvers.mbonus_material(10, 4),
			atk = resolvers.mbonus_material(10, 2),
			physspeed = -0.1,
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of imperviousness", suffix=true, instant_resolve=true,
	keywords = {impervious=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 90,
	wielder = {
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(7, 3),
		},
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(5, 1, function(e, v) return 0, -v end),
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_armor = resolvers.mbonus_material(7, 3),
		combat_atk = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),
		combat = {
			talent_on_hit = { [Talents.T_UNSTOPPABLE] = {level=1, chance=5} },
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
	resolvers.charmt(Talents.T_DISPERSE_MAGIC, 3, 50),
	wielder = {
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material(7, 3),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(7, 3),
		},
		combat = {
			melee_project={  [DamageType.ARCANE] = resolvers.mbonus_material(15, 4), },
			talent_on_hit = { [Talents.T_MANATHRUST] = {level=3, chance=10} },
		},
	},
}

newEntity{
	power_source = {nature=true},
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
		poison_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		disease_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		combat_atk = resolvers.mbonus_material(7, 3),
		combat_dam = resolvers.mbonus_material(7, 1),
		combat = {
			melee_project={
				[DamageType.SLIME] = resolvers.mbonus_material(15, 3),
				[DamageType.ACID] = resolvers.mbonus_material(24, 4),
			},
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the juggernaut", suffix=true, instant_resolve=true,
	keywords = {juggernaut=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.charmt(Talents.T_JUGGERNAUT, {2,3,4}, 80),
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_mentalresist = resolvers.mbonus_material(7, 3),
		combat_physresist = resolvers.mbonus_material(7, 3),
		combat_spellresist = resolvers.mbonus_material(7, 3),
		combat = {
			melee_project={ [DamageType.PHYSICAL] = resolvers.mbonus_material(25, 4), },
			talent_on_hit = { [Talents.T_JUGGERNAUT] = {level=1, chance=10} },
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the beastfinder", suffix=true, instant_resolve=true,
	keywords = {beastfinder=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 80,
	resolvers.charmt(Talents.T_TRACK, 2, 30),
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(5, 1),
		},
		combat_atk = resolvers.mbonus_material(7, 3),
		combat = {
			physcrit = resolvers.mbonus_material(8, 4),
			atk = resolvers.mbonus_material(8, 4),
			inc_damage_type = {animal=25},
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "nightfighting ", prefix=true, instant_resolve=true,
	keywords = {nightfight=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
		},
		blind_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		infravision = resolvers.mbonus_material(1, 1),
		combat = {
			melee_project={ [DamageType.DARKNESS] = resolvers.mbonus_material(25, 4), },
			talent_on_hit = { [Talents.T_SHADOWSTEP] = {level=3, chance=10} },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "spellstreaming ", prefix=true, instant_resolve=true,
	keywords = {spellstream=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
		},
		combat_spellpower = resolvers.mbonus_material(7, 1),
		combat_spellcrit = resolvers.mbonus_material(4, 1),
		combat = {
			melee_project={  [DamageType.ARCANE] = resolvers.mbonus_material(15, 4), },
			talent_on_hit = { [Talents.T_ELEMENTAL_BOLT] = {level=3, chance=10} },
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "elemental ", prefix=true, instant_resolve=true,
	keywords = {elemental=true},
	level_range = {45, 50},
	greater_ego = 1,
	rarity = 50,
	cost = 100,
	wielder = {
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
	name = "contortionist's ", prefix=true, instant_resolve=true,
	keywords = {contortion=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(7, 3),
		},
		stun_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		knockback_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		pin_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		combat = {
			melee_project={ [DamageType.PHYSICAL] = resolvers.mbonus_material(25, 4), },
			talent_on_hit = { [Talents.T_SET_UP] = {level=1, chance=10} },
		},
	},
}