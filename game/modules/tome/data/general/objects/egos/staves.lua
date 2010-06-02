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
	name = " of power",
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_spellpower = resolvers.mbonus(30, 3),
	},
}

newEntity{
	name = "shimmering ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 8,
	wielder = {
		max_mana = resolvers.mbonus(100, 10),
	},
}

newEntity{
	name = " of might",
	level_range = {1, 50},
	rarity = 3,
	cost = 8,
	wielder = {
		combat_spellcrit = resolvers.mbonus(15, 4),
	},
}

newEntity{
	name = " of wizardry",
	level_range = {30, 50},
	rarity = 12,
	cost = 45,
	wielder = {
		combat_spellpower = resolvers.mbonus(30, 3),
		max_mana = resolvers.mbonus(100, 10),
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus(5, 1), [Stats.STAT_WIL] = resolvers.mbonus(5, 1) },
	},
}

newEntity{
	name = "magma ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.FIRE] = resolvers.mbonus(25, 8), },
	},
}

newEntity{
	name = "icy ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.COLD] = resolvers.mbonus(25, 8), },
	},
}

newEntity{
	name = "acidic ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.ACID] = resolvers.mbonus(25, 8), },
	},
}

newEntity{
	name = "crackling ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.LIGHTNING] = resolvers.mbonus(25, 8), },
	},
}

newEntity{
	name = "naturalist ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.NATURE] = resolvers.mbonus(25, 8), },
	},
}

newEntity{
	name = "blighted ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		inc_damage={ [DamageType.BLIGHT] = resolvers.mbonus(25, 8), },
	},
}
