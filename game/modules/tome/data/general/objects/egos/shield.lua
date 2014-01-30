-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

-- resists... shields are very good at providing resists
newEntity{
	power_source = {technique=true},
	name = " of fire resistance (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {fire=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus_material(15, 15)},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of cold resistance (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {cold=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material(15, 15)},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of acid resistance (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {acid=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus_material(15, 15)},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of lightning resistance (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {lightning=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 15)},
	},
}
-- rare resists
newEntity{
	power_source = {antimagic=true},
	name = " of arcane resistance (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {arcane=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 4,
	wielder = {
		resists={[DamageType.ARCANE] = resolvers.mbonus_material(10, 10)},
	},
}
newEntity{
	power_source = {psionic=true},
	name = " of mind resistance (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {mind=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 4,
	wielder = {
		resists={[DamageType.MIND] = resolvers.mbonus_material(10, 10)},
	},
}
newEntity{
	power_source = {technique=true},
	name = " of physical resistance (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {physical=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 4,
	wielder = {
		resists={[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 10)},
	},
}
newEntity{
	power_source = {nature=true},
	name = " of purity", suffix=true, instant_resolve=true,
	keywords = {purity=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 10,
	wielder = {
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(10, 10),
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 10),
		},
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of reflection", suffix=true, instant_resolve=true,
	keywords = {reflection=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 10,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 10),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 10),
		},
	},
}
newEntity{
	power_source = {nature=true},
	name = " of temporal resistance (#RESIST#)", suffix=true, instant_resolve=true,
	keywords = {temporal=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 4,
	wielder = {
		resists={[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 10)},
	},
}
newEntity{
	power_source = {nature=true},
	name = " of resistance", suffix=true, instant_resolve=true,
	keywords = {resistance=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 24,
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
-- retalation/melee_project shields
newEntity{
	power_source = {nature=true},
	name = "flaming ", prefix=true, instant_resolve=true,
	keywords = {flaming=true},
	level_range = {10, 50},
	rarity = 8,
	cost = 8,
	special_combat = {
		burst_on_hit={[DamageType.FIRE] = resolvers.mbonus_material(10, 10)},
	},
	wielder = {
		on_melee_hit={[DamageType.FIRE] = resolvers.mbonus_material(10, 10)},
		melee_project={
			[DamageType.FIRE] = resolvers.mbonus_material(5, 5),
	},
	},
}
newEntity{
	power_source = {nature=true},
	name = "icy ", prefix=true, instant_resolve=true,
	keywords = {icy=true},
	level_range = {10, 50},
	rarity = 8,
	cost = 10,
	special_combat = {
		melee_project={[DamageType.ICE] = resolvers.mbonus_material(10, 10)},
	},
	wielder = {
		on_melee_hit={[DamageType.COLD] = resolvers.mbonus_material(10, 10)},
		melee_project={
			[DamageType.COLD] = resolvers.mbonus_material(5, 5),
	},
	},
}
newEntity{
	power_source = {nature=true},
	name = "shocking ", prefix=true, instant_resolve=true,
	keywords = {shocking=true},
	level_range = {10, 50},
	rarity = 8,
	cost = 8,
	special_combat = {
		melee_project={[DamageType.LIGHTNING_DAZE] = resolvers.mbonus_material(10, 10)},
	},
	wielder = {
		on_melee_hit={[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 10)},
		melee_project={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(5, 5),
	},
	},
}
newEntity{
	power_source = {nature=true},
	name = "acidic ", prefix=true, instant_resolve=true,
	keywords = {acidic=true},
	level_range = {10, 50},
	rarity = 8,
	cost = 8,
	special_combat = {
		melee_project={[DamageType.ACID_BLIND] = resolvers.mbonus_material(10, 10)},
	},
	wielder = {
		on_melee_hit={[DamageType.ACID] = resolvers.mbonus_material(10, 10)},
		melee_project={
			[DamageType.ACID] = resolvers.mbonus_material(5, 5),
	},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of gloom", suffix=true, instant_resolve=true,
	keywords = {gloom=true},
	level_range = {10, 50},
	rarity = 14,
	cost = 12,
	special_combat = {
		melee_project={[DamageType.RANDOM_GLOOM] = resolvers.mbonus_material(7, 7)},
	},
	wielder = {
		on_melee_hit={[DamageType.RANDOM_GLOOM] = resolvers.mbonus_material(10, 10)},
		melee_project={
			[DamageType.RANDOM_GLOOM] = resolvers.mbonus_material(5, 5),
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
	special_combat = {
		melee_project = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 10),
		},
	},
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 10),
		},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(5, 1),
		},
		on_melee_hit = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 10),
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
	special_combat = {
		melee_project = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 10),
		},
	},
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 10),
		},
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(5, 1),
		},
		on_melee_hit = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 10),
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
	special_combat = {
		melee_project = {
			[DamageType.ACID] = resolvers.mbonus_material(10, 10),
		},
	},
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(10, 10),
		},
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		on_melee_hit = {
			[DamageType.ACID] = resolvers.mbonus_material(10, 10),
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
	special_combat = {
		melee_project = {
			[DamageType.COLD] = resolvers.mbonus_material(10, 10),
		},
	},
	wielder = {
		resists={
			[DamageType.COLD] = resolvers.mbonus_material(10, 10),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
		},
		on_melee_hit = {
			[DamageType.COLD] = resolvers.mbonus_material(10, 10),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "living ", prefix=true, instant_resolve=true,
	keywords = {living=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	special_combat = {
		melee_project = {
			[DamageType.NATURE] = resolvers.mbonus_material(10, 10),
		},
	},
	wielder = {
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(10, 10),
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 10),
		},
		max_life = resolvers.mbonus_material(70, 40),
		on_melee_hit = {
			[DamageType.NATURE] = resolvers.mbonus_material(10, 10),
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of the forge", suffix=true, instant_resolve=true,
	keywords = {forge=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 28,
	cost = 60,
	special_combat = {
		melee_project={[DamageType.DREAMFORGE] = resolvers.mbonus_material(10, 10)},
	},
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 3),
		},
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 10),
			[DamageType.MIND] = resolvers.mbonus_material(10, 10),
		},
		on_melee_hit = {[DamageType.DREAMFORGE] = resolvers.mbonus_material(10, 10)},
		psi_regen_when_hit = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of patience", suffix=true, instant_resolve=true,
	keywords = {patience=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	resolvers.charmt(Talents.T_TIME_SHIELD, {2,3,4,5}, 30 ),
	special_combat = {
		melee_project={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 10)
		},
	},
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 10),
		},
		on_melee_hit = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 10),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the sun", suffix=true, instant_resolve=true,
	keywords = {sun=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	resolvers.charmt(Talents.T_SUN_FLARE, 2, 20),
	special_combat = {
		melee_project={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 10)
		},
	},
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		on_melee_hit={[DamageType.LIGHT] = resolvers.mbonus_material(10, 10)},
	},
}

