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
	level_range = {10, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		disarm_bonus = resolvers.mbonus_material(25, 5, function(e, v) return v * 1.2 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of criticals", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 9,
	cost = 15,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(15, 5, function(e, v) return v * 1.4 end),
		combat_physcrit = resolvers.mbonus_material(15, 5, function(e, v) return v * 1.4 end),
		combat = {
			physcrit = resolvers.mbonus_material(10, 4, function(e, v) return v * 0.4 end),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of mighty criticals", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 25,
	wielder = {
		combat_critical_power = resolvers.mbonus_material(35, 5, function(e, v) return v * 2, v end),
		combat = {
			physcrit = resolvers.mbonus_material(10, 4, function(e, v) return v * 0.4 end),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of attack", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 5,
	wielder = {
		combat_atk = resolvers.mbonus_material(15, 10, function(e, v) return v * 1 end),
		combat = {
			atk = resolvers.mbonus_material(10, 4, function(e, v) return v * 0.4 end),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of damage", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		combat_dam = resolvers.mbonus_material(15, 5, function(e, v) return v * 3 end),
		combat = {
			dam = resolvers.mbonus_material(7, 3, function(e, v) return v * 3 end),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "cinder ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.FIRE] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
		resists = { [DamageType.FIRE] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end), },
		combat = {
			melee_project={[DamageType.FIRE] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.64 end)},
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "polar ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.COLD] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
		resists = { [DamageType.COLD] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end), },
		combat = {
			melee_project={[DamageType.ICE] = resolvers.mbonus_material(15, 4, function(e, v) return v * 0.64 end)},
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "corrosive ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.ACID] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
		resists = { [DamageType.ACID] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end), },
		combat = {
			melee_project={[DamageType.ACID] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.64 end)},
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "charged ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHTNING] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
		resists = { [DamageType.LIGHTNING] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end), },
		combat = {
			melee_project={[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.64 end)},
		},
	},
}
newEntity{
	power_source = {arcane=true},
	name = "temporal ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.TEMPORAL] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
		resists = { [DamageType.TEMPORAL] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end), },
		combat = {
			melee_project={[DamageType.TEMPORAL] = resolvers.mbonus_material(15, 4, function(e, v) return v * 0.64 end)},
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "naturalist ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.NATURE] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
		resists = { [DamageType.NATURE] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end), },
		combat = {
			melee_project={[DamageType.SLIME] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.64 end)},
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "blighted ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.BLIGHT] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
		resists = { [DamageType.BLIGHT] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end), },
		combat = {
			melee_project={[DamageType.BLIGHT] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.64 end)},
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "powerful ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
		combat = {
			dam = resolvers.mbonus_material(7, 3, function(e, v) return v * 3 end),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of strength (#STATBONUS#)", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end) },
		combat = {
			dam = resolvers.mbonus_material(7, 3, function(e, v) return v * 3 end),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of dexterity (#STATBONUS#)", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	unarmed_combat = {
		physcrit = resolvers.mbonus_material(10, 4, function(e, v) return v * 0.4 end),
	},
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end) },
		combat = {
			physcrit = resolvers.mbonus_material(10, 4, function(e, v) return v * 0.4 end),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of magic (#STATBONUS#)", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end) },
	},
}

newEntity{
	power_source = {technique=true},
	name = " of iron grip", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 9,
	cost = 15,
	wielder = {
		talent_cd_reduction={[Talents.T_CLINCH]=2},
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end) },
		disarm_immune = resolvers.mbonus_material(4, 4, function(e, v) v=v/10 return v * 8, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of protection", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 25,
	wielder = {
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
		},
		combat_mentalresist = resolvers.mbonus_material(7, 3),
		combat_physresist = resolvers.mbonus_material(7, 3),
		combat_spellresist = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of warmaking", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 35,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 2, function(e, v) return v * 3 end),
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 2, function(e, v) return v * 3 end),
			},
		combat_apr = resolvers.mbonus_material(4, 4, function(e, v) return v * 0.3 end),
		combat = {
			physcrit = resolvers.mbonus_material(10, 4, function(e, v) return v * 0.4 end),
			atk = resolvers.mbonus_material(10, 2, function(e, v) return v * 0.3 end),
		},
	},

}

