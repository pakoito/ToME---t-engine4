-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

newEntity{
	name = " of disarming", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		disarm_bonus = resolvers.mbonus_material(25, 5, function(e, v) return v * 1.2 end),
	},
}

newEntity{
	name = " of criticals", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 9,
	cost = 15,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(15, 5, function(e, v) return v * 1.4 end),
		combat_physcrit = resolvers.mbonus_material(15, 5, function(e, v) return v * 1.4 end),
	},
}

newEntity{
	name = " of mighty criticals", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 12,
	cost = 25,
	wielder = {
		combat_critical_power = resolvers.mbonus_material(35, 5, function(e, v) v=v/100 return v * 200, v end),
	},
}

newEntity{
	name = " of attack", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 5,
	wielder = {
		combat_atk = resolvers.mbonus_material(15, 10, function(e, v) return v * 1 end),
	},
}

newEntity{
	name = " of damage", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		combat_dam = resolvers.mbonus_material(15, 5, function(e, v) return v * 3 end),
	},
}

newEntity{
	name = "cinder ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.FIRE] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "polar ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.COLD] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "corrosive ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.ACID] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "charged ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHTNING] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "naturalist ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.NATURE] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "blighted ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.BLIGHT] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "powerful ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = resolvers.mbonus_material(8, 3, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = " of strength (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end) },
	},
}

newEntity{
	name = " of dexterity (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end) },
	},
}

newEntity{
	name = " of magic (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end) },
	},
}

newEntity{
	name = " of iron grip", suffix=true,
	level_range = {20, 50},
	rarity = 9,
	cost = 15,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end) },
		disarm_immune = 0.7,
	},
}
