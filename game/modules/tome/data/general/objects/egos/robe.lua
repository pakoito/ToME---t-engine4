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

--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {arcane=true},
	name = " of fire resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of cold resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of acid resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of lightning resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	power_source = {nature=true},
	name = " of nature resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "shimmering ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		max_mana = resolvers.mbonus_material(100, 10, function(e, v) return v * 0.1 end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "slimy ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		on_melee_hit={[DamageType.SLIME] = resolvers.mbonus_material(7, 3, function(e, v) return v * 1 end)},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of power", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 18,
	cost = 15,
	wielder = {
		inc_damage = {
			[DamageType.ARCANE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.COLD] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.ACID] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.NATURE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
		},
		combat_spellpower = resolvers.mbonus_material(4, 3, function(e, v) return v * 0.8 end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "enchanted ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(4, 2, function(e, v) return v * 0.8 end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "shielded ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_armor = resolvers.mbonus_material(6, 2, function(e, v) return v * 1 end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "spellwoven ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(4, 2, function(e, v) return v * 0.4 end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "runed ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return v * 80, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "bilefire ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 50,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.ACID] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 4, function(e, v) return v * 3 end),
			},
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.ACID] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "timelord's ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 50,
	wielder = {
		resists={
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 4, function(e, v) return v * 3 end),
			},
		inc_damage = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "stormlord's ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 50,
	wielder = {
		resists={
			[DamageType.COLD] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 4, function(e, v) return v * 3 end),
			},
		inc_damage = {
			[DamageType.COLD] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "radiant ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 16,
	cost = 50,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
		},
		lite = 1,
		inc_damage = {
			[DamageType.LIGHT] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.DARKNESS] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of Angolwen", suffix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = true,
	rarity = 20,
	cost = 60,
	wielder = {

		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end),
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end),
			[Stats.STAT_CUN] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end),
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 2, function(e, v) return v * 3 end),
			},

	},
}

newEntity{
	power_source = {arcane=true},
	name = " of Linaniil", suffix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = true,
	rarity = 20,
	cost = 60,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.8 end),
		combat_spellcrit = resolvers.mbonus_material(3, 3, function(e, v) return v * 0.4 end),
		max_mana = resolvers.mbonus_material(60, 40, function(e, v) return v * 0.1 end),
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return v * 80, v end),

	},
}

newEntity{
	power_source = {nature=true},
	name = " of life", suffix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = true,
	rarity = 20,
	cost = 60,
	wielder = {
		max_life=resolvers.mbonus_material(60, 40, function(e, v) return v * 0.1 end),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return v * 10, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return v * 80, v end),
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.15 end),
		},

	},
}