-- The rest
newEntity{
	power_source = {technique=true},
	name = "reinforced ", prefix=true, instant_resolve=true,
	keywords = {reinforced=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	special_combat = {
		block = resolvers.mbonus_material(80, 20),
	},
	wielder = {
		combat_armor = resolvers.mbonus_material(8, 4),
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
		combat_physresist = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 3),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "spellplated ", prefix=true, instant_resolve=true,
	keywords = {spellplated=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
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
		life_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/10 return 0, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 3),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of crushing", suffix=true, instant_resolve=true,
	keywords = {crushing=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 24,
	cost = 20,
	special_combat = {
		dam = resolvers.mbonus_material(5, 5),
	},
	wielder = {
		combat_dam = resolvers.mbonus_material(5, 5),
		combat_physcrit = resolvers.mbonus_material(3, 3),
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
	power_source = {arcane=true},
	name = " of displacement", suffix=true, instant_resolve=true,
	keywords = {displacement=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 40,
	resolvers.charmt(Talents.T_DISPLACEMENT_SHIELD, {2,3,4}, 40),
	special_combat = {
		melee_project={
			[DamageType.ARCANE] = resolvers.mbonus_material(10, 10)
		},
	},
	wielder = {
		combat_def = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the earth", suffix=true, instant_resolve=true,
	keywords = {earth=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 40,
	resolvers.charmt(Talents.T_STONE_WALL, {2,3,4,5}, 40),
	special_combat = {
		melee_project={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 10)
		},
	},
	wielder = {
		combat_armor = resolvers.mbonus_material(10, 5),
		combat_armor_hardiness = resolvers.mbonus_material(5, 5),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of harmony", suffix=true, instant_resolve=true,
	keywords = {harmony=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 14,
	cost = 12,
	resolvers.charmt(Talents.T_WATERS_OF_LIFE, 4, 30),
	wielder = {
		talents_types_mastery = {
			["wild-gift/harmony"] = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return 0, v end),
		},
		healing_factor = resolvers.mbonus_material(10, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of faith", suffix=true, instant_resolve=true,
	keywords = {faith=true},
	level_range = {10, 50},
	rarity = 14,
	cost = 12,
	resolvers.charmt(Talents.T_BARRIER, {2,3,4}, 40),
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
		},
	},
}