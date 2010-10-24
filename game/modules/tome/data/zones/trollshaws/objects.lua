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

load("/data/general/objects/objects.lua")

local Stats = require "engine.interface.ActorStats"

-- Artifact, droped (and used!) by Bill the Stone Troll

newEntity{ base = "BASE_GREATMAUL",
	define_as = "GREATMAUL_BILL_TRUNK",
	name = "Bill's Tree Trunk", unique=true,
	desc = [[This is a big nasty looking tree trunk that Bill was using as a weapon. It could still serve this purpose, should you be strong enough to wield it!]],
	require = { stat = { str=25 }, },
	rarity = false,
	metallic = false,
	cost = 5,
	combat = {
		dam = 30,
		apr = 7,
		physcrit = 1.5,
		dammod = {str=1.3},
		damrange = 1.7,
	},

	wielder = {
	},
}

for i = 1, 5 do
newEntity{ base = "BASE_SCROLL",
	define_as = "NOTE"..i,
	name = "tattered paper scrap", lore="trollshaws-note-"..i,
	desc = [[A paper scrap, left by an adventurer.]],
	rarity = false,
	is_magic_device = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_SHIELD",
	define_as = "SANGUINE_SHIELD",
	unided_name = "bloody shield",
	name = "Sanguine Shield", unique=true,
	desc = [[Though tarnished and spattered with blood, the emblem of the sun still manages to shine through on this shield.]],
	require = { stat = { str=39 }, },
	cost = 120,

	special_combat = {
		dam = 40,
		physcrit = 9,
		dammod = {str=1.2},
	},
	wielder = {
		combat_armor = 4,
		combat_def = 14,
		combat_def_ranged = 14,
		inc_stats = { [Stats.STAT_CON] = 5, },
		fatigue = 19,
		resists = { [DamageType.BLIGHT] = 25, },
		life_regen = 5,
	},
}
