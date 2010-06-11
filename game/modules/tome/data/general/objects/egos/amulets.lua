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
	name = " of cunning (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus(8, 2) },
	},
}
newEntity{
	name = " of willpower (#STATBONUS#)", suffix=true,
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus(8, 2) },
	},
}
newEntity{
	name = " of mastery (#MASTERY#)", suffix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 2,
	wielder = {},
	resolvers.generic(function(e)
		local tts = {
			"cunning/dirty",
			"cunning/lethality",
			"cunning/stealth",
			"cunning/survival",
			"spell/air",
			"spell/arcane",
			"spell/conveyance",
			"spell/divination",
			"spell/earth",
			"spell/fire",
			"spell/meta",
			"spell/nature",
			"spell/phantasm",
			"spell/temporal",
			"spell/water",
			"technique/2hweapon-cripple",
			"technique/2hweapon-offense",
			"technique/archery-bow",
			"technique/archery-sling",
			"technique/archery-training",
			"technique/archery-utility",
			"technique/combat-techniques-active",
			"technique/combat-techniques-passive",
			"technique/combat-training",
			"technique/dualweapon-attack",
			"technique/dualweapon-training",
			"technique/shield-defense",
			"technique/shield-offense",
			"wild-gift/call",
			"wild-gift/cold-drake",
			"wild-gift/fire-drake",
			"wild-gift/sand-drake",
			"wild-gift/slime",
			"wild-gift/summon-augmentation",
			"wild-gift/summon-distance",
			"wild-gift/summon-melee",
			"wild-gift/summon-utility",
		}
		local tt = tts[rng.range(1, #tts)]

		e.wielder.talents_types_mastery = {}
		e.wielder.talents_types_mastery[tt] = (10 + rng.mbonus(30, resolvers.current_level, 50)) / 100
	end),
}
newEntity{
	name = " of greater telepathy", suffix=true,
	level_range = {40, 50},
	rarity = 15,
	cost = 15,
	wielder = {
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
	name = " of the fish", suffix=true,
	level_range = {25, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		can_breath = {water=1},
	},
}
