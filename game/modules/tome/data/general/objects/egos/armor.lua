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
		resists={[DamageType.FIRE] = resolvers.mbonus_material(30, 10)},
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
		resists={[DamageType.COLD] = resolvers.mbonus_material(30, 10)},
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
		resists={[DamageType.ACID] = resolvers.mbonus_material(30, 10)},
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
		resists={[DamageType.LIGHTNING] = resolvers.mbonus_material(30, 10)},
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
		resists={[DamageType.NATURE] = resolvers.mbonus_material(30, 10)},
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
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		knockback_immune = resolvers.mbonus_material(20, 20, function(e, v) v=v/100 return 0, v end),
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
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 10),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 10),
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
		on_melee_hit={[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 10)},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "searing ", prefix=true, instant_resolve=true,
	keywords = {searing=true},
	level_range = {10, 50},
	rarity = 10,
	cost = 7,
	wielder = {
		melee_project={
			[DamageType.FIRE] = resolvers.mbonus_material(8, 8),
			[DamageType.ACID] = resolvers.mbonus_material(8, 8),
		},
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
		stamina_regen = resolvers.mbonus_material(50, 20, function(e, v) v=v/100 return 0, v end),
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
		melee_project={[DamageType.LIGHT] = resolvers.mbonus_material(10, 4),},
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(20, 10),
			[DamageType.DARKNESS] = resolvers.mbonus_material(20, 10),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
			[Stats.STAT_LCK] = resolvers.mbonus_material(10, 1),
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
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
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
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
		},
		stun_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "anchoring ", prefix=true, instant_resolve=true,
	keywords = {anchor=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
		},
		teleport_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
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
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.NATURE] = resolvers.mbonus_material(10, 5),
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
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 2),
			[Stats.STAT_STR] = resolvers.mbonus_material(5, 2),
		},
		max_life=resolvers.mbonus_material(70, 30),
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
			[DamageType.ACID] = resolvers.mbonus_material(8, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 5),
			[DamageType.COLD] = resolvers.mbonus_material(8, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 5),
		},
		combat_armor = resolvers.mbonus_material(5, 5),
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
		max_life = resolvers.mbonus_material(40, 40),
	},
}



newEntity{
	power_source = {nature=true},
	name = " of the sky", suffix=true, instant_resolve=true,
	keywords = {sky=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 35,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(8, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 5),
			[DamageType.COLD] = resolvers.mbonus_material(8, 5),
		},
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(6, 2),
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
		max_life=resolvers.mbonus_material(60, 40),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
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
		combat_dam = resolvers.mbonus_material(5, 5),
		combat_physcrit = resolvers.mbonus_material(3, 3),
		combat_critical_power = resolvers.mbonus_material(10, 10),
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
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		pin_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		combat_armor = resolvers.mbonus_material(6, 4),
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
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
			[Stats.STAT_STR] = resolvers.mbonus_material(7, 3),
			[Stats.STAT_DEX] = resolvers.mbonus_material(7, 3),
		},
		disarm_immune = resolvers.mbonus_material(25, 15, function(e, v) v=v/100 return 0, v end),
		combat_physresist = resolvers.mbonus_material(15, 5),
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
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		poison_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		disease_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		life_regen = resolvers.mbonus_material(30, 5, function(e, v) v=v/10 return 0, v end),
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
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
			[Stats.STAT_WIL] = resolvers.mbonus_material(7, 3),
		},
		combat_armor = resolvers.mbonus_material(7, 3),
		combat_physcrit = resolvers.mbonus_material(5, 1),
		combat_spellcrit = resolvers.mbonus_material(5, 1),
		combat_atk = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {psionic=true},
	name = "enlightening ", prefix=true, instant_resolve=true,
	keywords = {enlight=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
		},
		blind_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		confusion_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		combat_mentalresist = resolvers.mbonus_material(10, 5),
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
	resolvers.charmt(Talents.T_SECOND_WIND, {3,4,5}, 35),
	wielder = {
		max_life = resolvers.mbonus_material(60, 40, function(e, v) return 0, -v end),
		combat_armor = resolvers.mbonus_material(7, 3, function(e, v) return 0, -v end),

		combat_physcrit = resolvers.mbonus_material(7, 3),
		combat_apr = resolvers.mbonus_material(15, 5),
		combat_def = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of command", suffix=true, instant_resolve=true,
	keywords = {command=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
		},
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_armor = resolvers.mbonus_material(7, 3),
		combat_def = resolvers.mbonus_material(10, 5),
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
	resolvers.charmt(Talents.T_TRACK, 2, 30),
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(6, 4),
		},
		lite = resolvers.mbonus_material(1, 1),
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
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
		combat_armor = resolvers.mbonus_material(5, 1),
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
			[Stats.STAT_STR] = resolvers.mbonus_material(7, 3),
			[Stats.STAT_MAG] = resolvers.mbonus_material(7, 3),
		},
		combat_physcrit = resolvers.mbonus_material(3, 2),
		combat_spellcrit = resolvers.mbonus_material(3, 2),
		combat_dam = resolvers.mbonus_material(7, 3),
	},
}
