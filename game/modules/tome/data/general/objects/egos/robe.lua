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

--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {arcane=true},
	name = " of fire resistance", suffix=true, instant_resolve=true,
	keywords = {fire=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus_material(30, 10)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of cold resistance", suffix=true, instant_resolve=true,
	keywords = {cold=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material(30, 10)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of acid resistance", suffix=true, instant_resolve=true,
	keywords = {acid=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus_material(30, 10)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of lightning resistance", suffix=true, instant_resolve=true,
	keywords = {lightning=true},
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
	keywords = {nature=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus_material(30, 10)},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "shimmering ", prefix=true, instant_resolve=true,
	keywords = {shimmering=true},
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		max_mana = resolvers.mbonus_material(100, 10),
	},
}

newEntity{
	power_source = {antimagic=true},
	name = "slimy ", prefix=true, instant_resolve=true,
	keywords = {slimy=true},
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		on_melee_hit={[DamageType.SLIME] = resolvers.mbonus_material(7, 3)},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of power", suffix=true, instant_resolve=true,
	keywords = {power=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 15,
	wielder = {
		inc_damage = {
			[DamageType.ARCANE] = resolvers.mbonus_material(15, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5),
			[DamageType.COLD] = resolvers.mbonus_material(15, 5),
			[DamageType.ACID] = resolvers.mbonus_material(15, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5),
			[DamageType.NATURE] = resolvers.mbonus_material(15, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5),
		},
		combat_spellpower = resolvers.mbonus_material(4, 3),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "enchanted ", prefix=true, instant_resolve=true,
	keywords = {enchanted=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(4, 2),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "shielded ", prefix=true, instant_resolve=true,
	keywords = {shielded=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_armor = resolvers.mbonus_material(6, 2),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "spellwoven ", prefix=true, instant_resolve=true,
	keywords = {spellwoven=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(4, 2),
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
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "bilefire ", prefix=true, instant_resolve=true,
	keywords = {bilefire=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 50,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 4),
			},
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5),
			[DamageType.ACID] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "timelord's ", prefix=true, instant_resolve=true,
	keywords = {timelord=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 50,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 4),
			},
		inc_damage = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(15, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "stormlord's ", prefix=true, instant_resolve=true,
	keywords = {stormlord=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 50,
	wielder = {
		resists={
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 4),
			},
		inc_damage = {
			[DamageType.COLD] = resolvers.mbonus_material(15, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "radiant ", prefix=true, instant_resolve=true,
	keywords = {radiant=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 50,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		lite = 1,
		inc_damage = {
			[DamageType.LIGHT] = resolvers.mbonus_material(15, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of Angolwen", suffix=true, instant_resolve=true,
	keywords = {Angolwen=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {

		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 2),
			[Stats.STAT_CUN] = resolvers.mbonus_material(4, 2),
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 2),
			},

	},
}

newEntity{
	power_source = {arcane=true},
	name = " of Linaniil", suffix=true, instant_resolve=true,
	keywords = {Linaniil=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3),
		combat_spellcrit = resolvers.mbonus_material(3, 3),
		max_mana = resolvers.mbonus_material(60, 40),
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),

	},
}

newEntity{
	power_source = {nature=true},
	name = " of life", suffix=true, instant_resolve=true,
	keywords = {life=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		max_life=resolvers.mbonus_material(60, 40),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5),
		},

	},
}

newEntity{
	power_source = {arcane=true},
	name = " of chaos", suffix=true, instant_resolve=true,
	keywords = {chaos=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.NATURE] = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
			[DamageType.ARCANE] = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),
		},
		resists_pen = { 
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of explosions", suffix=true, instant_resolve=true,
	keywords = {explosions=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.charmt(Talents.T_GLYPH_OF_EXPLOSION, {2,3,4}, 30),
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
		},
		combat_armor = resolvers.mbonus_material(7, 3),
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of retribution", suffix=true, instant_resolve=true,
	keywords = {retribution=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		on_melee_hit = {
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = " of novas", suffix=true, instant_resolve=true,
	keywords = {novas=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	resolvers.charmt(Talents.T_NOVA, {2,3,4}, 16),
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 5),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "outcast's ", prefix=true, instant_resolve=true,
	keywords = {outcast=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5, function(e, v) return 0, -v end),
			[DamageType.ARCANE] = resolvers.mbonus_material(7, 3),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(7, 3),
		},
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_physresist = resolvers.mbonus_material(10, 5),
		combat_spellresist = resolvers.mbonus_material(10, 5),
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "stargazer's ", prefix=true, instant_resolve=true,
	keywords = {stargazer=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
		},
		blind_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		combat_spellpower = resolvers.mbonus_material(7, 3),
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "ancient ", prefix=true, instant_resolve=true,
	keywords = {ancient=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(9, 1),
		},
		confusion_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		melee_project = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "fearwoven ", prefix=true, instant_resolve=true,
	keywords = {fearwoven=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 80,
	wielder = {
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(35, 5),
		},
		combat_mentalresist = resolvers.mbonus_material(15, 5),
		combat_armor = resolvers.mbonus_material(7, 3),
		combat_spellpower = resolvers.mbonus_material(7, 3),
	},	
}

newEntity{
	power_source = {psionic=true},
	name = "tormentor's ", prefix=true, instant_resolve=true,
	keywords = {tormentor=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(9, 1),
		},
		combat_mindcrit = resolvers.mbonus_material(4, 1),
		combat_critical_power = resolvers.mbonus_material(30, 10),
	},	
}