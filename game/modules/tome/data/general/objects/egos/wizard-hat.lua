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
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	name = " of amplification", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		mana_regen_on_hit = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return v * 10, v end),
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
	name = " of magic (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
	},
}
newEntity{
	name = " of willpower (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
	},
}
newEntity{
	name = " of cunning (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material(8, 2, function(e, v) return v * 3 end) },
	},
}
newEntity{
	name = " of greater telepathy", suffix=true,
	level_range = {40, 50},
	greater_ego = true,
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
	name = "shimmering ", prefix=true,
	level_range = {1, 50},
	rarity = 10,
	cost = 4,
	wielder = {
		max_mana = resolvers.mbonus_material(100, 10, function(e, v) return v * 0.2 end),
	},
}
newEntity{
	name = " of seeing ", suffix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		blind_immune = 0.5,
	},
}

newEntity{
	name = "arcanist's ", prefix=true, instant_resolve=true,
	level_range = {25, 50},
	greater_ego = true,
	rarity = 18,
	cost = 20,
	wielder = {
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material(5, 5, function(e, v) return v * 0.15 end),
		},
		combat_spellpower = resolvers.mbonus_material(5, 3, function(e, v) return v * 0.6 end),
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_MANAFLOW, level = 1, power = 80 },
}
