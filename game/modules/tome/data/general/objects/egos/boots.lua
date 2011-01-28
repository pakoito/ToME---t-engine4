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
local Talents = require "engine.interface.ActorTalents"

newEntity{
	power_source = {arcane=true},
	name = " of phasing", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 18,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
			[Stats.STAT_WIL] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
		},
	},
	max_power = 60, power_regen = 1,
	use_power = { name = "blink to a nearby random location", power = 35, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 10 + who:getMag(5))
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}

}

newEntity{
	power_source = {technique=true},
	name = " of uncanny dodging", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_def_ranged = resolvers.mbonus_material(8, 2, function(e, v) return v * 1 end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of speed", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	greater_ego = true,
	rarity = 20,
	cost = 60,
	wielder = {
		movement_speed = -0.2,
	},
}

newEntity{
	power_source = {technique=true},
	name = " of rushing", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 18,
	cost = 40,
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_RUSH, level = 2, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
			[Stats.STAT_CON] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of disengagement", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 18,
	cost = 40,

	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_DISENGAGE, level = 2, power = 80 },
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
			[Stats.STAT_CUN] = resolvers.mbonus_material(2, 2, function(e, v) return v * 3 end),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of stability", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 12,
	cost = 12,
	wielder = {
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
		knockback_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of tirelessness", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 9,
	cost = 7,
	wielder = {
		max_stamina = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.1 end),
		stamina_regen = resolvers.mbonus_material(10, 3, function(e, v) v=v/10 return v * 10, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "traveler's ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		max_encumber = resolvers.mbonus_material(30, 20, function(e, v) return v * 0.4, v end),
	},
}


newEntity{
	power_source = {arcane=true},
	name = "scholar's ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.8 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "miner's ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_armor = resolvers.mbonus_material(6, 4, function(e, v) return v * 1 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "stalker's ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		infravision = resolvers.mbonus_material(2, 1, function(e, v) return v * 1.4 end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "restorative ", prefix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = true,
	rarity = 18,
	cost = 60,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
		cut_immune = resolvers.mbonus_material(2, 2, function(e, v) v=v/10 return v * 8, v end),
		life_regen = resolvers.mbonus_material(10, 5, function(e, v) v=v/10 return v * 10, v end),
		poison_immune = resolvers.mbonus_material(10, 10, function(e, v) return v * 0.15, v/100 end),

	},
}

newEntity{
	power_source = {nature=true},
	name = "invigorating ", prefix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = true,
	rarity = 20,
	cost = 70,
	wielder = {
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return v * 1, -v end),
		max_life=resolvers.mbonus_material(30, 30, function(e, v) return v * 0.1 end),
		movement_speed = -0.1,
	},
}

newEntity{
	power_source = {technique=true},
	name = "blood-soaked ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	greater_ego = true,
	rarity = 15,
	cost = 20,
	wielder = {
		combat_dam = resolvers.mbonus_material(3, 3, function(e, v) return v * 3 end),
		combat_apr = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.3 end),
		pin_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}


