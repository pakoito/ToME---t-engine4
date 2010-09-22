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
	name = " of the badger", suffix=true,
	level_range = {1, 50},
	rarity = 7,
	cost = 20,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
}

newEntity{
	name = " of strength", suffix=true,
	level_range = {10, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(4, 1, function(e, v) return v * 3 end) },
	},
}

newEntity{
	name = " of delving", suffix=true,
	level_range = {30, 50},
	rarity = 20,
	cost = 20,
	wielder = {
		lite = 1,
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(3, 1, function(e, v) return v * 3 end), [Stats.STAT_CON] = resolvers.mbonus_material(3, 1, function(e, v) return v * 3 end) },
	},
}
