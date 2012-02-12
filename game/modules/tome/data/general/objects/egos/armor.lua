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

local Talents = require("engine.interface.ActorTalents")
local Stats = require "engine.interface.ActorStats"

newEntity{
	power_source = {technique=true},
	name = " of fire resistance", suffix=true, instant_resolve=true,
	keywords = {['fire res']=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus_material("resists")},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of cold resistance", suffix=true, instant_resolve=true,
	keywords = {['cold res']=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material("resists")},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of acid resistance", suffix=true, instant_resolve=true,
	keywords = {['acid res']=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus_material("resists")},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of lightning resistance", suffix=true, instant_resolve=true,
	keywords = {['lightning res']=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus_material("resists")},
	},
}
newEntity{
	power_source = {nature=true},
	name = " of nature resistance", suffix=true, instant_resolve=true,
	keywords = {['nature res']=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus_material("nature")},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of stability", suffix=true, instant_resolve=true,
	keywords = {stable=true},
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		stun_immune = resolvers.mbonus_material("immunity"),
		knockback_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {nature=true},
	name = "prismatic ", prefix=true, instant_resolve=true,
	keywords = {primatic=true},
	level_range = {10, 50},
	rarity = 10,
	cost = 7,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material("resists"),
			[DamageType.DARKNESS] = resolvers.mbonus_material("resists"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "spiked ", prefix=true, instant_resolve=true,
	keywords = {spiked=true},
	level_range = {5, 50},
	rarity = 6,
	cost = 7,
	wielder = {
		on_melee_hit={[DamageType.PHYSICAL] = resolvers.mbonus_material("on_melee_hit")},
	},
}

newEntity{
	power_source = {nature=true},
	name = "rejuvenating ", prefix=true, instant_resolve=true,
	keywords = {rejuv=true},
	level_range = {15, 50},
	rarity = 10,
	cost = 15,
	wielder = {
		stamina_regen = resolvers.mbonus_material("stamina_regen", 2),
	},
}

newEntity{
	power_source = {nature=true},
	name = "radiant ", prefix=true, instant_resolve=true,
	keywords = {radiant=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 15,
	wielder = {
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material("resists"),
			[DamageType.DARKNESS] = resolvers.mbonus_material("resists"),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_LCK] = resolvers.mbonus_material("inc_stats"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "insulating ", prefix=true, instant_resolve=true,
	keywords = {insulate=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
	},
}



newEntity{
	power_source = {technique=true},
	name = "grounding ", prefix=true, instant_resolve=true,
	keywords = {ground=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material("resists"),
		},
		stun_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "anchoring ", prefix=true, instant_resolve=true,
	keywords = {anchor=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material("resists"),
		},
		teleport_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {nature=true},
	name = "cleansing ", prefix=true, instant_resolve=true,
	keywords = {cleansing=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
			[DamageType.POISON] = resolvers.mbonus_material("resists"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "fortifying ", prefix=true, instant_resolve=true,
	keywords = {['fortif.']=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 35,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
		},
		max_life=resolvers.mbonus_material("max_life"),
	},
}


newEntity{
	power_source = {technique=true},
	name = "hardened ", prefix=true, instant_resolve=true,
	keywords = {hardened=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 29,
	cost = 47,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
		combat_armor = resolvers.mbonus_material("combat_armor"),
	},
}



newEntity{
	power_source = {nature=true},
	name = " of resilience", suffix=true, instant_resolve=true,
	keywords = {resilience=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		max_life = resolvers.mbonus_material("max_life", 2),
	},
}



newEntity{
	power_source = {arcane=true},
	name = " of the sky", suffix=true, instant_resolve=true,
	keywords = {sky=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 35,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of Eyal", suffix=true, instant_resolve=true,
	keywords = {eyal=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 30,
	wielder = {
		max_life=resolvers.mbonus_material("max_life"),
		life_regen = resolvers.mbonus_material("life_regen"),
		healing_factor = resolvers.mbonus_material("healing_factor"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of Toknor", suffix=true, instant_resolve=true,
	keywords = {toknor=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 30,
	wielder = {
		combat_dam = resolvers.mbonus_material("combat_dam", 2),
		combat_physcrit = resolvers.mbonus_material("combat_physcrit"),
		--combat_critical_power = resolvers.mbonus_material("combat_critical_power"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of implacability", suffix=true, instant_resolve=true,
	keywords = {['implac.']=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 30,
	wielder = {
		stun_immune = resolvers.mbonus_material("immunity"),
		pin_immune = resolvers.mbonus_material("immunity"),
		combat_armor = resolvers.mbonus_material("combat_armor"),
		fatigue = resolvers.mbonus_material("fatigue"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "marauder's ", prefix=true, instant_resolve=true,
	keywords = {marauder=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
		},
		disarm_immune = resolvers.mbonus_material("immunity"),
		combat_physresist = resolvers.mbonus_material("save"),
	},
}

newEntity{
	power_source = {nature=true},
	name = "verdant ", prefix=true, instant_resolve=true,
	keywords = {verdant=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
		},
		poison_immune = resolvers.mbonus_material("immunity"),
		disease_immune = resolvers.mbonus_material("immunity"),
		life_regen = resolvers.mbonus_material("life_regen"),
		fatigue = resolvers.mbonus_material("fatigue"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "sunsealed ", prefix=true, instant_resolve=true,
	keywords = {sunseal=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 80,
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
		},
		combat_armor = resolvers.mbonus_material("combat_armor"),
		combat_physcrit = resolvers.mbonus_material("combat_physcrit"),
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
		combat_atk = resolvers.mbonus_material("combat_atk"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "enlightening ", prefix=true, instant_resolve=true,
	keywords = {enlight=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		blind_immune = resolvers.mbonus_material("immunity"),
		confusion_immune = resolvers.mbonus_material("immunity"),
		combat_mentalresist = resolvers.mbonus_material("save"),
		combat_spellresist = resolvers.mbonus_material("save"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the wind", suffix=true, instant_resolve=true,
	keywords = {wind=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 80,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_SECOND_WIND, level = 5, power = 80 },
	wielder = {
		max_life = resolvers.mbonus_material("max_life", -1),
		combat_armor = resolvers.mbonus_material("combat_armor", -1),

		combat_physcrit = resolvers.mbonus_material("combat_physcrit"),
		combat_apr = resolvers.mbonus_material("combat_apr"),
		combat_def = resolvers.mbonus_material("combat_def", 2),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of command", suffix=true, instant_resolve=true,
	keywords = {command=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		combat_mentalresist = resolvers.mbonus_material("save"),
		combat_armor = resolvers.mbonus_material("combat_armor"),
		combat_def = resolvers.mbonus_material("combat_def"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of delving", suffix=true, instant_resolve=true,
	keywords = {delving=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 60,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_TRACK, level = 2, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
		},
		lite = resolvers.mbonus_material("lite"),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the deep", suffix=true, instant_resolve=true,
	keywords = {deep=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 90,
	cost = 20,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
		combat_armor = resolvers.mbonus_material("combat_armor"),
		can_breath = {water=1},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of thunder", suffix=true, instant_resolve=true,
	keywords = {thunder=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 100,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats"),
		},
		combat_physcrit = resolvers.mbonus_material("combat_physcrit"),
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
		combat_dam = resolvers.mbonus_material("combat_dam"),
	},
}