newEntity{
	power_source = {technique=true},
	name = " of regeneration", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 25,
	wielder = {
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return v * 10, v end),
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return v * 80, v end),
		stamina_regen = resolvers.mbonus_material(10, 3, function(e, v) v=v/10 return v * 10, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "heroic ", prefix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 75,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		max_life=resolvers.mbonus_material(40, 40, function(e, v) return v * 0.1 end),
		combat_armor = resolvers.mbonus_material(3, 3, function(e, v) return v * 1 end),
		combat = {
			dam = resolvers.mbonus_material(7, 3, function(e, v) return v * 0.3 end),
			atk = resolvers.mbonus_material(10, 2, function(e, v) return v * 0.3 end),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "alchemist's ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 35,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 2, function(e, v) return v * 3 end),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 2, function(e, v) return v * 3 end),
			},
		blind_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		confusion_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
	},

}

newEntity{
	power_source = {technique=true},
	name = "archer's ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 35,
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 2, function(e, v) return v * 3 end),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 2, function(e, v) return v * 3 end),
			},
		combat_atk = resolvers.mbonus_material(5, 5, function(e, v) return v * 1 end),
		combat = {
			apr = resolvers.mbonus_material(8, 1, function(e, v) return v * 0.3 end),
			atk = resolvers.mbonus_material(10, 2, function(e, v) return v * 0.3 end),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "brawler's ", prefix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 75,
	wielder = {
		talent_cd_reduction={ [Talents.T_DOUBLE_STRIKE]=1,	},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 2, function(e, v) return v * 3 end),
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 2, function(e, v) return v * 3 end),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 2, function(e, v) return v * 3 end),
		},
		combat = {
			physcrit = resolvers.mbonus_material(10, 4, function(e, v) return v * 0.4 end),
			atk = resolvers.mbonus_material(10, 2, function(e, v) return v * 0.3 end),
			physspeed = -0.1,
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of imperviousness", suffix=true, instant_resolve=true,
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
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of dispersion", suffix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 70,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_DISPERSE_MAGIC, level = 4, power = 80 },
	wielder = {
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material(7, 3),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(7, 3),
		},
	},	
}

newEntity{
	power_source = {nature=true},
	name = " of butchering", suffix=true, instant_resolve=true,
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
	},	
}

newEntity{
	power_source = {technique=true},
	name = " of the juggernaut", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_JUGGERNAUT, level = 4, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_mentalresist = resolvers.mbonus_material(7, 3),
		combat_physresist = resolvers.mbonus_material(7, 3),
		combat_spellresist = resolvers.mbonus_material(7, 3),
	},	
}

newEntity{
	power_source = {nature=true},
	name = " of the beastfinder", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 80,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_TRACK, level = 2, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(5, 1),
		},
		combat_atk = resolvers.mbonus_material(7, 3),
	},	
}

newEntity{
	power_source = {nature=true},
	name = "leeching ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 40,
	wielder = {
	
		resource_leech_chance = resolvers.mbonus_material(10, 5),
		resource_leech_value = resolvers.mbonus_material(1, 1),
		life_regen = resolvers.mbonus_material(12, 3, function(e, v) v=v/10 return 0, -v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, -v end),
	},	
}

newEntity{
	power_source = {technique=true},
	name = "nightfighting ", prefix=true, instant_resolve=true,
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
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "spellstreaming ", prefix=true, instant_resolve=true,
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
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "elemental ", prefix=true, instant_resolve=true,
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
	},	
}

newEntity{
	power_source = {technique=true},
	name = "contortionist's ", prefix=true, instant_resolve=true,
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
	},	
}