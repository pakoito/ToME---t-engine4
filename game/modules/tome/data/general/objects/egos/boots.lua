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

newEntity{
	name = " of phasing", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	greater_ego = true,
	rarity = 10,
	cost = 40,
	max_power = 60, power_regen = 1,
	use_power = { name = "blink to a nearby random location", power = 35, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 10 + who:getMag(5))
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	name = " of uncanny dodging", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_def_ranged = resolvers.mbonus_material(8, 2, function(e, v) return v * 1 end),
	},
}

newEntity{
	name = " of speed", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	greater_ego = true,
	rarity = 20,
	cost = 60,
	wielder = {
		movement_speed = -0.2,
	},
}

newEntity{
	name = " of rushing", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	greater_ego = true,
	rarity = 10,
	cost = 20,

	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_RUSH, level = 2, power = 80 },
}

newEntity{
	name = " of disengagement", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	greater_ego = true,
	rarity = 10,
	cost = 20,

	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_DISENGAGE, level = 2, power = 80 },
}

newEntity{
	name = " of stability", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 12,
	cost = 12,
	wielder = {
		stun_immune = 0.2,
		knockback_immune = 0.2,
	},
}
