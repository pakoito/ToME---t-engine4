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
load("/data/general/objects/lore/sunwall.lua")

local Talents = require("engine.interface.ActorTalents")
local Stats = require"engine.interface.ActorStats"

newEntity{ base = "BASE_LIGHT_ARMOR",
	define_as = "CHROMATIC_HARNESS", rarity=false,
	name = "Chromatic Harness", unique=true,
	unided_name = "multi-hued leather armour", color=colors.VIOLET,
	desc = [[This leather harness shines of multiple colors, quickly shifting through them in a seemingly chaotic manner.]],
	cost = 500,
	material_level = 5,
	wielder = {
		talent_cd_reduction={[Talents.T_ICE_BREATH]=3, [Talents.T_FIRE_BREATH]=3, [Talents.T_SAND_BREATH]=3, },
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 4, [Stats.STAT_DEX] = 3, [Stats.STAT_LCK] = 10, },
		poison_immune = 0.7,
		combat_armor = 10,
		esp = { dragon = 1 },
		fatigue = 10,
	},
}
