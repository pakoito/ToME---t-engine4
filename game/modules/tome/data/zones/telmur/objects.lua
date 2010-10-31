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

load("/data/general/objects/objects.lua")

local Stats = require "engine.interface.ActorStats"

newEntity{ base = "BASE_STAFF",
	define_as = "TELOS_TOP_HALF", rarity=false,
	slot_forbid = false,
	twohanded = false,
	name = "Telos's Staff (Top Half)", unique=true,
	desc = [[The top part of Telos's broken staff.]],
	require = { stat = { mag=35 }, },
	encumberance = 2.5,
	cost = 500,
	combat = {
		dam = 35,
		apr = 0,
		physcrit = 1.5,
		dammod = {mag=1.0},
	},
	wielder = {
		combat_spellpower = 25,
		combat_spellcrit = 5,
		combat_mentalresist = 8,
		inc_stats = { [Stats.STAT_WIL] = 5, },
	},
}

newEntity{ base = "BASE_STAFF",
	slot = "OFFHAND", slot_forbid = false,
	twohanded = false, add_name=false,
	define_as = "TELOS_BOTTOM_HALF", rarity=false,
	name = "Telos's Staff (Bottom Half)", unique=true,
	desc = [[The bottom part of Telos's broken staff.]],
	require = { stat = { mag=35 }, },
	encumberance = 2.5,
	cost = 500,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 4, },
		max_mana = 50,
		combat_mentalresist = 8,
		inc_damage={
			[DamageType.COLD] = 20,
			[DamageType.ACID] = 20,
		},
	},
}
