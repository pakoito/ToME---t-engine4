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
	name = " of strength (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {strength=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material("inc_stats") },
	},
}
newEntity{
	power_source = {technique=true},
	name = " of constitution (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {con=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = resolvers.mbonus_material("inc_stats") },
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
	name = "shaloran ", prefix=true, instant_resolve=true,
	keywords = {shaloran=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 10,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats") },
		disease_immune = resolvers.mbonus_material("immunity"),
		stun_immune = resolvers.mbonus_material("immunity"),
	},
}
newEntity{
	power_source = {nature=true},
	name = "prismatic ", prefix=true, instant_resolve=true,
	keywords = {prismatic=true},
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
	power_source = {nature=true},
	name = " of precognition", suffix=true, instant_resolve=true,
	keywords = {precog=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 25,
	wielder = {
		combat_atk = resolvers.mbonus_material("combat_atk"),
		combat_def = resolvers.mbonus_material("combat_def"),
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats") },
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the depths", suffix=true,
	keywords = {depths=true},
	level_range = {15, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		can_breath = {water=1},
	},
}

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
	power_source = {technique=true},
	name = "miner's ", prefix=true, instant_resolve=true,
	keywords = {miner=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		infravision = resolvers.mbonus_material("infravision"),
		combat_armor = resolvers.mbonus_material("combat_armor"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "insulating ", prefix=true, instant_resolve=true,
	keywords = {insulate=true},
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
	power_source = {technique=true},
	name = "grounding ", prefix=true, instant_resolve=true,
	keywords = {ground=true},
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
	power_source = {technique=true},
	name = "anchoring ", prefix=true, instant_resolve=true,
	keywords = {anchor=true},
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
	power_source = {technique=true},
	name = "stabilizing ", prefix=true, instant_resolve=true,
	keywords = {stabilize=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		stun_immune = resolvers.mbonus_material("immunity"),
		knockback_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {nature=true},
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
	name = " of knowledge", suffix=true, instant_resolve=true,
	keywords = {knowledge=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 15,
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
	power_source = {technique=true},
	name = " of might", suffix=true, instant_resolve=true,
	keywords = {might=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 20,
	wielder = {
		combat_physcrit = resolvers.mbonus_material("combat_physcrit"),
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
			},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of trickery", suffix=true, instant_resolve=true,
	keywords = {trickery=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 13,
	cost = 20,
	wielder = {
		combat_apr = resolvers.mbonus_material("combat_apr"),
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
			},
	},
}

newEntity{
	power_source = {nature=true},
	name = "warlord's ", prefix=true, instant_resolve=true,
	keywords = {warlord=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 50,
	wielder = {
		combat_dam = resolvers.mbonus_material("combat_dam"),
		pin_immune = resolvers.mbonus_material("immunity"),
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
			},
	},
}

newEntity{
	power_source = {technique=true},
	name = "defender's ", prefix=true, instant_resolve=true,
	keywords = {defender=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 50,
	wielder = {
		combat_armor = resolvers.mbonus_material("combat_armor"),
		combat_def = resolvers.mbonus_material("combat_def"),
		combat_physresist = resolvers.mbonus_material("save"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "dragonslayer's ", prefix=true, instant_resolve=true,
	keywords = {dragonslayer=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 17,
	cost = 50,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("resists"),
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "werebeast's ", prefix=true, instant_resolve=true,
	keywords = {werebeast=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 80,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material("resists", -1),
		},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		life_regen = resolvers.mbonus_material("life_regen"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "mindcaging ", prefix=true, instant_resolve=true,
	keywords = {mindcage=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		resists={
			[DamageType.MIND] = resolvers.mbonus_material("rare_resists"),
		},
		blind_immune = resolvers.mbonus_material("immunity"),
		confusion_immune = resolvers.mbonus_material("immunity"),
		combat_mentalresist = resolvers.mbonus_material("save"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "champion's ", prefix=true, instant_resolve=true,
	keywords = {champion=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
		},
		confusion_immune = resolvers.mbonus_material("immunity"),
		lite = resolvers.mbonus_material("lite"),
	},
}

newEntity{
	power_source = {nature=true},
	name = "leafwalker's ", prefix=true, instant_resolve=true,
	keywords = {learwalker=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 80,
	wielder = {
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material("resists"),
		},
		poison_immune = resolvers.mbonus_material("immunity"),
		disease_immune = resolvers.mbonus_material("immunity"),
		max_life = resolvers.mbonus_material("max_life"),
		healing_factor = resolvers.mbonus_material("healing_factor"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "catburglar's ", prefix=true, instant_resolve=true,
	keywords = {catburglar=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material("resists"),
		},
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
		},
		infravision = resolvers.mbonus_material("infravision"),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of blood magic", suffix=true, instant_resolve=true,
	keywords = {blood=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 100,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats", -1),
			[Stats.STAT_MAG] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_WIL] = resolvers.mbonus_material("inc_stats"),
		},
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
		inc_damage = {
			[DamageType.BLIGHT] = resolvers.mbonus_material("inc_damage"),
			[DamageType.ARCANE] = resolvers.mbonus_material("inc_damage"),
		},
		healing_factor = resolvers.mbonus_material("healing_factor", -1),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of fortune", suffix=true, instant_resolve=true,
	keywords = {fortune=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_LCK] = resolvers.mbonus_material("inc_stats"),
		},
		combat_physcrit = resolvers.mbonus_material("combat_physcrit"),
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of sanctity", suffix=true, instant_resolve=true,
	keywords = {sanctity=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_CIRCLE_OF_SANCTITY, level = 4, power = 80 },
	wielder = {
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material("resists"),
			[DamageType.DARKNESS] = resolvers.mbonus_material("resists"),
		},
		confusion_immune = resolvers.mbonus_material("immunity"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of ire", suffix=true, instant_resolve=true,
	keywords = {ire=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_BATTLE_CRY, level = 2, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats", 2),
		},
		--combat_mentalresist = resolvers.mbonus_material("save"),
		combat_physresist = resolvers.mbonus_material("save"),
	},
}
--[=[
newEntity{
	power_source = {technique=true},
	name = " of hoarding", suffix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		resource_leech_chance = resolvers.mbonus_material("resource_leech_chance"),
		resource_leech_value = resolvers.mbonus_material("resource_leech_value"),
	},
}
]=]
