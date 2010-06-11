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
local DamageType = require "engine.DamageType"

newEntity{
	name = " of see invisible", suffix=true,
	level_range = {1, 20},
	rarity = 4,
	cost = 2,
	wielder = {
		see_invisible = resolvers.mbonus(20, 5),
	},
}

newEntity{
	name = " of invisibility", suffix=true,
	desc = [[Allows the wearer to become invisible to normal sight
Beware, you should take off your light, otherwise you will still be easily spotted.]],
	level_range = {30, 40},
	rarity = 4,
	cost = 16,
	wielder = {
		invisible = resolvers.mbonus(10, 5),
	},
}

newEntity{
	name = " of regeneration", suffix=true,
	level_range = {10, 20},
	rarity = 10,
	cost = 8,
	wielder = {
		life_regen = resolvers.mbonus(3, 1),
	},
}

newEntity{
	name = "energizing ", prefix=true,
	level_range = {10, 20},
	rarity = 8,
	cost = 3,
	wielder = {
		mana_regen = resolvers.mbonus(3, 1),
	},
}

newEntity{
	name = " of accuracy", suffix=true,
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_atk = resolvers.mbonus(15, 5),
	},
}

newEntity{
	name = " of defense", suffix=true,
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_def = resolvers.mbonus(15, 5),
	},
}

newEntity{
	name = " of fire resistance", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.FIRE] = resolvers.mbonus(15, 20), }
	},
}

newEntity{
	name = " of cold resistance", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.COLD] = resolvers.mbonus(15, 20), }
	},
}

newEntity{
	name = " of nature resistance", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.NATURE] = resolvers.mbonus(15, 20), }
	},
}

newEntity{
	name = " of lightning resistance", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.LIGHTNING] = resolvers.mbonus(15, 20), }
	},
}

newEntity{
	name = " of acid resistance", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.ACID] = resolvers.mbonus(15, 20), }
	},
}

newEntity{
	name = " of spell resistance", suffix=true,
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_spellresist = resolvers.mbonus(15, 5),
	},
}

newEntity{
	name = " of physical resistance", suffix=true,
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_physresist = resolvers.mbonus(15, 5),
	},
}

newEntity{
	name = " of strength (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus(8, 2) },
	},
}
newEntity{
	name = " of dexterity (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus(8, 2) },
	},
}
newEntity{ define_as = "RING_MAGIC",
	name = " of magic (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus(8, 2) },
	},
}
newEntity{
	name = " of constitution (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = resolvers.mbonus(8, 2) },
	},
}

-------------------------- Damage increase rings
newEntity{
	name = " of massacre (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus(15, 5) },
	},
}
newEntity{ define_as = "RING_ARCANE_POWER",
	name = " of arcane power (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus(15, 5) },
	},
}
newEntity{ define_as = "RING_BURNING",
	name = " of burning (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.FIRE] = resolvers.mbonus(15, 5) },
	},
}
newEntity{ define_as = "RING_FREEZING",
	name = " of freezing (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.COLD] = resolvers.mbonus(15, 5) },
	},
}
newEntity{ define_as = "RING_NATURE_BLESSING",
	name = " of nature's blessing (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.NATURE] = resolvers.mbonus(15, 5) },
	},
}
newEntity{ define_as = "RING_BLIGHT",
	name = " of blight (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = resolvers.mbonus(15, 5) },
	},
}
newEntity{ define_as = "RING_SHOCK",
	name = " of shock (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.LIGHTNING] = resolvers.mbonus(15, 5) },
	},
}
newEntity{ define_as = "RING_CORROSION",
	name = " of corrosion (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.ACID] = resolvers.mbonus(15, 5) },
	},
}
