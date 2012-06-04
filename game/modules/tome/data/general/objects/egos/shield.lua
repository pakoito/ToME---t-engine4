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
local Talents = require "engine.interface.ActorTalents"

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {technique=true},
	name = " of fire resistance", suffix=true, instant_resolve=true,
	keywords = {fire=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus_material(20, 10)},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of cold resistance", suffix=true, instant_resolve=true,
	keywords = {cold=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material(20, 10)},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of acid resistance", suffix=true, instant_resolve=true,
	keywords = {acid=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus_material(20, 10)},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of lightning resistance", suffix=true, instant_resolve=true,
	keywords = {lightning=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 10)},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of nature resistance", suffix=true, instant_resolve=true,
	keywords = {nature=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus_material(20, 10)},
	},
}

newEntity{
	power_source = {technique=true},
	name = "reinforced ", prefix=true, instant_resolve=true,
	keywords = {reinforced=true},
	level_range = {10, 50},
	rarity = 9,
	cost = 9,
	special_combat = {
		block = resolvers.mbonus_material(80, 20),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "flaming ", prefix=true, instant_resolve=true,
	keywords = {flaming=true},
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.FIRE] = resolvers.mbonus_material(10, 10)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = "icy ", prefix=true, instant_resolve=true,
	keywords = {icy=true},
	level_range = {15, 50},
	rarity = 8,
	cost = 10,
	wielder = {
		on_melee_hit={[DamageType.ICE] = resolvers.mbonus_material(10, 10)},
	},
}
newEntity{
	power_source = {nature=true},
	name = "acidic ", prefix=true, instant_resolve=true,
	keywords = {acidic=true},
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.ACID] = resolvers.mbonus_material(10, 10)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = "shocking ", prefix=true, instant_resolve=true,
	keywords = {shocking=true},
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 10)},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of resilience", suffix=true, instant_resolve=true,
	keywords = {resilience=true},
	level_range = {10, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		max_life=resolvers.mbonus_material(60, 40),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of deflection", suffix=true, instant_resolve=true,
	keywords = {deflection=true},
	level_range = {10, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		combat_def=resolvers.mbonus_material(11, 4),
	},
}

newEntity{
	power_source = {nature=true},
	name = "reflective ", prefix=true, instant_resolve=true,
	keywords = {reflective=true},
	level_range = {10, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 10),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 10),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "brilliant ", prefix=true, instant_resolve=true,
	keywords = {brilliant=true},
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.LIGHT] = resolvers.mbonus_material(10, 10)},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of crushing", suffix=true, instant_resolve=true,
	keywords = {crushing=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 20,
	wielder = {
		pin_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		combat_dam = resolvers.mbonus_material(5, 5),
		combat_physcrit = resolvers.mbonus_material(3, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of resistance", suffix=true, instant_resolve=true,
	keywords = {resistance=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 20,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(8, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 5),
			[DamageType.COLD] = resolvers.mbonus_material(8, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the night", suffix=true, instant_resolve=true,
	keywords = {night=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 20,
	wielder = {
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 10),
		},
		on_melee_hit={[DamageType.DARKNESS] = resolvers.mbonus_material(10, 10)},
		infravision = resolvers.mbonus_material(2, 1),
	},
}

newEntity{
	power_source = {technique=true},
	name = "impervious ", prefix=true, instant_resolve=true,
	keywords = {impervious=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 40,
	special_combat = {
		block = resolvers.mbonus_material(90, 30),
	},
	wielder = {
		combat_armor = resolvers.mbonus_material(8, 4),
		stun_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return 0, v end),
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 3),
			},
	},
}

newEntity{
	power_source = {nature=true},
	name = "spellplated ", prefix=true, instant_resolve=true,
	keywords = {spellplated=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 18,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_spellresist = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 2),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "blood-etched ", prefix=true, instant_resolve=true,
	keywords = {etched=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 30,
	wielder = {
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 3),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "obstinate ", prefix=true, instant_resolve=true,
	keywords = {obstinate=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	encumber = 15,
	wielder = {
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material(7, 3),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
		on_melee_hit = {
			[DamageType.ARCANE] = resolvers.mbonus_material(10, 5),
		},
		melee_project = {
			[DamageType.ARCANE] = resolvers.mbonus_material(10, 5),
		},
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "living ", prefix=true, instant_resolve=true,
	keywords = {living=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(10, 5),
		},
		max_life = resolvers.mbonus_material(70, 40),
		melee_project = {
			[DamageType.NATURE] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "coruscating ", prefix=true, instant_resolve=true,
	keywords = {coruscating=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(5, 1),
		},
		on_melee_hit = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
		},
		melee_project = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "crackling ", prefix=true, instant_resolve=true,
	keywords = {crackling=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(5, 1),
		},
		on_melee_hit = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
		},
		melee_project = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "corrosive ", prefix=true, instant_resolve=true,
	keywords = {corrosive=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		on_melee_hit = {
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
		},
		melee_project = {
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "wintry ", prefix=true, instant_resolve=true,
	keywords = {wintry=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
		},
		on_melee_hit = {
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
		melee_project = {
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of displacement", suffix=true, instant_resolve=true,
	keywords = {displacement=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 40,
	resolvers.charmt(Talents.T_DISPLACEMENT_SHIELD, {2,3,4}, 40),
	wielder = {
		combat_def = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the earth", suffix=true, instant_resolve=true,
	keywords = {earth=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 40,
	resolvers.charmt(Talents.T_EARTHEN_BARRIER, {2,3,4,5}, 40),
	wielder = {
		combat_armor = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the sun", suffix=true, instant_resolve=true,
	keywords = {sun=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 20,
	resolvers.charmt(Talents.T_ILLUMINATE, 2, 6),
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of patience", suffix=true, instant_resolve=true,
	keywords = {patience=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.charmt(Talents.T_TIME_SHIELD, {2,3,4,5}, 30 ),
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
		},
		melee_project = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(7, 3),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of harmony", suffix=true, instant_resolve=true,
	keywords = {harmony=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	resolvers.charmt(Talents.T_WATERS_OF_LIFE, 4, 30),
	wielder = {
		talents_types_mastery = {
			["wild-gift/harmony"] = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of faith", suffix=true, instant_resolve=true,
	keywords = {faith=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 20,
	resolvers.charmt(Talents.T_BARRIER, {2,3,4}, 40),
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
		},
	},
}
