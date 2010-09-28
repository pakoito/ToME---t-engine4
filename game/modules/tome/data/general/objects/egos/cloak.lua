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

--load("/data/general/objects/egos/charged-defensive.lua")

newEntity{
	name = "shadow ", prefix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		inc_stealth = resolvers.mbonus_material(20, 5, function(e, v) return v * 1, v end),
	},
}

newEntity{
	name = "thick ", prefix=true, instant_resolve=true,
	level_range = {1, 40},
	rarity = 6,
	cost = 7,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.15 end)},
	},
}

newEntity{
	name = "plush ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 7,
	wielder = {
		combat_armor = resolvers.mbonus_material(8, 5, function(e, v) return v * 1 end),
	},
}

newEntity{
	name = " of the Shire", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 2, [Stats.STAT_CUN] = 2, },
	},
}

newEntity{
	name = " of the Sindar", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 2, [Stats.STAT_WIL] = 2, },
	},
}

newEntity{
	name = " of Lonely Mountain", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 2, [Stats.STAT_CON] = 2, },
	},
}
