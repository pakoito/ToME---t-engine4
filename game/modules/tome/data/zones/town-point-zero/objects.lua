-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

load("/data/general/objects/objects-maj-eyal.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {arcane=true},
	define_as = "TIME_SHARD",
	desc = [[An iridescent shard of violet crystal.  Its light ebbs and flows, sometimes fast and sometimes slow, keeping track with the chaotic streams of time itself.  It makes you feel both old and young, a newborn child and an ancient being, your flesh simply one instance in a thousand refractions of a single timeless and eternal soul.]],
	unique = true,
	name = "Shard of Crystalized Time", color = colors.YELLOW,
	unided_name = "glowing shard", image = "object/artifact/time_shard.png",
	desc = [[]],
	level_range = {5, 12},
	rarity = false,
	cost = 10,
	material_level = 1,
	metallic = false,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CON] = 2, },
		combat_def = 5,
		inc_damage = { [DamageType.TEMPORAL] = 7 },
		paradox_reduce_fails = 25,
	},
}
