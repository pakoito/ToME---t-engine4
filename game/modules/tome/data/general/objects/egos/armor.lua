-- ToME - Tales of Middle-Earth
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

local Talents = require("engine.interface.ActorTalents")
local Stats = require "engine.interface.ActorStats"

newEntity{
	name = " of fire resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of cold resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of acid resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of lightning resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of nature resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}

newEntity{
	name = " of stability", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		stun_immune = 0.7,
		knockback_immune = 0.7,
	},
}

newEntity{
	name = "prismatic ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 10,
	cost = 7,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 10, function(e, v) return v * 0.15 end),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 10, function(e, v) return v * 0.15 end),
		},
	},
}

newEntity{
	name = "spiked ", prefix=true, instant_resolve=true,
	level_range = {5, 50},
	rarity = 6,
	cost = 7,
	wielder = {
		on_melee_hit={[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 3, function(e, v) return v * 0.6 end)},
	},
}

newEntity{
	name = "searing ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 10,
	cost = 7,
	wielder = {
		melee_project={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 4, function(e, v) return v * 0.7 end),
			[DamageType.ACID] = resolvers.mbonus_material(10, 4, function(e, v) return v * 0.7 end),
		},
	},
}

newEntity{
	name = "rejuvenating ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 10,
	cost = 15,
	wielder = {
		stamina_regen = 0.5,
	},
}

newEntity{
	name = "radiant ", prefix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 18,
	cost = 15,
	wielder = {
		melee_project={[DamageType.LIGHT] = resolvers.mbonus_material(10, 4, function(e, v) return v * 0.7 end),},
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.15 end),
			[DamageType.DARKNESS] = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.15 end),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1, function(e, v) return v * 3 end),
			[Stats.STAT_LCK] = resolvers.mbonus_material(10, 1, function(e, v) return v * 3 end),
		},
	},
}

newEntity{
	name = "insulating ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
	},
}



newEntity{
	name = "grounding ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		stun_immune = 0.3,
	},
}


newEntity{
	name = "cleansing ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 9,
	cost = 5,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.POISON] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
	},
}

newEntity{
	name = "fortifying ", prefix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 18,
	cost = 35,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 2, function(e, v) return v * 3 end),
			[Stats.STAT_STR] = resolvers.mbonus_material(5, 2, function(e, v) return v * 3 end),
		},
		max_life=resolvers.mbonus_material(70, 30, function(e, v) return v * 0.1 end),
	},
}


newEntity{
	name = "hardened ", prefix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = true,
	rarity = 29,
	cost = 47,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(8, 5, function(e, v) return v * 0.15 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 5, function(e, v) return v * 0.15 end),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 5, function(e, v) return v * 0.15 end),
			[DamageType.COLD] = resolvers.mbonus_material(8, 5, function(e, v) return v * 0.15 end),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 5, function(e, v) return v * 0.15 end),
		},
		combat_armor = resolvers.mbonus_material(5, 5, function(e, v) return v * 1 end),
	},
}



newEntity{
	name = " of resilience", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		max_life = resolvers.mbonus_material(40, 20, function(e, v) return v * 0.1 end),
	},
}



newEntity{
	name = " of the sky", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 20,
	cost = 35,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(8, 5, function(e, v) return v * 0.15 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 5, function(e, v) return v * 0.15 end),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 5, function(e, v) return v * 0.15 end),
			[DamageType.COLD] = resolvers.mbonus_material(8, 5, function(e, v) return v * 0.15 end),
		},
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(6, 2, function(e, v) return v * 3 end),
		},
	},
}
