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

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	name = " of see invisible", suffix=true,
	level_range = {1, 20},
	rarity = 4,
	cost = 2,
	wielder = {
		see_invisible = resolvers.mbonus_material(20, 5, function(e, v) return v * 0.2 end),
	},

}

newEntity{
	name = " of invisibility", suffix=true,
	desc = [[Allows the wearer to become invisible to normal sight.
Such a power comes at a huge cost though...
Beware, you should take off your light, otherwise you will still be easily spotted.]],
	level_range = {30, 40},
	rarity = 4,
	cost = 16,
	wielder = {
		invisible = resolvers.mbonus_material(10, 5, function(e, v) return v * 1 end),
		life_regen = -11,
	},
}

newEntity{
	name = " of regeneration (#REGEN#)", suffix=true,
	level_range = {10, 20},
	rarity = 10,
	cost = 8,
	wielder = {
		life_regen = resolvers.mbonus_material(30, 5, function(e, v) v=v/10 return v * 10, v end),
	},
}

newEntity{
	name = " of mana (#REGEN#)", suffix=true,
	level_range = {10, 20},
	rarity = 8,
	cost = 3,
	wielder = {
		mana_regen = resolvers.mbonus_material(3, 1, function(e, v) v=v/10 return v * 8, v end),
	},
}

newEntity{
	name = " of accuracy (#ATTACK#)", suffix=true,
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_atk = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.3 end),
	},
}

newEntity{
	name = " of defense (#ARMOR#)", suffix=true,
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_def = resolvers.mbonus_material(15, 5, function(e, v) return v * 1 end),
	},
}

newEntity{
	name = " of fire resistance (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.FIRE] = resolvers.mbonus_material(15, 20, function(e, v) return v * 0.15 end), }
	},
}

newEntity{
	name = " of cold resistance (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.COLD] = resolvers.mbonus_material(15, 20, function(e, v) return v * 0.15 end), }
	},
}

newEntity{
	name = " of nature resistance (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.NATURE] = resolvers.mbonus_material(15, 20, function(e, v) return v * 0.15 end), }
	},
}

newEntity{
	name = " of lightning resistance (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.LIGHTNING] = resolvers.mbonus_material(15, 20, function(e, v) return v * 0.15 end), }
	},
}

newEntity{
	name = " of acid resistance (#RESIST#)", suffix=true,
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.ACID] = resolvers.mbonus_material(15, 20, function(e, v) return v * 0.15 end), }
	},
}

newEntity{
	name = " of spell resistance", suffix=true,
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_spellresist = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.15 end),
	},
}

newEntity{
	name = " of physical resistance", suffix=true,
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_physresist = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.15 end),
	},
}

newEntity{
	name = " of strength (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
	},
}
newEntity{
	name = " of dexterity (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
	},
}
newEntity{ define_as = "RING_MAGIC",
	name = " of magic (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
	},
}
newEntity{
	name = " of constitution (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
	},
}

-------------------------- Damage increase rings
newEntity{
	name = " of massacre (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },
	},
}
newEntity{ define_as = "RING_ARCANE_POWER",
	name = " of arcane power (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },
	},
}
newEntity{ define_as = "RING_BURNING",
	name = " of burning (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.FIRE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },
	},
}
newEntity{ define_as = "RING_FREEZING",
	name = " of freezing (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.COLD] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },
	},
}
newEntity{ define_as = "RING_NATURE_BLESSING",
	name = " of nature's blessing (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.NATURE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },
	},
}
newEntity{ define_as = "RING_BLIGHT",
	name = " of blight (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },
	},
}
newEntity{ define_as = "RING_SHOCK",
	name = " of shock (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },
	},
}
newEntity{ define_as = "RING_CORROSION",
	name = " of corrosion (#DAMBONUS#)", suffix=true,
	level_range = {6, 50},
	rarity = 4,
	cost = 4,
	wielder = {
		inc_damage = { [DamageType.ACID] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.8 end) },
	},
}
