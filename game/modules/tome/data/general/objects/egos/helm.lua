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

load("/data/general/objects/egos/charged-attack.lua")
load("/data/general/objects/egos/charged-defensive.lua")
load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	name = " of rage", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		stamina_regen_on_hit = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return v * 10, v end),
	},
}
newEntity{
	name = " of the wilds", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		equilibrium_regen_on_hit = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return v * 10, v end),
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
	name = " of constitution (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
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
newEntity{
	name = " of greater telepathy", suffix=true,
	level_range = {40, 50},
	rarity = 120,
	cost = 25,
	wielder = {
		life_regen = -3,
		esp = {all=1},
	},
}
newEntity{
	name = " of telepathic range", suffix=true,
	level_range = {40, 50},
	rarity = 15,
	cost = 15,
	wielder = {
		esp = {range=10},
	},
}
newEntity{
	name = "gondorian ", prefix=true, instant_resolve=true,
	level_range = {25, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material(2, 1, function(e, v) return v * 3 end) },
		disease_immune = 0.3,
		stun_immune = 0.2,
	},
}
