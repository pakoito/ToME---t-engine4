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

load("/data/general/objects/objects-far-east.lua")

local Stats = require"engine.interface.ActorStats"

newEntity{ base = "BASE_GREATSWORD",
	define_as = "MURDERBLADE", rarity=false,
	name = "Warmaster Gnarg's Murderblade", unique=true,
	unided_name = "blood-etched greatsword", color=colors.CRIMSON,
	desc = [[A blood etched greatsword, it has seen many foes. From the inside.]],

	require = { stat = { str=35 }, },
	cost = 300,
	material_level = 5,
	combat = {
		dam = 54,
		apr = 19,
		physcrit = 4.5,
		dammod = {str=1.2},
	},
	wielder = {
		see_invisible = 25,
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, },
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.2,
			["technique/2hweapon-offense"] = 0.2,
		},
	},
}

newEntity{ define_as = "ATHAME",
	quest=true, unique=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="misc",
	unided_name = "athame",
	name = "Blood-Runed Athame",
	level_range = {50, 50},
	display = "|", color=colors.VIOLET,
	encumber = 1,
	desc = [[An athame, covered in blood runes. It radiates power.]],

	on_pickup = function(self, who)
		if who == game.player then
			who:setQuestStatus("west-portal", engine.Quest.COMPLETED, "athame")
			return true
		end
	end,
}
