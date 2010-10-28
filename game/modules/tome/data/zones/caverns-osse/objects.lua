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

load("/data/general/objects/2htridents.lua", function(e) e.rarity = e.trident_rarity end)
load("/data/general/objects/objects.lua")

local Talents = require "engine.interface.ActorTalents"
local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"

-- Artifact, droped (and used!) by Bill the Stone Troll

newEntity{ base = "BASE_LITE",
	define_as = "WATER_SILMARIL",
	name = "The Water Silmaril", unique=true,
	display ='*', color = colors.AQUAMARINE,
	desc = [[Thousands of years deep into the sea have infused the powerful Silmaril with the fury of rushing water. It pulses light.]],

	-- No cost, it's invaluable

	wielder = {
		lite = 6,
		can_breath = {water=1},
		combat_dam = 12,
		combat_spellpower = 12,
		inc_stats = {
			[Stats.STAT_STR] = 4,
			[Stats.STAT_DEX] = 4,
			[Stats.STAT_MAG] = 4,
			[Stats.STAT_WIL] = 4,
			[Stats.STAT_CUN] = 4,
			[Stats.STAT_CON] = 4,
			[Stats.STAT_LCK] = -5,
		},
	},

	max_power = 150, power_regen = 1,
	use_talent = { id = Talents.T_TIDAL_WAVE, level=4, power = 80 },
}
