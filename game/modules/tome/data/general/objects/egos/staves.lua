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

local Stats = require "engine.interface.ActorStats"

newEntity{
	name = " of power", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(30, 3, function(e, v) return v * 0.8 end),
	},
}

newEntity{
	name = "shimmering ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 8,
	wielder = {
		max_mana = resolvers.mbonus_material(100, 10, function(e, v) return v * 0.2 end),
	},
}

newEntity{
	name = " of might", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 8,
	wielder = {
		combat_spellcrit = resolvers.mbonus_material(15, 4, function(e, v) return v * 0.4 end),
	},
}

newEntity{
	name = " of wizardry", suffix=true, instant_resolve=true,
	level_range = {30, 50},
	rarity = 18,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(30, 3, function(e, v) return v * 0.6 end),
		max_mana = resolvers.mbonus_material(100, 10, function(e, v) return v * 0.2 end),
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(5, 1, function(e, v) return v * 3 end), [Stats.STAT_WIL] = resolvers.mbonus_material(5, 1, function(e, v) return v * 3 end) },
	},
}

newEntity{
	name = "magma ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.FIRE] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "icy ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.COLD] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "acidic ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.ACID] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "crackling ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHTNING] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "naturalist ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.NATURE] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = "blighted ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.BLIGHT] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}
