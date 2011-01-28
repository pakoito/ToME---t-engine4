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
local Talents = require("engine.interface.ActorTalents")
local Stats = require("engine.interface.ActorStats")

--load("/data/general/objects/egos/charged-attack.lua")

newEntity{
	power_source = {technique=true},
	name = " of power", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 6,
	combat={apr = resolvers.mbonus_material(15, 1, function(e, v) return v * 0.3 end)},
}

newEntity{
	power_source = {technique=true},
	name = "mighty ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	power_source = {technique=true},
	name = "steady ", prefix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		talent_cd_reduction={[Talents.T_STEADY_SHOT]=1},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of dexterity (#STATBONUS#)", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 7,
	cost = 7,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(6, 2, function(e, v) return v * 3 end) },
	},
}

newEntity{
	power_source = {technique=true},
	name = " of speed", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 7,
	cost = 7,
	combat={physspeed = -0.1},
}

newEntity{
	power_source = {technique=true},
	name = " of great speed", suffix=true, instant_resolve=true,
	level_range = {40, 50},
	greater_ego = true,
	rarity = 10,
	cost = 60,
	combat={physspeed = -0.2},
}

newEntity{
	power_source = {technique=true},
	name = "halfling ", prefix=true, instant_resolve=true,
	level_range = {30, 50},
	greater_ego = true,
	rarity = 24,
	cost = 40,
	wielder = {
		talent_cd_reduction={
			[Talents.T_STEADY_SHOT]=1,
			[Talents.T_PINNING_SHOT]=1,
			[Talents.T_MULTISHOT]=2,
		},
		inc_damage={ [DamageType.PHYSICAL] = resolvers.mbonus_material(14, 8, function(e, v) return v * 0.8 end), },
	},
}
