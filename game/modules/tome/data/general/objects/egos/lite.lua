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

--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	name = "bright ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 1,
	wielder = {
		lite=1,
	},
}

newEntity{
	name = " of clear sight", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 5,
	cost = 1,
	wielder = {
		blind_immune=resolvers.mbonus_material(3, 3, function(e, v) v=v/10 return v * 8, v end),
	},
}

newEntity{
	name = " of the sun", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 9,
	cost = 10,
	wielder = {
		blind_immune=resolvers.mbonus_material(3, 3, function(e, v) v=v/10 return v * 8, v end),
		combat_spellresist = 15,
		lite=1,
	},
}

newEntity{
	name = "scorching ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		on_melee_hit={[DamageType.FIRE] = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.6 end)},
	},
}

newEntity{
	name = " of revealing", suffix=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		see_invisible = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.2 end),
		trap_detect_power = resolvers.mbonus_material(15, 5, function(e, v) return v * 1.2 end),
	},
}

newEntity{
	name = " of clarity", suffix=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		confusion_immune = resolvers.mbonus_material(3, 2, function(e, v) v=v/10 return v * 8, v end),
	},
}

newEntity{
	name = " of health", suffix=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		max_life=resolvers.mbonus_material(40, 40, function(e, v) return v * 0.1 end),
	},
}

newEntity{
	name = " of guile", suffix=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		inc_stats = {
		[Stats.STAT_CUN] = resolvers.mbonus_material(4, 3, function(e, v) return v * 3 end),
		},
	},
}

newEntity{
	name = "burglar's ", prefix=true,
	level_range = {15, 50},
	rarity = 9,
	cost = 12,
	wielder = {
		lite = -2,
		infravision = resolvers.mbonus_material(2, 1, function(e, v) return v * 1.4 end),
	},
}

newEntity{
	name = "guard's ", prefix=true,
	level_range = {15, 50},
	rarity = 9,
	cost = 12,
	wielder = {
		stun_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	name = "healer's ", prefix=true,
	level_range = {15, 50},
	rarity = 9,
	cost = 12,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	name = "guide's ", prefix=true,
	level_range = {15, 50},
	rarity = 9,
	cost = 12,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.15 end),
	},
}

newEntity{
	name = "reflective ", prefix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 10,
	cost = 30,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		blind_immune = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	name = "nightwalker's ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 10,
	cost = 50,
	wielder = {
		combat_dam = resolvers.mbonus_material(5, 5, function(e, v) return v * 3 end),
		combat_physcrit = resolvers.mbonus_material(3, 3, function(e, v) return v * 1.4 end),
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 3, function(e, v) return v * 3 end),
			},
	},
}

newEntity{
	name = "ethereal ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 10,
	cost = 50,
	encumber = -1,
	wielder = {
		lite = 2,
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 3, function(e, v) return v * 3 end),
			},
	},
}

newEntity{
	name = " of illusion", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 10,
	cost = 50,
	wielder = {
		combat_def = resolvers.mbonus_material(4, 4, function(e, v) return v * 1 end),
		combat_mentalresist = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		combat_physresist = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		combat_spellresist = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
	},
}

newEntity{
	name = " of corpselight", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 10,
	cost = 50,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.8 end),
		combat_spellcrit = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.4 end),
		see_invisible = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.2 end),
	},
}
