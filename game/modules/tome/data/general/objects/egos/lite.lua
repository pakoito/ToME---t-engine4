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

--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {technique=true},
	name = "bright ", prefix=true, instant_resolve=true,
	keywords = {bright=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 1,
	wielder = {
		lite=1,
	},
}

newEntity{
	power_source = {technique=true},
	name = " of clear sight", suffix=true, instant_resolve=true,
	keywords = {sight=true},
	level_range = {10, 50},
	rarity = 5,
	cost = 1,
	wielder = {
		blind_immune=resolvers.mbonus_material(3, 3, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the sun", suffix=true, instant_resolve=true,
	keywords = {sun=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 9,
	cost = 10,
	wielder = {
		blind_immune=resolvers.mbonus_material(3, 3, function(e, v) v=v/10 return 0, v end),
		combat_spellresist = 15,
		lite=1,
	},
}

newEntity{
	power_source = {arcane=true},
	name = "scorching ", prefix=true, instant_resolve=true,
	keywords = {scorching=true},
	level_range = {10, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		on_melee_hit={[DamageType.FIRE] = resolvers.mbonus_material(20, 10)},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of revealing", suffix=true, instant_resolve=true,
	keywords = {revealing=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		lite = 1,
		see_invisible = resolvers.mbonus_material(20, 5),
		trap_detect_power = resolvers.mbonus_material(15, 10),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of clarity", suffix=true, instant_resolve=true,
	keywords = {clarity=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		confusion_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of health", suffix=true, instant_resolve=true,
	keywords = {health=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		max_life=resolvers.mbonus_material(40, 40),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of guile", suffix=true, instant_resolve=true,
	keywords = {guile=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(4, 3),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "burglar's ", prefix=true, instant_resolve=true,
	keywords = {burglar=true},
	level_range = {15, 50},
	rarity = 9,
	cost = 12,
	wielder = {
		lite = -2,
		infravision = resolvers.mbonus_material(2, 1),
	},
}

newEntity{
	power_source = {technique=true},
	name = "guard's ", prefix=true, instant_resolve=true,
	keywords = {guard=true},
	level_range = {15, 50},
	rarity = 9,
	cost = 12,
	wielder = {
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "healer's ", prefix=true, instant_resolve=true,
	keywords = {heakler=true},
	level_range = {15, 50},
	rarity = 9,
	cost = 12,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "guide's ", prefix=true, instant_resolve=true,
	keywords = {guide=true},
	level_range = {15, 50},
	rarity = 9,
	cost = 12,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(15, 5),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "reflective ", prefix=true, instant_resolve=true,
	keywords = {reflect=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 30,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		blind_immune = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "nightwalker's ", prefix=true, instant_resolve=true,
	keywords = {nightwalker=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 50,
	wielder = {
		combat_dam = resolvers.mbonus_material(5, 5),
		combat_physcrit = resolvers.mbonus_material(3, 3),
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 3),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "ethereal ", prefix=true, instant_resolve=true,
	keywords = {ethereal=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 50,
	encumber = -1,
	wielder = {
		lite = 2,
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 3),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of illusion", suffix=true, instant_resolve=true,
	keywords = {illusion=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 50,
	wielder = {
		combat_def = resolvers.mbonus_material(4, 4),
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_physresist = resolvers.mbonus_material(10, 5),
		combat_spellresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of corpselight", suffix=true, instant_resolve=true,
	keywords = {corpselight=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 50,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3),
		combat_spellcrit = resolvers.mbonus_material(3, 3),
		see_invisible = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = "traitor's ", prefix=true, instant_resolve=true,
	keywords = {traitor=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_LCK] = resolvers.mbonus_material(5, 5, function(e, v) return 0, -v end),
			[Stats.STAT_DEX] = resolvers.mbonus_material(9, 1),
			[Stats.STAT_CON] = resolvers.mbonus_material(9, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 5, function(e, v) return 0, -v end),
			[Stats.STAT_CUN] = resolvers.mbonus_material(9, 1),
		},
	},	
}

newEntity{
	power_source = {technique=true},
	name = "watchleader's ", prefix=true, instant_resolve=true,
	keywords = {watchleader=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		stun_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		knockback_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		pin_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		lite = resolvers.mbonus_material(1, 1),
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "faithful ", prefix=true, instant_resolve=true,
	keywords = {faithful=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(6, 1),
		inc_damage = {
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
	},	
}

newEntity{
	power_source = {technique=true},
	name = "piercing ", prefix=true, instant_resolve=true,
	keywords = {piercing=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		combat_apr = resolvers.mbonus_material(10, 5),
		resists_pen = { 
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
		lite = resolvers.mbonus_material(1, 1),
	},	
}

newEntity{
	power_source = {nature=true},
	name = "preserving ", prefix=true, instant_resolve=true,
	keywords = {preserve=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 20,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		poison_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		disease_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		life_regen = resolvers.mbonus_material(27, 3, function(e, v) v=v/10 return 0, v end),
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of the zealot", suffix=true, instant_resolve=true,
	keywords = {zealot=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.charmt(Talents.T_ARCANE_EYE, {2,3,4,5}, 40),
	wielder = {
		blind_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, -v end),
		confusion_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, -v end),
		inc_damage = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of blinding", suffix=true, instant_resolve=true,
	keywords = {blinding=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.charmt(Talents.T_ILLUMINATE, 3, 30),
}

newEntity{
	power_source = {arcane=true},
	name = " of refraction", suffix=true, instant_resolve=true,
	keywords = {refract=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 10,
	cost = 40,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(7, 3),
			[DamageType.DARKNESS] = resolvers.mbonus_material(7, 3),
		},

		resists_pen = { 
			[DamageType.LIGHT] = resolvers.mbonus_material(7, 3),
			[DamageType.DARKNESS] = resolvers.mbonus_material(7, 3),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of moonlight", suffix=true, instant_resolve=true,
	keywords = {moonlight=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.charmt(Talents.T_MOONLIGHT_RAY, 4, 8),
	wielder = {
		combat_spellpower = resolvers.mbonus_material(7, 3),
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of repulsion", suffix=true, instant_resolve=true,
	keywords = {repulsion=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 40,
	resolvers.charmt(Talents.T_GLYPH_OF_REPULSION, 3, 40),
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
	},	
}
