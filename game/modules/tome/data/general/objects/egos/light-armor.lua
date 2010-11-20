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
local Stats = require "engine.interface.ActorStats"

load("/data/general/objects/egos/armor.lua")

newEntity{
	name = "troll-hide ", prefix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 12,
	cost = 14,
	wielder = {
		life_regen = resolvers.mbonus_material(60, 15, function(e, v) v=v/10 return v * 10, v end),
	},
}

newEntity{
	name = "nimble", prefix=true, instant_resolve=true,
	level_range = {25, 50},
	greater_ego = true,
	rarity = 22,
	cost = 35,
	wielder = {
		combat_def_ranged = resolvers.mbonus_material(8, 2, function(e, v) return v * 1 end),
		movement_speed = -0.1,
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(3, 2, function(e, v) return v * 3 end), },
	},
}
