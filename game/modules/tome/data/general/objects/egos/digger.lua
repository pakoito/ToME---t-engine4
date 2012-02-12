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

newEntity{
	power_source = {technique=true},
	name = " of the badger", suffix=true,
	keywords = {badger=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 20,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
}

newEntity{
	power_source = {technique=true},
	name = " of strength", suffix=true, instant_resolve=true,
	keywords = {strength=true},
	level_range = {10, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material("inc_stats") },
	},
}

newEntity{
	power_source = {technique=true},
	name = " of delving", suffix=true, instant_resolve=true,
	keywords = {delving=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 20,
	wielder = {
		lite = resolvers.mbonus_material("lite"),
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
			},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of endurance", suffix=true, instant_resolve=true,
	keywords = {endurance=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		fatigue = resolvers.mbonus_material("fatigue"),
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
	},
}

newEntity{
	power_source = {nature=true},
	name = "woodsman's ", prefix=true, instant_resolve=true,
	keywords = {woodsman=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists = { [DamageType.NATURE] = resolvers.mbonus_material("resists"), },
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the Iron Throne", suffix=true, instant_resolve=true,
	keywords = {['iron.throne']=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 15,
	wielder = {
		max_life = resolvers.mbonus_material("max_life"),
		max_stamina = resolvers.mbonus_material("max_stamina"),
	},
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
}

newEntity{
	power_source = {technique=true},
	name = " of Reknor", suffix=true, instant_resolve=true,
	keywords = {reknor=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 15,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.DARKNESS] = resolvers.mbonus_material("resists"),
		},
	},
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
}

newEntity{
	power_source = {technique=true},
	name = "brutal ", prefix=true, instant_resolve=true,
	keywords = {brutal=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 70,
	wielder = {
		combat_dam = resolvers.mbonus_material("combat_dam", 2),
		combat_apr = resolvers.mbonus_material("combat_apr"),
		--combat_critical_power = resolvers.mbonus_material("combat_critical_power"),
	},
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
}

newEntity{
	power_source = {technique=true},
	name = "builder's ", prefix=true, instant_resolve=true,
	keywords = {builder=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 15,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
			},
		confusion_immune = resolvers.mbonus_material("immunity"),
	},
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
}

newEntity{
	power_source = {technique=true},
	name = "soldier's ", prefix=true, instant_resolve=true,
	keywords = {soldier=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 15,
	wielder = {
		combat_def = resolvers.mbonus_material("combat_def"),
		combat_armor = resolvers.mbonus_material("combat_armor"),
	},
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
}

newEntity{
	power_source = {arcane=true},
	name = "bloodhexed ", prefix=true, instant_resolve=true,
	keywords = {bloodhexed=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats", 2),
		},
		combat_physcrit = resolvers.mbonus_material("combat_physcrit"),
		healing_factor = resolvers.mbonus_material("healing_factor", -1),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "crystalomancer's ", prefix=true, instant_resolve=true,
	keywords = {crystal=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		max_mana = resolvers.mbonus_material("max_mana"),
		combat_spellcrit = resolvers.mbonus_material("combat_spellcrit"),
	},
}

newEntity{
	power_source = {technique=true},
	name = "shattering ", prefix=true, instant_resolve=true,
	keywords = {shattering=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
	wielder = {
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material("resists_pen"),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "sapper's ", prefix=true, instant_resolve=true,
	keywords = {sapper=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material("inc_stats"),
		},
		combat_atk = resolvers.mbonus_material("combat_atk"),
		infravision = resolvers.mbonus_material("infravision"),
	},
}

newEntity{
	power_source = {nature=true},
	name = "dwarven ", prefix=true, instant_resolve=true,
	keywords = {dwarven=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		combat_mentalresist = resolvers.mbonus_material("save"),
		--combat_physresist = resolvers.mbonus_material("save"),
		--combat_spellresist = resolvers.mbonus_material("save"),
		max_life = resolvers.mbonus_material("max_life"),
	},
}
--[=[
newEntity{
	power_source = {technique=true},
	name = " of avarice", suffix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 60,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		blind_immune = resolvers.mbonus_material("immunity", -1),
		combat_mentalresist = resolvers.mbonus_material("save", -1),
		resource_leech_chance = resolvers.mbonus_material("resource_leech_chance"),
		resource_leech_value = resolvers.mbonus_material("resource_leech_value"),
	},	
}
]=]
newEntity{
	power_source = {arcane=true},
	name = " of quickening", suffix=true, instant_resolve=true,
	keywords = {quickening=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_QUICKEN_SPELLS, level = 2, power = 80 },
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
}

newEntity{
	power_source = {technique=true},
	name = " of predation", suffix=true, instant_resolve=true,
	keywords = {predation=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material("inc_stats"),
		},
		pin_immune = resolvers.mbonus_material("immunity"),
		combat_dam = resolvers.mbonus_material("combat_dam"),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of deeplife", suffix=true, instant_resolve=true,
	keywords = {deeplife=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material("resists"),
		},
		blind_immune = resolvers.mbonus_material("immunity"),
		confusion_immune = resolvers.mbonus_material("immunity"),
		infravision = resolvers.mbonus_material("infravision"),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of wreckage", suffix=true, instant_resolve=true,
	keywords = {wreckage=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_PERFECT_STRIKE, level = 3, power = 80 },
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
		},
		combat_apr = resolvers.mbonus_material("combat_apr"),
	},
}
