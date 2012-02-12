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
		disarm_bonus = resolvers.mbonus_material("disarm_bonus"),
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
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
		combat_physcrit = resolvers.mbonus_material("combat_physcrit"),
		combat_mindcrit = resolvers.mbonus_material("combat_mindcrit"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of might", suffix=true, instant_resolve=true,
	keywords = {critical=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 25,
	wielder = {
		combat_dam = resolvers.mbonus_material("combat_dam"),
		combat = {
			critical_power = resolvers.mbonus_material("critical_power"),
			dam = resolvers.mbonus_material("dam"),
			talent_on_hit = { [Talents.T_HAYMAKER] = {level=1, chance=10} },
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of precision", suffix=true, instant_resolve=true,
	keywords = {precision=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 5,
	wielder = {
		combat_atk = resolvers.mbonus_material("combat_atk"),
		combat = {
			max_acc = resolvers.mbonus_material("max_acc"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of power", suffix=true, instant_resolve=true,
	keywords = {power=true},
	level_range = {10, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		combat_dam = resolvers.mbonus_material("combat_dam"),
		combat = {
			dam = resolvers.mbonus_material("dam"),
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
		inc_damage={ [DamageType.FIRE] = resolvers.mbonus_material("inc_damage"), },
		resists = { [DamageType.FIRE] = resolvers.mbonus_material("resists"), },
		combat = {
			melee_project={[ DamageType.FIRE] = resolvers.mbonus_material("melee_project") },
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
		inc_damage={ [DamageType.COLD] = resolvers.mbonus_material("inc_damage"), },
		resists = { [DamageType.COLD] = resolvers.mbonus_material("resists"), },
		combat = {
			melee_project={ [DamageType.ICE] = resolvers.mbonus_material("melee_project") },
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
		inc_damage={ [DamageType.ACID] = resolvers.mbonus_material("inc_damage"), },
		resists = { [DamageType.ACID] = resolvers.mbonus_material("resists"), },
		combat = {
			melee_project={ [DamageType.ACID] = resolvers.mbonus_material("melee_project") },
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
		inc_damage={ [DamageType.LIGHTNING] = resolvers.mbonus_material("inc_damage"), },
		resists = { [DamageType.LIGHTNING] = resolvers.mbonus_material("resists"), },
		combat = {
			melee_project={ [DamageType.LIGHTNING] = resolvers.mbonus_material("melee_project") },
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
		inc_damage={ [DamageType.TEMPORAL] = resolvers.mbonus_material("inc_damage"), },
		resists = { [DamageType.TEMPORAL] = resolvers.mbonus_material("resists"), },
		combat = {
			melee_project={ [DamageType.TEMPORAL] = resolvers.mbonus_material("melee_project") },
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
		inc_damage={ [DamageType.NATURE] = resolvers.mbonus_material("inc_damage"), },
		resists = { [DamageType.NATURE] = resolvers.mbonus_material("resists"), },
		combat = {
			melee_project={ [DamageType.SLIME] = resolvers.mbonus_material("melee_project") },
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
		inc_damage={ [DamageType.BLIGHT] = resolvers.mbonus_material("inc_damage"), },
		resists = { [DamageType.BLIGHT] = resolvers.mbonus_material("resists"), },
		combat = {
			melee_project={ [DamageType.BLIGHT] = resolvers.mbonus_material("melee_project") },
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
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material("inc_stats") },
		combat = {
			dam = resolvers.mbonus_material("dam"),
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
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats") },
		combat = {
			max_acc = resolvers.mbonus_material("max_acc"),
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
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats") },
		combat = {
			melee_project={ [DamageType.ARCANE] = resolvers.mbonus_material("melee_project") },
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
		talents_types_mastery = { ["technique/grappling"] = resolvers.mbonus_material("talents_types_mastery")},
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material("inc_stats") },
		disarm_immune = resolvers.mbonus_material("immunity"),
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
			[DamageType.NATURE] = resolvers.mbonus_material("resists"),
		},
		combat_physresist = resolvers.mbonus_material("save", 2),
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
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
			},
		combat_apr = resolvers.mbonus_material("combat_apr"),
		combat = {
			critical_power = resolvers.mbonus_material("critical_power"),
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
		life_regen = resolvers.mbonus_material("life_regen"),
		mana_regen = resolvers.mbonus_material("mana_regen"),
		stamina_regen = resolvers.mbonus_material("stamina_regen"),
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
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
		max_life=resolvers.mbonus_material("max_life"),
		combat_armor = resolvers.mbonus_material("combat_armor"),
		combat = {
			dam = resolvers.mbonus_material("combat_dam"),
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
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
			},
		blind_immune = resolvers.mbonus_material("immunity"),
		confusion_immune = resolvers.mbonus_material("immunity"),
		combat = {
			melee_project={
				[DamageType.FIRE] = resolvers.mbonus_material("melee_project", 0.5),
				[DamageType.ICE] = resolvers.mbonus_material("melee_project", 0.5),
				[DamageType.ACID] = resolvers.mbonus_material("melee_project", 0.5),
				[DamageType.LIGHTNING] = resolvers.mbonus_material("melee_project", 0.5),
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
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		combat_atk = resolvers.mbonus_material("combat_atk"),
		combat = {
			max_acc = resolvers.mbonus_material("max_acc"),
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
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		combat = {
			critical_power = resolvers.mbonus_material("critical_power"),
			physspeed = resolvers.mbonus_material("combat_physspeed"),
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
			[DamageType.PHYSICAL] = resolvers.mbonus_material("rare_resists"),
		},
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats", -1),
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
		},
		combat_armor = resolvers.mbonus_material("combat_armor"),
		combat_atk = resolvers.mbonus_material("combat_atk", -1),
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
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_DISPERSE_MAGIC, level = 3, power = 80 },
	wielder = {
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material("rare_resists"),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats"),
		},
		combat = {
			melee_project={  [DamageType.ARCANE] = resolvers.mbonus_material("melee_project"), },
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
			[DamageType.BLIGHT] = resolvers.mbonus_material("resists"),
		},
		poison_immune = resolvers.mbonus_material("immunity"),
		disease_immune = resolvers.mbonus_material("immunity"),
		combat_dam = resolvers.mbonus_material("combat_dam"),
		combat = {
			melee_project={
				[DamageType.SLIME] = resolvers.mbonus_material("melee_project"),
				[DamageType.ACID] = resolvers.mbonus_material("melee_project"),
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
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_JUGGERNAUT, level = 4, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
		},
		combat_physresist = resolvers.mbonus_material("save"),
		combat_spellresist = resolvers.mbonus_material("save"),
		combat = {
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
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_TRACK, level = 2, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
		},
		combat_atk = resolvers.mbonus_material("combat_atk"),
		combat = {
			max_acc = resolvers.mbonus_material("max_acc"),
			inc_damage_type = {animal=resolvers.mbonus_material("inc_damage_type"),},
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
			[DamageType.DARKNESS] = resolvers.mbonus_material("resists"),
		},
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		blind_immune = resolvers.mbonus_material("immunity"),
		infravision = resolvers.mbonus_material("infravision"),
		combat = {
			melee_project={ [DamageType.DARKNESS] = resolvers.mbonus_material("melee_project"), },
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
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
		},
		combat_spellpower = resolvers.mbonus_material("combat_spellpower"),
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
		combat = {
			melee_project={  [DamageType.ARCANE] = resolvers.mbonus_material("melee_project"), },
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
		learn_talent = {
			[Talents.T_WARD] = resolvers.mbonus_material("learn_talent"),
		},
		wards = {
			[DamageType.ACID] = resolvers.mbonus_material("wards"),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("wards"),
			[DamageType.FIRE] = resolvers.mbonus_material("wards"),
			[DamageType.COLD] = resolvers.mbonus_material("wards"),	
		},
		combat = {
			melee_project={
				[DamageType.FIRE] = resolvers.mbonus_material("melee_project"),
				[DamageType.ICE] = resolvers.mbonus_material("melee_project"),
				[DamageType.ACID] = resolvers.mbonus_material("melee_project"),
				[DamageType.LIGHTNING] = resolvers.mbonus_material("melee_project"),
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
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
		},
		stun_immune = resolvers.mbonus_material("immunity"),
		knockback_immune = resolvers.mbonus_material("immunity"),
		pin_immune = resolvers.mbonus_material("immunity"),
		combat = {
			critical_power = resolvers.mbonus_material("critical_power"),
			talent_on_hit = { [Talents.T_SET_UP] = {level=1, chance=10} },
		},
	},
}