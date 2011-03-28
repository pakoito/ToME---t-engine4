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
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-defensive.lua")

newEntity{
	power_source = {arcane=true},
	name = " of carrying", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		max_encumber = resolvers.mbonus_material(40, 20, function(e, v) return v * 0.4, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of shielding", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 10,
	cost = 40,
	wielder = {
		combat_def = resolvers.mbonus_material(10, 5, function(e, v) return v * 1, v end),
	},
	max_power = 120, power_regen = 1,
	use_power = { name = "create a temporary shield that absorbs damage", power = 100, use = function(self, who)
		local power = 100 + who:getMag(120)
		who:setEffect(who.EFF_DAMAGE_SHIELD, 10, {power=power})
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return true, nil, true
	end}
}

newEntity{
	power_source = {arcane=true},
	name = " of the mystic", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(10, 2, function(e, v) return v * 1 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the titan", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_dam = resolvers.mbonus_material(10, 2, function(e, v) return v * 1 end),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of life", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 8,
	cost = 6,
	wielder = {
		life_regen = resolvers.mbonus_material(10, 2, function(e, v) return v * 1, v/10 end),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of resilience", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		max_life = resolvers.mbonus_material(40, 30, function(e, v) return v * 0.2 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "blurring ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		combat_def_ranged = resolvers.mbonus_material(8, 2, function(e, v) return v * 1 end),
		inc_stealth = resolvers.mbonus_material(10, 5, function(e, v) return v * 1, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "insulating ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "grounding ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "anchoring ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		teleport_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "stabilizing ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
		knockback_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "cleansing ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 9,
	cost = 9,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		poison_immune = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15, v/100 end),
		disease_immune = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15, v/100 end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of magery", suffix=true, instant_resolve=true,
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 50,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 3, function(e, v) return v * 3 end),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 3, function(e, v) return v * 3 end),
		},
		combat_spellcrit = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.4 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of burglary", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		disarm_bonus = resolvers.mbonus_material(25, 5, function(e, v) return v * 1.2 end),
		trap_detect_power = resolvers.mbonus_material(25, 5, function(e, v) return v * 1.2 end),
		infravision = resolvers.mbonus_material(2, 2, function(e, v) return v * 1.4 end),
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 3, function(e, v) return v * 3 end),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of dampening", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 50,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
			[DamageType.FIRE] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
			[DamageType.COLD] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of inertia", suffix=true, instant_resolve=true,
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 50,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 3, function(e, v) return v * 3 end),
			[Stats.STAT_CON] = resolvers.mbonus_material(3, 3, function(e, v) return v * 3 end),
		},
		pin_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}


newEntity{
	power_source = {technique=true},
	name = "monstrous ", prefix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		size_category = 1,
		combat_dam = resolvers.mbonus_material(5, 5, function(e, v) return v * 3 end),
		combat_critical_power = resolvers.mbonus_material(10, 10, function(e, v) return v * 2, v end),

	},
}

newEntity{
	power_source = {technique=true},
	name = "balancing ", prefix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 3, function(e, v) return v * 3 end),
		},
		combat_atk = resolvers.mbonus_material(5, 5, function(e, v) return v * 3 end),
		combat_physcrit = resolvers.mbonus_material(3, 3, function(e, v) return v * 1.4 end),
	},
}


newEntity{
	power_source = {technique=true},
	name = "protective ", prefix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		combat_armor = resolvers.mbonus_material(6, 4, function(e, v) return v * 1 end),
		combat_def = resolvers.mbonus_material(4, 4, function(e, v) return v * 1 end),
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}