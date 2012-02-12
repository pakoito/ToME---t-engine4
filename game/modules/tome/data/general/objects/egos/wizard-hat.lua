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
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {technique=true},
	name = " of absorption", suffix=true, instant_resolve=true,
	keywords = {absorb=true},
	level_range = {20, 50},
	rarity = 10,
	cost = 20,
	wielder = {
		stamina_regen_on_hit = resolvers.mbonus_material("stamina_regen_on_hit"),
		equilibrium_regen_on_hit = resolvers.mbonus_material("equilibrium_regen_on_hit"),
		mana_regen_on_hit = resolvers.mbonus_material("mana_regen_on_hit"),
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
	},
}
newEntity{
	power_source = {nature=true},
	name = " of willpower (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {will=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats") },
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of cunning (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {cun=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats") },
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of telepathic range", suffix=true,
	keywords = {range=true},
	level_range = {40, 50},
	rarity = 15,
	cost = 15,
	wielder = {
		esp_range = 10,
	},
}
newEntity{
	power_source = {arcane=true},
	name = "shimmering ", prefix=true, instant_resolve=true,
	keywords = {shimmering=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 4,
	wielder = {
		max_mana = resolvers.mbonus_material("max_mana"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of seeing ", suffix=true, instant_resolve=true,
	keywords = {seeing=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		blind_immune = resolvers.mbonus_material("immunity"),
	},
}


newEntity{
	power_source = {arcane=true},
	name = " of the arcanist", suffix=true, instant_resolve=true,
	keywords = {arcanist=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 20,
	wielder = {
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material("rare_resists"),
		},
		combat_spellpower = resolvers.mbonus_material("combat_spellpower"),
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_MANAFLOW, level = 1, power = 80 },
}

newEntity{
	power_source = {arcane=true},
	name = "insulating ", prefix=true, instant_resolve=true,
	keywords = {insulating=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "grounding ", prefix=true, instant_resolve=true,
	keywords = {grounding=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material("resists"),
		},
		stun_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {nature=true},
	name = "anchoring ", prefix=true, instant_resolve=true,
	keywords = {anchoring=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material("resists"),
		},
		teleport_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "stabilizing ", prefix=true, instant_resolve=true,
	keywords = {stable=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		stun_immune = resolvers.mbonus_material("immunity"),
		knockback_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "cleansing ", prefix=true, instant_resolve=true,
	keywords = {cleanse=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 9,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
		},
		poison_immune = resolvers.mbonus_material("immunity"),
		disease_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "runed ", prefix=true, instant_resolve=true,
	keywords = {runed=true},
	level_range = {15, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		mana_regen = resolvers.mbonus_material("mana_regen"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of knowledge", suffix=true, instant_resolve=true,
	keywords = {knowledge=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 13,
	cost = 20,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the Spellblaze", suffix=true, instant_resolve=true,
	keywords = {Spellblaze=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 20,
	wielder = {
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material("inc_damage"),
			[DamageType.COLD] = resolvers.mbonus_material("inc_damage"),
			[DamageType.ACID] = resolvers.mbonus_material("inc_damage"),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("inc_damage"),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "aegis ", prefix=true, instant_resolve=true,
	keywords = {aegis=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 11,
	cost = 15,
	wielder = {
		max_life=resolvers.mbonus_material("max_life"),
		life_regen = resolvers.mbonus_material("life_regen"),
		talents_types_mastery = {
			["spell/aegis"] = resolvers.mbonus_material("talents_types_mastery"),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "soothing ", prefix=true, instant_resolve=true,
	keywords = {soothing=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 20,
	wielder = {
		disease_immune = resolvers.mbonus_material("immunity"),
		confusion_immune = resolvers.mbonus_material("immunity"),
		poison_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "whispering ", prefix=true, instant_resolve=true,
	keywords = {whisper=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material("resists"),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats", 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats", -1),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats", 2),
		},
		confusion_immune = resolvers.mbonus_material("immunity", -1),
		talents_types_mastery = {
			["spell/temporal"] = resolvers.mbonus_material("talents_types_mastery"),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "sorcerer's ", prefix=true, instant_resolve=true,
	keywords = {sorcerer=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
		},
		mana_regen = resolvers.mbonus_material("mana_regen"),
		combat_spellpower = resolvers.mbonus_material("combat_spellpower"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "augmenting ", prefix=true, instant_resolve=true,
	keywords = {augment=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 60,
	wielder = {
		inc_damage = {
			[DamageType.ACID] = resolvers.mbonus_material("inc_damage"),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("inc_damage"),
			[DamageType.FIRE] = resolvers.mbonus_material("inc_damage"),
			[DamageType.COLD] = resolvers.mbonus_material("inc_damage"),
			[DamageType.ARCANE] = resolvers.mbonus_material("inc_damage"),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "purifying ", prefix=true, instant_resolve=true,
	keywords = {purify=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 20,
	wielder = {
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material("resists"),
		},
		poison_immune = resolvers.mbonus_material("immunity"),
		disease_immune = resolvers.mbonus_material("immunity"),
		combat_physresist = resolvers.mbonus_material("save"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "eldritch ", prefix=true, instant_resolve=true,
	keywords = {eldritch=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 20,
	wielder = {
		max_mana = resolvers.mbonus_material("max_mana"),
		talents_types_mastery = {
			["spell/arcane"] = resolvers.mbonus_material("talents_types_mastery"),
			["spell/arcane-shield"] = resolvers.mbonus_material("talents_types_mastery"),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of madness", suffix=true, instant_resolve=true,
	keywords = {madness=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_HATEFUL_WHISPER, level = 4, power = 80 },
	wielder = {
		resists={
			[DamageType.MIND] = resolvers.mbonus_material("rare_resists", -1),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats", 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats", 2),
		},
		combat_mentalresist = resolvers.mbonus_material("save", -1),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of earthrunes", suffix=true, instant_resolve=true,
	keywords = {earthrunes=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 20,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_STONE_WALL, level = 3, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
		},
		combat_armor = resolvers.mbonus_material("combat_armor"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of rainmaking", suffix=true, instant_resolve=true,
	keywords = {rainmaking=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_CORROSIVE_VAPOUR, level = 3, power = 80 },
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the Brotherhood", suffix=true, instant_resolve=true,
	keywords = {Brotherhood=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_ARCANE_EYE, level = 5, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats", 2),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of warding", suffix=true, instant_resolve=true,
	keywords = {warding=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_CIRCLE_OF_WARDING, level = 3, power = 50 },
}